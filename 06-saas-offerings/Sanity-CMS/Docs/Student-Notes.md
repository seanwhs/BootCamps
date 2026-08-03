# Mastering Sanity CMS: Student Notes

## How to Use These Notes

These notes are designed to accompany the Mastering Sanity CMS tutorial series. Use them as a reference during and after the course. Each section includes:

- **Key Concepts**: The most important ideas to remember
- **Code Snippets**: Essential code you'll use repeatedly
- **Diagrams**: Visual representations of concepts
- **Quick Reference**: Cheat sheets for syntax and commands
- **Notes Space**: Blank lines for your own notes

---

## PART 0: Introduction & Setup

### Key Concepts

**What is Structured Content?**
- Content broken into its smallest meaningful pieces
- Stored as data, not presentation
- Reusable across multiple channels (web, mobile, AI, etc.)
- Future-proof for channels that don't exist yet

**Headless CMS Philosophy**
- Body (content) separated from Head (presentation)
- Content → API → Any Frontend
- Freedom to choose any technology stack

**Sanity's Three Layers**
| Layer | Purpose |
|-------|---------|
| Content Lake | Database storing structured JSON |
| Studio | React-based editing interface |
| APIs & SDKs | GROQ, GraphQL, JavaScript client |

### Quick Reference

**Install Sanity CLI:**
```bash
npm install -g @sanity/cli
```

**Start a new project:**
```bash
sanity init
```

**Start the Studio:**
```bash
sanity dev
```

**Deploy the Studio:**
```bash
sanity deploy
```

### Notes

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## PART 1: Foundations of Structured Content

### Key Concepts

**The Three Building Blocks**

| Block | Definition | Example |
|-------|------------|---------|
| Document | Top-level content with its own URL | Blog post, author, product |
| Object | Reusable group of fields | SEO metadata, address |
| Field | Single piece of data | Title (string), Price (number) |

**Schema Anatomy**
```typescript
export default defineType({
  name: 'post',           // Unique identifier
  title: 'Blog Post',     // Display name
  type: 'document',       // Document or object
  fields: [...],          // Array of field definitions
  validation: [...],      // Rules for data quality
  preview: {...},         // How it appears in lists
  initialValue: {...},    // Default values
  orderings: [...],       // Sort options
})
```

**References**
- Create relationships between documents
- Use `type: 'reference'` with `to: [{ type: 'author' }]`
- Follow with `->` in GROQ queries

**Portable Text**
- Structured rich text as JSON
- Blocks, Spans, and Marks
- Customizable and queryable
- NOT HTML or Markdown

### Code Snippets

**Basic Schema Pattern:**
```typescript
import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'author',
  title: 'Author',
  type: 'document',
  fields: [
    defineField({
      name: 'name',
      title: 'Name',
      type: 'string',
      validation: (Rule) => Rule.required(),
    }),
  ],
})
```

**Reference Field:**
```typescript
defineField({
  name: 'author',
  title: 'Author',
  type: 'reference',
  to: [{ type: 'author' }],
  validation: (Rule) => Rule.required(),
})
```

**Portable Text Field:**
```typescript
defineField({
  name: 'body',
  title: 'Body',
  type: 'array',
  of: [
    {
      type: 'block',
      styles: [
        { title: 'Normal', value: 'normal' },
        { title: 'Heading 1', value: 'h1' },
      ],
      marks: {
        decorators: [
          { title: 'Bold', value: 'strong' },
          { title: 'Italic', value: 'em' },
        ],
        annotations: [
          {
            name: 'link',
            title: 'URL',
            type: 'object',
            fields: [
              { name: 'href', title: 'URL', type: 'url' }
            ],
          },
        ],
      },
    },
    { type: 'image' },
    { type: 'code' },
  ],
})
```

**Validation Patterns:**
```typescript
// Basic validation
validation: (Rule) => Rule.required()

// Chain validators
validation: (Rule) => [
  Rule.required().error('Title is required'),
  Rule.min(5).error('Title must be at least 5 characters'),
  Rule.max(100).error('Title cannot exceed 100 characters'),
]

// Custom validation
validation: (Rule) => Rule.custom((value) => {
  if (value && value.toLowerCase().includes('click here')) {
    return 'Avoid "click here" in titles'
  }
  return true
})

// Cross-field validation
validation: (Rule) => Rule.custom((value, context) => {
  const price = context.parent?.price
  if (value && price && value >= price) {
    return 'Sale price must be less than regular price'
  }
  return true
})
```

**Preview Configuration:**
```typescript
preview: {
  select: {
    title: 'title',
    subtitle: 'excerpt',
    media: 'featuredImage',
    author: 'author.name',
    date: 'publishedAt',
  },
  prepare(selection) {
    return {
      title: selection.title || 'Untitled',
      subtitle: selection.author ? `By ${selection.author}` : '',
      media: selection.media,
    }
  },
}
```

**Field Groups:**
```typescript
groups: [
  { name: 'content', title: 'Content', default: true },
  { name: 'metadata', title: 'SEO & Metadata' },
  { name: 'settings', title: 'Settings' },
],

fields: [
  defineField({
    name: 'title',
    group: 'content',
    // ...
  }),
]
```

### Common Field Types

| Type | Description | Example |
|------|-------------|---------|
| `string` | Text | `"Hello World"` |
| `text` | Multi-line text | `"Lorem ipsum..."` |
| `number` | Numeric value | `42` |
| `boolean` | True/False | `true` |
| `date` | Date only | `"2024-01-01"` |
| `datetime` | Date and time | `"2024-01-01T12:00:00Z"` |
| `url` | Web address | `"https://example.com"` |
| `email` | Email address | `"user@example.com"` |
| `slug` | URL-friendly string | `"hello-world"` |
| `image` | Image with metadata | Asset reference |
| `file` | File attachment | Asset reference |
| `array` | List of items | `[...]` |
| `object` | Group of fields | `{...}` |
| `reference` | Link to another document | Document reference |

### Notes

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## PART 2: Querying Content with GROQ

### Key Concepts

**GROQ Syntax Pattern:**
```
*[filter]{ projection }
```
- `*` = All documents
- `[filter]` = Filter conditions
- `{projection}` = Shape of results

**Core Operators:**

| Operator | Purpose | Example |
|----------|---------|---------|
| `==` | Equality | `title == "Hello"` |
| `!=` | Inequality | `status != "draft"` |
| `>` | Greater than | `publishedAt > "2024-01-01"` |
| `<` | Less than | `price < 100` |
| `&&` | Logical AND | `_type == "post" && published` |
| `||` | Logical OR | `_type == "post" || _type == "page"` |
| `!` | Logical NOT | `!defined(excerpt)` |
| `in` | Array membership | `"tech" in categories` |
| `match` | String matching | `title match "Hello*"` |

**Special Fields:**

| Field | Description |
|-------|-------------|
| `_id` | Document ID |
| `_type` | Document type |
| `_createdAt` | Creation timestamp |
| `_updatedAt` | Last update timestamp |
| `_rev` | Revision ID |
| `^` | Current document (for nested queries) |

**Projection Features:**
- Rename fields: `"newName": oldField`
- Computed fields: `"readingTime": round(length(pt::text(body)) / 900)`
- Follow references: `author->name`
- Expand all fields: `...`

### Code Snippets

**Basic Queries:**
```groq
// All posts
*[_type == "post"]

// Published posts
*[_type == "post" && defined(publishedAt) && publishedAt < now()]

// Recent posts
*[_type == "post"] | order(publishedAt desc) [0..9]

// Single post by slug
*[_type == "post" && slug.current == $slug][0]
```

**Projections:**
```groq
// Specific fields
*[_type == "post"] { title, slug }

// Renamed fields
*[_type == "post"] { "postTitle": title }

// Computed fields
*[_type == "post"] {
  title,
  "wordCount": length(pt::text(body)),
  "readingTime": round(length(pt::text(body)) / 900)
}

// Full projection with relationships
*[_type == "post"] {
  _id,
  title,
  slug,
  "author": author-> {
    name,
    slug,
    bio
  },
  "categories": categories[]-> {
    title,
    slug
  }
}
```

**Pagination:**
```groq
// First 10
[0..9]

// Next 10 (skipping first 10)
[10..19]

// Skip 10, take 10 (exclusive)
[10...20]

// Last 5
[-5..]
```

**Advanced Functions:**
```groq
// Count
*[_type == "post"] {
  title,
  "categoryCount": count(categories)
}

// Coalesce (first non-null)
*[_type == "post"] {
  "metaTitle": coalesce(seo.metaTitle, title)
}

// Conditional
*[_type == "post"] {
  "status": select(
    defined(publishedAt) && publishedAt < now() => "Published",
    defined(publishedAt) && publishedAt > now() => "Scheduled",
    true => "Draft"
  )
}

// Score for search
*[_type == "post" && title match "sanity*"] | order(_score desc)
```

**GROQ Functions Table:**

| Function | Purpose | Example |
|----------|---------|---------|
| `count()` | Count items in an array | `count(categories)` |
| `defined()` | Check if field exists | `defined(featuredImage)` |
| `coalesce()` | First non-null value | `coalesce(title, "Untitled")` |
| `select()` | Conditional value | `select(true => "Yes")` |
| `pt::text()` | Extract text from Portable Text | `pt::text(body)` |
| `round()` | Round a number | `round(price)` |
| `now()` | Current date/time | `publishedAt < now()` |
| `references()` | Check for references | `references($id)` |

### Notes

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## PART 3: Extending Sanity Studio

### Key Concepts

**Studio Customization Points:**
1. **Schema** - Add custom fields, validation, previews
2. **Structure** - Organize the sidebar navigation
3. **Input Components** - Custom field editors
4. **Document Actions** - Custom buttons on documents
5. **Dashboard Widgets** - Stats and data views
6. **Badges** - Status indicators on documents

**Field Groups** organize fields in the Studio UI:
```typescript
groups: [
  { name: 'content', title: 'Content', default: true },
  { name: 'metadata', title: 'SEO & Metadata' },
]
```

**Custom Input Components** extend the editor:
- Use `form.components.input` in config
- Return a React component
- Use `set()` from Sanity to update values

**Document Actions** add custom functionality:
- Access via `useDocumentOperation`
- Can validate before publishing
- Can call external APIs
- Can show dialogs

### Code Snippets

**Custom Input Component:**
```typescript
// studio/components/ColorPicker.tsx
import { set, type StringInputProps } from 'sanity'

export function ColorPicker(props: StringInputProps) {
  const { value, onChange } = props
  
  const handleSelect = (color: string) => {
    onChange(set(color))
  }
  
  return (
    // Your custom input UI
  )
}
```

**Register Custom Input:**
```typescript
// sanity.config.ts
export default defineConfig({
  form: {
    components: {
      input: (props) => {
        if (props.schemaType.name === 'color') {
          return ColorPicker
        }
        return undefined
      },
    },
  },
})
```

**Custom Document Action:**
```typescript
// studio/actions/PublishWithValidation.ts
import { useDocumentOperation, type DocumentActionProps } from 'sanity'

export function PublishWithValidation(props: DocumentActionProps) {
  const { id, type, draft, published } = props
  const { publish } = useDocumentOperation(id, type)

  const handlePublish = () => {
    // Validate before publishing
    publish.execute()
    props.onComplete?.()
  }

  return {
    label: published ? 'Update' : 'Publish',
    disabled: !draft,
    onHandle: handlePublish,
  }
}
```

**Register Document Action:**
```typescript
// sanity.config.ts
export default defineConfig({
  document: {
    actions: (prev, context) => {
      if (context.schemaType === 'post') {
        return [
          ...prev.filter(action => action.action !== 'publish'),
          PublishWithValidation,
        ]
      }
      return prev
    },
  },
})
```

**Custom Structure:**
```typescript
// studio/structure/index.ts
export const structure = (S: StructureBuilder) => {
  const posts = S.listItem()
    .title('Blog Posts')
    .schemaType('post')
    .child(
      S.documentList()
        .title('Blog Posts')
        .filter('_type == "post"')
        .defaultOrdering([{ field: 'publishedAt', direction: 'desc' }])
    )

  return S.list()
    .title('Content')
    .items([
      posts,
      authors,
      categories,
      S.divider(),
      settings,
    ])
}
```

### Notes

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## PART 4: Real-Time Content & Visual Editing

### Key Concepts

**Live Content API**
- Real-time synchronization via WebSockets
- No polling required
- Auto-cache invalidation
- Tag-based revalidation

**Visual Editing Stack:**
1. **Presentation Tool** - Preview with click-to-edit
2. **Stega Encoding** - Editing metadata in content
3. **Draft Mode** - Preview unpublished content
4. **Live Content API** - Real-time updates

**Draft Mode Flow:**
1. Editor enables Draft Mode via URL parameter
2. Next.js enables `draftMode`
3. Client uses token to fetch drafts
4. Editor sees unpublished content

**Content Releases:**
- Batch publishing of multiple documents
- Scheduled releases
- Status tracking
- Rollback capabilities

### Code Snippets

**Live Content Client:**
```typescript
// lib/sanity/live.ts
import { defineLive } from 'next-sanity/live'
import { client } from './client'

export const { sanityFetch, SanityLive } = defineLive({
  client,
  // Automatically fetches fresh data in draft mode
})
```

**Presentation Tool Config:**
```typescript
// sanity.config.ts
import { presentationTool } from '@sanity/presentation'

export default defineConfig({
  plugins: [
    presentationTool({
      previewUrl: {
        origin: 'http://localhost:3000',
        previewMode: {
          enable: '/api/draft-mode/enable',
          disable: '/api/draft-mode/disable',
        },
      },
      resolve: {
        mainDocuments: [
          { route: '/posts/:slug', type: 'post' },
        ],
      },
    }),
  ],
})
```

**Enable Draft Mode:**
```typescript
// app/api/draft-mode/enable/route.ts
import { draftMode } from 'next/headers'
import { redirect } from 'next/navigation'

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const slug = searchParams.get('slug')
  
  const draft = await draftMode()
  draft.enable()

  if (slug) {
    redirect(`/posts/${slug}?preview=true`)
  }
  redirect('/?preview=true')
}
```

**Disable Draft Mode:**
```typescript
// app/api/draft-mode/disable/route.ts
import { draftMode } from 'next/headers'
import { redirect } from 'next/navigation'

export async function GET() {
  const draft = await draftMode()
  draft.disable()
  redirect('/')
}
```

**Stega Configuration:**
```typescript
const client = createClient({
  // ... other config
  stega: {
    enabled: process.env.NODE_ENV === 'development',
    studioUrl: 'http://localhost:3333',
  },
})
```

**Content Release Schema:**
```typescript
// schemas/release.ts
export default defineType({
  name: 'release',
  title: 'Content Release',
  type: 'document',
  fields: [
    defineField({
      name: 'title',
      title: 'Release Title',
      type: 'string',
    }),
    defineField({
      name: 'scheduledDate',
      title: 'Scheduled Release Date',
      type: 'datetime',
    }),
    defineField({
      name: 'posts',
      title: 'Posts',
      type: 'array',
      of: [{ type: 'reference', to: [{ type: 'post' }] }],
    }),
    defineField({
      name: 'status',
      title: 'Status',
      type: 'string',
      options: {
        list: [
          { title: 'Draft', value: 'draft' },
          { title: 'Scheduled', value: 'scheduled' },
          { title: 'Published', value: 'published' },
        ],
      },
    }),
  ],
})
```

### Notes

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## PART 5: React 19 & Next.js 16 Integration

### Key Concepts

**React 19 Features:**
- React Compiler (optimization)
- Improved Server Components
- Async components
- Better Suspense support

**Next.js 16 Features:**
- App Router default
- Async `params` and `searchParams` (must await)
- Server Actions (optional)
- Improved ISR

**Server Component Pattern:**
```typescript
export default async function Page() {
  const data = await fetchData()
  return <Component data={data} />
}
```

**Caching Layers:**
1. Sanity CDN (global edge cache)
2. Next.js Data Cache (server-side)
3. Browser Cache (client-side)

**Cache Revalidation:**
- Tag-based: `revalidateTag('post')`
- Path-based: `revalidatePath('/posts')`
- Time-based: `export const revalidate = 3600`

### Code Snippets

**Async Parameters (Next.js 16):**
```typescript
interface PageProps {
  params: Promise<{ slug: string }>
  searchParams: Promise<{ [key: string]: string | string[] }>
}

export default async function Page({ params, searchParams }: PageProps) {
  const { slug } = await params
  const { page } = await searchParams
  // ...
}
```

**Server Component with Fetch:**
```typescript
// app/posts/page.tsx
import { sanityFetch } from '@/sanity/live'
import { POSTS_QUERY } from '@/sanity/queries'

export default async function PostsPage() {
  const { data: posts } = await sanityFetch({
    query: POSTS_QUERY,
  })
  
  return (
    <div>
      {posts.map(post => <PostCard key={post._id} post={post} />)}
    </div>
  )
}
```

**Dynamic Metadata:**
```typescript
// app/posts/[slug]/page.tsx
export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params
  const post = await getPostBySlug(slug)
  
  if (!post) {
    return { title: 'Post Not Found' }
  }

  return {
    title: post.seo?.metaTitle || post.title,
    description: post.seo?.metaDescription || post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: post.featuredImage ? [{
        url: urlFor(post.featuredImage).url(),
        width: 1200,
        height: 630,
      }] : [],
    },
  }
}
```

**Revalidation API:**
```typescript
// app/api/revalidate/route.ts
import { revalidateTag, revalidatePath } from 'next/cache'

export async function POST(request: Request) {
  const body = await request.json()
  const { tag, path } = body

  if (tag) {
    revalidateTag(tag)
  }
  if (path) {
    revalidatePath(path)
  }

  return Response.json({ revalidated: true })
}
```

**Sitemap Generation:**
```typescript
// app/sitemap.ts
export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const posts = await getAllPosts()
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL!

  const entries = [
    { url: baseUrl, priority: 1.0 },
    { url: `${baseUrl}/posts`, priority: 0.8 },
  ]

  for (const post of posts) {
    entries.push({
      url: `${baseUrl}/posts/${post.slug.current}`,
      lastModified: new Date(post.publishedAt),
      changeFrequency: 'monthly',
      priority: 0.6,
    })
  }

  return entries
}
```

**ISR Configuration:**
```typescript
// app/posts/[slug]/page.tsx
export const revalidate = 3600 // 1 hour

export async function generateStaticParams() {
  const posts = await getAllPosts()
  return posts.map((post) => ({
    slug: post.slug.current,
  }))
}
```

**Cache Tags:**
```typescript
// lib/sanity/client.ts
export const CACHE_TAGS = {
  POST: 'post',
  AUTHOR: 'author',
  CATEGORY: 'category',
  post: (id: string) => `post:${id}`,
  author: (id: string) => `author:${id}`,
  category: (id: string) => `category:${id}`,
}

// Use in queries
export async function getPostBySlug(slug: string) {
  return client.fetch(
    POST_QUERY,
    { slug },
    { next: { tags: [CACHE_TAGS.POST, CACHE_TAGS.post(slug)] } }
  )
}
```

### Notes

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## Appendix A: CLI Commands Reference

### Sanity Commands

| Command | Description |
|---------|-------------|
| `sanity init` | Create a new Sanity project |
| `sanity dev` | Start development server |
| `sanity build` | Build for production |
| `sanity deploy` | Deploy Studio to Sanity hosting |
| `sanity start` | Start production server |
| `sanity login` | Authenticate with Sanity |
| `sanity logout` | Log out of Sanity |
| `sanity schema extract` | Extract schema to JSON |
| `sanity typegen generate` | Generate TypeScript types |
| `sanity cors add` | Add CORS origin |
| `sanity cors list` | List CORS origins |
| `sanity cors remove` | Remove CORS origin |
| `sanity dataset export` | Export dataset to file |
| `sanity dataset import` | Import dataset from file |

### NPM Commands

| Command | Description |
|---------|-------------|
| `npm install` | Install dependencies |
| `npm update` | Update dependencies |
| `npm run dev` | Run development server |
| `npm run build` | Build for production |
| `npm run start` | Start production server |
| `npm run lint` | Run linter |
| `npm run type-check` | Run TypeScript checker |

### Next.js Commands

| Command | Description |
|---------|-------------|
| `npx create-next-app@latest` | Create new Next.js project |
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm run start` | Start production server |
| `npm run lint` | Run linter |

### Notes

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## Appendix B: Troubleshooting Quick Reference

### Common Errors & Solutions

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| `'sanity' is not recognized` | CLI not installed | `npm install -g @sanity/cli` |
| `Module not found` | Missing dependency | `npm install [package-name]` |
| `Invalid schema` | Schema export error | Check your schema exports |
| `CORS error` | Domain not allowed | `sanity cors add` |
| `GROQ parse error` | Query syntax error | Check quotes and braces |
| `Port already in use` | Running process on port | Change port or kill process |
| `TypeGen: No schema found` | Missing schema extraction | Run `sanity schema extract` |
| `Expected type but got: null` | Missing field value | Add validation or default |

### Port Conflicts

```bash
# Sanity Studio
sanity dev --port 3334

# Next.js
npx next dev --port 3001

# Kill process on port
lsof -i :3333
kill -9 [PID]
```

### Cache Clearing

```bash
# Clear Next.js cache
rm -rf .next

# Clear npm cache
npm cache clean --force

# Clear Sanity cache
rm -rf node_modules/.cache/sanity
```

### Notes

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## Appendix C: Deployment Checklist

### Pre-Deployment Checklist

**Code Quality:**
- [ ] TypeScript type-check passes
- [ ] ESLint passes
- [ ] All tests pass

**Environment Variables:**
- [ ] All variables set in production
- [ ] No secrets in code

**Security:**
- [ ] CORS origins restricted
- [ ] Webhook secrets set
- [ ] API tokens are read-only where possible

**Performance:**
- [ ] `useCdn: true` configured
- [ ] Cache tags implemented
- [ ] Image optimization configured

**SEO:**
- [ ] Sitemap configured
- [ ] Robots.txt configured
- [ ] Dynamic metadata working

### Post-Deployment Checklist

**Studio:**
- [ ] Studio loads without errors
- [ ] Editor can log in
- [ ] Content displays correctly
- [ ] Custom components work

**Frontend:**
- [ ] Homepage loads
- [ ] All pages load
- [ ] Preview mode works
- [ ] Images display correctly
- [ ] Forms work

**Infrastructure:**
- [ ] SSL/HTTPS configured
- [ ] CORS origins configured
- [ ] Webhooks configured
- [ ] Health check passes

### Notes

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

**[END: Student Notes]**
