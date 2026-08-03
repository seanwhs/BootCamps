# Appendix C: Advanced Patterns & Real-World Use Cases

Welcome to the Advanced Patterns and Real-World Use Cases appendix. This section explores sophisticated implementation patterns and demonstrates how to apply your Sanity CMS knowledge to solve real-world business problems. Use these patterns as inspiration for your own projects.

---

## C.1 Multi-Language Content Management

### The Concept

Managing content in multiple languages is a common requirement for global businesses. Sanity supports internationalization (i18n) through document structure, field-level translations, or dedicated language datasets.

**Real-world analogy**: Multi-language content management is like having separate editions of a magazine for different countries. Each edition has the same structure but different content in each language.

### Implementation: Field-Level Translations

This approach stores all language versions in a single document, using language-specific fields.

#### Schema Configuration

```typescript
// studio/schemas/post.ts
import { defineField, defineType } from 'sanity'

export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  fields: [
    defineField({
      name: 'title',
      title: 'Title',
      type: 'object',
      fields: [
        {
          name: 'en',
          title: 'English',
          type: 'string',
          validation: Rule => Rule.required()
        },
        {
          name: 'es',
          title: 'Spanish',
          type: 'string',
          validation: Rule => Rule.required()
        },
        {
          name: 'fr',
          title: 'French',
          type: 'string',
          validation: Rule => Rule.required()
        }
      ]
    }),
    defineField({
      name: 'body',
      title: 'Body',
      type: 'object',
      fields: [
        {
          name: 'en',
          title: 'English',
          type: 'array',
          of: [{ type: 'block' }]
        },
        {
          name: 'es',
          title: 'Spanish',
          type: 'array',
          of: [{ type: 'block' }]
        },
        {
          name: 'fr',
          title: 'French',
          type: 'array',
          of: [{ type: 'block' }]
        }
      ]
    })
  ]
})
```

#### Querying Multi-Language Content

```typescript
// frontend/lib/sanity/queries.ts
export const postBySlugQuery = `
  *[_type == "post" && slug.current == $slug][0] {
    _id,
    title,
    "title": title[$lang],
    "body": body[$lang],
    "publishedAt": publishedAt,
    "author": author-> {
      name,
      slug
    }
  }
`

// Usage in component
export async function getPostBySlug(slug: string, lang: string = 'en') {
  const post = await client.fetch<Post>(
    postBySlugQuery,
    { slug, lang }
  )
  return post
}
```

### Implementation: Language-Specific Datasets

For complete separation, use different datasets for each language.

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'

export default defineConfig([
  {
    name: 'default',
    title: 'English',
    projectId: 'your-project-id',
    dataset: 'production-en',
    plugins: [structureTool()],
    schema: { types: schemaTypes }
  },
  {
    name: 'spanish',
    title: 'Spanish',
    basePath: '/es',
    projectId: 'your-project-id',
    dataset: 'production-es',
    plugins: [structureTool()],
    schema: { types: schemaTypes }
  }
])
```

### Implementation: Language Selector Component

```typescript
// frontend/components/LanguageSelector.tsx
'use client'

import { usePathname, useRouter } from 'next/navigation'
import { useState } from 'react'

const LANGUAGES = [
  { code: 'en', name: 'English', flag: '🇺🇸' },
  { code: 'es', name: 'Spanish', flag: '🇪🇸' },
  { code: 'fr', name: 'French', flag: '🇫🇷' },
]

export function LanguageSelector() {
  const pathname = usePathname()
  const router = useRouter()
  const [currentLang, setCurrentLang] = useState('en')

  const handleLanguageChange = (langCode: string) => {
    setCurrentLang(langCode)
    
    // Update URL with language parameter
    const url = new URL(pathname, window.location.origin)
    url.searchParams.set('lang', langCode)
    router.push(url.toString())
    
    // Store preference
    localStorage.setItem('preferred-language', langCode)
  }

  return (
    <div className="relative inline-block">
      <select
        value={currentLang}
        onChange={(e) => handleLanguageChange(e.target.value)}
        className="appearance-none bg-white border border-gray-300 rounded-lg px-4 py-2 pr-8 cursor-pointer hover:border-blue-500 transition-colors"
      >
        {LANGUAGES.map((lang) => (
          <option key={lang.code} value={lang.code}>
            {lang.flag} {lang.name}
          </option>
        ))}
      </select>
      <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
        <svg className="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
          <path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/>
        </svg>
      </div>
    </div>
  )
}
```

---

## C.2 Custom Content APIs

### The Concept

Sometimes you need to expose your Sanity content through custom API endpoints for external applications, mobile apps, or third-party integrations.

**Real-world analogy**: Custom APIs are like having a dedicated delivery service for your products. Instead of customers coming to your store, you deliver directly to them.

### Implementation: Next.js API Route

```typescript
// frontend/app/api/content/posts/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { client } from '@/lib/sanity/client'

export async function GET(request: NextRequest) {
  try {
    // Parse query parameters
    const searchParams = request.nextUrl.searchParams
    const limit = parseInt(searchParams.get('limit') || '10')
    const offset = parseInt(searchParams.get('offset') || '0')
    const category = searchParams.get('category')
    const author = searchParams.get('author')
    
    // Build the GROQ query
    let query = `*[_type == "post"`
    const params: Record<string, any> = {}
    
    if (category) {
      query += ` && $category in categories[]->slug.current`
      params.category = category
    }
    
    if (author) {
      query += ` && author->slug.current == $author`
      params.author = author
    }
    
    query += `] | order(publishedAt desc) [${offset}...${offset + limit}] {
      _id,
      title,
      slug,
      excerpt,
      publishedAt,
      featuredImage {
        asset-> {
          url,
          metadata {
            dimensions
          }
        },
        alt
      },
      "author": author-> {
        name,
        slug,
        avatar {
          asset-> {
            url
          }
        }
      },
      "categories": categories[]-> {
        title,
        slug
      },
      "readingTime": round(length(join(body[].children[].text, "")) / 5 / 180)
    }`
    
    // Fetch posts
    const posts = await client.fetch(query, params)
    
    // Get total count for pagination
    const countQuery = `count(*[_type == "post"])`
    const total = await client.fetch(countQuery)
    
    return NextResponse.json({
      data: posts,
      pagination: {
        total,
        limit,
        offset,
        hasMore: offset + posts.length < total
      }
    })
  } catch (error) {
    console.error('API Error:', error)
    return NextResponse.json(
      { error: 'Failed to fetch posts' },
      { status: 500 }
    )
  }
}
```

### Implementation: GraphQL API with Sanity

```typescript
// frontend/app/api/graphql/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { createGraphQLClient, gql } from '@sanity/graphql'

// Create a GraphQL client
const graphqlClient = createGraphQLClient({
  projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
  dataset: process.env.NEXT_PUBLIC_SANITY_DATASET!,
  apiVersion: '2024-01-01',
  useCdn: true
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { query, variables } = body
    
    // Execute GraphQL query
    const result = await graphqlClient.query({
      query: gql(query),
      variables
    })
    
    return NextResponse.json(result)
  } catch (error) {
    console.error('GraphQL Error:', error)
    return NextResponse.json(
      { error: 'GraphQL query failed' },
      { status: 500 }
    )
  }
}
```

### Implementation: REST API with Filtering

```typescript
// frontend/app/api/search/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { client } from '@/lib/sanity/client'

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams
    const q = searchParams.get('q')
    const type = searchParams.get('type') || 'all'
    
    if (!q || q.length < 2) {
      return NextResponse.json({
        data: [],
        message: 'Please provide at least 2 characters for search'
      })
    }
    
    // Build search query
    let query = `*[`
    if (type === 'post') {
      query += `_type == "post" && `
    } else if (type === 'author') {
      query += `_type == "author" && `
    } else if (type === 'category') {
      query += `_type == "category" && `
    }
    
    query += `
      title match $searchTerm + "*" ||
      excerpt match $searchTerm + "*" ||
      description match $searchTerm + "*" ||
      name match $searchTerm + "*"
    ] {
      _type,
      _id,
      title,
      "slug": slug.current,
      excerpt,
      description,
      "image": coalesce(featuredImage.asset->url, avatar.asset->url),
      "author": author->name
    } | score(popularity)
    `
    
    const results = await client.fetch(query, {
      searchTerm: `${q}*`
    })
    
    return NextResponse.json({
      data: results,
      total: results.length,
      query: q
    })
  } catch (error) {
    console.error('Search API Error:', error)
    return NextResponse.json(
      { error: 'Search failed' },
      { status: 500 }
    )
  }
}
```

---

## C.3 E-Commerce Integration

### The Concept

Sanity can serve as the content backbone for e-commerce platforms, managing product descriptions, categories, and marketing content that integrates with your commerce engine.

**Real-world analogy**: Sanity provides the store window displays and product descriptions, while your commerce platform handles the checkout and inventory.

### Implementation: Product Schema

```typescript
// studio/schemas/product.ts
import { defineField, defineType } from 'sanity'

export default defineType({
  name: 'product',
  title: 'Product',
  type: 'document',
  fields: [
    defineField({
      name: 'name',
      title: 'Product Name',
      type: 'string',
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      options: { source: 'name' },
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'sku',
      title: 'SKU',
      type: 'string',
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'price',
      title: 'Price',
      type: 'number',
      validation: Rule => Rule.required().positive()
    }),
    defineField({
      name: 'salePrice',
      title: 'Sale Price',
      type: 'number',
      validation: Rule => Rule.lessThan(Rule.valueOfField('price'))
    }),
    defineField({
      name: 'categories',
      title: 'Categories',
      type: 'array',
      of: [{ type: 'reference', to: [{ type: 'productCategory' }] }]
    }),
    defineField({
      name: 'images',
      title: 'Product Images',
      type: 'array',
      of: [
        {
          type: 'image',
          options: { hotspot: true },
          fields: [
            {
              name: 'alt',
              title: 'Alt Text',
              type: 'string'
            },
            {
              name: 'isPrimary',
              title: 'Primary Image',
              type: 'boolean',
              initialValue: false
            }
          ]
        }
      ],
      validation: Rule => Rule.min(1).max(10)
    }),
    defineField({
      name: 'description',
      title: 'Description',
      type: 'array',
      of: [{ type: 'block' }]
    }),
    defineField({
      name: 'specifications',
      title: 'Specifications',
      type: 'object',
      fields: [
        {
          name: 'dimensions',
          title: 'Dimensions',
          type: 'object',
          fields: [
            { name: 'length', title: 'Length', type: 'number' },
            { name: 'width', title: 'Width', type: 'number' },
            { name: 'height', title: 'Height', type: 'number' },
            { name: 'unit', title: 'Unit', type: 'string', options: { list: ['in', 'cm', 'mm'] } }
          ]
        },
        {
          name: 'weight',
          title: 'Weight',
          type: 'object',
          fields: [
            { name: 'value', title: 'Value', type: 'number' },
            { name: 'unit', title: 'Unit', type: 'string', options: { list: ['lb', 'kg', 'g'] } }
          ]
        },
        {
          name: 'color',
          title: 'Color',
          type: 'string'
        },
        {
          name: 'material',
          title: 'Material',
          type: 'string'
        }
      ]
    }),
    defineField({
      name: 'inventory',
      title: 'Inventory',
      type: 'object',
      fields: [
        {
          name: 'quantity',
          title: 'Quantity',
          type: 'number',
          validation: Rule => Rule.min(0)
        },
        {
          name: 'inStock',
          title: 'In Stock',
          type: 'boolean',
          initialValue: true
        },
        {
          name: 'backorderAllowed',
          title: 'Backorder Allowed',
          type: 'boolean',
          initialValue: false
        }
      ]
    }),
    defineField({
      name: 'seo',
      title: 'SEO',
      type: 'object',
      fields: [
        { name: 'metaTitle', title: 'Meta Title', type: 'string' },
        { name: 'metaDescription', title: 'Meta Description', type: 'text' },
        { name: 'keywords', title: 'Keywords', type: 'array', of: [{ type: 'string' }] }
      ]
    })
  ],
  preview: {
    select: {
      title: 'name',
      subtitle: 'sku',
      price: 'price'
    },
    prepare({ title, subtitle, price }) {
      return {
        title: title,
        subtitle: `${subtitle} - $${price}`,
      }
    }
  }
})
```

### Implementation: Shopping Cart API

```typescript
// frontend/app/api/cart/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { client } from '@/lib/sanity/client'

// In a real application, you'd use a database for cart storage
// This example uses a simple in-memory store
let cartStore: Map<string, any> = new Map()

export async function GET(request: NextRequest) {
  try {
    const cartId = request.headers.get('cart-id') || 'default'
    const cart = cartStore.get(cartId) || { items: [], total: 0 }
    
    return NextResponse.json(cart)
  } catch (error) {
    console.error('Cart API Error:', error)
    return NextResponse.json(
      { error: 'Failed to fetch cart' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { productId, quantity = 1 } = body
    const cartId = request.headers.get('cart-id') || 'default'
    
    // Fetch product details
    const product = await client.fetch(`
      *[_type == "product" && _id == $productId][0] {
        _id,
        name,
        sku,
        price,
        salePrice,
        "image": images[0].asset->url
      }
    `, { productId })
    
    if (!product) {
      return NextResponse.json(
        { error: 'Product not found' },
        { status: 404 }
      )
    }
    
    // Get or create cart
    let cart = cartStore.get(cartId) || { items: [], total: 0 }
    
    // Check if product already in cart
    const existingItem = cart.items.find((item: any) => item.productId === productId)
    
    if (existingItem) {
      existingItem.quantity += quantity
    } else {
      cart.items.push({
        productId,
        quantity,
        product: {
          name: product.name,
          sku: product.sku,
          price: product.salePrice || product.price,
          image: product.image
        }
      })
    }
    
    // Recalculate total
    cart.total = cart.items.reduce((sum: number, item: any) => {
      return sum + (item.product.price * item.quantity)
    }, 0)
    
    cartStore.set(cartId, cart)
    
    return NextResponse.json(cart)
  } catch (error) {
    console.error('Cart API Error:', error)
    return NextResponse.json(
      { error: 'Failed to add to cart' },
      { status: 500 }
    )
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const cartId = request.headers.get('cart-id') || 'default'
    cartStore.delete(cartId)
    
    return NextResponse.json({
      message: 'Cart cleared successfully'
    })
  } catch (error) {
    console.error('Cart API Error:', error)
    return NextResponse.json(
      { error: 'Failed to clear cart' },
      { status: 500 }
    )
  }
}
```

### Implementation: Product Listing with Filters

```typescript
// frontend/components/ProductFilters.tsx
'use client'

import { useState, useEffect } from 'react'

interface Filters {
  categories: string[]
  priceRange: { min: number; max: number }
  inStock: boolean
  sortBy: 'price-asc' | 'price-desc' | 'name-asc' | 'name-desc' | 'popularity'
}

const initialFilters: Filters = {
  categories: [],
  priceRange: { min: 0, max: 1000 },
  inStock: false,
  sortBy: 'popularity'
}

export function ProductFilters() {
  const [filters, setFilters] = useState<Filters>(initialFilters)
  const [products, setProducts] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [categories, setCategories] = useState<any[]>([])

  useEffect(() => {
    fetchCategories()
    fetchProducts()
  }, [])

  useEffect(() => {
    fetchProducts()
  }, [filters])

  const fetchCategories = async () => {
    try {
      const response = await fetch('/api/categories')
      const data = await response.json()
      setCategories(data)
    } catch (error) {
      console.error('Failed to fetch categories:', error)
    }
  }

  const fetchProducts = async () => {
    try {
      setLoading(true)
      const params = new URLSearchParams()
      if (filters.categories.length > 0) {
        params.append('categories', filters.categories.join(','))
      }
      params.append('minPrice', filters.priceRange.min.toString())
      params.append('maxPrice', filters.priceRange.max.toString())
      params.append('inStock', filters.inStock.toString())
      params.append('sortBy', filters.sortBy)
      
      const response = await fetch(`/api/products?${params.toString()}`)
      const data = await response.json()
      setProducts(data)
    } catch (error) {
      console.error('Failed to fetch products:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
      {/* Filters Sidebar */}
      <aside className="md:col-span-1">
        <div className="sticky top-24 space-y-6">
          <div>
            <h3 className="font-semibold mb-3">Categories</h3>
            {categories.map((category) => (
              <label key={category._id} className="flex items-center gap-2 mb-2">
                <input
                  type="checkbox"
                  checked={filters.categories.includes(category.slug.current)}
                  onChange={(e) => {
                    if (e.target.checked) {
                      setFilters({
                        ...filters,
                        categories: [...filters.categories, category.slug.current]
                      })
                    } else {
                      setFilters({
                        ...filters,
                        categories: filters.categories.filter(
                          c => c !== category.slug.current
                        )
                      })
                    }
                  }}
                />
                <span>{category.title}</span>
                <span className="text-sm text-gray-500">({category.productCount})</span>
              </label>
            ))}
          </div>
          
          <div>
            <h3 className="font-semibold mb-3">Price Range</h3>
            <div className="flex gap-2">
              <input
                type="number"
                placeholder="Min"
                value={filters.priceRange.min}
                onChange={(e) => setFilters({
                  ...filters,
                  priceRange: { ...filters.priceRange, min: Number(e.target.value) }
                })}
                className="w-1/2 px-3 py-2 border rounded-lg"
              />
              <input
                type="number"
                placeholder="Max"
                value={filters.priceRange.max}
                onChange={(e) => setFilters({
                  ...filters,
                  priceRange: { ...filters.priceRange, max: Number(e.target.value) }
                })}
                className="w-1/2 px-3 py-2 border rounded-lg"
              />
            </div>
          </div>
          
          <div>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={filters.inStock}
                onChange={(e) => setFilters({
                  ...filters,
                  inStock: e.target.checked
                })}
              />
              <span>In Stock Only</span>
            </label>
          </div>
          
          <div>
            <h3 className="font-semibold mb-3">Sort By</h3>
            <select
              value={filters.sortBy}
              onChange={(e) => setFilters({
                ...filters,
                sortBy: e.target.value as any
              })}
              className="w-full px-3 py-2 border rounded-lg"
            >
              <option value="popularity">Popularity</option>
              <option value="price-asc">Price: Low to High</option>
              <option value="price-desc">Price: High to Low</option>
              <option value="name-asc">Name: A to Z</option>
              <option value="name-desc">Name: Z to A</option>
            </select>
          </div>
        </div>
      </aside>
      
      {/* Product Grid */}
      <div className="md:col-span-3">
        {loading ? (
          <div className="flex justify-center items-center h-64">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          </div>
        ) : products.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-500">No products found matching your criteria</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {products.map((product) => (
              <ProductCard key={product._id} product={product} />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

function ProductCard({ product }: { product: any }) {
  return (
    <div className="bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow duration-300">
      <div className="relative aspect-square">
        <img
          src={product.image}
          alt={product.name}
          className="w-full h-full object-cover"
        />
        {product.salePrice && (
          <span className="absolute top-2 right-2 bg-red-500 text-white text-sm px-2 py-1 rounded-full">
            Sale!
          </span>
        )}
      </div>
      <div className="p-4">
        <h3 className="font-semibold text-lg mb-1">{product.name}</h3>
        <p className="text-gray-600 text-sm mb-2">{product.description}</p>
        <div className="flex justify-between items-center">
          <div>
            {product.salePrice ? (
              <>
                <span className="text-gray-400 line-through mr-2">${product.price}</span>
                <span className="text-blue-600 font-bold">${product.salePrice}</span>
              </>
            ) : (
              <span className="text-gray-900 font-bold">${product.price}</span>
            )}
          </div>
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
            Add to Cart
          </button>
        </div>
      </div>
    </div>
  )
}
```

---

## C.4 Real-Time Collaboration & Commenting

### The Concept

Sanity's Live Content API enables real-time collaboration features like commenting, activity tracking, and live presence.

**Real-world analogy**: This is like having a shared whiteboard where multiple people can draw, write, and see each other's contributions in real-time.

### Implementation: Commenting System

```typescript
// studio/schemas/comment.ts
import { defineField, defineType } from 'sanity'

export default defineType({
  name: 'comment',
  title: 'Comment',
  type: 'document',
  fields: [
    defineField({
      name: 'post',
      title: 'Post',
      type: 'reference',
      to: [{ type: 'post' }],
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'author',
      title: 'Author',
      type: 'object',
      fields: [
        { name: 'name', title: 'Name', type: 'string' },
        { name: 'email', title: 'Email', type: 'string' },
        { name: 'website', title: 'Website', type: 'url' },
        { name: 'avatar', title: 'Avatar URL', type: 'url' }
      ]
    }),
    defineField({
      name: 'content',
      title: 'Content',
      type: 'text',
      validation: Rule => Rule.required().min(3)
    }),
    defineField({
      name: 'status',
      title: 'Status',
      type: 'string',
      options: {
        list: [
          { title: 'Pending', value: 'pending' },
          { title: 'Approved', value: 'approved' },
          { title: 'Spam', value: 'spam' },
          { title: 'Trash', value: 'trash' }
        ]
      },
      initialValue: 'pending'
    }),
    defineField({
      name: 'parentComment',
      title: 'Parent Comment',
      type: 'reference',
      to: [{ type: 'comment' }]
    }),
    defineField({
      name: 'createdAt',
      title: 'Created At',
      type: 'datetime',
      initialValue: () => new Date().toISOString()
    }),
    defineField({
      name: 'updatedAt',
      title: 'Updated At',
      type: 'datetime'
    }),
    defineField({
      name: 'likes',
      title: 'Likes',
      type: 'number',
      initialValue: 0
    })
  ],
  preview: {
    select: {
      title: 'content',
      subtitle: 'author.name',
      postTitle: 'post.title'
    },
    prepare({ title, subtitle, postTitle }) {
      return {
        title: title ? `${title.slice(0, 50)}...` : 'Untitled comment',
        subtitle: subtitle ? `By ${subtitle} on ${postTitle || 'unknown post'}` : 'Anonymous'
      }
    }
  }
})
```

### Implementation: Live Comments Component

```typescript
// frontend/components/Comments.tsx
'use client'

import { useState, useEffect } from 'react'
import { liveClient } from '@/lib/sanity/client'
import { formatDistanceToNow } from 'date-fns'

interface Comment {
  _id: string
  content: string
  author: { name: string; avatar?: string }
  createdAt: string
  likes: number
  parentComment?: { _id: string }
}

export function Comments({ postId }: { postId: string }) {
  const [comments, setComments] = useState<Comment[]>([])
  const [newComment, setNewComment] = useState('')
  const [authorName, setAuthorName] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [loading, setLoading] = useState(true)

  // Fetch initial comments
  useEffect(() => {
    fetchComments()
  }, [postId])

  // Subscribe to live updates
  useEffect(() => {
    const subscription = liveClient
      .listen(
        `*[_type == "comment" && post._ref == $postId && status == "approved"] | order(createdAt asc)`,
        { postId }
      )
      .subscribe({
        next: (update) => {
          if (update.result) {
            fetchComments() // Refresh comments on update
          }
        },
        error: (err) => console.error('Comment subscription error:', err)
      })

    return () => subscription.unsubscribe()
  }, [postId])

  const fetchComments = async () => {
    try {
      setLoading(true)
      const query = `
        *[_type == "comment" && post._ref == $postId && status == "approved"] | order(createdAt asc) {
          _id,
          content,
          author,
          createdAt,
          likes,
          parentComment
        }
      `
      const data = await liveClient.fetch(query, { postId })
      setComments(data)
    } catch (error) {
      console.error('Failed to fetch comments:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!newComment.trim() || !authorName.trim()) {
      alert('Please fill in all fields')
      return
    }

    try {
      setIsSubmitting(true)
      
      const comment = {
        _type: 'comment',
        post: { _ref: postId, _type: 'reference' },
        content: newComment,
        author: {
          name: authorName,
          avatar: `https://ui-avatars.com/api/?name=${encodeURIComponent(authorName)}&background=random`
        },
        status: 'pending',
        createdAt: new Date().toISOString(),
        likes: 0
      }

      await liveClient.create(comment)
      
      setNewComment('')
      // Refresh comments
      await fetchComments()
    } catch (error) {
      console.error('Failed to post comment:', error)
      alert('Failed to post comment. Please try again.')
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleLike = async (commentId: string) => {
    try {
      await liveClient
        .patch(commentId)
        .inc({ likes: 1 })
        .commit()
      
      // Optimistically update UI
      setComments(comments.map(comment => {
        if (comment._id === commentId) {
          return { ...comment, likes: comment.likes + 1 }
        }
        return comment
      }))
    } catch (error) {
      console.error('Failed to like comment:', error)
    }
  }

  if (loading) {
    return (
      <div className="animate-pulse space-y-4">
        <div className="h-20 bg-gray-200 rounded-lg"></div>
        <div className="h-20 bg-gray-200 rounded-lg"></div>
        <div className="h-20 bg-gray-200 rounded-lg"></div>
      </div>
    )
  }

  return (
    <div className="mt-8">
      <h3 className="text-xl font-bold mb-4">
        Comments ({comments.length})
      </h3>

      {/* Comment Form */}
      <form onSubmit={handleSubmit} className="mb-8 space-y-4">
        <div>
          <input
            type="text"
            placeholder="Your name"
            value={authorName}
            onChange={(e) => setAuthorName(e.target.value)}
            className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>
        <div>
          <textarea
            placeholder="Write a comment..."
            value={newComment}
            onChange={(e) => setNewComment(e.target.value)}
            rows={4}
            className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>
        <button
          type="submit"
          disabled={isSubmitting}
          className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50"
        >
          {isSubmitting ? 'Posting...' : 'Post Comment'}
        </button>
      </form>

      {/* Comments List */}
      <div className="space-y-4">
        {comments.length === 0 ? (
          <p className="text-gray-500 text-center py-8">
            No comments yet. Be the first to comment!
          </p>
        ) : (
          comments.map((comment) => (
            <div key={comment._id} className="bg-gray-50 rounded-lg p-4">
              <div className="flex items-start gap-3">
                <img
                  src={comment.author.avatar || `https://ui-avatars.com/api/?name=${comment.author.name}`}
                  alt={comment.author.name}
                  className="w-10 h-10 rounded-full"
                />
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <div>
                      <span className="font-semibold">{comment.author.name}</span>
                      <span className="text-sm text-gray-500 ml-2">
                        {formatDistanceToNow(new Date(comment.createdAt), { addSuffix: true })}
                      </span>
                    </div>
                    <button
                      onClick={() => handleLike(comment._id)}
                      className="flex items-center gap-1 text-sm text-gray-500 hover:text-blue-600 transition-colors"
                    >
                      <span>❤️</span>
                      <span>{comment.likes}</span>
                    </button>
                  </div>
                  <p className="mt-2 text-gray-800">{comment.content}</p>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  )
}
```

---

## C.5 Content Personalization

### The Concept

Personalization delivers customized content experiences based on user behavior, preferences, and demographics.

**Real-world analogy**: Personalization is like having a personal shopper who knows your tastes and recommends products you're likely to enjoy.

### Implementation: User Preferences

```typescript
// frontend/lib/personalization.ts
import { client } from '@/lib/sanity/client'

interface UserPreferences {
  topics: string[]
  authors: string[]
  contentTypes: string[]
  readingLevel: 'beginner' | 'intermediate' | 'advanced'
  frequency: 'daily' | 'weekly' | 'monthly'
}

export async function getPersonalizedContent(
  userId: string,
  limit: number = 10
) {
  // Get user preferences (from database or cookies)
  const preferences = await getUserPreferences(userId)
  
  // Build personalized query
  let query = `*[_type == "post"`
  const params: Record<string, any> = {}
  
  if (preferences.topics.length > 0) {
    query += ` && count(categories[@.title in $topics]) > 0`
    params.topics = preferences.topics
  }
  
  if (preferences.authors.length > 0) {
    query += ` && author->name in $authors`
    params.authors = preferences.authors
  }
  
  query += `] | order(
    _score(publishedAt) desc
  ) [0...${limit}] {
    _id,
    title,
    slug,
    excerpt,
    publishedAt,
    featuredImage { asset->{ url }, alt },
    "author": author-> { name, slug },
    "categories": categories[]-> { title },
    "relevanceScore": _score
  }`
  
  const posts = await client.fetch(query, params)
  
  // Add personalized recommendations
  const recommendations = await getRecommendations(userId)
  
  return {
    posts,
    recommendations,
    preferences
  }
}

async function getUserPreferences(userId: string): Promise<UserPreferences> {
  // In production, fetch from a database
  // For now, return default preferences
  return {
    topics: ['Technology', 'Web Development'],
    authors: [],
    contentTypes: ['Blog Post', 'Tutorial'],
    readingLevel: 'intermediate',
    frequency: 'weekly'
  }
}

async function getRecommendations(userId: string): Promise<any[]> {
  // Get recommendations based on user behavior
  const query = `
    *[_type == "post"] | order(popularity desc) [0...5] {
      _id,
      title,
      slug,
      "author": author-> { name }
    }
  `
  return client.fetch(query)
}
```

### Implementation: A/B Testing

```typescript
// frontend/components/ABTest.tsx
'use client'

import { useState, useEffect } from 'react'

interface Variant {
  id: string
  name: string
  weight: number // Percentage weight for this variant
  component: React.ReactNode
}

interface ABTestProps {
  variants: Variant[]
  experimentId: string
  children?: React.ReactNode
}

export function ABTest({ variants, experimentId }: ABTestProps) {
  const [selectedVariant, setSelectedVariant] = useState<Variant | null>(null)

  useEffect(() => {
    // Check if user already has a variant for this experiment
    const storedVariant = localStorage.getItem(`abtest-${experimentId}`)
    
    if (storedVariant) {
      const variant = variants.find(v => v.id === storedVariant)
      if (variant) {
        setSelectedVariant(variant)
        trackImpression(experimentId, variant.id)
        return
      }
    }
    
    // Weighted random selection
    const random = Math.random() * 100
    let cumulative = 0
    
    for (const variant of variants) {
      cumulative += variant.weight
      if (random < cumulative) {
        setSelectedVariant(variant)
        localStorage.setItem(`abtest-${experimentId}`, variant.id)
        trackImpression(experimentId, variant.id)
        break
      }
    }
  }, [experimentId, variants])

  const trackImpression = (experimentId: string, variantId: string) => {
    // Track in analytics
    if (typeof window !== 'undefined') {
      // @ts-ignore - Analytics tracking
      if (window.gtag) {
        window.gtag('event', 'experiment_impression', {
          experiment_id: experimentId,
          variant_id: variantId
        })
      }
    }
  }

  if (!selectedVariant) {
    return null
  }

  return (
    <div data-experiment={experimentId} data-variant={selectedVariant.id}>
      {selectedVariant.component}
    </div>
  )
}

// Usage example
export function HomepageHero() {
  const variants = [
    {
      id: 'control',
      name: 'Control',
      weight: 50,
      component: <HeroControl />
    },
    {
      id: 'variant-a',
      name: 'Variant A',
      weight: 25,
      component: <HeroVariantA />
    },
    {
      id: 'variant-b',
      name: 'Variant B',
      weight: 25,
      component: <HeroVariantB />
    }
  ]

  return (
    <ABTest
      variants={variants}
      experimentId="homepage-hero-test"
    />
  )
}

function HeroControl() {
  return <div className="bg-blue-600 text-white p-8 rounded-xl">Hero Control</div>
}

function HeroVariantA() {
  return <div className="bg-purple-600 text-white p-8 rounded-xl">Hero Variant A</div>
}

function HeroVariantB() {
  return <div className="bg-green-600 text-white p-8 rounded-xl">Hero Variant B</div>
}
```

---

## C.6 Third-Party Integrations

### Implementation: MailChimp Newsletter Integration

```typescript
// frontend/app/api/newsletter/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { email, name } = body

    if (!email) {
      return NextResponse.json(
        { error: 'Email is required' },
        { status: 400 }
      )
    }

    // MailChimp API configuration
    const MAILCHIMP_API_KEY = process.env.MAILCHIMP_API_KEY
    const MAILCHIMP_LIST_ID = process.env.MAILCHIMP_LIST_ID
    const MAILCHIMP_SERVER_PREFIX = process.env.MAILCHIMP_SERVER_PREFIX

    if (!MAILCHIMP_API_KEY || !MAILCHIMP_LIST_ID || !MAILCHIMP_SERVER_PREFIX) {
      console.error('MailChimp configuration missing')
      return NextResponse.json(
        { error: 'Newsletter service not configured' },
        { status: 500 }
      )
    }

    // Subscribe user to MailChimp
    const response = await fetch(
      `https://${MAILCHIMP_SERVER_PREFIX}.api.mailchimp.com/3.0/lists/${MAILCHIMP_LIST_ID}/members`,
      {
        method: 'POST',
        headers: {
          'Authorization': `apikey ${MAILCHIMP_API_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          email_address: email,
          status: 'subscribed',
          merge_fields: {
            FNAME: name || ''
          }
        })
      }
    )

    const data = await response.json()

    if (response.status >= 400) {
      // If user already subscribed, return success anyway
      if (data.title === 'Member Exists') {
        return NextResponse.json({
          success: true,
          message: 'You are already subscribed!'
        })
      }
      
      throw new Error(data.detail || 'Subscription failed')
    }

    return NextResponse.json({
      success: true,
      message: 'Successfully subscribed!'
    })
  } catch (error) {
    console.error('Newsletter error:', error)
    return NextResponse.json(
      { error: 'Failed to subscribe' },
      { status: 500 }
    )
  }
}
```

### Implementation: Newsletter Subscription Form

```typescript
// frontend/components/NewsletterForm.tsx
'use client'

import { useState } from 'react'

export function NewsletterForm() {
  const [email, setEmail] = useState('')
  const [name, setName] = useState('')
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle')
  const [message, setMessage] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    setStatus('loading')
    setMessage('')

    try {
      const response = await fetch('/api/newsletter', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ email, name })
      })

      const data = await response.json()

      if (response.ok) {
        setStatus('success')
        setMessage(data.message || 'Successfully subscribed!')
        setEmail('')
        setName('')
      } else {
        setStatus('error')
        setMessage(data.error || 'Subscription failed')
      }
    } catch (error) {
      setStatus('error')
      setMessage('An error occurred. Please try again.')
    }
  }

  return (
    <div className="bg-gray-50 rounded-xl p-6">
      <h3 className="text-xl font-bold mb-2">Subscribe to Newsletter</h3>
      <p className="text-gray-600 mb-4">
        Get the latest posts delivered to your inbox.
      </p>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <input
            type="text"
            placeholder="Your name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
        <div>
          <input
            type="email"
            placeholder="Your email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>
        
        <button
          type="submit"
          disabled={status === 'loading'}
          className="w-full bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50"
        >
          {status === 'loading' ? 'Subscribing...' : 'Subscribe'}
        </button>
        
        {message && (
          <div className={`text-sm ${status === 'success' ? 'text-green-600' : 'text-red-600'}`}>
            {message}
          </div>
        )}
      </form>
    </div>
  )
}
```

---

## C.7 Analytics & Performance Monitoring

### Implementation: Custom Analytics

```typescript
// frontend/lib/analytics.ts
'use client'

interface AnalyticsEvent {
  category: string
  action: string
  label?: string
  value?: number
  metadata?: Record<string, any>
}

class Analytics {
  private static instance: Analytics
  private isReady: boolean = false

  private constructor() {
    this.isReady = typeof window !== 'undefined'
  }

  static getInstance(): Analytics {
    if (!Analytics.instance) {
      Analytics.instance = new Analytics()
    }
    return Analytics.instance
  }

  trackEvent(event: AnalyticsEvent) {
    if (!this.isReady) return

    // Google Analytics
    if (typeof window.gtag !== 'undefined') {
      window.gtag('event', event.action, {
        event_category: event.category,
        event_label: event.label,
        value: event.value,
        ...event.metadata
      })
    }

    // Sanity tracking (store events for analysis)
    this.sendToSanity(event)
  }

  trackPageView(page: string, metadata?: Record<string, any>) {
    if (!this.isReady) return

    if (typeof window.gtag !== 'undefined') {
      window.gtag('config', process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID!, {
        page_path: page,
        ...metadata
      })
    }
  }

  private async sendToSanity(event: AnalyticsEvent) {
    try {
      const response = await fetch('/api/analytics', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          type: 'event',
          timestamp: new Date().toISOString(),
          event,
          userAgent: navigator.userAgent,
          referrer: document.referrer
        })
      })

      if (!response.ok) {
        console.error('Failed to send analytics to Sanity')
      }
    } catch (error) {
      console.error('Analytics error:', error)
    }
  }

  trackPostView(postId: string, postTitle: string) {
    this.trackEvent({
      category: 'Content',
      action: 'Post View',
      label: postTitle,
      metadata: { postId }
    })
  }

  trackSearch(searchTerm: string, resultsCount: number) {
    this.trackEvent({
      category: 'Search',
      action: 'Search',
      label: searchTerm,
      value: resultsCount
    })
  }

  trackClick(element: string, destination: string) {
    this.trackEvent({
      category: 'Navigation',
      action: 'Click',
      label: element,
      metadata: { destination }
    })
  }

  trackConversion(type: string, value?: number) {
    this.trackEvent({
      category: 'Conversion',
      action: 'Convert',
      label: type,
      value
    })
  }
}

// Usage Hook
export function useAnalytics() {
  const analytics = Analytics.getInstance()
  
  return {
    trackEvent: analytics.trackEvent.bind(analytics),
    trackPageView: analytics.trackPageView.bind(analytics),
    trackPostView: analytics.trackPostView.bind(analytics),
    trackSearch: analytics.trackSearch.bind(analytics),
    trackClick: analytics.trackClick.bind(analytics),
    trackConversion: analytics.trackConversion.bind(analytics)
  }
}
```

---

This appendix has covered advanced patterns and real-world use cases that extend beyond the core tutorial. Use these patterns as building blocks for your own projects, adapting them to your specific needs.

**Happy building! 🚀**
