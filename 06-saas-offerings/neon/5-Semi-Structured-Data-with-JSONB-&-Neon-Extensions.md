# Serverless Postgres with Neon: From Zero to Production

## Part 5: Semi-Structured Data with JSONB & Neon Extensions

### The Target

In this part, we'll:
1. Understand JSONB and when to use it vs. relational tables
2. Store flexible product attributes (specs, variants, metadata) using JSONB
3. Query and manipulate JSONB data with PostgreSQL's JSON operators
4. Create indexes on JSONB fields for performance
5. Enable and use PostgreSQL extensions in Neon (pg_trgm, uuid-ossp)
6. Implement fuzzy text search with trigram similarity
7. Build a flexible, searchable product catalog

By the end of this part, you'll have a hybrid database that combines the best of relational and document storage, with powerful search capabilities.

---

### The Concept: The Best of Both Worlds

Think of JSONB like a flexible sticky note you can attach to each record. 

**Relational tables** (what we've been using) are like a filing cabinet with labeled folders:
- Every folder has the exact same form
- You always know where to find specific information
- Strict rules ensure consistency

**JSONB** is like adding a custom sticky note to each folder:
- Each note can have different information
- You can write anything on it
- It's flexible but less structured

**Why use both?**
- Use relational tables for core, stable data (customer names, order totals)
- Use JSONB for flexible, variable data (product specifications, custom attributes)
- JSONB is perfect when you don't know all the fields upfront

**The Power of PostgreSQL**: With JSONB, you get:
- **Storage efficiency**: Binary JSON format (compressed, indexed)
- **Query capability**: Full SQL operations on JSON data
- **Index support**: GIN indexes for fast JSON queries
- **Type safety**: JSONB validates JSON structure

---

### Implementation Step 1: Adding JSONB to Products

#### 1.1 Add JSONB Column to Products Table

First, let's extend our products table with JSONB capabilities:

```sql
-- Add JSONB column for flexible product attributes
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS attributes JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS variants JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- Add a search vector column for full-text search (we'll populate this later)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- Update existing products with default values
UPDATE products 
SET 
    attributes = '{}'::jsonb WHERE attributes IS NULL,
    variants = '[]'::jsonb WHERE variants IS NULL,
    metadata = '{}'::jsonb WHERE metadata IS NULL;
```

**The Verification**: Run `\d products` to see the new columns.

---

### Implementation Step 2: Inserting JSONB Data

#### 2.1 Insert Products with Rich JSONB Data

Let's update our products with realistic JSONB attributes:

```sql
-- Update products with rich JSONB data
-- Product 1: Premium Wireless Headphones
UPDATE products 
SET 
    attributes = jsonb_build_object(
        'color', 'Black',
        'connectivity', 'Bluetooth 5.3',
        'battery_life', '40 hours',
        'noise_cancellation', 'Active',
        'driver_size', '40mm',
        'impedance', '32 ohms',
        'weight', '250g',
        'material', 'Memory foam, aluminum'
    ),
    variants = jsonb_build_array(
        jsonb_build_object(
            'color', 'Black',
            'price_adjustment', 0,
            'sku', 'HP-BLK-001',
            'stock', 50
        ),
        jsonb_build_object(
            'color', 'Silver',
            'price_adjustment', 10.00,
            'sku', 'HP-SLV-001',
            'stock', 25
        ),
        jsonb_build_object(
            'color', 'Gold',
            'price_adjustment', 20.00,
            'sku', 'HP-GLD-001',
            'stock', 15
        )
    ),
    metadata = jsonb_build_object(
        'brand', 'AudioPro',
        'warranty_months', 24,
        'release_date', '2024-01-15',
        'category', 'Audio',
        'subcategory', 'Headphones',
        'tags', array['premium', 'wireless', 'noise-cancelling', 'studio']
    )
WHERE name = 'Premium Wireless Headphones';

-- Product 2: 4K Action Camera Pro
UPDATE products 
SET 
    attributes = jsonb_build_object(
        'video_resolution', '4K 60fps',
        'photo_resolution', '20MP',
        'stabilization', 'HyperSmooth',
        'waterproof_depth', '33ft',
        'screen', 'Dual touchscreen',
        'battery', '1500mAh',
        'storage', 'MicroSD up to 1TB',
        'field_of_view', '170 degrees'
    ),
    variants = jsonb_build_array(
        jsonb_build_object(
            'color', 'Black',
            'price_adjustment', 0,
            'sku', 'CAM-BLK-001',
            'stock', 20
        ),
        jsonb_build_object(
            'color', 'White',
            'price_adjustment', 0,
            'sku', 'CAM-WHT-001',
            'stock', 12
        )
    ),
    metadata = jsonb_build_object(
        'brand', 'ActionPro',
        'warranty_months', 12,
        'release_date', '2024-03-01',
        'category', 'Cameras',
        'subcategory', 'Action Cameras',
        'tags', array['4k', 'waterproof', 'action', 'sports']
    )
WHERE name = '4K Action Camera Pro';

-- Product 3: Smart Health Tracker
UPDATE products 
SET 
    attributes = jsonb_build_object(
        'display_type', 'AMOLED',
        'screen_size', '1.4 inches',
        'health_sensors', array['ECG', 'Blood Oxygen', 'Heart Rate', 'Sleep Staging'],
        'water_resistant', '5ATM',
        'battery_life', '7 days',
        'connectivity', 'Bluetooth 5.2, GPS',
        'notifications', true,
        'app_compatibility', array['iOS', 'Android']
    ),
    variants = jsonb_build_array(
        jsonb_build_object(
            'color', 'Black',
            'price_adjustment', 0,
            'sku', 'TRK-BLK-001',
            'stock', 30
        ),
        jsonb_build_object(
            'color', 'Silver',
            'price_adjustment', 0,
            'sku', 'TRK-SLV-001',
            'stock', 18
        ),
        jsonb_build_object(
            'color', 'Rose Gold',
            'price_adjustment', 20.00,
            'sku', 'TRK-RGD-001',
            'stock', 10
        )
    ),
    metadata = jsonb_build_object(
        'brand', 'HealthTech',
        'warranty_months', 24,
        'release_date', '2024-02-01',
        'category', 'Wearables',
        'subcategory', 'Fitness Trackers',
        'tags', array['health', 'fitness', 'smart', 'tracking']
    )
WHERE name = 'Smart Health Tracker';

-- Product 4: Universal Laptop Docking Station
UPDATE products 
SET 
    attributes = jsonb_build_object(
        'ports', jsonb_build_object(
            'hdmi', '2x 4K',
            'usb_c', '2x (1 for power delivery)',
            'usb_a', '3x USB 3.0',
            'ethernet', 'Gigabit',
            'audio', '3.5mm jack'
        ),
        'power_delivery', '100W',
        'compatibility', array['Windows', 'macOS', 'Linux'],
        'material', 'Aluminum',
        'dimensions', '12 x 3 x 1 inches'
    ),
    variants = jsonb_build_array(
        jsonb_build_object(
            'color', 'Space Gray',
            'price_adjustment', 0,
            'sku', 'DOCK-GRY-001',
            'stock', 15
        ),
        jsonb_build_object(
            'color', 'Silver',
            'price_adjustment', 0,
            'sku', 'DOCK-SLV-001',
            'stock', 8
        )
    ),
    metadata = jsonb_build_object(
        'brand', 'ConnectPro',
        'warranty_months', 36,
        'release_date', '2023-11-01',
        'category', 'Accessories',
        'subcategory', 'Docking Stations',
        'tags', array['docking', 'multi-monitor', 'usb-c', 'work-from-home']
    )
WHERE name = 'Universal Laptop Docking Station';

-- Product 5: Mechanical Gaming Keyboard Pro
UPDATE products 
SET 
    attributes = jsonb_build_object(
        'switch_type', 'Cherry MX',
        'switch_color', 'Blue',
        'key_type', 'Mechanical',
        'layout', 'US ANSI',
        'wireless', true,
        'backlight', 'RGB',
        'programmable_keys', 12,
        'polling_rate', '1000Hz',
        'battery', '2000mAh',
        'keycaps', 'PBT Double-shot'
    ),
    variants = jsonb_build_array(
        jsonb_build_object(
            'switch_color', 'Blue',
            'price_adjustment', 0,
            'sku', 'KB-BLU-001',
            'stock', 20
        ),
        jsonb_build_object(
            'switch_color', 'Red',
            'price_adjustment', 0,
            'sku', 'KB-RED-001',
            'stock', 18
        ),
        jsonb_build_object(
            'switch_color', 'Brown',
            'price_adjustment', 0,
            'sku', 'KB-BRN-001',
            'stock', 15
        )
    ),
    metadata = jsonb_build_object(
        'brand', 'GameMaster',
        'warranty_months', 24,
        'release_date', '2024-04-01',
        'category', 'Gaming',
        'subcategory', 'Keyboards',
        'tags', array['gaming', 'mechanical', 'rgb', 'wireless']
    )
WHERE name = 'Mechanical Gaming Keyboard Pro';
```

**The Verification**: 

```sql
-- Check the JSONB data
SELECT 
    name,
    attributes,
    variants,
    metadata
FROM products 
WHERE name LIKE '%Wireless%' 
   OR name LIKE '%Action%'
   OR name LIKE '%Smart%'
ORDER BY id
LIMIT 5;
```

---

### Implementation Step 3: Querying JSONB Data

#### 3.1 Basic JSONB Operators

PostgreSQL provides several operators for JSONB:

- `->` : Get JSON object field as JSON
- `->>` : Get JSON object field as text
- `#>` : Get nested JSON object field as JSON
- `#>>` : Get nested JSON object field as text
- `@>` : Contains operator
- `?` : Does key exist?
- `?|` : Does any key exist?
- `?&` : Do all keys exist?

```sql
-- Get specific attributes as JSON
SELECT 
    name,
    attributes->'color' AS color_json,
    attributes->>'color' AS color_text,
    attributes->'battery_life' AS battery_json,
    attributes->>'battery_life' AS battery_text
FROM products
WHERE attributes->>'connectivity' LIKE '%Bluetooth%';

-- Get nested JSON values
SELECT 
    name,
    attributes->'ports' AS ports_json,
    attributes#>>'{ports,hdmi}' AS hdmi_ports,
    attributes->'health_sensors' AS health_sensors
FROM products
WHERE metadata->>'category' = 'Accessories';

-- Check if a key exists
SELECT 
    name,
    attributes ? 'noise_cancellation' AS has_noise_cancellation,
    attributes ? 'battery_life' AS has_battery_info
FROM products;

-- Check if any key exists
SELECT 
    name,
    attributes ?| array['color', 'connectivity', 'battery_life'] AS has_essential_attrs
FROM products;

-- Check if all keys exist
SELECT 
    name,
    attributes ?& array['color', 'connectivity', 'battery_life'] AS has_all_essential_attrs
FROM products;
```

#### 3.2 Complex JSONB Queries

```sql
-- Products with specific attributes
SELECT 
    name,
    price,
    attributes->>'battery_life' AS battery_life,
    attributes->>'noise_cancellation' AS noise_cancellation
FROM products
WHERE attributes @> '{"noise_cancellation": "Active"}'::jsonb;

-- Products by brand (using metadata)
SELECT 
    name,
    price,
    metadata->>'brand' AS brand,
    metadata->>'category' AS category
FROM products
WHERE metadata @> '{"brand": "AudioPro"}'::jsonb;

-- Products with specific health sensors
SELECT 
    name,
    attributes->'health_sensors' AS health_sensors
FROM products
WHERE attributes->'health_sensors' @> '["ECG"]'::jsonb;

-- Products with tags containing specific values
SELECT 
    name,
    metadata->'tags' AS tags
FROM products
WHERE metadata->'tags' @> '["wireless"]'::jsonb;

-- Products by price range with attributes
SELECT 
    name,
    price,
    attributes,
    metadata->>'category' AS category
FROM products
WHERE price BETWEEN 100 AND 300
  AND metadata @> '{"category": "Audio"}'::jsonb;
```

#### 3.3 JSONB Array Operations

```sql
-- Products with variants count
SELECT 
    name,
    jsonb_array_length(variants) AS variant_count,
    variants
FROM products
WHERE jsonb_array_length(variants) > 1;

-- Products where any variant has specific color
SELECT 
    name,
    variants
FROM products
WHERE variants @> '[{"color": "Silver"}]'::jsonb;

-- Unnest variants (flatten JSON array)
SELECT 
    p.name,
    v.value->>'color' AS variant_color,
    v.value->>'price_adjustment' AS price_adjustment,
    v.value->>'stock' AS variant_stock
FROM products p,
     jsonb_array_elements(p.variants) AS v(value)
WHERE p.variants != '[]'::jsonb
ORDER BY p.name, variant_color;

-- Products with specific variant stock
SELECT 
    p.name,
    v.value->>'color' AS color,
    (v.value->>'stock')::int AS stock
FROM products p,
     jsonb_array_elements(p.variants) AS v(value)
WHERE (v.value->>'stock')::int < 20
ORDER BY stock ASC;

-- Calculate total stock across all variants
SELECT 
    name,
    SUM((v.value->>'stock')::int) AS total_variant_stock,
    stock_quantity AS base_stock,
    SUM((v.value->>'stock')::int) + stock_quantity AS total_stock
FROM products p,
     jsonb_array_elements(p.variants) AS v(value)
GROUP BY p.id, p.name, stock_quantity
ORDER BY total_stock DESC;
```

---

### Implementation Step 4: Indexing JSONB

#### 4.1 GIN Index for JSONB

GIN (Generalized Inverted Index) is perfect for JSONB:

```sql
-- Create GIN index on attributes for fast lookup
CREATE INDEX idx_products_attributes_gin ON products USING gin(attributes);

-- Create GIN index on metadata for fast lookup
CREATE INDEX idx_products_metadata_gin ON products USING gin(metadata);

-- Create GIN index on variants for array queries
CREATE INDEX idx_products_variants_gin ON products USING gin(variants);

-- Create GIN index on tags within metadata
CREATE INDEX idx_products_tags_gin ON products USING gin((metadata->'tags'));

-- Show all indexes on products
SELECT 
    indexname, 
    indexdef 
FROM pg_indexes 
WHERE tablename = 'products';
```

#### 4.2 Path-Specific JSONB Indexes

For specific nested fields, create path-specific indexes:

```sql
-- Index on specific JSONB paths (PostgreSQL 12+)
CREATE INDEX idx_products_brand ON products ((metadata->>'brand'));
CREATE INDEX idx_products_category ON products ((metadata->>'category'));
CREATE INDEX idx_products_color ON products ((attributes->>'color'));

-- Index on nested arrays (GIN)
CREATE INDEX idx_products_health_sensors ON products USING gin((attributes->'health_sensors'));

-- Partial index for specific category
CREATE INDEX idx_products_audio_attributes ON products USING gin(attributes)
WHERE metadata->>'category' = 'Audio';
```

#### 4.3 Query Performance Comparison

```sql
-- Before indexing (may be slow on large datasets)
EXPLAIN ANALYZE
SELECT * FROM products 
WHERE metadata->>'brand' = 'AudioPro';

-- After indexing (should use the index)
EXPLAIN ANALYZE
SELECT * FROM products 
WHERE metadata->>'brand' = 'AudioPro';

-- JSON containment query (uses GIN index)
EXPLAIN ANALYZE
SELECT * FROM products 
WHERE attributes @> '{"noise_cancellation": "Active"}'::jsonb;
```

---

### Implementation Step 5: Enabling PostgreSQL Extensions in Neon

#### 5.1 Available Extensions in Neon

Neon supports many PostgreSQL extensions. Check available extensions:

```sql
-- List all available extensions
SELECT * FROM pg_available_extensions 
ORDER BY name;

-- List installed extensions
SELECT * FROM pg_extension 
ORDER BY extname;

-- Check if an extension is available
SELECT 
    name,
    default_version,
    installed_version,
    comment
FROM pg_available_extensions 
WHERE name IN ('pg_trgm', 'uuid-ossp', 'pgcrypto', 'btree_gin');
```

#### 5.2 Enable pg_trgm for Fuzzy Search

```sql
-- Enable pg_trgm extension for trigram similarity
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Verify installation
SELECT * FROM pg_extension WHERE extname = 'pg_trgm';

-- Create GIN index for trigram search on product names
CREATE INDEX idx_products_name_trgm ON products USING gin(name gin_trgm_ops);
CREATE INDEX idx_products_description_trgm ON products USING gin(description gin_trgm_ops);
```

#### 5.3 Enable btree_gin for Combined Indexes

```sql
-- Enable btree_gin for combining B-tree and GIN indexes
CREATE EXTENSION IF NOT EXISTS btree_gin;

-- Create combined index for price and JSONB attributes
CREATE INDEX idx_products_price_attributes ON products 
USING gin(price, attributes);

-- Verify
SELECT * FROM pg_extension WHERE extname = 'btree_gin';
```

---

### Implementation Step 6: Fuzzy Text Search with pg_trgm

#### 6.1 Trigram Similarity

Trigram similarity measures how similar two strings are:

```sql
-- Calculate similarity between strings
SELECT 
    'wireless headphones' AS text1,
    'wireless headphone' AS text2,
    similarity('wireless headphones', 'wireless headphone') AS similarity_score;

-- Find products similar to a search term
SELECT 
    name,
    similarity(name, 'wireless headphone') AS name_similarity,
    similarity(description, 'wireless headphone') AS description_similarity,
    (similarity(name, 'wireless headphone') + similarity(description, 'wireless headphone')) / 2 AS combined_similarity
FROM products
ORDER BY combined_similarity DESC
LIMIT 10;

-- Find products with fuzzy match (threshold 0.3)
SELECT 
    name,
    description,
    similarity(name, 'wireless headphone') AS similarity_score
FROM products
WHERE similarity(name, 'wireless headphone') > 0.3
ORDER BY similarity_score DESC;
```

#### 6.2 Advanced Fuzzy Search

```sql
-- Search with custom threshold
CREATE OR REPLACE FUNCTION fuzzy_search(search_term TEXT, min_similarity FLOAT DEFAULT 0.3)
RETURNS TABLE(
    product_id INTEGER,
    product_name VARCHAR,
    description TEXT,
    similarity_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.description,
        GREATEST(
            similarity(p.name, search_term),
            similarity(p.description, search_term)
        ) AS sim_score
    FROM products p
    WHERE GREATEST(
        similarity(p.name, search_term),
        similarity(p.description, search_term)
    ) > min_similarity
    ORDER BY sim_score DESC;
END;
$$ LANGUAGE plpgsql;

-- Use the fuzzy search function
SELECT * FROM fuzzy_search('wireless headphone', 0.3);

-- Search with typo tolerance
SELECT 
    name,
    description,
    word_similarity('wirelss headphone', name) AS name_sim,
    word_similarity('wirelss headphone', description) AS desc_sim
FROM products
WHERE word_similarity('wirelss headphone', description) > 0.3
   OR word_similarity('wirelss headphone', name) > 0.3
ORDER BY GREATEST(name_sim, desc_sim) DESC;
```

#### 6.3 Combined Search

```sql
-- Combine fuzzy search with JSONB filtering
SELECT 
    p.name,
    p.price,
    p.metadata->>'brand' AS brand,
    p.attributes->'color' AS color,
    GREATEST(
        similarity(p.name, 'wireless'),
        similarity(p.description, 'wireless')
    ) AS similarity_score
FROM products p
WHERE GREATEST(
    similarity(p.name, 'wireless'),
    similarity(p.description, 'wireless')
) > 0.3
AND p.metadata @> '{"category": "Audio"}'::jsonb
ORDER BY similarity_score DESC, p.price ASC;

-- Full-text search with fuzzy fallback
WITH full_text_results AS (
    SELECT 
        id,
        name,
        price,
        ts_rank_cd(search_vector, plainto_tsquery('wireless headphones')) AS rank
    FROM products
    WHERE search_vector @@ plainto_tsquery('wireless headphones')
    ORDER BY rank DESC
    LIMIT 5
),
fuzzy_results AS (
    SELECT 
        id,
        name,
        price,
        GREATEST(
            similarity(name, 'wireless headphones'),
            similarity(description, 'wireless headphones')
        ) AS score
    FROM products
    WHERE GREATEST(
        similarity(name, 'wireless headphones'),
        similarity(description, 'wireless headphones')
    ) > 0.3
    ORDER BY score DESC
    LIMIT 5
)
SELECT DISTINCT
    COALESCE(ft.id, fr.id) AS product_id,
    COALESCE(ft.name, fr.name) AS product_name,
    COALESCE(ft.price, fr.price) AS price,
    CASE 
        WHEN ft.rank IS NOT NULL THEN 'Full Text'
        ELSE 'Fuzzy'
    END AS match_type
FROM full_text_results ft
FULL OUTER JOIN fuzzy_results fr ON ft.id = fr.id
ORDER BY product_name;
```

---

### Implementation Step 7: JSONB Data Transformation

#### 7.1 Updating JSONB Data

```sql
-- Add new attribute to all products
UPDATE products 
SET attributes = attributes || '{"in_stock": true}'::jsonb;

-- Update specific attribute
UPDATE products 
SET attributes = jsonb_set(attributes, '{battery_life}', '"45 hours"'::jsonb)
WHERE name = 'Premium Wireless Headphones';

-- Remove an attribute
UPDATE products 
SET attributes = attributes - 'in_stock';

-- Add a new variant
UPDATE products 
SET variants = variants || '{"color": "Blue", "price_adjustment": 15.00, "sku": "HP-BLU-001", "stock": 10}'::jsonb
WHERE name = 'Premium Wireless Headphones';

-- Update variant price adjustment
UPDATE products 
SET variants = jsonb_set(
    variants, 
    '{0,price_adjustment}', 
    '15.00'::jsonb
)
WHERE name = 'Premium Wireless Headphones';

-- Update all variants to increase stock
UPDATE products 
SET variants = (
    SELECT jsonb_agg(
        jsonb_set(v, '{stock}', ((v->>'stock')::int + 5)::text::jsonb)
    )
    FROM jsonb_array_elements(variants) AS v
)
WHERE variants != '[]'::jsonb;
```

#### 7.2 Dynamic JSONB Queries

```sql
-- Find products with specific attributes using dynamic queries
DO $$
DECLARE
    search_key TEXT := 'noise_cancellation';
    search_value TEXT := 'Active';
BEGIN
    EXECUTE format('
        SELECT name, price
        FROM products
        WHERE attributes->>%L = %L
    ', search_key, search_value);
END $$;

-- Build dynamic query based on user input
CREATE OR REPLACE FUNCTION search_products(
    p_category TEXT DEFAULT NULL,
    p_brand TEXT DEFAULT NULL,
    p_min_price NUMERIC DEFAULT NULL,
    p_max_price NUMERIC DEFAULT NULL,
    p_attributes JSONB DEFAULT NULL
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR,
    price NUMERIC,
    brand TEXT,
    category TEXT
) AS $$
DECLARE
    query TEXT := 'SELECT id, name, price, metadata->>''brand'' AS brand, metadata->>''category'' AS category FROM products WHERE 1=1';
BEGIN
    IF p_category IS NOT NULL THEN
        query := query || format(' AND metadata->>''category'' = %L', p_category);
    END IF;
    
    IF p_brand IS NOT NULL THEN
        query := query || format(' AND metadata->>''brand'' = %L', p_brand);
    END IF;
    
    IF p_min_price IS NOT NULL THEN
        query := query || format(' AND price >= %L', p_min_price);
    END IF;
    
    IF p_max_price IS NOT NULL THEN
        query := query || format(' AND price <= %L', p_max_price);
    END IF;
    
    IF p_attributes IS NOT NULL AND jsonb_typeof(p_attributes) = 'object' THEN
        -- Filter for each key-value pair in the JSON
        FOR key, value IN SELECT * FROM jsonb_each(p_attributes) LOOP
            query := query || format(' AND attributes->>%L = %L', key, value);
        END LOOP;
    END IF;
    
    RETURN QUERY EXECUTE query;
END;
$$ LANGUAGE plpgsql;

-- Use the dynamic search function
SELECT * FROM search_products(
    p_category => 'Audio',
    p_brand => 'AudioPro',
    p_min_price => 50,
    p_max_price => 200,
    p_attributes => '{"noise_cancellation": "Active"}'::jsonb
);
```

---

### Implementation Step 8: Hybrid Search System

#### 8.1 Full-Text Search Index

```sql
-- Update search_vector for all products
UPDATE products 
SET search_vector = 
    setweight(to_tsvector('english', COALESCE(name, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(description, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(metadata->>'brand', '')), 'C') ||
    setweight(to_tsvector('english', COALESCE(metadata->>'category', '')), 'C') ||
    setweight(to_tsvector('english', COALESCE(metadata->>'tags'::text, '')), 'D');

-- Create GIN index on search_vector
CREATE INDEX idx_products_search_vector ON products USING gin(search_vector);

-- Full-text search query
SELECT 
    name,
    price,
    metadata->>'brand' AS brand,
    metadata->>'category' AS category,
    ts_rank_cd(search_vector, plainto_tsquery('wireless headphones premium')) AS rank
FROM products
WHERE search_vector @@ plainto_tsquery('wireless headphones premium')
ORDER BY rank DESC;
```

#### 8.2 Complete Hybrid Search

```sql
-- Hybrid search combining all methods
CREATE OR REPLACE FUNCTION hybrid_product_search(
    search_term TEXT,
    p_category TEXT DEFAULT NULL,
    p_min_price NUMERIC DEFAULT NULL,
    p_max_price NUMERIC DEFAULT NULL,
    p_min_rating NUMERIC DEFAULT NULL
)
RETURNS TABLE(
    product_id INTEGER,
    product_name VARCHAR,
    price NUMERIC,
    brand TEXT,
    category TEXT,
    relevance_score FLOAT,
    search_method TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH full_text AS (
        SELECT 
            p.id,
            p.name,
            p.price,
            p.metadata->>'brand' AS brand,
            p.metadata->>'category' AS category,
            ts_rank_cd(p.search_vector, plainto_tsquery(search_term)) AS score
        FROM products p
        WHERE p.search_vector @@ plainto_tsquery(search_term)
          AND (p_category IS NULL OR p.metadata->>'category' = p_category)
          AND (p_min_price IS NULL OR p.price >= p_min_price)
          AND (p_max_price IS NULL OR p.price <= p_max_price)
        ORDER BY score DESC
        LIMIT 20
    ),
    fuzzy_matches AS (
        SELECT 
            p.id,
            p.name,
            p.price,
            p.metadata->>'brand' AS brand,
            p.metadata->>'category' AS category,
            GREATEST(
                similarity(p.name, search_term),
                similarity(p.description, search_term),
                similarity(p.metadata->>'brand', search_term),
                similarity(p.metadata->>'category', search_term)
            ) AS score
        FROM products p
        WHERE GREATEST(
            similarity(p.name, search_term),
            similarity(p.description, search_term),
            similarity(p.metadata->>'brand', search_term),
            similarity(p.metadata->>'category', search_term)
        ) > 0.3
        AND (p_category IS NULL OR p.metadata->>'category' = p_category)
        AND (p_min_price IS NULL OR p.price >= p_min_price)
        AND (p_max_price IS NULL OR p.price <= p_max_price)
        ORDER BY score DESC
        LIMIT 20
    ),
    combined AS (
        SELECT 
            ft.id,
            ft.name,
            ft.price,
            ft.brand,
            ft.category,
            ft.score AS relevance_score,
            'Full-Text' AS search_method
        FROM full_text ft
        
        UNION ALL
        
        SELECT 
            fm.id,
            fm.name,
            fm.price,
            fm.brand,
            fm.category,
            fm.score AS relevance_score,
            'Fuzzy' AS search_method
        FROM fuzzy_matches fm
        WHERE NOT EXISTS (
            SELECT 1 FROM full_text ft 
            WHERE ft.id = fm.id 
              AND ft.score >= fm.score
        )
    )
    SELECT 
        c.id,
        c.name,
        c.price,
        c.brand,
        c.category,
        c.relevance_score,
        c.search_method
    FROM combined c
    ORDER BY c.relevance_score DESC, c.price ASC
    LIMIT 50;
END;
$$ LANGUAGE plpgsql;

-- Test the hybrid search
SELECT * FROM hybrid_product_search(
    search_term => 'wireless headphone',
    p_category => 'Audio',
    p_min_price => 50,
    p_max_price => 200
);
```

---

### Implementation Step 9: Reporting with JSONB

#### 9.1 Product Attribute Analytics

```sql
-- Extract and analyze product attributes
SELECT 
    metadata->>'category' AS category,
    COUNT(*) AS product_count,
    AVG(price) AS avg_price,
    SUM(stock_quantity) AS total_stock,
    AVG(jsonb_array_length(variants)) AS avg_variants
FROM products
WHERE deleted_at IS NULL
GROUP BY metadata->>'category'
ORDER BY product_count DESC;

-- Most common attributes across products
SELECT 
    key AS attribute_name,
    COUNT(*) AS product_count,
    COUNT(DISTINCT value) AS unique_values
FROM products,
     jsonb_each(attributes)
WHERE deleted_at IS NULL
GROUP BY key
ORDER BY product_count DESC
LIMIT 20;

-- Product with highest number of variants
SELECT 
    name,
    jsonb_array_length(variants) AS variant_count,
    variants
FROM products
WHERE deleted_at IS NULL
ORDER BY variant_count DESC
LIMIT 5;

-- Revenue by product category (from JSONB)
SELECT 
    p.metadata->>'category' AS category,
    COUNT(DISTINCT o.id) AS order_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.line_total) AS total_revenue
FROM products p
INNER JOIN order_items oi ON p.id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND p.deleted_at IS NULL
GROUP BY p.metadata->>'category'
ORDER BY total_revenue DESC;
```

---

### Verification Checklist

Before moving to Part 6, confirm you can:

- [ ] Add JSONB columns to existing tables
- [ ] Insert and update JSONB data using jsonb_build_object and jsonb_set
- [ ] Query JSONB data with `->`, `->>`, `@>`, `?`, and `?|` operators
- [ ] Index JSONB fields with GIN indexes
- [ ] Enable and use PostgreSQL extensions (pg_trgm, btree_gin)
- [ ] Perform fuzzy search using trigram similarity
- [ ] Create and query full-text search vectors
- [ ] Update and transform JSONB data dynamically
- [ ] Build hybrid search combining multiple methods
- [ ] Generate reports from JSONB data

---

### Deep Dive: JSONB Performance Considerations

**When to use JSONB**:
- Unstructured or semi-structured data
- Data that changes frequently (schema agility)
- Data that varies per row
- Configurations, settings, metadata
- Complex nested data

**When to avoid JSONB**:
- Core business entities (users, orders)
- Data that's always queried together
- Data that needs strict validation
- Data that's updated frequently (JSONB updates are expensive)

**Performance Tips**:
1. Use JSONB instead of JSON (binary format is more efficient)
2. Create GIN indexes for fast querying
3. Use path-specific indexes for common queries
4. Consider partial indexes for specific conditions
5. Avoid deep nesting (> 3 levels) for performance
6. Use `jsonb_build_object` vs manually building JSON
7. Prefer containment (`@>`) over path extraction for querying

---

### Common Pitfalls to Avoid

1. **Overusing JSONB**: Don't store relational data in JSONB
2. **No indexes**: JSONB queries can be slow without proper indexing
3. **Deep nesting**: Deeply nested JSON is hard to query and index
4. **Missing type safety**: JSONB doesn't enforce schema
5. **Large documents**: JSONB has a 1GB size limit, but aim for < 100KB
6. **Forgetting to update search vectors**: Must update tsvector when data changes
7. **Not using extensions**: pg_trgm and other extensions are powerful tools

---

### What's Next?

Excellent work! You've added flexibility and powerful search capabilities to your e-commerce backend. In Part 6, we'll:

- Optimize query performance with EXPLAIN ANALYZE
- Create advanced indexing strategies
- Implement ACID transactions for checkout flows
- Build a bulletproof inventory reservation system
- Set up CI/CD with Neon branches
- Deploy to production with best practices

You're almost at the finish line—let's make your application production-ready!
