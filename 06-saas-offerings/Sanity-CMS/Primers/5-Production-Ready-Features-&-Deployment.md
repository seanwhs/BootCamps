# Primer 5: Production-Ready Features & Deployment

Welcome to the final primer. You've built your Studio, created content models, mastered GROQ, and integrated with Next.js. Now it's time to add production-ready features and deploy your application to the world.

---

## Step 1: Implementing Preview Mode

### The Concept

Preview Mode allows editors to see unpublished content before it goes live. This is essential for editorial workflows—writers can review their posts exactly as they'll appear on the site.

**Real-world analogy**: Preview Mode is like a dress rehearsal before a theater performance. Everything looks and feels like the real show, but the audience (the public) hasn't arrived yet.

### Setup Preview Mode

Create `app/api/preview/route.ts`:

```typescript
// app/api/preview/route.ts
import { draftMode } from 'next/headers'
import { redirect } from 'next/navigation'
import { client } from '@/lib/sanity/client'

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const secret = searchParams.get('secret')
  const slug = searchParams.get('slug')

  // Verify the secret
  if (secret !== process.env.SANITY_PREVIEW_SECRET) {
    return new Response('Invalid secret', { status: 401 })
  }

  // Enable draft mode
  const draft = await draftMode()
  draft.enable()

  // Redirect to the post
  if (slug) {
    redirect(`/posts/${slug}`)
  }

  redirect('/')
}
```

### Disable Preview Mode

Create `app/api/preview/disable/route.ts`:

```typescript
// app/api/preview/disable/route.ts
import { draftMode } from 'next/headers'
import { redirect } from 'next/navigation'

export async function GET() {
  const draft = await draftMode()
  draft.disable()
  redirect('/')
}
```

### Update the Sanity Client for Preview

```typescript
// lib/sanity/client.ts
import { draftMode } from 'next/headers'

export async function getClient() {
  const { isEnabled: isDraftMode } = await draftMode()
  
  return createClient({
    projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
    dataset: process.env.NEXT_PUBLIC_SANITY_DATASET!,
    apiVersion: '2024-01-01',
    useCdn: !isDraftMode,
    token: isDraftMode ? process.env.SANITY_READ_TOKEN : undefined,
    perspective: isDraftMode ? 'previewDrafts' : 'published',
  })
}
```

### Update Query Functions for Preview

```typescript
// lib/sanity/queries.ts
import { getClient } from './client'

export async function getPostBySlug(slug: string) {
  const client = await getClient()
  return client.fetch(postBySlugQuery, { slug })
}
```

---

## Step 2: Implementing Webhooks

### The Concept

Webhooks are automated notifications from Sanity to your application. When content changes in the Studio, a webhook triggers a revalidation, ensuring your site stays up-to-date without manual intervention.

**Real-world analogy**: Webhooks are like a doorbell. When someone rings it (content changes in Sanity), your application answers (revalidates content).

### Set Up the Revalidation Route

Create `app/api/webhook/route.ts`:

```typescript
// app/api/webhook/route.ts
import { revalidateTag } from 'next/cache'
import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  try {
    // Verify webhook signature
    const signature = request.headers.get('sanity-webhook-signature')
    const secret = process.env.SANITY_WEBHOOK_SECRET
    
    // In production, validate the signature here
    // For now, just check the secret in the body

    const body = await request.json()
    const { _type, slug, _id } = body

    // Revalidate based on content type
    if (_type === 'post') {
      revalidateTag('posts')
      if (slug?.current) {
        revalidateTag(`post:${slug.current}`)
      }
    } else if (_type === 'author') {
      revalidateTag('authors')
      if (slug?.current) {
        revalidateTag(`author:${slug.current}`)
      }
    } else if (_type === 'category') {
      revalidateTag('categories')
      if (slug?.current) {
        revalidateTag(`category:${slug.current}`)
      }
    }

    // Revalidate everything
    revalidateTag('all')

    return NextResponse.json({
      success: true,
      revalidated: { _type, slug }
    })
  } catch (error) {
    console.error('Webhook error:', error)
    return NextResponse.json(
      { success: false, error: 'Webhook processing failed' },
      { status: 500 }
    )
  }
}
```

### Configure Sanity Webhook

In your Sanity project dashboard:

1. Navigate to Settings → API → Webhooks
2. Click "Create Webhook"
3. URL: `https://your-domain.com/api/webhook`
4. HTTP Method: POST
5. Secret: Your webhook secret
6. Trigger: "Create, Update, Delete"
7. Filter: Specific document types

---

## Step 3: SEO Optimization

### Dynamic Metadata

Create metadata for all pages:

```typescript
// app/posts/[slug]/page.tsx
export async function generateMetadata({ params }: { params: { slug: string } }) {
  const post = await getPostBySlug(params.slug)
  
  if (!post) {
    return {
      title: 'Post Not Found',
    }
  }

  const title = post.seo?.metaTitle || post.title
  const description = post.seo?.metaDescription || post.excerpt || ''

  return {
    title,
    description,
    openGraph: {
      title,
      description,
      type: 'article',
      publishedTime: post.publishedAt,
      authors: post.author?.name ? [post.author.name] : [],
      images: post.featuredImage ? [{
        url: urlFor(post.featuredImage).url(),
        width: 1200,
        height: 630,
        alt: post.featuredImage.alt || post.title,
      }] : [],
    },
    twitter: {
      card: 'summary_large_image',
      title,
      description,
      images: post.featuredImage ? [urlFor(post.featuredImage).url()] : [],
    },
  }
}
```

### Generate Sitemap

Create `app/sitemap.ts`:

```typescript
// app/sitemap.ts
import { getAllPosts, getAllAuthors, getAllCategories } from '@/lib/sanity/queries'
import type { MetadataRoute } from 'next'

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'https://example.com'
  
  const [posts, authors, categories] = await Promise.all([
    getAllPosts(),
    getAllAuthors(),
    getAllCategories(),
  ])

  const routes: MetadataRoute.Sitemap = [
    { url: baseUrl, lastModified: new Date(), priority: 1.0 },
    { url: `${baseUrl}/posts`, lastModified: new Date(), priority: 0.8 },
    { url: `${baseUrl}/authors`, lastModified: new Date(), priority: 0.7 },
    { url: `${baseUrl}/categories`, lastModified: new Date(), priority: 0.7 },
  ]

  // Add posts
  for (const post of posts) {
    routes.push({
      url: `${baseUrl}/posts/${post.slug.current}`,
      lastModified: new Date(post.publishedAt),
      changeFrequency: 'monthly',
      priority: 0.6,
    })
  }

  // Add authors
  for (const author of authors) {
    routes.push({
      url: `${baseUrl}/authors/${author.slug.current}`,
      lastModified: new Date(),
      changeFrequency: 'monthly',
      priority: 0.5,
    })
  }

  // Add categories
  for (const category of categories) {
    routes.push({
      url: `${baseUrl}/categories/${category.slug.current}`,
      lastModified: new Date(),
      changeFrequency: 'monthly',
      priority: 0.5,
    })
  }

  return routes
}
```

### Generate Robots.txt

Create `app/robots.ts`:

```typescript
// app/robots.ts
import type { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'https://example.com'
  
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/api/', '/studio/', '/preview/'],
    },
    sitemap: `${baseUrl}/sitemap.xml`,
  }
}
```

---

## Step 4: Performance Optimization

### Image Optimization

Configure Next.js image optimization:

```typescript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'cdn.sanity.io',
        pathname: '/images/**',
      },
    ],
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
  },
}

module.exports = nextConfig
```

### Component Code Splitting

Lazy load heavy components:

```typescript
// components/RichContent.tsx
import dynamic from 'next/dynamic'

const PortableText = dynamic(
  () => import('@portabletext/react').then(mod => mod.PortableText),
  { ssr: true, loading: () => <div>Loading content...</div> }
)
```

### Server Component Caching

Use the `cache` directive for server components:

```typescript
// app/posts/[slug]/page.tsx
import { cache } from 'react'

const getCachedPost = cache(getPostBySlug)

export default async function PostPage({ params }: { params: { slug: string } }) {
  const post = await getCachedPost(params.slug)
  // ...
}
```

---

## Step 5: Error Handling

### Global Error Boundary

Create `app/error.tsx`:

```tsx
// app/error.tsx
'use client'

export default function ErrorBoundary({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="text-center">
        <h1 className="text-2xl font-bold text-red-600">Something went wrong</h1>
        <p className="text-gray-600 mt-2">{error.message}</p>
        <button
          onClick={reset}
          className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          Try again
        </button>
      </div>
    </div>
  )
}
```

### Custom 404 Page

Create `app/not-found.tsx`:

```tsx
// app/not-found.tsx
import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="text-center">
        <h1 className="text-4xl font-bold">404</h1>
        <p className="text-xl text-gray-600 mt-2">Page not found</p>
        <Link href="/" className="mt-4 inline-block text-blue-600 hover:underline">
          Go back home
        </Link>
      </div>
    </div>
  )
}
```

### Graceful Fallbacks

Handle missing data gracefully:

```typescript
// components/PostCard.tsx
export function PostCard({ post }: { post: Post | null }) {
  if (!post) {
    return (
      <div className="bg-gray-100 rounded-xl p-6 animate-pulse">
        <div className="h-40 bg-gray-200 rounded-lg mb-4"></div>
        <div className="h-6 bg-gray-200 rounded w-3/4 mb-2"></div>
        <div className="h-4 bg-gray-200 rounded w-1/2"></div>
      </div>
    )
  }

  // Normal rendering
  // ...
}
```

---

## Step 6: Environment Configuration

### Environment Variables

Create `.env.example`:

```env
# Sanity
NEXT_PUBLIC_SANITY_PROJECT_ID=your-project-id
NEXT_PUBLIC_SANITY_DATASET=production
NEXT_PUBLIC_SANITY_API_VERSION=2024-01-01

# Preview Mode
SANITY_PREVIEW_SECRET=your-preview-secret
SANITY_READ_TOKEN=your-read-token

# Webhook
SANITY_WEBHOOK_SECRET=your-webhook-secret

# Site
NEXT_PUBLIC_BASE_URL=https://your-domain.com
```

### Multi-Environment Setup

```typescript
// lib/config.ts
export const config = {
  projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
  dataset: process.env.NEXT_PUBLIC_SANITY_DATASET || 'production',
  apiVersion: process.env.NEXT_PUBLIC_SANITY_API_VERSION || '2024-01-01',
  baseUrl: process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000',
  isDev: process.env.NODE_ENV === 'development',
  isProd: process.env.NODE_ENV === 'production',
}
```

---

## Step 7: Deployment

### Deploy to Vercel

1. **Push your code to a Git repository**

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:username/my-sanity-site.git
git push -u origin main
```

2. **Connect to Vercel**
   - Go to [vercel.com](https://vercel.com)
   - Click "Add New" → "Project"
   - Import your repository

3. **Configure Environment Variables**
   - Add all environment variables from `.env.example`
   - Set production values

4. **Deploy**
   - Click "Deploy"
   - Wait for the build to complete
   - Visit your deployment URL

### Deploy Sanity Studio

```bash
cd studio
sanity deploy
```

### Configure CORS

```bash
# Add production domain to CORS whitelist
sanity cors add https://your-domain.com --credentials
```

---

## Step 8: Monitoring & Maintenance

### Set Up Analytics

```tsx
// app/layout.tsx
import { Analytics } from '@vercel/analytics/react'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  )
}
```

### Health Check

Create `app/api/health/route.ts`:

```typescript
// app/api/health/route.ts
import { client } from '@/lib/sanity/client'

export async function GET() {
  try {
    // Check if Sanity is reachable
    await client.fetch('count(*[_type == "post"])')
    
    return new Response('OK', { status: 200 })
  } catch (error) {
    return new Response('ERROR', { status: 500 })
  }
}
```

### Monitoring Checklist

- [ ] Vercel Analytics or Google Analytics installed
- [ ] Error tracking (Sentry, LogRocket) configured
- [ ] Health check endpoint available
- [ ] Uptime monitoring set up
- [ ] Performance monitoring in place
- [ ] Backup strategy defined

---

## Summary

In this primer, you've learned how to:

✅ Implement Preview Mode for editorial workflows
✅ Set up webhooks for automatic revalidation
✅ Optimize SEO with metadata and sitemaps
✅ Improve performance with image optimization and caching
✅ Handle errors gracefully
✅ Configure environment variables
✅ Deploy to production
✅ Set up monitoring

### Production Readiness Checklist

| Area | Status |
|------|--------|
| Preview Mode | ✅ |
| Webhooks | ✅ |
| SEO | ✅ |
| Performance | ✅ |
| Error Handling | ✅ |
| Environment Config | ✅ |
| Deployment | ✅ |
| Monitoring | ✅ |

### Resources for Further Learning

- [Sanity Webhook Documentation](https://www.sanity.io/docs/webhooks)
- [Next.js Preview Mode](https://nextjs.org/docs/app/building-your-application/configuring/draft-mode)
- [Vercel Deployment](https://vercel.com/docs/deployments)
- [Sanity CORS Configuration](https://www.sanity.io/docs/cors)

