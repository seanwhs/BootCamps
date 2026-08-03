# Primer 4: Frontend Integration with React & Next.js

Welcome to the sixth primer. You've built your Studio, created content models, and mastered GROQ. Now it's time to bring your content to life on the frontend. In this primer, we'll integrate Sanity with React and Next.js to build a modern, performant website.

---

## Why React + Next.js?

Next.js is the most popular framework for building React applications, and it's particularly well-suited for headless CMS integration:

- **Server Components**: Fetch content on the server for better performance and SEO
- **ISR (Incremental Static Regeneration)**: Update content without redeploying
- **Image Optimization**: Automatic image optimization with Next.js Image component
- **API Routes**: Create API endpoints for your content
- **App Router**: Modern routing with built-in support for loading states and error handling

**Real-world analogy**: Think of Next.js as a high-performance delivery service. It takes your content from Sanity (the warehouse) and delivers it to users (the customers) as fast and efficiently as possible.

---

## Step 1: Setting Up the Project

### Create a Next.js Project

```bash
# Create a new Next.js project
npx create-next-app@latest my-sanity-site --typescript --tailwind --app

# Navigate to the project
cd my-sanity-site
```

### Install Sanity Dependencies

```bash
# Install Sanity client and related packages
npm install @sanity/client @sanity/image-url @portabletext/react

# Install types for development
npm install -D @sanity/types
```

### Set Up Environment Variables

Create `.env.local`:

```env
NEXT_PUBLIC_SANITY_PROJECT_ID=your-project-id
NEXT_PUBLIC_SANITY_DATASET=production
NEXT_PUBLIC_SANITY_API_VERSION=2024-01-01
```

---

## Step 2: Configure the Sanity Client

Create `lib/sanity/client.ts`:

```typescript
// lib/sanity/client.ts
import { createClient } from '@sanity/client'
import imageUrlBuilder from '@sanity/image-url'

// Sanity client configuration
export const client = createClient({
  projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
  dataset: process.env.NEXT_PUBLIC_SANITY_DATASET!,
  apiVersion: process.env.NEXT_PUBLIC_SANITY_API_VERSION || '2024-01-01',
  useCdn: process.env.NODE_ENV === 'production',
})

// Image URL builder
const builder = imageUrlBuilder(client)

export function urlFor(source: any) {
  return builder.image(source)
}
```

---

## Step 3: Define Types

Create `lib/sanity/types.ts`:

```typescript
// lib/sanity/types.ts
import { SanityDocument } from 'sanity'

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
  bio?: string
  avatar?: {
    asset: any
    alt: string
  }
  socialLinks?: {
    twitter?: string
    linkedin?: string
    github?: string
  }
}

// Category type
export interface Category extends BaseDocument {
  title: string
  slug: { current: string }
  description?: string
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
  body: any[]
  author: Author
  categories: Category[]
  seo?: {
    metaTitle?: string
    metaDescription?: string
    noIndex?: boolean
  }
}
```

---

## Step 4: Write GROQ Queries

Create `lib/sanity/queries.ts`:

```typescript
// lib/sanity/queries.ts
import { client } from './client'
import type { Post, Author, Category } from './types'

// --- Queries ---

export const postBySlugQuery = `
  *[_type == "post" && slug.current == $slug][0] {
    _id,
    title,
    slug,
    excerpt,
    publishedAt,
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
      }
    },
    "author": author-> {
      _id,
      name,
      slug,
      bio,
      avatar {
        asset-> {
          url
        },
        alt
      },
      socialLinks
    },
    "categories": categories[]-> {
      _id,
      title,
      slug
    },
    seo
  }
`

export const allPostsQuery = `
  *[_type == "post"] | order(publishedAt desc) {
    _id,
    title,
    slug,
    excerpt,
    publishedAt,
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
    "author": author-> {
      name,
      slug
    },
    "categories": categories[]-> {
      title,
      slug
    }
  }
`

export const postsByCategoryQuery = `
  *[_type == "post" && $categorySlug in categories[]->slug.current] | order(publishedAt desc) {
    _id,
    title,
    slug,
    excerpt,
    publishedAt,
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

export const authorBySlugQuery = `
  *[_type == "author" && slug.current == $slug][0] {
    _id,
    name,
    slug,
    bio,
    avatar {
      asset-> {
        url
      },
      alt
    },
    socialLinks,
    "posts": *[_type == "post" && references(^._id)] | order(publishedAt desc) {
      _id,
      title,
      slug,
      excerpt,
      publishedAt,
      featuredImage {
        asset-> {
          url
        },
        alt
      }
    }
  }
`

export const allAuthorsQuery = `
  *[_type == "author"] | order(name asc) {
    _id,
    name,
    slug,
    bio,
    avatar {
      asset-> {
        url
      },
      alt
    },
    "postCount": count(*[_type == "post" && references(^._id)])
  }
`

export const categoryBySlugQuery = `
  *[_type == "category" && slug.current == $slug][0] {
    _id,
    title,
    slug,
    description,
    "posts": *[_type == "post" && references(^._id)] | order(publishedAt desc) {
      _id,
      title,
      slug,
      excerpt,
      publishedAt,
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
  }
`

export const allCategoriesQuery = `
  *[_type == "category"] | order(title asc) {
    _id,
    title,
    slug,
    description,
    "postCount": count(*[_type == "post" && references(^._id)])
  }
`

// --- Query Functions ---

export async function getPostBySlug(slug: string): Promise<Post | null> {
  return client.fetch(postBySlugQuery, { slug })
}

export async function getAllPosts(): Promise<Post[]> {
  return client.fetch(allPostsQuery)
}

export async function getPostsByCategory(categorySlug: string): Promise<Post[]> {
  return client.fetch(postsByCategoryQuery, { categorySlug })
}

export async function getAuthorBySlug(slug: string): Promise<Author | null> {
  return client.fetch(authorBySlugQuery, { slug })
}

export async function getAllAuthors(): Promise<Author[]> {
  return client.fetch(allAuthorsQuery)
}

export async function getCategoryBySlug(slug: string): Promise<Category | null> {
  return client.fetch(categoryBySlugQuery, { slug })
}

export async function getAllCategories(): Promise<Category[]> {
  return client.fetch(allCategoriesQuery)
}
```

---

## Step 5: Build the Portable Text Components

Create `components/PortableText.tsx`:

```tsx
// components/PortableText.tsx
import { PortableText as PortableTextComponent } from '@portabletext/react'
import Image from 'next/image'
import Link from 'next/link'
import { urlFor } from '@/lib/sanity/client'

// Custom components for rendering Portable Text
const components = {
  block: {
    h1: ({ children }: any) => <h1 className="text-4xl font-bold mt-8 mb-4">{children}</h1>,
    h2: ({ children }: any) => <h2 className="text-3xl font-bold mt-6 mb-3">{children}</h2>,
    h3: ({ children }: any) => <h3 className="text-2xl font-bold mt-4 mb-2">{children}</h3>,
    h4: ({ children }: any) => <h4 className="text-xl font-bold mt-3 mb-1">{children}</h4>,
    normal: ({ children }: any) => <p className="mb-4 leading-relaxed">{children}</p>,
    blockquote: ({ children }: any) => (
      <blockquote className="border-l-4 border-gray-300 pl-4 italic my-4">
        {children}
      </blockquote>
    ),
  },
  list: {
    bullet: ({ children }: any) => <ul className="list-disc pl-6 mb-4 space-y-1">{children}</ul>,
    number: ({ children }: any) => <ol className="list-decimal pl-6 mb-4 space-y-1">{children}</ol>,
  },
  listItem: {
    bullet: ({ children }: any) => <li className="mb-1">{children}</li>,
    number: ({ children }: any) => <li className="mb-1">{children}</li>,
  },
  marks: {
    strong: ({ children }: any) => <strong className="font-bold">{children}</strong>,
    em: ({ children }: any) => <em className="italic">{children}</em>,
    code: ({ children }: any) => (
      <code className="bg-gray-100 px-1 py-0.5 rounded text-sm font-mono">
        {children}
      </code>
    ),
    link: ({ value, children }: any) => {
      const href = value?.href || '#'
      const isExternal = href.startsWith('http')
      return (
        <a
          href={href}
          target={isExternal ? '_blank' : undefined}
          rel={isExternal ? 'noopener noreferrer' : undefined}
          className="text-blue-600 hover:underline"
        >
          {children}
        </a>
      )
    },
  },
  types: {
    image: ({ value }: any) => {
      if (!value?.asset) {
        return null
      }
      return (
        <figure className="my-8">
          <div className="relative aspect-video rounded-lg overflow-hidden">
            <Image
              src={urlFor(value).url()}
              alt={value.alt || ''}
              fill
              className="object-cover"
              placeholder="blur"
              blurDataURL={value.asset.metadata?.lqip}
            />
          </div>
          {value.caption && (
            <figcaption className="text-center text-sm text-gray-500 mt-2">
              {value.caption}
            </figcaption>
          )}
        </figure>
      )
    },
    code: ({ value }: any) => {
      if (!value?.code) {
        return null
      }
      return (
        <div className="my-4 rounded-lg overflow-hidden">
          <div className="bg-gray-800 text-white px-4 py-2 text-sm font-mono flex justify-between">
            <span>{value.language || 'code'}</span>
            <button
              className="text-gray-400 hover:text-white"
              onClick={() => navigator.clipboard.writeText(value.code)}
            >
              Copy
            </button>
          </div>
          <pre className="bg-gray-900 text-white p-4 overflow-x-auto">
            <code>{value.code}</code>
          </pre>
        </div>
      )
    },
  },
}

export function PortableText({ value }: { value: any }) {
  return <PortableTextComponent value={value} components={components} />
}
```

---

## Step 6: Build the Pages

### Blog Post Detail Page

Create `app/posts/[slug]/page.tsx`:

```tsx
// app/posts/[slug]/page.tsx
import { getPostBySlug, getAllPosts } from '@/lib/sanity/queries'
import { PortableText } from '@/components/PortableText'
import Image from 'next/image'
import Link from 'next/link'
import { notFound } from 'next/navigation'
import { Metadata } from 'next'
import { urlFor } from '@/lib/sanity/client'

// Generate all static pages at build time
export async function generateStaticParams() {
  const posts = await getAllPosts()
  return posts.map((post) => ({
    slug: post.slug.current,
  }))
}

// Generate metadata for SEO
export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  const post = await getPostBySlug(params.slug)
  if (!post) return { title: 'Post Not Found' }

  return {
    title: post.seo?.metaTitle || post.title,
    description: post.seo?.metaDescription || post.excerpt || '',
    openGraph: {
      title: post.seo?.metaTitle || post.title,
      description: post.seo?.metaDescription || post.excerpt || '',
      images: post.featuredImage ? [urlFor(post.featuredImage).url()] : [],
    },
  }
}

export default async function PostPage({ params }: { params: { slug: string } }) {
  const post = await getPostBySlug(params.slug)

  if (!post) {
    notFound()
  }

  const publishDate = new Date(post.publishedAt).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })

  // Calculate reading time
  const readingTime = (body: any[]) => {
    const text = body
      .filter((block: any) => block._type === 'block')
      .map((block: any) => block.children?.map((child: any) => child.text || '').join('') || '')
      .join(' ')
    const words = text.split(/\s+/).length
    return Math.ceil(words / 200)
  }

  return (
    <article className="max-w-4xl mx-auto px-4 py-8">
      <header className="mb-8">
        <div className="flex gap-2 flex-wrap mb-4">
          {post.categories.map((category) => (
            <Link
              key={category._id}
              href={`/categories/${category.slug.current}`}
              className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm hover:bg-blue-200"
            >
              {category.title}
            </Link>
          ))}
        </div>

        <h1 className="text-4xl md:text-5xl font-bold mb-4">{post.title}</h1>

        <div className="flex flex-wrap items-center gap-4 text-gray-600">
          {post.author && (
            <Link href={`/authors/${post.author.slug.current}`} className="flex items-center gap-2">
              {post.author.avatar && (
                <Image
                  src={urlFor(post.author.avatar).url()}
                  alt={post.author.name}
                  width={40}
                  height={40}
                  className="rounded-full"
                />
              )}
              <span className="hover:text-blue-600">{post.author.name}</span>
            </Link>
          )}
          <span>•</span>
          <time dateTime={post.publishedAt}>{publishDate}</time>
          <span>•</span>
          <span>{readingTime(post.body)} min read</span>
        </div>
      </header>

      {post.featuredImage && (
        <div className="relative aspect-video rounded-xl overflow-hidden mb-8">
          <Image
            src={urlFor(post.featuredImage).url()}
            alt={post.featuredImage.alt || 'Featured image'}
            fill
            className="object-cover"
            priority
          />
          {post.featuredImage.caption && (
            <figcaption className="absolute bottom-0 left-0 right-0 bg-black/50 text-white p-2 text-sm text-center">
              {post.featuredImage.caption}
            </figcaption>
          )}
        </div>
      )}

      {post.excerpt && (
        <div className="text-xl text-gray-600 mb-8 border-l-4 border-gray-300 pl-4 italic">
          {post.excerpt}
        </div>
      )}

      <div className="prose prose-lg max-w-none">
        <PortableText value={post.body} />
      </div>
    </article>
  )
}
```

### Blog Listing Page

Create `app/posts/page.tsx`:

```tsx
// app/posts/page.tsx
import { getAllPosts } from '@/lib/sanity/queries'
import Link from 'next/link'
import Image from 'next/image'
import { urlFor } from '@/lib/sanity/client'

export const metadata = {
  title: 'All Posts',
  description: 'Browse all blog posts',
}

export default async function PostsPage() {
  const posts = await getAllPosts()

  return (
    <div className="max-w-6xl mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-8">All Posts</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {posts.map((post) => (
          <article key={post._id} className="bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow">
            {post.featuredImage && (
              <Link href={`/posts/${post.slug.current}`} className="block relative aspect-video">
                <Image
                  src={urlFor(post.featuredImage).url()}
                  alt={post.featuredImage.alt || ''}
                  fill
                  className="object-cover hover:scale-105 transition-transform"
                />
              </Link>
            )}
            <div className="p-6">
              <div className="flex gap-2 flex-wrap mb-3">
                {post.categories.slice(0, 2).map((category) => (
                  <span key={category._id} className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded-full">
                    {category.title}
                  </span>
                ))}
              </div>
              <Link href={`/posts/${post.slug.current}`}>
                <h2 className="text-xl font-bold mb-2 hover:text-blue-600 transition-colors">
                  {post.title}
                </h2>
              </Link>
              {post.excerpt && (
                <p className="text-gray-600 mb-4 line-clamp-3">{post.excerpt}</p>
              )}
              <div className="flex items-center justify-between text-sm text-gray-500">
                <div className="flex items-center gap-2">
                  {post.author && <span>{post.author.name}</span>}
                </div>
                <time dateTime={post.publishedAt}>
                  {new Date(post.publishedAt).toLocaleDateString()}
                </time>
              </div>
            </div>
          </article>
        ))}
      </div>
    </div>
  )
}
```

### Author Page

Create `app/authors/[slug]/page.tsx`:

```tsx
// app/authors/[slug]/page.tsx
import { getAuthorBySlug, getAllAuthors } from '@/lib/sanity/queries'
import Image from 'next/image'
import Link from 'next/link'
import { notFound } from 'next/navigation'
import { urlFor } from '@/lib/sanity/client'

export async function generateStaticParams() {
  const authors = await getAllAuthors()
  return authors.map((author) => ({
    slug: author.slug.current,
  }))
}

export default async function AuthorPage({ params }: { params: { slug: string } }) {
  const author = await getAuthorBySlug(params.slug)

  if (!author) {
    notFound()
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <div className="flex items-center gap-6 mb-8">
        {author.avatar && (
          <Image
            src={urlFor(author.avatar).url()}
            alt={author.avatar.alt || author.name}
            width={120}
            height={120}
            className="rounded-full"
          />
        )}
        <div>
          <h1 className="text-4xl font-bold">{author.name}</h1>
          {author.bio && <p className="text-gray-600 mt-2">{author.bio}</p>}
          {author.socialLinks && (
            <div className="flex gap-4 mt-4">
              {author.socialLinks.twitter && (
                <a href={author.socialLinks.twitter} target="_blank" rel="noopener noreferrer">
                  Twitter
                </a>
              )}
              {author.socialLinks.linkedin && (
                <a href={author.socialLinks.linkedin} target="_blank" rel="noopener noreferrer">
                  LinkedIn
                </a>
              )}
              {author.socialLinks.github && (
                <a href={author.socialLinks.github} target="_blank" rel="noopener noreferrer">
                  GitHub
                </a>
              )}
            </div>
          )}
        </div>
      </div>

      {author.posts && author.posts.length > 0 && (
        <div>
          <h2 className="text-2xl font-bold mb-4">Posts by {author.name}</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {author.posts.map((post) => (
              <Link key={post._id} href={`/posts/${post.slug.current}`}>
                <div className="bg-white rounded-lg shadow p-4 hover:shadow-lg transition-shadow">
                  <h3 className="font-semibold hover:text-blue-600">{post.title}</h3>
                  <time className="text-sm text-gray-500">
                    {new Date(post.publishedAt).toLocaleDateString()}
                  </time>
                </div>
              </Link>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
```

---

## Step 7: Optimize Images

### Custom Image Component

Create `components/Image.tsx`:

```tsx
// components/Image.tsx
import Image from 'next/image'
import { urlFor } from '@/lib/sanity/client'

interface SanityImageProps {
  image: any
  alt: string
  width?: number
  height?: number
  className?: string
  priority?: boolean
}

export function SanityImage({
  image,
  alt,
  width,
  height,
  className,
  priority = false,
}: SanityImageProps) {
  if (!image) return null

  const imageUrl = urlFor(image).url()
  const metadata = image.asset?.metadata

  return (
    <Image
      src={imageUrl}
      alt={alt || ''}
      width={width || metadata?.dimensions?.width || 800}
      height={height || metadata?.dimensions?.height || 600}
      className={className}
      priority={priority}
      placeholder="blur"
      blurDataURL={metadata?.lqip}
    />
  )
}
```

---

## Step 8: Add Incremental Static Regeneration

Update your page to use ISR:

```tsx
// app/posts/[slug]/page.tsx
export const revalidate = 3600 // Revalidate every hour

// Or use on-demand revalidation with tags
export const dynamic = 'force-static'
export const revalidate = false // Disable automatic revalidation
```

Add revalidation API:

```tsx
// app/api/revalidate/route.ts
import { revalidateTag } from 'next/cache'
import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  const body = await request.json()
  const { tag } = body

  if (!tag) {
    return NextResponse.json({ error: 'Tag required' }, { status: 400 })
  }

  revalidateTag(tag)

  return NextResponse.json({ revalidated: true })
}
```

---

## Summary

In this primer, you've learned how to:

✅ Set up a Next.js project with Sanity
✅ Configure the Sanity client
✅ Write GROQ queries for different use cases
✅ Build Portable Text components
✅ Create dynamic blog post pages
✅ Build author and category pages
✅ Optimize images with Sanity CDN
✅ Implement Incremental Static Regeneration

**Your frontend is now ready to display content from Sanity!**
