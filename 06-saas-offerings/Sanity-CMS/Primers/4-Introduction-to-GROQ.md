# Primer 4: Introduction to GROQ

Welcome to the fourth primer. Now that you have content in your Studio, it's time to learn how to get it out. This primer focuses exclusively on GROQ (Graph-Relational Object Queries), Sanity's powerful query language.

By the end of this primer, you'll be able to fetch exactly the content you need, when you need it.

---

## What is GROQ?

GROQ is a query language designed specifically for content. Think of it as SQL, but built for JSON documents instead of database tables. It allows you to:

- Filter documents based on any criteria
- Shape the response to include only the fields you need
- Follow references between documents
- Sort, slice, and paginate results
- Compute new fields on the fly

**Real-world analogy**: If your Sanity dataset is a library, GROQ is your super-librarian. You can say, "Give me all books about technology, published after 2020, showing only the title and author, sorted by the author's last name." The librarian finds exactly that set.

## Your First GROQ Query

The simplest GROQ query selects everything:

```
*[_type == "post"]
```

**Breakdown**:

- `*` means "all documents"
- `[_type == "post"]` is a filter: "where the _type field equals 'post'"

Let's run this in the Vision tool:

1. Open your Studio at `http://localhost:3333`
2. Click "Vision" in the sidebar
3. Paste the query: `*[_type == "post"]`
4. Click "Run Query"

You'll see all your posts as JSON.

## Filtering Documents

Filters are how you select specific documents. The syntax is `[condition]` where condition is a boolean expression.

### Basic Filters

```groq
// All posts
*[_type == "post"]

// Posts published after a date
*[_type == "post" && publishedAt > "2024-01-01"]

// Posts by a specific author
*[_type == "post" && author->name == "Jane Smith"]

// Posts with a specific category
*[_type == "post" && "technology" in categories[]->slug.current]

// Posts that have a featured image
*[_type == "post" && defined(featuredImage)]

// Posts that don't have an excerpt
*[_type == "post" && !defined(excerpt)]

// Posts that have at least 3 categories
*[_type == "post" && count(categories) > 2]
```

### Working with References

The `->` operator is how you follow references:

```groq
// All posts with author names
*[_type == "post"] {
  title,
  "authorName": author->name
}

// All posts by authors with a specific name
*[_type == "post" && author->name == "Jane Smith"]

// All posts with category details
*[_type == "post"] {
  title,
  "categories": categories[]-> {
    title,
    slug
  }
}
```

## Projections: Shaping Your Results

Projections determine what fields are returned. The syntax is `{ field1, field2, ... }`.

### Basic Projections

```groq
// Return only title and slug
*[_type == "post"] {
  title,
  "slug": slug.current
}

// Rename fields
*[_type == "post"] {
  "postTitle": title,
  "url": slug.current
}

// Computed fields
*[_type == "post"] {
  title,
  "date": publishedAt[0..10],  // First 10 characters (YYYY-MM-DD)
  "readingTime": round(length(pt::text(body)) / 900) // Rough reading time
}
```

### Nested Projections

```groq
// Full post with author and categories
*[_type == "post"] {
  _id,
  title,
  slug,
  excerpt,
  publishedAt,
  
  "author": author-> {
    name,
    slug,
    bio
  },
  
  "categories": categories[]-> {
    title,
    slug
  },
  
  body
}
```

## Advanced GROQ Operators

### Splat (`...`)

The splat operator expands all fields of a document:

```groq
// Include all existing fields plus new ones
*[_type == "post"] {
  ...,
  "isRecent": publishedAt > "2024-01-01"
}
```

### Coalesce

Return the first non-null value:

```groq
*[_type == "post"] {
  "metaTitle": coalesce(seo.metaTitle, title),
  "description": coalesce(seo.metaDescription, excerpt, "No description")
}
```

### Conditional Fields

Use `select()` for conditional logic:

```groq
*[_type == "post"] {
  title,
  "image": select(
    defined(featuredImage) => featuredImage.asset->url,
    true => "fallback-image.jpg"
  ),
  "status": select(
    defined(publishedAt) && publishedAt < now() => "Published",
    defined(publishedAt) && publishedAt > now() => "Scheduled",
    true => "Draft"
  )
}
```

## Ordering and Pagination

### Ordering

```groq
// Sort by date, newest first
*[_type == "post"] | order(publishedAt desc)

// Sort by multiple fields
*[_type == "post"] | order(publishedAt desc, title asc)

// Custom sorting with weights
*[_type == "post"] | order(
  _score(popularity) desc,
  publishedAt desc
)
```

### Pagination

```groq
// First 10 posts
*[_type == "post"] [0..9]

// Next 10 posts
*[_type == "post"] [10..19]

// Skip first 10, take 10
*[_type == "post"] [10...20]  // Note the three dots

// Last 5 posts
*[_type == "post"] [-5..]
```

## Working with Arrays

### Array Functions

```groq
// Count items
*[_type == "post"] {
  title,
  "categoryCount": count(categories)
}

// Check if item exists
*[_type == "post" && "technology" in categories[]->slug.current]

// Get first item
*[_type == "post"] {
  title,
  "firstCategory": categories[0]->title
}

// Transform array
*[_type == "post"] {
  title,
  "categoryNames": categories[]->title
}
```

### Array Operators

```groq
// All items must match
*[_type == "post" && categories[]->name == "Technology"]

// Any item matches
*[_type == "post" && "Technology" in categories[]->name]

// Select items from array
*[_type == "post"] {
  title,
  "categories": categories[0..2]->title
}
```

## Practice: Real-World Queries

### Blog Homepage Query

```groq
*[_type == "post"] | order(publishedAt desc) [0..9] {
  _id,
  title,
  slug,
  excerpt,
  publishedAt,
  featuredImage {
    asset-> {
      url,
      metadata { lqip, dimensions }
    },
    alt
  },
  "author": author-> {
    name,
    slug,
    avatar { asset-> { url }, alt }
  },
  "categories": categories[]-> {
    title,
    slug
  },
  "readingTime": round(length(pt::text(body)) / 900)
}
```

### Post Detail Query

```groq
*[_type == "post" && slug.current == $slug][0] {
  _id,
  title,
  slug,
  excerpt,
  publishedAt,
  featuredImage {
    asset-> { url, metadata { lqip, dimensions } },
    alt,
    caption
  },
  body[] {
    ...,
    _type == "image" => {
      ...,
      asset-> { url, metadata { lqip, dimensions } }
    }
  },
  "author": author-> {
    name,
    slug,
    bio,
    avatar { asset-> { url }, alt },
    socialLinks
  },
  "categories": categories[]-> {
    title,
    slug
  },
  seo,
  "readingTime": round(length(pt::text(body)) / 900)
}
```

### Author Page Query

```groq
*[_type == "author" && slug.current == $slug][0] {
  _id,
  name,
  slug,
  bio,
  avatar { asset-> { url }, alt },
  socialLinks,
  "posts": *[_type == "post" && references(^._id)] | order(publishedAt desc) {
    title,
    slug,
    publishedAt,
    excerpt,
    featuredImage { asset-> { url }, alt }
  }
}
```

### Category Page Query

```groq
*[_type == "category" && slug.current == $slug][0] {
  _id,
  title,
  slug,
  description,
  "posts": *[_type == "post" && references(^._id)] | order(publishedAt desc) {
    title,
    slug,
    publishedAt,
    excerpt,
    featuredImage { asset-> { url }, alt },
    "author": author-> { name, slug }
  }
}
```

### Search Query

```groq
*[
  _type in ["post", "author", "category"] &&
  (
    title match $searchTerm + "*" ||
    name match $searchTerm + "*" ||
    excerpt match $searchTerm + "*" ||
    description match $searchTerm + "*"
  )
] {
  _type,
  _id,
  title,
  name,
  "slug": slug.current,
  excerpt,
  description,
  "image": coalesce(featuredImage.asset->url, avatar.asset->url)
} | order(_score)
```

## Testing Queries in Vision

The Vision tool is your playground for writing and testing GROQ queries:

1. Open Vision from the Studio sidebar
2. Write your query in the left pane
3. Click "Run" to execute
4. Results appear in the right pane

**Pro Tips**:

- Use the "Pretty Print" toggle to format results
- Save queries you use often by clicking the "Save" button
- Use the "History" tab to see previous queries
- Click "Params" to add variables to your queries

## GROQ Cheat Sheet

### Operators

| Operator | Purpose | Example |
|----------|---------|---------|
| `==` | Equality | `title == "Hello"` |
| `!=` | Inequality | `status != "draft"` |
| `>` | Greater than | `publishedAt > "2024-01-01"` |
| `<` | Less than | `price < 100` |
| `>=` | Greater than or equal | `views >= 1000` |
| `<=` | Less than or equal | `rating <= 5` |
| `&&` | Logical AND | `_type == "post" && published` |
| `||` | Logical OR | `_type == "post" || _type == "page"` |
| `!` | Logical NOT | `!defined(excerpt)` |
| `in` | Array membership | `"tech" in categories` |
| `match` | String matching | `title match "Hello*"` |

### Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `count()` | Count items | `count(categories)` |
| `defined()` | Check if field exists | `defined(featuredImage)` |
| `coalesce()` | First non-null value | `coalesce(title, "Untitled")` |
| `select()` | Conditional value | `select(true => "Yes")` |
| `pt::text()` | Extract text from Portable Text | `pt::text(body)` |
| `round()` | Round a number | `round(price)` |
| `now()` | Current date/time | `publishedAt < now()` |

### Special Fields

| Field | Description |
|-------|-------------|
| `_id` | Document ID |
| `_type` | Document type |
| `_createdAt` | Creation timestamp |
| `_updatedAt` | Last update timestamp |
| `_rev` | Revision ID |
| `^` | Current document (for nested queries) |
