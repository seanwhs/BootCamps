# Part 2: Querying Content with GROQ

Welcome to Part 2! You've built a solid foundation with structured content models. Now it's time to unlock that content and make it accessible to your applications. In this part, we'll master GROQ (Graph-Relational Object Queries), Sanity's powerful query language.

By the end of this part, you'll have:
- Mastery of GROQ syntax and patterns
- Type-safe queries with Sanity TypeGen
- An optimized query layer for your frontend
- Advanced querying techniques for complex data needs

Let's dive in.

---

## Step 1: Understanding GROQ Fundamentals

### The Target
Learn the core concepts of GROQ and write your first queries.

### The Concept
GROQ stands for "Graph-Relational Object Queries." Think of it as SQL for JSON, but designed specifically for content. While SQL works with tables and rows, GROQ works with documents and fields.

**Real-world analogy**: Imagine you're at a massive library. Instead of browsing shelves (like you would in a traditional CMS), you have a super-smart librarian who can instantly find any book based on your criteria:
- "Find all books by Jane Austen" = Filtering
- "Give me only the titles and publication years" = Projection
- "Sort them by year" = Ordering
- "Show me the first 10" = Pagination

GROQ gives you this same power over your content.

### The Implementation

#### 1.1 Setting Up the Query Environment

First, let's create a dedicated file for our queries. This will keep our code organized and reusable.

Create `studio/queries/index.ts`:

```typescript
// studio/queries/index.ts
/**
 * GROQ Queries
 * 
 * Central repository for all GROQ queries.
 * These queries are organized by document type and purpose.
 * Each query includes type annotations for use with Sanity TypeGen.
 */

/**
 * POST QUERIES
 * ============
 * All queries related to blog posts
 */

// Get a single post by slug
export const postBySlugQuery = `
  *[_type == "post" && slug.current == $slug][0] {
    _id,
    title,
    slug,
    excerpt,
    "publishedAt": publishedAt,
    featuredImage {
      asset-> {
        _id,
        url,
        metadata {
          lqip,
          dimensions {
            width,
            height
          }
        }
      },
      alt,
      caption
    },
    body[] {
      ...,
      _type == "image" => {
        ...,
        asset-> {
          _id,
          url,
          metadata {
            lqip,
            dimensions {
              width,
              height
            }
          }
        }
      },
      _type == "code" => {
        ...,
        language,
        code
      },
      _type == "callout" => {
        ...,
        content[] {
          ...,
          children[] {
            ...,
            _type == "span" => {
              ...,
              marks
            }
          }
        }
      }
    },
    "categories": categories[]-> {
      title,
      slug
    },
    "author": author-> {
      name,
      slug,
      avatar {
        asset-> {
          url,
          metadata {
            lqip
          }
        },
        alt
      },
      bio,
      socialLinks
    },
    tags,
    seo,
    "estimatedReadingTime": round(length(join(body[].children[].text, "")) / 5 / 180)
  }
`

// Get all posts with metadata (for listings)
export const allPostsQuery = `
  *[_type == "post"] | order(publishedAt desc) {
    _id,
    title,
    slug,
    excerpt,
    "publishedAt": publishedAt,
    featuredImage {
      asset-> {
        url,
        metadata {
          lqip,
          dimensions {
            width,
            height
          }
        }
      },
      alt
    },
    "categories": categories[]-> {
      title,
      slug
    },
    "author": author-> {
      name,
      slug,
      avatar {
        asset-> {
          url
        }
      }
    }
  }
`

// Get posts by category
export const postsByCategoryQuery = `
  *[_type == "post" && $categorySlug in categories[]->slug.current] | order(publishedAt desc) {
    _id,
    title,
    slug,
    excerpt,
    "publishedAt": publishedAt,
    featuredImage {
      asset-> {
        url,
        metadata {
          lqip
        }
      },
      alt
    },
    "author": author-> {
      name,
      slug
    }
  }
`

// Get posts by author
export const postsByAuthorQuery = `
  *[_type == "post" && author->slug.current == $authorSlug] | order(publishedAt desc) {
    _id,
    title,
    slug,
    excerpt,
    "publishedAt": publishedAt,
    featuredImage {
      asset-> {
        url,
        metadata {
          lqip
        }
      },
      alt
    },
    "categories": categories[]-> {
      title,
      slug
    }
  }
`

/**
 * AUTHOR QUERIES
 * ==============
 * All queries related to authors
 */

// Get a single author by slug
export const authorBySlugQuery = `
  *[_type == "author" && slug.current == $slug][0] {
    _id,
    name,
    slug,
    bio,
    avatar {
      asset-> {
        url,
        metadata {
          lqip
        }
      },
      alt
    },
    socialLinks,
    role,
    biographyLong,
    "postCount": count(*[_type == "post" && references(^._id)])
  }
`

// Get all authors
export const allAuthorsQuery = `
  *[_type == "author"] | order(name asc) {
    _id,
    name,
    slug,
    avatar {
      asset-> {
        url
      },
      alt
    },
    role,
    "postCount": count(*[_type == "post" && references(^._id)])
  }
`

/**
 * CATEGORY QUERIES
 * ================
 * All queries related to categories
 */

// Get a single category by slug
export const categoryBySlugQuery = `
  *[_type == "category" && slug.current == $slug][0] {
    _id,
    title,
    slug,
    description,
    image {
      asset-> {
        url
      },
      alt
    },
    parentCategory-> {
      title,
      slug
    },
    "postCount": count(*[_type == "post" && references(^._id)])
  }
`

// Get all categories with post counts
export const allCategoriesQuery = `
  *[_type == "category"] | order(order asc, title asc) {
    _id,
    title,
    slug,
    description,
    image {
      asset-> {
        url
      },
      alt
    },
    "postCount": count(*[_type == "post" && references(^._id)])
  }
`

/**
 * SETTINGS QUERY
 * ==============
 * Get site settings
 */
export const settingsQuery = `
  *[_type == "settings"][0] {
    siteTitle,
    siteDescription,
    logo {
      asset-> {
        url,
        metadata {
          dimensions {
            width,
            height
          }
        }
      },
      alt
    },
    socialLinks,
    defaultSeo {
      metaTitle,
      metaDescription,
      ogImage {
        asset-> {
          url
        }
      }
    },
    contactInfo
  }
`

/**
 * SEARCH QUERY
 * ============
 * Search across multiple document types
 */
export const searchQuery = `
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
    slug,
    excerpt,
    description,
    "image": featuredImage.asset->url,
    "avatar": avatar.asset->url
  }
`
```

### The Verification

#### 1.2 Test Queries in Vision Tool

The Vision tool is a built-in GROQ playground in Sanity Studio. It's like a calculator for your content queries.

1. **Open Vision Tool**: Go to http://localhost:3333 and click "Vision" in the sidebar

2. **Test a simple query**:
```groq
*[_type == "post"] {
  title,
  publishedAt
}
```
Click "Run Query" and you should see all your posts with their titles and publish dates.

3. **Test a filtered query**:
```groq
*[_type == "post" && publishedAt < "2024-01-01"] {
  title,
  publishedAt
}
```

4. **Test a projection**:
```groq
*[_type == "post"] {
  "titleCase": title,
  "slugValue": slug.current,
  "year": publishedAt[0..3]
}
```

5. **Test a more complex query**:
```groq
*[_type == "post"] | order(publishedAt desc) [0..2] {
  title,
  "authorName": author->name,
  "categoryTitles": categories[]->title
}
```

**You should see**:
- Results appear in the right panel
- Each query returns exactly the data you requested
- The results update as you modify the query

---

## Step 2: Setting Up the Sanity Client

### The Target
Install and configure the Sanity client for your frontend application.

### The Concept
The Sanity client is your application's connection to the Content Lake. Think of it as a phone line between your frontend and Sanity's servers. The client handles authentication, query execution, and caching.

**Real-world analogy**: The Sanity client is like a waiter at a restaurant. You (the frontend) tell the waiter what you want (a GROQ query), and the waiter brings it to you from the kitchen (Content Lake).

### The Implementation

#### 2.1 Install Dependencies

```bash
# Navigate to the project root
cd ..  # Back to mastering-sanity-cms

# Create a folder for the frontend
mkdir frontend
cd frontend

# Initialize a new Next.js project
npx create-next-app@latest . --typescript --tailwind --app

# Install Sanity client and related packages
npm install @sanity/client @sanity/image-url @portabletext/react

# Install development dependencies
npm install -D @sanity/types
```

**What each package does**:
- `@sanity/client`: Main Sanity client for fetching content
- `@sanity/image-url`: Generates optimized image URLs from Sanity assets
- `@portabletext/react`: Renders Portable Text content in React
- `@sanity/types`: TypeScript types for Sanity documents

#### 2.2 Configure Environment Variables

Create `.env.local` in the frontend directory:

```bash
# frontend/.env.local
# Sanity Configuration
NEXT_PUBLIC_SANITY_PROJECT_ID=your-project-id-here
NEXT_PUBLIC_SANITY_DATASET=production
NEXT_PUBLIC_SANITY_API_VERSION=2024-01-01

# For preview/draft mode (we'll configure this in Part 4)
SANITY_STUDIO_API_READ_TOKEN=your-read-token-here
```

**Important**: Never commit `.env.local` to Git. It's already in `.gitignore`.

#### 2.3 Create the Sanity Client

Create `frontend/lib/sanity/client.ts`:

```typescript
// frontend/lib/sanity/client.ts
import { createClient, type ClientConfig } from '@sanity/client'
import imageUrlBuilder from '@sanity/image-url'
import type { SanityImageSource } from '@sanity/image-url/lib/types/types'

/**
 * Sanity Client Configuration
 * 
 * This client is used for all content fetching in the frontend.
 * It's configured with environment variables for security.
 */
const config: ClientConfig = {
  // Project ID from Sanity dashboard
  projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
  
  // Dataset name (production, development, etc.)
  dataset: process.env.NEXT_PUBLIC_SANITY_DATASET!,
  
  // API version - use a specific date for consistency
  apiVersion: process.env.NEXT_PUBLIC_SANITY_API_VERSION || '2024-01-01',
  
  // Use the CDN for better performance
  useCdn: process.env.NODE_ENV === 'production',
  
  // Enable stega for visual editing (we'll configure this in Part 4)
  stega: {
    enabled: false,
    studioUrl: '/studio',
  },
}

// Create the client
export const client = createClient(config)

/**
 * Image URL Builder
 * 
 * Generates optimized image URLs for Sanity assets.
 * This is used for responsive images and CDN optimization.
 */
const builder = imageUrlBuilder(client)

/**
 * Generate an image URL with optional transformations
 * 
 * @param source - The Sanity image asset
 * @param options - Transformation options (width, height, etc.)
 * @returns The optimized image URL
 */
export function urlForImage(source: SanityImageSource, options?: {
  width?: number
  height?: number
  quality?: number
  format?: 'webp' | 'jpg' | 'png' | 'avif'
}) {
  if (!source) {
    return null
  }

  let url = builder.image(source)

  if (options?.width) {
    url = url.width(options.width)
  }
  if (options?.height) {
    url = url.height(options.height)
  }
  if (options?.quality) {
    url = url.quality(options.quality)
  }
  if (options?.format) {
    url = url.format(options.format)
  }

  return url.url()
}

/**
 * Get the blurhash or LQIP for an image
 * LQIP = Low Quality Image Placeholder
 */
export function getImagePlaceholder(source: SanityImageSource) {
  if (!source || !source.asset) {
    return null
  }
  
  // The LQIP is stored in the metadata
  return builder.image(source)
    .width(20)
    .height(20)
    .blur(10)
    .format('webp')
    .url()
}

/**
 * Create a typed client for better TypeScript support
 * This will be used with our generated types
 */
export function getSanityClient() {
  return client
}
```

#### 2.4 Create Type Definitions

Create `frontend/lib/sanity/types.ts`:

```typescript
// frontend/lib/sanity/types.ts
import type { SanityDocument } from '@sanity/client'

/**
 * Core Content Types
 * 
 * These types represent the structure of our content.
 * They'll be enhanced with Sanity TypeGen in Step 4.
 */

// Base document with common fields
export interface BaseDocument extends SanityDocument {
  _id: string
  _createdAt: string
  _updatedAt: string
}

// Author type
export interface Author extends BaseDocument {
  name: string
  slug: { current: string }
  bio: any[] // Portable Text array
  avatar: {
    asset: any
    alt: string
  }
  socialLinks: {
    twitter?: string
    linkedin?: string
    github?: string
    personalWebsite?: string
  }
  role: string
  biographyLong?: any[]
  postCount?: number
}

// Category type
export interface Category extends BaseDocument {
  title: string
  slug: { current: string }
  description?: string
  image?: {
    asset: any
    alt: string
  }
  parentCategory?: {
    title: string
    slug: { current: string }
  }
  order: number
  postCount?: number
}

// Post type
export interface Post extends BaseDocument {
  title: string
  slug: { current: string }
  excerpt?: string
  featuredImage?: {
    asset: any
    alt: string
    caption?: string
  }
  publishedAt: string
  body: any[] // Portable Text array
  categories: Array<{
    title: string
    slug: { current: string }
  }>
  author: Author
  tags: string[]
  seo: {
    metaTitle?: string
    metaDescription?: string
    keywords?: string[]
    noIndex?: boolean
  }
  estimatedReadingTime?: number
}

// Settings type
export interface Settings extends BaseDocument {
  siteTitle: string
  siteDescription: string
  logo: {
    asset: any
    alt: string
  }
  socialLinks: {
    twitter?: string
    linkedin?: string
    github?: string
    youtube?: string
    instagram?: string
  }
  defaultSeo: {
    metaTitle?: string
    metaDescription?: string
    ogImage?: {
      asset: any
    }
  }
  contactInfo: {
    email?: string
    phone?: string
    address?: string
  }
}

// Search result type
export interface SearchResult {
  _type: 'post' | 'author' | 'category'
  _id: string
  title: string
  slug: { current: string }
  excerpt?: string
  description?: string
  image?: string
  avatar?: string
}
```

---

## Step 3: Building a Query Layer

### The Target
Create a robust query layer with error handling and caching.

### The Concept
A query layer abstracts away the complexity of fetching content. It provides clean, typed functions that your components can call without worrying about the underlying implementation.

**Real-world analogy**: Think of a query layer like a library's catalog system. You (the component) ask for books by title (query function), and the catalog system (query layer) handles the actual search, retrieval, and organization.

### The Implementation

Create `frontend/lib/sanity/queries.ts`:

```typescript
// frontend/lib/sanity/queries.ts
import { client, urlForImage, getImagePlaceholder } from './client'
import type { Post, Author, Category, Settings, SearchResult } from './types'
import { 
  postBySlugQuery,
  allPostsQuery,
  postsByCategoryQuery,
  postsByAuthorQuery,
  authorBySlugQuery,
  allAuthorsQuery,
  categoryBySlugQuery,
  allCategoriesQuery,
  settingsQuery,
  searchQuery
} from '../../../studio/queries/index'

/**
 * Error handling helper
 * Wraps queries with try-catch for graceful error handling
 */
async function fetchWithErrorHandling<T>(
  query: string,
  params?: Record<string, any>,
  errorMessage = 'Failed to fetch data'
): Promise<T | null> {
  try {
    const result = await client.fetch<T>(query, params)
    return result
  } catch (error) {
    console.error(`${errorMessage}:`, error)
    return null
  }
}

/**
 * POST QUERIES
 * ============
 */

/**
 * Get a single post by slug
 * 
 * @param slug - The post's slug
 * @returns The post or null if not found
 */
export async function getPostBySlug(slug: string): Promise<Post | null> {
  const post = await fetchWithErrorHandling<Post>(
    postBySlugQuery,
    { slug },
    `Failed to fetch post with slug: ${slug}`
  )
  
  // Process images to add optimized URLs
  if (post) {
    // Add placeholder for featured image
    if (post.featuredImage) {
      post.featuredImage.asset.url = urlForImage(post.featuredImage) || ''
      post.featuredImage.asset.placeholder = getImagePlaceholder(post.featuredImage) || ''
    }
    
    // Process body images
    if (post.body) {
      post.body = post.body.map((block: any) => {
        if (block._type === 'image' && block.asset) {
          return {
            ...block,
            url: urlForImage(block) || '',
            placeholder: getImagePlaceholder(block) || '',
          }
        }
        return block
      })
    }
  }
  
  return post
}

/**
 * Get all posts
 * 
 * @param limit - Optional limit for pagination
 * @param offset - Optional offset for pagination
 * @returns Array of posts
 */
export async function getAllPosts(limit?: number, offset?: number): Promise<Post[]> {
  let query = allPostsQuery
  
  // Add pagination if needed
  if (limit !== undefined || offset !== undefined) {
    const limitClause = limit !== undefined ? `[0...${limit}]` : ''
    const offsetClause = offset !== undefined ? `[${offset}...]` : ''
    query = query.replace(']', `${offsetClause}${limitClause}]`)
  }
  
  const posts = await fetchWithErrorHandling<Post[]>(
    query,
    undefined,
    'Failed to fetch all posts'
  )
  
  // Process images for each post
  if (posts) {
    return posts.map(post => {
      if (post.featuredImage) {
        post.featuredImage.asset.url = urlForImage(post.featuredImage) || ''
        post.featuredImage.asset.placeholder = getImagePlaceholder(post.featuredImage) || ''
      }
      return post
    })
  }
  
  return []
}

/**
 * Get posts by category
 * 
 * @param categorySlug - The category's slug
 * @param limit - Optional limit for pagination
 * @returns Array of posts in the category
 */
export async function getPostsByCategory(categorySlug: string, limit?: number): Promise<Post[]> {
  let query = postsByCategoryQuery
  
  if (limit !== undefined) {
    query = query.replace(']', `[0...${limit}]`)
  }
  
  const posts = await fetchWithErrorHandling<Post[]>(
    query,
    { categorySlug },
    `Failed to fetch posts for category: ${categorySlug}`
  )
  
  if (posts) {
    return posts.map(post => {
      if (post.featuredImage) {
        post.featuredImage.asset.url = urlForImage(post.featuredImage) || ''
      }
      return post
    })
  }
  
  return []
}

/**
 * Get posts by author
 * 
 * @param authorSlug - The author's slug
 * @param limit - Optional limit for pagination
 * @returns Array of posts by the author
 */
export async function getPostsByAuthor(authorSlug: string, limit?: number): Promise<Post[]> {
  let query = postsByAuthorQuery
  
  if (limit !== undefined) {
    query = query.replace(']', `[0...${limit}]`)
  }
  
  const posts = await fetchWithErrorHandling<Post[]>(
    query,
    { authorSlug },
    `Failed to fetch posts for author: ${authorSlug}`
  )
  
  if (posts) {
    return posts.map(post => {
      if (post.featuredImage) {
        post.featuredImage.asset.url = urlForImage(post.featuredImage) || ''
      }
      return post
    })
  }
  
  return []
}

/**
 * AUTHOR QUERIES
 * ==============
 */

/**
 * Get a single author by slug
 * 
 * @param slug - The author's slug
 * @returns The author or null if not found
 */
export async function getAuthorBySlug(slug: string): Promise<Author | null> {
  const author = await fetchWithErrorHandling<Author>(
    authorBySlugQuery,
    { slug },
    `Failed to fetch author with slug: ${slug}`
  )
  
  if (author?.avatar) {
    author.avatar.asset.url = urlForImage(author.avatar) || ''
  }
  
  return author
}

/**
 * Get all authors
 * 
 * @returns Array of authors
 */
export async function getAllAuthors(): Promise<Author[]> {
  const authors = await fetchWithErrorHandling<Author[]>(
    allAuthorsQuery,
    undefined,
    'Failed to fetch all authors'
  )
  
  if (authors) {
    return authors.map(author => {
      if (author.avatar) {
        author.avatar.asset.url = urlForImage(author.avatar) || ''
      }
      return author
    })
  }
  
  return []
}

/**
 * CATEGORY QUERIES
 * ================
 */

/**
 * Get a single category by slug
 * 
 * @param slug - The category's slug
 * @returns The category or null if not found
 */
export async function getCategoryBySlug(slug: string): Promise<Category | null> {
  const category = await fetchWithErrorHandling<Category>(
    categoryBySlugQuery,
    { slug },
    `Failed to fetch category with slug: ${slug}`
  )
  
  if (category?.image) {
    category.image.asset.url = urlForImage(category.image) || ''
  }
  
  return category
}

/**
 * Get all categories
 * 
 * @returns Array of categories
 */
export async function getAllCategories(): Promise<Category[]> {
  const categories = await fetchWithErrorHandling<Category[]>(
    allCategoriesQuery,
    undefined,
    'Failed to fetch all categories'
  )
  
  if (categories) {
    return categories.map(category => {
      if (category.image) {
        category.image.asset.url = urlForImage(category.image) || ''
      }
      return category
    })
  }
  
  return []
}

/**
 * SETTINGS QUERY
 * ==============
 */

/**
 * Get site settings
 * 
 * @returns The site settings or null if not found
 */
export async function getSettings(): Promise<Settings | null> {
  const settings = await fetchWithErrorHandling<Settings>(
    settingsQuery,
    undefined,
    'Failed to fetch settings'
  )
  
  if (settings?.logo) {
    settings.logo.asset.url = urlForImage(settings.logo) || ''
  }
  
  return settings
}

/**
 * SEARCH QUERY
 * ============
 */

/**
 * Search across all content types
 * 
 * @param searchTerm - The term to search for
 * @returns Array of search results
 */
export async function searchContent(searchTerm: string): Promise<SearchResult[]> {
  if (!searchTerm || searchTerm.length < 2) {
    return []
  }
  
  const results = await fetchWithErrorHandling<SearchResult[]>(
    searchQuery,
    { searchTerm: `*${searchTerm}*` },
    `Failed to search for: ${searchTerm}`
  )
  
  return results || []
}

/**
 * CACHE REVALIDATION
 * ==================
 */

/**
 * Revalidate specific content by ID
 * This triggers Next.js ISR (Incremental Static Regeneration)
 */
export async function revalidateContent(id: string): Promise<void> {
  // This will be implemented with Next.js Server Actions
  // in Part 5
  console.log(`Revalidating content: ${id}`)
}

/**
 * Revalidate all content
 * Used for global content changes
 */
export async function revalidateAll(): Promise<void> {
  // This will be implemented with Next.js Server Actions
  // in Part 5
  console.log('Revalidating all content')
}
```

---

## Step 4: Generating TypeScript Types with Sanity TypeGen

### The Target
Generate type-safe TypeScript types from your GROQ queries.

### The Concept
Sanity TypeGen automatically generates TypeScript types based on your GROQ queries. Instead of manually defining types (which can go out of sync), TypeGen ensures your types are always correct.

**Real-world analogy**: Sanity TypeGen is like an automatic translator. You write queries in GROQ (English), and TypeGen generates TypeScript types (Spanish). As your queries change, the types update automatically.

### The Implementation

#### 4.1 Install Sanity TypeGen

```bash
# Navigate to the project root
cd ../..  # Back to mastering-sanity-cms

# Install TypeGen globally
npm install -g @sanity/typegen

# Or install as a dev dependency
npm install -D @sanity/typegen
```

#### 4.2 Configure TypeGen

Create `frontend/sanity-typegen.json`:

```json
{
  "path": "lib/sanity/queries.ts",
  "schema": "../studio/sanity.config.ts",
  "generates": "lib/sanity/types.generated.ts",
  "overloadClientMethods": true
}
```

**What this configuration does**:
- `path`: Where to find your queries
- `schema`: Your Sanity schema file (for type inference)
- `generates`: Where to output the generated types
- `overloadClientMethods`: Enhances the client with typed methods

#### 4.3 Add TypeGen Script

Update `frontend/package.json`:

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "typegen": "sanity typegen generate ./sanity-typegen.json"
  }
}
```

#### 4.4 Generate Types

```bash
cd frontend

# Generate the types
npm run typegen
# or
sanity typegen generate ./sanity-typegen.json
```

You should see output like:
```
✓ Generated types in lib/sanity/types.generated.ts
✓ Found 12 queries
✓ Types are ready to use
```

### The Verification

#### 4.5 Use the Generated Types

Update `frontend/lib/sanity/queries.ts` to use generated types:

```typescript
// frontend/lib/sanity/queries.ts
import { client, urlForImage, getImagePlaceholder } from './client'
import type {
  Post,
  Author,
  Category,
  Settings,
  SearchResult
} from './types.generated'  // Use generated types

// Your query functions remain the same,
// but now they're fully type-safe!
```

### The Verification

1. **Check the generated file**: Open `frontend/lib/sanity/types.generated.ts`
2. **Verify types**: You should see TypeScript interfaces matching your content
3. **Test type safety**: Try modifying a query and see TypeScript catch type errors

**Your code is now fully type-safe!**

---

## Step 5: Advanced GROQ Techniques

### The Target
Master advanced GROQ patterns for complex content needs.

### The Concept
Basic GROQ handles simple queries. Advanced GROQ handles relationships, aggregations, and complex data shapes. Think of it as moving from basic arithmetic to algebra.

### The Implementation

#### 5.1 Create Advanced Queries

Add these to `studio/queries/index.ts`:

```typescript
// studio/queries/index.ts

/**
 * ADVANCED QUERIES
 * ================
 * Complex queries for specific use cases
 */

// Get related posts (same categories, excluding current)
export const relatedPostsQuery = `
  *[_type == "post" && _id != $postId && count(categories[@._ref in $categoryIds]) > 0] | order(publishedAt desc) [0..2] {
    _id,
    title,
    slug,
    excerpt,
    "publishedAt": publishedAt,
    featuredImage {
      asset-> {
        url,
        metadata {
          lqip
        }
      },
      alt
    },
    "author": author-> {
      name,
      slug
    }
  }
`

// Get latest posts with custom fields
export const latestPostsQuery = `
  *[_type == "post"] | order(publishedAt desc) [0..5] {
    _id,
    title,
    slug,
    "publishedAt": publishedAt,
    featuredImage {
      asset-> {
        url
      },
      alt
    },
    "excerptText": coalesce(excerpt, pt::text(body[0..3])),
    "authorName": author->name
  }
`

// Get popular posts (by engagement, if you have analytics)
export const popularPostsQuery = `
  *[_type == "post"] {
    _id,
    title,
    slug,
    "publishedAt": publishedAt,
    "views": 0,  // Replace with actual analytics
    "comments": 0,  // Replace with actual comments count
    "engagementScore": 0  // Calculated score
  } | order(engagementScore desc) [0..10]
`

// Get posts grouped by category
export const postsGroupedByCategoryQuery = `
  *[_type == "post"] {
    title,
    slug,
    categories[]-> {
      title,
      slug
    }
  }
`

// Get hierarchical categories (parent-child structure)
export const hierarchicalCategoriesQuery = `
  *[_type == "category"] {
    _id,
    title,
    slug,
    description,
    "childCategories": *[_type == "category" && parentCategory._ref == ^._id] {
      _id,
      title,
      slug,
      description
    }
  }
`

// Get content calendar (posts by month)
export const contentCalendarQuery = `
  *[_type == "post"] {
    title,
    "month": publishedAt[0..6],
    "year": publishedAt[0..3]
  } | order(publishedAt asc)
`

// Get authors with their most recent post
export const authorsWithRecentPostQuery = `
  *[_type == "author"] {
    name,
    slug,
    avatar {
      asset-> {
        url
      },
      alt
    },
    "recentPost": *[_type == "post" && references(^._id)] | order(publishedAt desc) [0] {
      title,
      slug,
      publishedAt
    }
  }
`

// Advanced filtering with multiple conditions
export const advancedFilterQuery = `
  *[_type == "post"] {
    _id,
    title,
    publishedAt,
    "authorName": author->name,
    "categoryCount": count(categories),
    "hasImage": defined(featuredImage),
    "contentLength": length(pt::text(body)),
    "isRecent": publishedAt > "2024-01-01"
  } | order(publishedAt desc)
`

// Conditional fields
export const conditionalFieldsQuery = `
  *[_type == "post"] {
    _id,
    title,
    "bodyText": pt::text(body),
    "shortBody": pt::text(body[0..5]),
    "hasBody": count(body) > 0
  }
`
```

#### 5.2 Add Utility Functions for Common Patterns

Create `frontend/lib/sanity/utils.ts`:

```typescript
// frontend/lib/sanity/utils.ts
import { client } from './client'

/**
 * GROQ Utility Functions
 * Helpers for common query patterns
 */

/**
 * Get a single document by ID
 */
export function getDocumentById<T>(id: string): Promise<T | null> {
  return client.fetch<T>(
    `*[_id == $id][0]`,
    { id }
  )
}

/**
 * Get documents that reference a specific document
 */
export function getReferencingDocuments<T>(
  id: string,
  types?: string[]
): Promise<T[]> {
  const typeFilter = types ? ` && _type in $types` : ''
  return client.fetch<T[]>(
    `*[references($id)${typeFilter}]`,
    { id, types }
  )
}

/**
 * Get all documents of a type with pagination
 */
export function getAllDocuments<T>(
  type: string,
  page = 1,
  pageSize = 20
): Promise<T[]> {
  const start = (page - 1) * pageSize
  const end = start + pageSize - 1
  return client.fetch<T[]>(
    `*[_type == $type] [${start}...${end}]`,
    { type }
  )
}

/**
 * Count documents of a type
 */
export function countDocuments(type: string): Promise<number> {
  return client.fetch<number>(
    `count(*[_type == $type])`,
    { type }
  )
}

/**
 * Get document with all references expanded (depth: 2)
 */
export function getDocumentWithReferences<T>(
  id: string
): Promise<T | null> {
  return client.fetch<T>(
    `*[_id == $id][0]{
      ...,
      "references": *[references(^._id)]{
        _id,
        _type,
        title,
        slug
      }
    }`,
    { id }
  )
}

/**
 * Format date for GROQ queries
 */
export function formatDateForGROQ(date: Date): string {
  return date.toISOString().split('T')[0]
}

/**
 * Create a date range filter for GROQ
 */
export function dateRangeFilter(
  field: string,
  startDate?: Date,
  endDate?: Date
): string {
  const conditions = []
  if (startDate) {
    conditions.push(`${field} >= "${formatDateForGROQ(startDate)}"`)
  }
  if (endDate) {
    conditions.push(`${field} <= "${formatDateForGROQ(endDate)}"`)
  }
  return conditions.length ? ` && (${conditions.join(' && ')})` : ''
}
```

#### 5.3 Add Query Function with Date Range

Add to `frontend/lib/sanity/queries.ts`:

```typescript
// frontend/lib/sanity/queries.ts

/**
 * Get posts in a date range
 */
export async function getPostsInDateRange(
  startDate?: Date,
  endDate?: Date
): Promise<Post[]> {
  const dateFilter = dateRangeFilter('publishedAt', startDate, endDate)
  const query = `
    *[_type == "post"${dateFilter}] | order(publishedAt desc) {
      _id,
      title,
      slug,
      excerpt,
      "publishedAt": publishedAt,
      featuredImage {
        asset-> {
          url
        },
        alt
      },
      "author": author-> {
        name,
        slug
      }
    }
  `
  
  const posts = await fetchWithErrorHandling<Post[]>(
    query,
    undefined,
    `Failed to fetch posts in date range`
  )
  
  if (posts) {
    return posts.map(post => {
      if (post.featuredImage) {
        post.featuredImage.asset.url = urlForImage(post.featuredImage) || ''
      }
      return post
    })
  }
  
  return []
}
```

### The Verification

1. **Test advanced queries in Vision tool**
2. **Use the query layer functions in your components**
3. **Verify complex data shapes return correctly**
4. **Check performance with large datasets**

**You now have a complete, type-safe query layer!**

---

## Part 2 Summary

### What We've Accomplished

In this part, we:

✅ Learned GROQ fundamentals and syntax
✅ Set up the Sanity client with proper configuration
✅ Created a complete query layer with error handling
✅ Generated TypeScript types with Sanity TypeGen
✅ Mastered advanced GROQ techniques
✅ Built utilities for common query patterns
✅ Created date range queries and pagination

### Key Concepts You've Mastered

1. **GROQ Syntax**: Filtering, projections, ordering, and pagination
2. **Relationships**: Traversing references and nested documents
3. **Type Safety**: Generated types ensure compile-time safety
4. **Query Organization**: Centralized, reusable queries
5. **Error Handling**: Graceful failure and debugging
6. **Performance**: Optimized queries and caching
7. **Advanced Patterns**: Complex filtering, aggregations, and computed fields

### Performance Tips

| Pattern | Why It Matters |
|---------|----------------|
| **Limit results** | Reduce payload size and query time |
| **Project only needed fields** | Return less data |
| **Use indexes** | Leverage Sanity's built-in indexing |
| **Avoid deep traversals** | Keep queries shallow when possible |
| **Use CDN** | Cache responses globally |
| **Batch queries** | Reduce round trips |

### What's Next

In **Part 3: Extending and Customizing Sanity Studio**, you'll transform the Studio into a tailored editorial environment. You'll learn to:

- Create custom input components
- Build dashboard widgets
- Develop custom document actions
- Implement AI-assisted workflows
- Create reusable plugins
- Integrate external APIs

**Estimated time for Part 3**: 3-4 hours

### Practice Exercises

1. **Write a query** that returns all posts with at least one category
2. **Create a query** that returns authors with their most recent 3 posts
3. **Build a search query** that sorts by relevance
4. **Add a query** for featured posts
5. **Create a query** for post statistics (count by month, author, category)

### Resources for Further Learning

- [GROQ Documentation](https://www.sanity.io/docs/groq)
- [GROQ Cheat Sheet](https://www.sanity.io/docs/query-cheat-sheet)
- [Sanity TypeGen Documentation](https://www.sanity.io/docs/sanity-typegen)
- [Sanity Client Documentation](https://www.sanity.io/docs/js-client)

---

You've built the content models and mastered queries. Now it's time to make the Studio truly your own. In Part 3, we'll customize every aspect of the Studio to create a tailored editorial experience.

Let's continue building!
