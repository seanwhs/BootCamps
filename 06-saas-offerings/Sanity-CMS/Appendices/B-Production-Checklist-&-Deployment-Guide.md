# Appendix B: Production Checklist & Deployment Guide

Welcome to the Production Checklist and Deployment Guide. This appendix provides a comprehensive checklist for taking your Sanity CMS application from development to production, along with detailed deployment instructions for various hosting platforms.

---

## B.1 Production Readiness Checklist

### The Concept

Before deploying your application to production, you need to ensure it's secure, performant, and reliable. This checklist covers all critical areas that should be addressed before going live.

**Real-world analogy**: Think of this checklist as a pre-flight inspection for an airplane. You wouldn't take off without checking the engines, fuel, navigation, and safety systems. The same applies to your application.

### Security Checklist

#### ✅ Authentication & Authorization

- [ ] **API Tokens**: Use environment variables for all API tokens, never hardcode them
- [ ] **CORS Configuration**: Restrict CORS origins to only your production domains
- [ ] **Read Tokens**: Use read-only tokens for frontend applications
- [ ] **Environment Variables**: Ensure all sensitive variables are set in production environment
- [ ] **Draft Mode Security**: Implement proper authentication for draft mode endpoints
- [ ] **Webhook Security**: Use a secret for webhook validation

**Implementation Example**:

```typescript
// frontend/lib/sanity/client.ts
const config: ClientConfig = {
  projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
  dataset: process.env.NEXT_PUBLIC_SANITY_DATASET!,
  apiVersion: '2024-01-01',
  useCdn: process.env.NODE_ENV === 'production',
  // Use read-only token for production
  token: process.env.NODE_ENV === 'production' 
    ? process.env.SANITY_READ_TOKEN 
    : undefined,
}
```

**CORS Configuration**:

```bash
# In production, only allow your frontend domains
sanity cors add https://your-domain.com --credentials
sanity cors add https://your-domain.vercel.app --credentials
```

#### ✅ Data Validation

- [ ] **Required Fields**: All required fields have validation rules
- [ ] **Data Types**: Fields have proper type validation
- [ ] **Custom Validation**: Implement custom validation for business rules
- [ ] **Unique Constraints**: Enforce uniqueness where needed (e.g., slugs)
- [ ] **Security Sanitization**: Sanitize user input to prevent XSS

**Implementation Example**:

```typescript
// studio/schemas/post.ts
defineField({
  name: 'title',
  title: 'Title',
  type: 'string',
  validation: (Rule) => [
    Rule.required().error('Title is required'),
    Rule.min(5).error('Title must be at least 5 characters'),
    Rule.max(100).error('Title cannot exceed 100 characters'),
    Rule.custom((value) => {
      // Custom validation for XSS prevention
      if (value && /<script/i.test(value)) {
        return 'Script tags are not allowed'
      }
      return true
    }),
  ],
})
```

### Performance Checklist

#### ✅ Caching Strategy

- [ ] **CDN Enabled**: `useCdn: true` for production clients
- [ ] **ISR Configured**: Set up incremental static regeneration
- [ ] **Cache Tags**: Implement cache tags for granular revalidation
- [ ] **Image Optimization**: Use Next.js Image component with Sanity CDN
- [ ] **Lazy Loading**: Implement lazy loading for images and components

**Implementation Example**:

```typescript
// frontend/app/posts/[slug]/page.tsx
export const revalidate = 3600 // Revalidate every hour

export async function generateStaticParams() {
  const posts = await getAllPosts()
  return posts.map((post) => ({
    slug: post.slug.current,
  }))
}

// frontend/lib/sanity/client.ts
export const client = createClient({
  projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
  dataset: process.env.NEXT_PUBLIC_SANITY_DATASET!,
  apiVersion: '2024-01-01',
  useCdn: process.env.NODE_ENV === 'production', // Use CDN in production
})
```

#### ✅ Performance Monitoring

- [ ] **Lighthouse Scores**: Test and optimize for scores >90
- [ ] **Core Web Vitals**: Monitor LCP, FID, CLS
- [ ] **Bundle Analysis**: Analyze and optimize bundle size
- [ ] **Image Sizes**: Serve appropriately sized images
- [ ] **Font Loading**: Optimize font loading with `font-display: swap`

**Performance Testing Commands**:

```bash
# Build for production
npm run build

# Analyze bundle size
npm install -D @next/bundle-analyzer
# Add to next.config.js
// frontend/next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})
module.exports = withBundleAnalyzer(nextConfig)
```

### SEO Checklist

#### ✅ Meta Data

- [ ] **Title Tags**: Unique, descriptive titles for all pages
- [ ] **Meta Descriptions**: Compelling descriptions for each page
- [ ] **Open Graph**: OG tags for social sharing
- [ ] **Twitter Cards**: Twitter-specific meta tags
- [ ] **Robots.txt**: Properly configured for production
- [ ] **Sitemap.xml**: Generated and submitted to search engines

**Implementation Example**:

```typescript
// frontend/app/posts/[slug]/page.tsx
export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const post = await getPostBySlug(params.slug)
  
  if (!post) {
    return {
      title: 'Post Not Found',
    }
  }
  
  return {
    title: post.seo?.metaTitle || post.title,
    description: post.seo?.metaDescription || post.excerpt,
    openGraph: {
      title: post.seo?.metaTitle || post.title,
      description: post.seo?.metaDescription || post.excerpt,
      images: post.featuredImage ? [post.featuredImage.asset.url] : [],
      type: 'article',
      publishedTime: post.publishedAt,
      authors: post.author ? [post.author.name] : undefined,
    },
    twitter: {
      card: 'summary_large_image',
      title: post.seo?.metaTitle || post.title,
      description: post.seo?.metaDescription || post.excerpt,
      images: post.featuredImage ? [post.featuredImage.asset.url] : [],
    },
    robots: {
      index: !post.seo?.noIndex,
      follow: !post.seo?.noIndex,
    },
  }
}
```

#### ✅ Structured Data

- [ ] **JSON-LD**: Implement structured data for rich snippets
- [ ] **Article Schema**: For blog posts
- [ ] **Person Schema**: For author pages
- [ ] **Breadcrumb Schema**: For navigation
- [ ] **Organization Schema**: For site-wide information

**Implementation Example**:

```typescript
// frontend/components/ArticleStructuredData.tsx
import { Post } from '@/lib/sanity/types'

export function ArticleStructuredData({ post }: { post: Post }) {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: post.title,
    description: post.excerpt,
    image: post.featuredImage?.asset.url,
    datePublished: post.publishedAt,
    author: post.author ? {
      '@type': 'Person',
      name: post.author.name,
    } : undefined,
    publisher: {
      '@type': 'Organization',
      name: 'Your Site Name',
    },
  }

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
    />
  )
}
```

### Monitoring & Error Handling Checklist

#### ✅ Error Handling

- [ ] **Error Boundaries**: Implement React error boundaries
- [ ] **404 Pages**: Custom 404 page with navigation
- [ ] **Fallback Content**: Graceful fallbacks for missing data
- [ ] **Logging**: Implement error logging
- [ ] **API Error Handling**: Proper API error responses

**Implementation Example**:

```typescript
// frontend/components/ErrorBoundary.tsx
'use client'

import React from 'react'

export class ErrorBoundary extends React.Component<{
  children: React.ReactNode
}, {
  hasError: boolean
  error?: Error
}> {
  constructor(props: any) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // Log to your error tracking service
    console.error('Error caught by boundary:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center p-4">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-red-600">Something went wrong</h1>
            <p className="text-gray-600 mt-2">We're sorry, but something went wrong.</p>
            <button
              className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              onClick={() => this.setState({ hasError: false })}
            >
              Try again
            </button>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}
```

#### ✅ Monitoring

- [ ] **Analytics**: Implement analytics tracking
- [ ] **Performance Monitoring**: Set up performance monitoring
- [ ] **Error Tracking**: Use a service like Sentry
- [ ] **Health Checks**: Implement health check endpoints
- [ ] **Alerting**: Set up alerts for critical issues

---

## B.2 Deployment Guides

### Deploying to Vercel

Vercel is the recommended hosting platform for Next.js applications and offers seamless integration with Sanity.

#### Step 1: Prepare Your Repository

```bash
# Ensure your code is in a Git repository
git init
git add .
git commit -m "Ready for production deployment"

# Push to GitHub, GitLab, or Bitbucket
git remote add origin https://github.com/yourusername/your-repo.git
git push -u origin main
```

#### Step 2: Create a Vercel Project

1. Go to [Vercel](https://vercel.com) and sign in
2. Click "Add New" → "Project"
3. Import your Git repository
4. Configure the project settings:
   - Framework Preset: Next.js
   - Root Directory: frontend (if using monorepo)
   - Build Command: `npm run build`
   - Output Directory: `.next`

#### Step 3: Configure Environment Variables

Add these environment variables in the Vercel dashboard:

| Variable | Description | Example |
|----------|-------------|---------|
| `NEXT_PUBLIC_SANITY_PROJECT_ID` | Your Sanity project ID | `abc123` |
| `NEXT_PUBLIC_SANITY_DATASET` | Your dataset name | `production` |
| `NEXT_PUBLIC_SANITY_API_VERSION` | API version | `2024-01-01` |
| `NEXT_PUBLIC_BASE_URL` | Your production URL | `https://your-site.com` |
| `SANITY_READ_TOKEN` | Read-only API token | `sk...` |
| `REVALIDATION_SECRET` | Secret for revalidation endpoint | `your-secret` |

#### Step 4: Deploy

1. Click "Deploy"
2. Wait for the build to complete
3. Visit your deployment URL

**Vercel Deployment Commands**:

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy to production
vercel --prod

# Preview deployment
vercel
```

### Deploying to Netlify

Netlify is another excellent hosting platform for Next.js applications.

#### Step 1: Prepare Your Repository

```bash
# Ensure your code is in a Git repository
git init
git add .
git commit -m "Ready for production deployment"
git push -u origin main
```

#### Step 2: Create a Netlify Project

1. Go to [Netlify](https://netlify.com) and sign in
2. Click "Add new site" → "Import an existing project"
3. Connect your Git provider
4. Select your repository

#### Step 3: Configure Build Settings

| Setting | Value |
|---------|-------|
| Build command | `npm run build` |
| Publish directory | `.next` |
| Node version | 20.x |

#### Step 4: Configure Environment Variables

Add the same environment variables as Vercel in the Netlify dashboard under "Site settings" → "Environment variables".

#### Step 5: Deploy

1. Click "Deploy site"
2. Wait for the build to complete
3. Visit your deployment URL

### Deploying Sanity Studio

Deploying your Sanity Studio makes it accessible to your editorial team.

#### Step 1: Build the Studio

```bash
cd studio

# Build the production version
npm run build
# or
sanity build
```

#### Step 2: Deploy to Sanity

```bash
# Deploy to Sanity's hosting
npm run deploy
# or
sanity deploy

# You'll be prompted for a studio name
# Example: your-studio-name
```

#### Step 3: Configure Studio URL

Update your frontend environment variables:

```env
NEXT_PUBLIC_SANITY_STUDIO_URL=https://your-studio-name.sanity.studio
```

#### Step 4: Configure CORS

```bash
# Add your frontend URL to the CORS whitelist
sanity cors add https://your-site.com --credentials
```

### Deploying to Custom Server

If you need to deploy to your own server:

#### Step 1: Build the Application

```bash
cd frontend

# Build the production version
npm run build

# Build will output to the .next directory
```

#### Step 2: Set Up Server

```bash
# Install PM2 for process management
npm install -g pm2

# Create a server script
# server.js
const { createServer } = require('http')
const { parse } = require('url')
const next = require('next')

const dev = process.env.NODE_ENV !== 'production'
const app = next({ dev })
const handle = app.getRequestHandler()

app.prepare().then(() => {
  createServer((req, res) => {
    const parsedUrl = parse(req.url!, true)
    handle(req, res, parsedUrl)
  }).listen(3000, (err) => {
    if (err) throw err
    console.log('> Ready on http://localhost:3000')
  })
})

# Start the server
pm2 start server.js --name "my-app"

# Save PM2 process list
pm2 save

# Set up PM2 to start on boot
pm2 startup
```

#### Step 3: Configure Nginx (Optional)

```nginx
# /etc/nginx/sites-available/your-site
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

## B.3 Post-Deployment Checklist

### Verify Production Functionality

#### ✅ Content Delivery

- [ ] **Studio Access**: Editorial team can access the production Studio
- [ ] **Content Fetching**: Content loads correctly on all pages
- [ ] **Real-time Updates**: Live Content API works in production
- [ ] **Image Delivery**: Images load from Sanity CDN
- [ ] **Portable Text**: Rich text renders correctly

#### ✅ Performance

- [ ] **Page Load Speed**: First Contentful Paint < 1.8s
- [ ] **Lighthouse Scores**: >90 for Performance, Accessibility, SEO
- [ ] **Core Web Vitals**: LCP < 2.5s, FID < 100ms, CLS < 0.1
- [ ] **Mobile Performance**: Test on various mobile devices
- [ ] **Caching**: CDN caching works as expected

#### ✅ SEO

- [ ] **Meta Tags**: Check page source for correct meta tags
- [ ] **Sitemap**: Visit `/sitemap.xml` and verify content
- [ ] **Robots.txt**: Visit `/robots.txt` and verify configuration
- [ ] **Structured Data**: Test with Google's Rich Results Test
- [ ] **Social Sharing**: Test Open Graph tags with social media debuggers

#### ✅ Security

- [ ] **HTTPS**: Ensure SSL/TLS is properly configured
- [ ] **CORS**: Verify CORS headers are correct
- [ ] **Security Headers**: Check for XSS protection, CSP, etc.
- [ ] **Environment Variables**: Ensure no secrets are exposed
- [ ] **API Authentication**: Verify API endpoints are protected

#### ✅ Monitoring

- [ ] **Analytics**: Verify tracking code is working
- [ ] **Error Tracking**: Test error logging
- [ ] **Performance Monitoring**: Verify metrics are being collected
- [ ] **Health Checks**: Test health check endpoints
- [ ] **Uptime Monitoring**: Set up uptime monitoring

### Testing Commands

```bash
# Test Lighthouse scores
npm install -g lighthouse
lighthouse https://your-site.com --view

# Test SEO with Google's Rich Results Test
# https://search.google.com/test/rich-results

# Test social sharing
# Twitter: https://cards-dev.twitter.com/validator
# Facebook: https://developers.facebook.com/tools/debug/

# Test CORS headers
curl -I https://your-site.com

# Test API endpoints
curl https://your-site.com/api/revalidate \
  -X POST \
  -H "Authorization: Bearer your-secret" \
  -d '{"type":"post"}'
```

---

## B.4 Maintenance & Updates

### Regular Maintenance Tasks

#### Daily Tasks
- [ ] Monitor error logs
- [ ] Check uptime monitoring
- [ ] Verify analytics data

#### Weekly Tasks
- [ ] Review Lighthouse scores
- [ ] Check Core Web Vitals
- [ ] Review content updates

#### Monthly Tasks
- [ ] Update dependencies
- [ ] Review security patches
- [ ] Analyze user engagement data
- [ ] Review backup status

#### Quarterly Tasks
- [ ] Full performance audit
- [ ] Security audit
- [ ] Content audit
- [ ] Update documentation

### Update Process

```bash
# 1. Update dependencies
npm update

# 2. Run tests
npm run test

# 3. Build for production
npm run build

# 4. Deploy to staging
vercel --prebuilt

# 5. Test staging environment

# 6. Deploy to production
vercel --prod
```

### Backup Strategy

```bash
# Export dataset (for backup)
sanity dataset export production backup.tar.gz

# Import dataset (for restore)
sanity dataset import backup.tar.gz production

# Schedule automatic backups (using cron)
# Example: Daily backup at 2 AM
0 2 * * * cd /path/to/studio && sanity dataset export production backup-$(date +\%Y\%m\%d).tar.gz
```

---

## B.5 Troubleshooting Production Issues

### Common Production Issues

#### Issue: Content Not Updating

**Symptoms**: Changes in Studio don't appear on the site

**Solutions**:
1. Check revalidation configuration
2. Verify webhook is correctly set up
3. Check cache tags are properly configured
4. Verify `useCdn` setting is correct

```typescript
// Ensure CDN is enabled in production
const client = createClient({
  useCdn: process.env.NODE_ENV === 'production',
})
```

#### Issue: Slow Page Load

**Symptoms**: Pages take too long to load

**Solutions**:
1. Check image optimization
2. Verify caching configuration
3. Analyze bundle size
4. Check server response times

```typescript
// Optimize images with Next.js Image component
<Image
  src={post.featuredImage.asset.url}
  alt={post.featuredImage.alt}
  width={800}
  height={400}
  priority={true} // For above-the-fold images
  className="object-cover"
/>
```

#### Issue: API Rate Limiting

**Symptoms**: API requests failing with 429 status code

**Solutions**:
1. Implement caching
2. Reduce API calls
3. Batch requests
4. Use CDN for static content

```typescript
// Batch multiple queries
const [posts, authors, categories] = await Promise.all([
  getAllPosts(),
  getAllAuthors(),
  getAllCategories(),
])
```

#### Issue: Memory Issues in Production

**Symptoms**: Server crashes or slow performance

**Solutions**:
1. Implement proper garbage collection
2. Reduce server-side processing
3. Use streaming where possible
4. Implement proper error handling

---

**[COMPLETED: Appendix B - Production Checklist & Deployment Guide]**

---

## Series Complete: Final Recap

### What You've Built

Over the entire series, you've created:

1. **Part 0**: Understanding the architecture and setting expectations
2. **Part 1**: Complete content models with validation and Portable Text
3. **Part 2**: Type-safe query layer with GROQ and Sanity TypeGen
4. **Part 3**: Customized Studio with AI workflows and dashboard
5. **Part 4**: Real-time content with visual editing and releases
6. **Part 5**: Production Next.js 16 frontend with caching and deployment

### Skills You've Mastered

- ✅ Structured content modeling
- ✅ Schema design and validation
- ✅ GROQ query language
- ✅ TypeScript type safety
- ✅ Studio customization
- ✅ AI-assisted workflows
- ✅ Real-time content updates
- ✅ Visual editing
- ✅ Next.js 16 with React 19
- ✅ Server Components
- ✅ Caching and revalidation
- ✅ Production deployment
- ✅ Production monitoring and maintenance

### Tools and Technologies

- **Sanity Studio v5** - Content management
- **GROQ** - Query language
- **Sanity TypeGen** - Type generation
- **React 19** - UI library
- **Next.js 16** - Framework
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling
- **Vercel/Netlify** - Hosting

### Resources for Continued Learning

- [Sanity Documentation](https://www.sanity.io/docs)
- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev)
- [GROQ Documentation](https://www.sanity.io/docs/groq)
- [Sanity Community](https://www.sanity.io/community)
- [Sanity Slack Community](https://slack.sanity.io)

---

Thank you for completing this comprehensive tutorial series. You now have the knowledge and skills to build modern content platforms with Sanity, React 19, and Next.js 16.

Happy building! 🚀
