# Part 4: Real-Time Content, Visual Editing, and Production Workflows

Welcome to Part 4! You've built a robust Studio with customizations and AI-powered workflows. Now it's time to bring real-time collaboration and visual editing to your content platform. In this part, we'll implement live content updates, preview environments, and production-ready workflows that will transform how your editorial team works.

By the end of this part, you'll have:
- Real-time content updates with the Live Content API
- Visual editing with the Presentation Tool
- Draft Mode for previewing unpublished content
- Stega encoding for secure visual editing
- Content releases and publishing workflows
- Production deployment strategies with caching and revalidation

Let's build the ultimate real-time content experience.

---

## Step 1: Setting Up the Live Content API

### The Target
Enable real-time content updates using Sanity's Live Content API.

### The Concept
The Live Content API enables real-time synchronization between the Studio and your frontend. Think of it like a live news ticker—when content changes in the Studio, it instantly updates on your website without refreshing the page.

**Real-world analogy**: The Live Content API is like a walkie-talkie between your editors and your website. When an editor makes a change, the website hears it instantly and updates accordingly.

### The Implementation

#### 1.1 Update the Sanity Client Configuration

Update `frontend/lib/sanity/client.ts` to enable live queries:

```typescript
// frontend/lib/sanity/client.ts
import { createClient, type ClientConfig, type QueryParams } from '@sanity/client'
import imageUrlBuilder from '@sanity/image-url'
import type { SanityImageSource } from '@sanity/image-url/lib/types/types'
import { useLiveQuery } from '@sanity/preview-kit'

/**
 * Sanity Client Configuration
 * 
 * This client is used for all content fetching in the frontend.
 * It's configured with environment variables for security.
 * 
 * The Live Content API is enabled when stega is active.
 */
const config: ClientConfig = {
  projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
  dataset: process.env.NEXT_PUBLIC_SANITY_DATASET!,
  apiVersion: process.env.NEXT_PUBLIC_SANITY_API_VERSION || '2024-01-01',
  useCdn: process.env.NODE_ENV === 'production' && !process.env.NEXT_PUBLIC_SANITY_USE_LIVE,
  
  // Enable stega for live content and visual editing
  stega: {
    enabled: process.env.NEXT_PUBLIC_SANITY_USE_LIVE === 'true',
    studioUrl: process.env.NEXT_PUBLIC_SANITY_STUDIO_URL || '/studio',
  },
}

// Create the base client
export const client = createClient(config)

/**
 * Live Client
 * 
 * A client configured for live content updates.
 * This client uses the Live Content API for real-time updates.
 */
export const liveClient = createClient({
  ...config,
  useCdn: false,
  stega: {
    enabled: true,
    studioUrl: process.env.NEXT_PUBLIC_SANITY_STUDIO_URL || '/studio',
  },
})

/**
 * Image URL Builder
 * Generates optimized image URLs for Sanity assets.
 */
const builder = imageUrlBuilder(client)

/**
 * Generate an image URL with optional transformations
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
 */
export function getImagePlaceholder(source: SanityImageSource) {
  if (!source || !source.asset) {
    return null
  }
  
  return builder.image(source)
    .width(20)
    .height(20)
    .blur(10)
    .format('webp')
    .url()
}

/**
 * Use Live Query Hook
 * 
 * A React hook that subscribes to live content updates.
 * Returns the current data and a loading state.
 * 
 * @param initialData - Initial data from server
 * @param query - GROQ query to execute
 * @param params - Query parameters
 * @returns { data, loading, error }
 */
export function useLiveQueryHook<T>(
  initialData: T | null,
  query: string,
  params?: QueryParams
): { data: T | null; loading: boolean; error: Error | null } {
  const [data, setData] = useState<T | null>(initialData)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    if (!query) return

    setLoading(true)
    
    // Subscribe to live updates
    const subscription = liveClient
      .listen(query, params)
      .subscribe({
        next: (update) => {
          // Update data when content changes
          if (update.result) {
            setData(update.result as T)
          }
          setLoading(false)
        },
        error: (err) => {
          setError(err)
          setLoading(false)
        },
      })

    // Cleanup subscription
    return () => subscription.unsubscribe()
  }, [query, JSON.stringify(params)])

  return { data, loading, error }
}
```

#### 1.2 Create Live Query Components

Create `frontend/components/PostLiveView.tsx`:

```typescript
// frontend/components/PostLiveView.tsx
'use client'

import React, { useState, useEffect } from 'react'
import { useLiveQueryHook, liveClient } from '@/lib/sanity/client'
import { PortableText } from '@portabletext/react'
import Image from 'next/image'

interface Post {
  _id: string
  title: string
  slug: { current: string }
  excerpt?: string
  featuredImage?: {
    asset: {
      url: string
      metadata: {
        lqip: string
        dimensions: { width: number; height: number }
      }
    }
    alt: string
    caption?: string
  }
  body: any[]
  publishedAt: string
  author: {
    name: string
    slug: { current: string }
    avatar?: {
      asset: { url: string }
      alt: string
    }
  }
  categories: Array<{ title: string; slug: { current: string } }>
}

/**
 * Post Live View Component
 * 
 * Displays a post with live content updates.
 * When content changes in the Studio, the page updates automatically.
 */
export function PostLiveView({ initialPost, slug }: { initialPost: Post; slug: string }) {
  // Use the live query hook for real-time updates
  const { data: post, loading, error } = useLiveQueryHook<Post>(
    initialPost,
    `*[_type == "post" && slug.current == $slug][0] {
      _id,
      title,
      slug,
      excerpt,
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
      publishedAt,
      "author": author-> {
        name,
        slug,
        avatar {
          asset-> {
            url
          },
          alt
        }
      },
      "categories": categories[]-> {
        title,
        slug
      }
    }`,
    { slug }
  )

  // Show loading state
  if (loading && !post) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-pulse text-gray-500">Loading content...</div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-red-500">Error loading content: {error.message}</div>
      </div>
    )
  }

  if (!post) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-gray-500">Post not found</div>
      </div>
    )
  }

  // Calculate reading time
  const getReadingTime = (body: any[]) => {
    const text = body
      .filter((block: any) => block._type === 'block')
      .map((block: any) => block.children?.map((child: any) => child.text || '').join('') || '')
      .join(' ')
    const words = text.split(/\s+/).length
    const minutes = Math.ceil(words / 200) // Average reading speed: 200 words/minute
    return minutes
  }

  const readingTime = getReadingTime(post.body)
  const publishDate = new Date(post.publishedAt).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })

  return (
    <article className="max-w-4xl mx-auto px-4 py-12">
      {/* Live indicator */}
      {loading && (
        <div className="fixed top-4 right-4 z-50 bg-blue-500 text-white px-4 py-2 rounded-lg shadow-lg animate-pulse">
          Syncing...
        </div>
      )}
      
      {/* Header */}
      <header className="mb-8">
        <h1 className="text-4xl md:text-5xl font-bold mb-4">
          {post.title}
        </h1>
        
        <div className="flex items-center gap-4 text-gray-600 mb-6">
          {post.author && (
            <div className="flex items-center gap-2">
              {post.author.avatar && (
                <img
                  src={post.author.avatar.asset.url}
                  alt={post.author.avatar.alt || post.author.name}
                  className="w-10 h-10 rounded-full object-cover"
                />
              )}
              <span className="font-medium">{post.author.name}</span>
            </div>
          )}
          <span>•</span>
          <time dateTime={post.publishedAt}>{publishDate}</time>
          <span>•</span>
          <span>{readingTime} min read</span>
        </div>

        {post.categories && post.categories.length > 0 && (
          <div className="flex gap-2 flex-wrap mb-4">
            {post.categories.map((category) => (
              <a
                key={category.slug.current}
                href={`/categories/${category.slug.current}`}
                className="bg-gray-100 hover:bg-gray-200 text-gray-800 px-3 py-1 rounded-full text-sm transition-colors"
              >
                {category.title}
              </a>
            ))}
          </div>
        )}
      </header>

      {/* Featured Image */}
      {post.featuredImage && (
        <div className="mb-8 rounded-xl overflow-hidden relative aspect-video">
          <Image
            src={post.featuredImage.asset.url}
            alt={post.featuredImage.alt || 'Featured image'}
            fill
            className="object-cover"
            placeholder="blur"
            blurDataURL={post.featuredImage.asset.metadata.lqip}
            priority
          />
          {post.featuredImage.caption && (
            <figcaption className="absolute bottom-0 left-0 right-0 bg-black bg-opacity-50 text-white p-2 text-sm">
              {post.featuredImage.caption}
            </figcaption>
          )}
        </div>
      )}

      {/* Excerpt */}
      {post.excerpt && (
        <div className="text-xl text-gray-600 mb-8 italic border-l-4 border-gray-300 pl-4">
          {post.excerpt}
        </div>
      )}

      {/* Body Content with Portable Text */}
      <div className="prose prose-lg max-w-none">
        <PortableText
          value={post.body}
          components={portableTextComponents}
        />
      </div>
    </article>
  )
}

/**
 * Portable Text Components
 * 
 * Custom components for rendering different block types.
 * Supports images, code blocks, and callouts.
 */
const portableTextComponents = {
  block: {
    h1: ({ children }: any) => <h1 className="text-3xl font-bold mt-8 mb-4">{children}</h1>,
    h2: ({ children }: any) => <h2 className="text-2xl font-bold mt-6 mb-3">{children}</h2>,
    h3: ({ children }: any) => <h3 className="text-xl font-bold mt-4 mb-2">{children}</h3>,
    h4: ({ children }: any) => <h4 className="text-lg font-bold mt-3 mb-1">{children}</h4>,
    normal: ({ children }: any) => <p className="mb-4 leading-relaxed">{children}</p>,
    blockquote: ({ children }: any) => (
      <blockquote className="border-l-4 border-gray-300 pl-4 italic my-4">
        {children}
      </blockquote>
    ),
  },
  list: {
    bullet: ({ children }: any) => <ul className="list-disc pl-6 mb-4">{children}</ul>,
    number: ({ children }: any) => <ol className="list-decimal pl-6 mb-4">{children}</ol>,
  },
  listItem: {
    bullet: ({ children }: any) => <li className="mb-1">{children}</li>,
    number: ({ children }: any) => <li className="mb-1">{children}</li>,
  },
  marks: {
    strong: ({ children }: any) => <strong className="font-bold">{children}</strong>,
    em: ({ children }: any) => <em className="italic">{children}</em>,
    underline: ({ children }: any) => <u className="underline">{children}</u>,
    'strike-through': ({ children }: any) => <s className="line-through">{children}</s>,
    code: ({ children }: any) => (
      <code className="bg-gray-100 px-1 py-0.5 rounded text-sm font-mono">
        {children}
      </code>
    ),
    highlight: ({ children }: any) => (
      <mark className="bg-yellow-200 px-1 rounded">{children}</mark>
    ),
    link: ({ value, children }: any) => {
      const href = value?.href || ''
      const target = href.startsWith('http') ? '_blank' : undefined
      return (
        <a
          href={href}
          target={target}
          rel={target === '_blank' ? 'noopener noreferrer' : undefined}
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
          <img
            src={value.asset.url}
            alt={value.alt || ''}
            className="rounded-lg w-full"
          />
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
          <div className="bg-gray-800 text-white px-4 py-2 text-sm font-mono flex justify-between items-center">
            <span>{value.language || 'code'}</span>
            <button
              className="text-gray-400 hover:text-white transition-colors"
              onClick={() => {
                navigator.clipboard.writeText(value.code)
              }}
            >
              Copy
            </button>
          </div>
          <pre className="bg-gray-900 text-white p-4 overflow-x-auto">
            <code className={`language-${value.language || 'javascript'}`}>
              {value.code}
            </code>
          </pre>
        </div>
      )
    },
    callout: ({ value }: any) => {
      if (!value?.content) {
        return null
      }
      
      const colors = {
        info: 'bg-blue-50 border-blue-200 text-blue-800',
        warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
        error: 'bg-red-50 border-red-200 text-red-800',
        success: 'bg-green-50 border-green-200 text-green-800',
      }
      
      const color = colors[value.type as keyof typeof colors] || colors.info
      
      return (
        <div className={`border-l-4 p-4 my-4 rounded ${color}`}>
          <div className="font-semibold mb-1">
            {value.type ? value.type.charAt(0).toUpperCase() + value.type.slice(1) : 'Info'}
          </div>
          <PortableText value={value.content} />
        </div>
      )
    },
  },
}
```

### The Verification

1. **Start your frontend**:
```bash
cd frontend
npm run dev
```

2. **Create a post in the Studio** with some content

3. **View the post in your browser** at `http://localhost:3000/posts/[slug]`

4. **Test live updates**:
   - Open the post in your browser
   - Go to the Studio and edit the post
   - Save changes
   - Watch the browser page update automatically!

5. **Check the sync indicator**: Notice the "Syncing..." indicator when changes are being applied

**You now have real-time content updates!**

---

## Step 2: Implementing Visual Editing

### The Target
Enable visual editing with the Presentation Tool and Draft Mode.

### The Concept
Visual editing allows editors to click on elements in the actual website and be taken directly to the corresponding field in the Studio. This eliminates the guesswork of finding where to make changes.

**Real-world analogy**: Visual editing is like having "Edit" buttons on every element of a webpage. Instead of describing where a change should be made, you just click on it and start editing.

### The Implementation

#### 2.1 Install the Presentation Tool

```bash
cd studio
npm install @sanity/presentation
```

#### 2.2 Configure the Presentation Tool

Update `studio/sanity.config.ts`:

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { structureTool } from 'sanity/structure'
import { visionTool } from '@sanity/vision'
import { presentationTool } from '@sanity/presentation'
import { schemaTypes } from './schemas'
import { structure } from './structure'
import { SlugInput } from './components/SlugInput'
import { ColorPickerInput } from './components/ColorPickerInput'
import { SEOInput } from './components/SEOInput'
import { PublishWithValidation } from './actions/PublishWithValidation'
import { GenerateAISummary } from './actions/GenerateAISummary'

// Add this: Your frontend URL for preview
const PREVIEW_URL = process.env.SANITY_STUDIO_PREVIEW_URL || 'http://localhost:3000'

export default defineConfig({
  projectId: process.env.SANITY_STUDIO_PROJECT_ID || '',
  dataset: process.env.SANITY_STUDIO_DATASET || 'production',
  plugins: [
    structureTool({ structure }),
    visionTool(),
    // Add the Presentation Tool
    presentationTool({
      // Where to open the preview
      previewUrl: {
        origin: PREVIEW_URL,
        previewMode: {
          enable: `${PREVIEW_URL}/api/draft-mode/enable`,
          disable: `${PREVIEW_URL}/api/draft-mode/disable`,
        },
      },
      // How to resolve the URL for a document
      resolve: {
        mainDocuments: [
          { route: '/posts/:slug', type: 'post' },
          { route: '/authors/:slug', type: 'author' },
          { route: '/categories/:slug', type: 'category' },
        ],
      },
    }),
  ],
  schema: {
    types: schemaTypes,
  },
  form: {
    components: {
      input: (props) => {
        if (props.schemaType.name === 'slug' && props.path.includes('slug')) {
          return SlugInput
        }
        if (props.schemaType.name === 'string' && props.schemaType.options?.isColor) {
          return ColorPickerInput
        }
        if (props.schemaType.name === 'seo' && props.schemaType.title === 'SEO Settings') {
          return SEOInput
        }
        return undefined
      },
    },
  },
  document: {
    actions: (prev, context) => {
      if (context.schemaType === 'post') {
        return [
          ...prev,
          PublishWithValidation,
          GenerateAISummary,
        ]
      }
      return prev
    },
  },
})
```

#### 2.3 Create Draft Mode API Endpoints

Create `frontend/app/api/draft-mode/enable/route.ts`:

```typescript
// frontend/app/api/draft-mode/enable/route.ts
import { draftMode } from 'next/headers'
import { redirect } from 'next/navigation'

/**
 * Enable Draft Mode
 * 
 * This API endpoint enables Next.js Draft Mode,
 * allowing editors to preview unpublished content.
 * 
 * Called by the Presentation Tool when an editor
 * wants to preview content.
 */
export async function GET(request: Request) {
  try {
    // Parse the URL to get parameters
    const { searchParams } = new URL(request.url)
    const slug = searchParams.get('slug')
    const type = searchParams.get('type')

    // Enable draft mode
    const draft = await draftMode()
    draft.enable()

    // Set cookies for Sanity to recognize draft mode
    // This is crucial for stega encoding to work
    const response = new Response(null, {
      status: 200,
      headers: {
        'Set-Cookie': `sanity-preview=active; Path=/; HttpOnly; SameSite=Lax`,
      },
    })

    // Redirect to the preview URL
    if (slug && type) {
      // Redirect to the specific content
      const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'
      
      // Determine the redirect path based on type
      let path = '/'
      if (type === 'post') {
        path = `/posts/${slug}`
      } else if (type === 'author') {
        path = `/authors/${slug}`
      } else if (type === 'category') {
        path = `/categories/${slug}`
      }
      
      // Add a query parameter to indicate preview mode
      const url = new URL(path, baseUrl)
      url.searchParams.set('preview', 'true')
      
      // Redirect with the cookie set
      return redirect(url.toString())
    }

    // If no specific content, redirect to homepage with preview
    return redirect('/?preview=true')
  } catch (error) {
    console.error('Error enabling draft mode:', error)
    return new Response('Error enabling draft mode', { status: 500 })
  }
}
```

Create `frontend/app/api/draft-mode/disable/route.ts`:

```typescript
// frontend/app/api/draft-mode/disable/route.ts
import { draftMode } from 'next/headers'
import { redirect } from 'next/navigation'

/**
 * Disable Draft Mode
 * 
 * This API endpoint disables Next.js Draft Mode,
 * returning to production content.
 */
export async function GET(request: Request) {
  try {
    // Disable draft mode
    const draft = await draftMode()
    draft.disable()
    
    // Clear the Sanity preview cookie
    const response = new Response(null, {
      status: 200,
      headers: {
        'Set-Cookie': `sanity-preview=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0`,
      },
    })

    // Redirect to the homepage
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'
    return redirect(baseUrl)
  } catch (error) {
    console.error('Error disabling draft mode:', error)
    return new Response('Error disabling draft mode', { status: 500 })
  }
}
```

#### 2.4 Update Environment Variables

Add to `frontend/.env.local`:

```env
# frontend/.env.local
# ... existing variables ...

# Draft Mode & Preview
NEXT_PUBLIC_BASE_URL=http://localhost:3000
NEXT_PUBLIC_SANITY_STUDIO_URL=http://localhost:3333
SANITY_STUDIO_PREVIEW_URL=http://localhost:3000
SANITY_API_READ_TOKEN=your-read-token-here
```

Add to `studio/.env`:

```env
# studio/.env
# ... existing variables ...

# Preview URL for Presentation Tool
SANITY_STUDIO_PREVIEW_URL=http://localhost:3000
```

#### 2.5 Add Stega Encoding

Update `frontend/lib/sanity/client.ts` to handle stega:

```typescript
// frontend/lib/sanity/client.ts

/**
 * Stega Encoding Helper
 * 
 * Stega (Steganography) is used to encode editing information
 * in the content. This allows the Presentation Tool to know
 * which field each piece of content belongs to.
 */
export function encodeStega(data: any, path: string[]) {
  if (typeof data === 'string') {
    // Add stega attributes to text
    return `__stega__${path.join('.')}__${data}`
  }
  
  if (Array.isArray(data)) {
    return data.map((item, index) => encodeStega(item, [...path, index.toString()]))
  }
  
  if (data && typeof data === 'object') {
    const result: any = {}
    for (const [key, value] of Object.entries(data)) {
      result[key] = encodeStega(value, [...path, key])
    }
    return result
  }
  
  return data
}

/**
 * Decode Stega Data
 * 
 * Removes stega encoding from content for display.
 */
export function decodeStega(data: any): any {
  if (typeof data === 'string' && data.startsWith('__stega__')) {
    // Remove stega prefix and return the actual content
    return data.split('__').slice(-1)[0]
  }
  
  if (Array.isArray(data)) {
    return data.map(decodeStega)
  }
  
  if (data && typeof data === 'object') {
    const result: any = {}
    for (const [key, value] of Object.entries(data)) {
      result[key] = decodeStega(value)
    }
    return result
  }
  
  return data
}
```

#### 2.6 Update Query Layer with Stega

Update `frontend/lib/sanity/queries.ts`:

```typescript
// frontend/lib/sanity/queries.ts
import { client, liveClient, decodeStega } from './client'

/**
 * Get a single post by slug with stega support
 * 
 * If in preview mode, fetches from the live client
 * to get unpublished content and stega encoding.
 */
export async function getPostBySlug(
  slug: string,
  preview: boolean = false
): Promise<Post | null> {
  const query = postBySlugQuery
  const params = { slug }
  
  try {
    // Use live client for preview mode
    const clientInstance = preview ? liveClient : client
    const result = await clientInstance.fetch<Post>(query, params)
    
    // Decode stega if present
    if (preview && result) {
      return decodeStega(result)
    }
    
    return result
  } catch (error) {
    console.error(`Failed to fetch post with slug: ${slug}`, error)
    return null
  }
}
```

### The Verification

1. **Start the Studio**:
```bash
cd studio
sanity dev
```

2. **Start the frontend**:
```bash
cd frontend
npm run dev
```

3. **Open the Studio** at http://localhost:3333

4. **Open the Presentation Tool**:
   - Click "Presentation" in the Studio sidebar
   - You should see a preview of your frontend

5. **Test visual editing**:
   - Click on any text in the preview
   - You should be taken directly to that field in the Studio
   - Edit the content and save
   - Watch the preview update in real-time

6. **Test Draft Mode**:
   - Create a new post with a title but don't publish it
   - Open the Presentation Tool
   - Navigate to the new post
   - You should see it with a "Draft" badge

**You now have visual editing and draft previews!**

---

## Step 3: Implementing Content Releases

### The Target
Create a content release system for scheduling and staging content.

### The Concept
Content releases allow editors to plan, stage, and schedule content in batches. This is like a "release train" where multiple content pieces are prepared and published together at a scheduled time.

**Real-world analogy**: Content releases are like album releases. A band records multiple songs, prepares them, and releases them all on the same day.

### The Implementation

#### 3.1 Create Content Release Schema

Create `studio/schemas/release.ts`:

```typescript
// studio/schemas/release.ts
import { defineField, defineType } from 'sanity'

/**
 * Content Release Schema
 * 
 * Manages scheduled releases of multiple content pieces.
 * Allows editors to batch and schedule content together.
 */
export default defineType({
  name: 'release',
  title: 'Content Release',
  type: 'document',
  
  fields: [
    defineField({
      name: 'title',
      title: 'Release Title',
      type: 'string',
      description: 'A descriptive title for this release',
      validation: (Rule) => Rule.required()
        .error('Release title is required'),
    }),
    
    defineField({
      name: 'description',
      title: 'Description',
      type: 'text',
      description: 'What is included in this release?',
      rows: 3,
    }),
    
    defineField({
      name: 'scheduledDate',
      title: 'Scheduled Release Date',
      type: 'datetime',
      description: 'When should this release go live?',
      validation: (Rule) => Rule.required()
        .error('Scheduled release date is required'),
    }),
    
    defineField({
      name: 'posts',
      title: 'Posts',
      type: 'array',
      description: 'Posts included in this release',
      of: [
        {
          type: 'reference',
          to: [{type: 'post'}],
        },
      ],
      validation: (Rule) => Rule.min(1)
        .error('At least one post is required for a release'),
    }),
    
    defineField({
      name: 'status',
      title: 'Status',
      type: 'string',
      options: {
        list: [
          {title: 'Draft', value: 'draft'},
          {title: 'Scheduled', value: 'scheduled'},
          {title: 'In Progress', value: 'in-progress'},
          {title: 'Published', value: 'published'},
          {title: 'Cancelled', value: 'cancelled'},
        ],
      },
      initialValue: 'draft',
      validation: (Rule) => Rule.required(),
    }),
    
    defineField({
      name: 'metadata',
      title: 'Metadata',
      type: 'object',
      fields: [
        {
          name: 'version',
          title: 'Version',
          type: 'string',
          description: 'Optional version number for this release',
        },
        {
          name: 'stagingUrl',
          title: 'Staging URL',
          type: 'url',
          description: 'URL where this release can be previewed',
        },
      ],
    }),
  ],
  
  preview: {
    select: {
      title: 'title',
      subtitle: 'scheduledDate',
      status: 'status',
    },
    prepare({title, subtitle, status}) {
      return {
        title: title || 'Untitled Release',
        subtitle: subtitle 
          ? `Scheduled: ${new Date(subtitle).toLocaleDateString()}`
          : 'No date set',
        media: () => {
          const icons = {
            draft: '📝',
            scheduled: '⏰',
            'in-progress': '🔄',
            published: '✅',
            cancelled: '❌',
          }
          return (icons[status as keyof typeof icons] || '📦')
        },
      }
    },
  },
  
  orderings: [
    {
      title: 'Scheduled Date, Newest',
      name: 'scheduledDateDesc',
      by: [{field: 'scheduledDate', direction: 'desc'}],
    },
  ],
})
```

#### 3.2 Create Release Management Component

Create `studio/components/ReleaseManager.tsx`:

```typescript
// studio/components/ReleaseManager.tsx
import React, { useState, useEffect } from 'react'
import { 
  Card, Container, Heading, Text, Stack, Grid, Badge, 
  Flex, Button, Table, TableHead, TableRow, TableCell,
  TableBody, Spinner, Dialog
} from '@sanity/ui'
import { client } from '../../frontend/lib/sanity/client'

interface Release {
  _id: string
  title: string
  description?: string
  scheduledDate: string
  status: 'draft' | 'scheduled' | 'in-progress' | 'published' | 'cancelled'
  posts: Array<{ _id: string; title: string }>
  metadata?: {
    version?: string
    stagingUrl?: string
  }
}

/**
 * Release Manager Component
 * 
 * Manages content releases for scheduling and staging.
 * Allows editors to create, schedule, and publish releases.
 */
export function ReleaseManager() {
  const [releases, setReleases] = useState<Release[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedRelease, setSelectedRelease] = useState<Release | null>(null)
  const [showDialog, setShowDialog] = useState(false)
  const [dialogAction, setDialogAction] = useState<'publish' | 'delete' | null>(null)

  useEffect(() => {
    fetchReleases()
  }, [])

  const fetchReleases = async () => {
    try {
      setLoading(true)
      const query = `
        *[_type == "release"] | order(scheduledDate desc) {
          _id,
          title,
          description,
          scheduledDate,
          status,
          "posts": posts[]-> { _id, title },
          metadata
        }
      `
      const data = await client.fetch<Release[]>(query)
      setReleases(data)
    } catch (error) {
      console.error('Failed to fetch releases:', error)
    } finally {
      setLoading(false)
    }
  }

  const handlePublishRelease = async (releaseId: string) => {
    try {
      setLoading(true)
      
      // Get the release
      const release = releases.find(r => r._id === releaseId)
      if (!release) return
      
      // Update all posts in the release
      const postUpdates = release.posts.map(post => {
        return client.patch(post._id)
          .set({
            publishedAt: new Date().toISOString(),
          })
          .commit()
      })
      
      await Promise.all(postUpdates)
      
      // Update release status
      await client.patch(releaseId)
        .set({ status: 'published' })
        .commit()
      
      // Refresh releases
      await fetchReleases()
      
      setShowDialog(false)
      setDialogAction(null)
    } catch (error) {
      console.error('Failed to publish release:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleDeleteRelease = async (releaseId: string) => {
    try {
      setLoading(true)
      
      // Delete the release
      await client.delete(releaseId)
      
      // Refresh releases
      await fetchReleases()
      
      setShowDialog(false)
      setDialogAction(null)
    } catch (error) {
      console.error('Failed to delete release:', error)
    } finally {
      setLoading(false)
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'published': return 'positive'
      case 'scheduled': return 'primary'
      case 'in-progress': return 'caution'
      case 'draft': return 'default'
      case 'cancelled': return 'critical'
      default: return 'default'
    }
  }

  const getStatusLabel = (status: string) => {
    return status.charAt(0).toUpperCase() + status.slice(1).replace('-', ' ')
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    })
  }

  if (loading && releases.length === 0) {
    return (
      <Container padding={4}>
        <Card padding={4} radius={2}>
          <Flex align="center" gap={3}>
            <Spinner />
            <Text>Loading releases...</Text>
          </Flex>
        </Card>
      </Container>
    )
  }

  return (
    <Container padding={4}>
      <Stack space={4}>
        {/* Header */}
        <Flex align="center" justify="space-between">
          <Stack space={1}>
            <Heading>Content Releases</Heading>
            <Text muted>
              Schedule and batch publish content
            </Text>
          </Stack>
          <Button
            text="New Release"
            tone="primary"
            onClick={() => {
              window.location.href = '/structure/release;create'
            }}
          />
        </Flex>

        {/* Stats */}
        <Grid columns={[2, 4]} gap={2}>
          <StatCard
            label="Total Releases"
            value={releases.length}
            subtitle="All releases"
          />
          <StatCard
            label="Scheduled"
            value={releases.filter(r => r.status === 'scheduled').length}
            tone="primary"
          />
          <StatCard
            label="In Progress"
            value={releases.filter(r => r.status === 'in-progress').length}
            tone="caution"
          />
          <StatCard
            label="Published"
            value={releases.filter(r => r.status === 'published').length}
            tone="positive"
          />
        </Grid>

        {/* Releases Table */}
        <Card padding={0} radius={2} tone="default">
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>
                  <Text weight="bold">Title</Text>
                </TableCell>
                <TableCell>
                  <Text weight="bold">Posts</Text>
                </TableCell>
                <TableCell>
                  <Text weight="bold">Scheduled Date</Text>
                </TableCell>
                <TableCell>
                  <Text weight="bold">Status</Text>
                </TableCell>
                <TableCell>
                  <Text weight="bold">Actions</Text>
                </TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {releases.map((release) => (
                <TableRow key={release._id}>
                  <TableCell>
                    <Stack space={1}>
                      <Text weight="bold">{release.title}</Text>
                      {release.description && (
                        <Text size={1} muted>
                          {release.description}
                        </Text>
                      )}
                      {release.metadata?.version && (
                        <Badge>v{release.metadata.version}</Badge>
                      )}
                    </Stack>
                  </TableCell>
                  <TableCell>
                    <Text>{release.posts.length} posts</Text>
                    {release.posts.length > 0 && (
                      <Text size={1} muted>
                        {release.posts.map(p => p.title).join(', ')}
                      </Text>
                    )}
                  </TableCell>
                  <TableCell>
                    <Text>
                      {formatDate(release.scheduledDate)}
                    </Text>
                  </TableCell>
                  <TableCell>
                    <Badge tone={getStatusColor(release.status)}>
                      {getStatusLabel(release.status)}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <Flex gap={1}>
                      {release.status === 'scheduled' && (
                        <Button
                          text="Publish"
                          size="small"
                          tone="positive"
                          onClick={() => {
                            setSelectedRelease(release)
                            setDialogAction('publish')
                            setShowDialog(true)
                          }}
                        />
                      )}
                      {release.status === 'draft' && (
                        <Button
                          text="Delete"
                          size="small"
                          tone="critical"
                          mode="ghost"
                          onClick={() => {
                            setSelectedRelease(release)
                            setDialogAction('delete')
                            setShowDialog(true)
                          }}
                        />
                      )}
                      <Button
                        text="View"
                        size="small"
                        mode="ghost"
                        onClick={() => {
                          window.location.href = `/structure/release;${release._id}`
                        }}
                      />
                    </Flex>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Card>
      </Stack>

      {/* Confirmation Dialog */}
      {showDialog && selectedRelease && (
        <Dialog
          id="release-confirmation"
          header={
            dialogAction === 'publish' 
              ? 'Publish Release' 
              : 'Delete Release'
          }
          onClose={() => {
            setShowDialog(false)
            setDialogAction(null)
          }}
          width={1}
        >
          <Card padding={4}>
            <Stack space={4}>
              <Text>
                {dialogAction === 'publish'
                  ? `Are you sure you want to publish "${selectedRelease.title}"? This will publish all ${selectedRelease.posts.length} posts in this release.`
                  : `Are you sure you want to delete "${selectedRelease.title}"? This action cannot be undone.`
                }
              </Text>
              <Flex gap={2}>
                <Button
                  text={dialogAction === 'publish' ? 'Publish' : 'Delete'}
                  tone={dialogAction === 'publish' ? 'positive' : 'critical'}
                  onClick={() => {
                    if (dialogAction === 'publish') {
                      handlePublishRelease(selectedRelease._id)
                    } else if (dialogAction === 'delete') {
                      handleDeleteRelease(selectedRelease._id)
                    }
                  }}
                  disabled={loading}
                />
                <Button
                  text="Cancel"
                  mode="ghost"
                  onClick={() => {
                    setShowDialog(false)
                    setDialogAction(null)
                  }}
                />
              </Flex>
            </Stack>
          </Card>
        </Dialog>
      )}
    </Container>
  )
}

function StatCard({ label, value, subtitle, tone = 'default' }: {
  label: string
  value: number
  subtitle?: string
  tone?: 'default' | 'positive' | 'caution' | 'critical' | 'primary'
}) {
  return (
    <Card padding={3} radius={2} tone={tone}>
      <Stack space={1}>
        <Text size={1} muted>{label}</Text>
        <Text size={3} weight="bold">{value}</Text>
        {subtitle && <Text size={1} muted>{subtitle}</Text>}
      </Stack>
    </Card>
  )
}
```

#### 3.3 Register the Release Schema

Update `studio/schemas/index.ts`:

```typescript
// studio/schemas/index.ts
import { SchemaTypeDefinition } from 'sanity'

import post from './post'
import author from './author'
import category from './category'
import settings from './settings'
import release from './release'  // Add this

export const schemaTypes: SchemaTypeDefinition[] = [
  post,
  author,
  category,
  settings,
  release,  // Add this
]
```

Add Release Manager to the Studio structure:

```typescript
// studio/structure/index.ts
const releaseManager = S.listItem()
  .title('Release Manager')
  .icon(() => '📦')
  .child(
    S.component()
      .id('releaseManager')
      .title('Release Manager')
      .component(
        () => import('../components/ReleaseManager').then(mod => mod.ReleaseManager)
      )
  )

// Add to main structure
return S.list()
  .title('Content')
  .items([
    dashboard,
    S.divider(),
    blogPosts,
    authors,
    categories,
    releases,  // Add releases list
    S.divider(),
    settings,
    S.divider(),
    contentCalendar,
    aiAssistant,
    releaseManager,  // Add this
  ])
```

### The Verification

1. **Create a release**:
   - Go to "Release Manager"
   - Click "New Release"
   - Add a title, description, and scheduled date
   - Add some posts to the release
   - Save the release

2. **Test release workflow**:
   - Create a release with status "Scheduled"
   - View it in the Release Manager
   - Click "Publish" to publish all posts
   - Verify posts are published

3. **Check status updates**:
   - See the status badge change
   - Published posts should show the current date

**You now have content release management!**

---

## Part 4 Summary

### What We've Accomplished

In this part, we:

✅ Implemented the Live Content API for real-time updates
✅ Enabled visual editing with the Presentation Tool
✅ Configured Draft Mode for content previews
✅ Added stega encoding for secure editing
✅ Created content releases for scheduling
✅ Built a release manager component

### Key Concepts You've Mastered

1. **Real-Time Updates**: Live Content API without polling
2. **Visual Editing**: Click-to-edit functionality
3. **Preview Environments**: Draft Mode for unpublished content
4. **Stega Encoding**: Secure visual editing
5. **Content Releases**: Scheduled batch publishing
6. **Production Workflows**: Staging and deployment

### Production Considerations

| Aspect | Best Practice |
|--------|---------------|
| **Caching** | Use CDN with proper revalidation |
| **Security** | API tokens with minimal permissions |
| **Performance** | Lazy loading and image optimization |
| **Deployment** | Environment-specific configurations |
| **Monitoring** | Logging and error tracking |

### What's Next

In **Part 5: Integrating with React 19 and Next.js 16**, you'll:

- Set up Next.js 16 with App Router
- Use React Server Components for content fetching
- Implement Server Actions for content operations
- Configure caching and revalidation
- Build a complete, production-ready frontend
- Deploy to production

**Estimated time for Part 5**: 4-5 hours

### Practice Exercises

1. **Implement a webhook**: Create a webhook that triggers cache revalidation
2. **Add analytics**: Track how content is being used
3. **Create a sitemap**: Generate XML sitemaps from your content
4. **Add commenting**: Use Sanity's Live Content API for comments
5. **Build a search page**: Implement full-text search with GROQ

### Resources for Further Learning

- [Sanity Live Content API](https://www.sanity.io/docs/live-content-api)
- [Sanity Presentation Tool](https://www.sanity.io/docs/presentation)
- [Next.js Draft Mode](https://nextjs.org/docs/app/building-your-application/configuring/draft-mode)
- [Stega Encoding](https://www.sanity.io/docs/stega-encoding)

---

You've built a complete content platform with real-time capabilities and production workflows. Now it's time to build the frontend that brings it all together. In Part 5, we'll use React 19 and Next.js 16 to create a modern, high-performance website that showcases your content.

This is the final piece of the puzzle. Let's build something amazing!
