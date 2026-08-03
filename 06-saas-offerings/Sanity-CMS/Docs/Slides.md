# Mastering Sanity CMS: Comprehensive Slide Outline

## Series Overview

**Total Slides:** ~180-200 across 8 modules + primers + appendices  
**Estimated Teaching Time:** 8-10 hours (with hands-on labs)  
**Target Audience:** Developers with basic JavaScript knowledge  
**Key Framework:** Sanity v5, React 19, Next.js 16, TypeScript

---

## MODULE 0: Introduction & Course Setup
*Slides: 15 | Time: 45 minutes*

### Section 0.1: Course Overview (Slides 1-4)

**Slide 1: Title Slide**
- Series title: "Mastering Sanity CMS: Building Modern Content Platforms"
- Tagline: "From Content Modeling to Production Deployment"
- Instructor intro and credentials
- Series prerequisites: Node.js 20+, basic React/JavaScript knowledge

**Slide 2: What You'll Build**
- Architecture diagram showing the complete system
- Content Lake + Studio v5 + Next.js 16 frontend
- Key features: structured content, GROQ, visual editing, real-time updates
- Deployment targets: Vercel/Netlify

**Slide 3: Learning Outcomes**
- Design flexible, scalable content models
- Build and customize Sanity Studio v5 
- Query content efficiently using GROQ 
- Generate type-safe APIs with Sanity TypeGen
- Implement real-time content with Live Content API 
- Integrate with React 19 and Next.js 16

**Slide 4: Why This Series Matters**
- Architecture-first approach 
- Production-ready patterns from real-world e-commerce/documentation platforms 
- Modern stack: Sanity v5 + React 19 + Next.js 16
- Type-safe development end-to-end

---

### Section 0.2: The Content OS Philosophy (Slides 5-8)

**Slide 5: The Problem with Traditional CMS**
- Content locked into page templates
- Rebuilding content for each new channel
- Content as presentation, not data 

**Slide 6: Structured Content Defined**
- Information broken into smallest reasonable pieces
- Explicitly organized and classified
- Understandable by computers and humans 
- The LEGO brick analogy: reusable, composable

**Slide 7: Headless vs Traditional CMS**
- Headless separates storage (body) from presentation (head) 
- Composable approach 
- Multi-channel delivery: web, mobile, digital signage, AI
- Future-proof content

**Slide 8: Sanity's Three Layers**
- **Content Lake**: The database (structured JSON)
- **Studio**: The editing interface (React application)
- **APIs and SDKs**: GROQ queries, GraphQL, JavaScript client

---

### Section 0.3: Course Roadmap (Slides 9-11)

**Slide 9: Series Roadmap - Part 1-3**
| Part | Topic | Key Skills |
|------|-------|------------|
| 1 | Foundations of Structured Content | Schema design, Portable Text, Studio setup  |
| 2 | Querying Content with GROQ | GROQ fundamentals, TypeGen, Client configuration  |
| 3 | Extending Sanity Studio | Custom inputs, document actions, AI workflows |

**Slide 10: Series Roadmap - Part 4-5**
| Part | Topic | Key Skills |
|------|-------|------------|
| 4 | Real-Time Content & Visual Editing | Live Content API, Presentation Tool, Draft Mode  |
| 5 | React 19 & Next.js 16 Integration | Server Components, caching, revalidation  |

**Slide 11: Optional Primers & Appendices**
- **Primers 1-7**: Quick-start guides (structured content, first steps, modeling, GROQ, Studio customization, frontend integration, production features)
- **Appendices A-C**: Reference, production checklist, advanced patterns

---

### Section 0.4: Tools & Setup (Slides 12-15)

**Slide 12: Development Environment**
- Node.js 20+ or npm-compatible runtime 
- Code editor: VS Code (recommended) or Cursor 
- Sanity CLI: `npm install -g @sanity/cli` 
- Free Sanity account 

**Slide 13: Project Structure Overview**
```
mastering-sanity-cms/
├── studio/          → Sanity Studio v5
├── frontend/        → Next.js 16 application
├── shared/          → Shared types/queries (optional)
└── package.json     → Monorepo configuration
```

**Slide 14: Recommended Extensions**
- Sanity Studio: Official Sanity extension
- ESLint, Prettier, TypeScript
- GitLens, Thunder Client
- Tailwind CSS IntelliSense

**Slide 15: Key Terminology Glossary**
| Term | Definition |
|------|------------|
| GROQ | Graph-Relational Object Queries  |
| Portable Text | Structured rich text format |
| Content Lake | Sanity's hosted database |
| TypeGen | TypeScript type generator |
| Stega | Encoding for visual editing |
| ISR | Incremental Static Regeneration |

---

## MODULE 1: Foundations of Structured Content
*Slides: 25 | Time: 90 minutes*

### Section 1.1: Structured Content Fundamentals (Slides 16-19)

**Slide 16: From Blobs to Chunks**
- Traditional: Big HTML blob 
- Structured: Broken into smallest pieces
- Each piece explicitly organized and classified
- Queryable, reusable, future-proof

**Slide 17: Content Modeling Principles**
- Based on meaning and intent, not presentation 
- Think in terms of concepts: authors, posts, products
- Design for channels that don't exist yet
- Reusable vs one-off content

**Slide 18: The Building Blocks**
| Block | Purpose | Example |
|-------|---------|---------|
| Document | Top-level content with its own URL | Blog post, product, author  |
| Object | Reusable group of fields | SEO metadata, social links |
| Field | Single piece of information | Title (string), Price (number) |

**Slide 19: Schema Design Process**
1. Identify concepts (Author, Post, Category)
2. Define fields for each concept
3. Establish relationships (references)
4. Add validation rules
5. Configure previews

---

### Section 1.2: Sanity Studio Setup (Slides 20-22)

**Slide 20: Installing Sanity Studio**
```bash
npm install -g @sanity/cli
sanity init
# Select: Clean project with no predefined schemas
# Dataset: production
# TypeScript: Yes
```

**Slide 21: Project Configuration**
- `sanity.config.ts`: Main configuration 
- `sanity.cli.ts`: CLI configuration
- `.env`: Environment variables (Project ID, Dataset)
- `schemas/`: Content model definitions

**Slide 22: Starting the Studio**
```bash
sanity dev
# Opens at http://localhost:3333
```

---

### Section 1.3: Schema Design Deep Dive (Slides 23-30)

**Slide 23: Author Schema**
```typescript
// schemas/author.ts
export default defineType({
  name: 'author',
  title: 'Author',
  type: 'document',
  fields: [
    defineField({
      name: 'name',
      title: 'Name',
      type: 'string',
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      options: { source: 'name' }
    })
  ]
})
```

**Slide 24: Post Schema Overview**
- Title, Slug, Excerpt
- Featured Image (with alt, caption)
- Published Date
- Author (reference)
- Categories (array of references)
- Body (Portable Text)
- SEO (object)
- Tags (array of strings)

**Slide 25: References - Building Relationships**
```typescript
defineField({
  name: 'author',
  title: 'Author',
  type: 'reference',
  to: [{ type: 'author' }],
  validation: Rule => Rule.required()
})
```
- Dropdown selection in Studio
- Queryable relationships
- Consistency across content

**Slide 26: Portable Text Overview**
- Structured rich text as JSON
- Blocks, spans, and marks
- Custom blocks: images, code, callouts
- Queryable content (find all links, images)
- Multi-channel rendering

**Slide 27: Portable Text Configuration**
```typescript
defineField({
  name: 'body',
  title: 'Body',
  type: 'array',
  of: [
    {
      type: 'block',
      styles: [
        {title: 'Normal', value: 'normal'},
        {title: 'Heading 1', value: 'h1'},
        {title: 'Heading 2', value: 'h2'}
      ],
      marks: {
        decorators: [
          {title: 'Bold', value: 'strong'},
          {title: 'Italic', value: 'em'}
        ],
        annotations: [
          {
            name: 'link',
            title: 'URL',
            type: 'object',
            fields: [{name: 'href', title: 'URL', type: 'url'}]
          }
        ]
      }
    },
    { type: 'image' },
    { type: 'code' }
  ]
})
```

**Slide 28: Category Schema**
```typescript
export default defineType({
  name: 'category',
  title: 'Category',
  type: 'document',
  fields: [
    defineField({
      name: 'title',
      title: 'Title',
      type: 'string',
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      options: { source: 'title' }
    })
  ]
})
```

**Slide 29: Settings (Singleton)**
```typescript
export default defineType({
  name: 'settings',
  title: 'Site Settings',
  type: 'document',
  fields: [
    defineField({
      name: 'siteTitle',
      title: 'Site Title',
      type: 'string',
      validation: Rule => Rule.required()
    })
  ]
})
```

**Slide 30: Registering Schemas**
```typescript
// schemas/index.ts
import author from './author'
import post from './post'
import category from './category'
import settings from './settings'

export const schemaTypes: SchemaTypeDefinition[] = [
  author,
  post,
  category,
  settings
]
```

---

### Section 1.4: Validation & Initial Values (Slides 31-34)

**Slide 31: Validation Rules**
```typescript
validation: (Rule) => [
  Rule.required().error('Title is required'),
  Rule.min(5).error('Title must be at least 5 characters'),
  Rule.max(100).error('Title cannot exceed 100 characters'),
  Rule.custom((value) => {
    if (value && value.includes('click here')) {
      return 'Avoid "click here" in titles'
    }
    return true
  })
]
```

**Slide 32: Cross-Field Validation**
```typescript
validation: (Rule) => Rule.custom((value, context) => {
  const price = context.parent?.price
  if (value && price && value >= price) {
    return 'Sale price must be less than regular price'
  }
  return true
})
```

**Slide 33: Initial Values**
```typescript
initialValue: () => ({
  publishedAt: new Date().toISOString(),
  tags: [],
  seo: { noIndex: false }
})
```

**Slide 34: Field Groups & UI Organization**
```typescript
groups: [
  { name: 'content', title: 'Content', default: true },
  { name: 'metadata', title: 'SEO & Metadata' },
  { name: 'settings', title: 'Settings' }
]
```

---

### Section 1.5: Preview Configuration (Slides 35-37)

**Slide 35: Document Previews**
```typescript
preview: {
  select: {
    title: 'title',
    subtitle: 'excerpt',
    media: 'featuredImage',
    author: 'author.name',
    date: 'publishedAt'
  },
  prepare(selection) {
    return {
      title: selection.title || 'Untitled',
      subtitle: `By ${selection.author || 'Unknown'} • ${selection.date}`,
      media: selection.media
    }
  }
}
```

**Slide 36: Orderings**
```typescript
orderings: [
  {
    title: 'Published Date, Newest',
    name: 'publishedAtDesc',
    by: [{ field: 'publishedAt', direction: 'desc' }]
  }
]
```

**Slide 37: Best Practices Summary**
- Always add validation with friendly error messages
- Use initial values to speed up editing
- Configure previews for better editorial UX
- Group related fields for clarity
- Test schemas with real content

---

## MODULE 2: Querying Content with GROQ
*Slides: 25 | Time: 90 minutes*

### Section 2.1: GROQ Fundamentals (Slides 38-45)

**Slide 38: What is GROQ?**
- Graph-Relational Object Queries 
- "SQL for JSON" 
- Query language for content
- Filters, projections, ordering, pagination

**Slide 39: Query Structure**
```
*[<filter>]{<projection>}
```
- `*`: All documents
- `[<filter>]`: Filter conditions
- `{<projection>}`: Shape of results

**Slide 40: Basic Filters**
```groq
// All posts
*[_type == "post"]

// Posts after a date
*[_type == "post" && publishedAt > "2024-01-01"]

// Posts with author
*[_type == "post" && defined(author)]

// Posts without excerpt
*[_type == "post" && !defined(excerpt)]
```

**Slide 41: Working with References**
```groq
// Follow reference with ->
*[_type == "post"] {
  title,
  "authorName": author->name,
  "categories": categories[]-> {
    title,
    slug
  }
}
```

**Slide 42: Projections - Shaping Results**
```groq
// Rename fields
*[_type == "post"] {
  "postTitle": title,
  "url": slug.current
}

// Computed fields
*[_type == "post"] {
  title,
  "date": publishedAt[0..10],
  "readingTime": round(length(pt::text(body)) / 900)
}
```

**Slide 43: The Splat Operator (`...`)**
```groq
// Include all fields plus new ones
*[_type == "post"] {
  ...,
  "isRecent": publishedAt > "2024-01-01"
}
```

**Slide 44: Coalesce - First Non-Null**
```groq
*[_type == "post"] {
  "metaTitle": coalesce(seo.metaTitle, title),
  "description": coalesce(seo.metaDescription, excerpt, "No description")
}
```

**Slide 45: Conditional Fields**
```groq
*[_type == "post"] {
  title,
  "status": select(
    defined(publishedAt) && publishedAt < now() => "Published",
    defined(publishedAt) && publishedAt > now() => "Scheduled",
    true => "Draft"
  )
}
```

---

### Section 2.2: Ordering & Pagination (Slides 46-48)

**Slide 46: Ordering**
```groq
// Single field
*[_type == "post"] | order(publishedAt desc)

// Multiple fields
*[_type == "post"] | order(publishedAt desc, title asc)

// Score-based
*[_type == "post"] | order(_score(popularity) desc)
```

**Slide 47: Pagination**
```groq
// First 10
*[_type == "post"] [0..9]

// Next 10
*[_type == "post"] [10..19]

// Skip 10, take 10 (inclusive/exclusive)
*[_type == "post"] [10...20]

// Last 5
*[_type == "post"] [-5..]
```

**Slide 48: Array Operations**
```groq
// Count
*[_type == "post"] {
  title,
  "categoryCount": count(categories)
}

// Membership
*[_type == "post" && "technology" in categories[]->slug.current]

// Transform
*[_type == "post"] {
  "categoryNames": categories[]->title
}
```

---

### Section 2.3: Advanced GROQ (Slides 49-52)

**Slide 49: GROQ Functions**
| Function | Purpose | Example |
|----------|---------|---------|
| `count()` | Count items | `count(categories)` |
| `defined()` | Check existence | `defined(featuredImage)` |
| `coalesce()` | First non-null | `coalesce(title, "Untitled")` |
| `select()` | Conditional value | `select(true => "Yes")` |
| `pt::text()` | Extract Portable Text | `pt::text(body)` |
| `round()` | Round number | `round(price)` |
| `now()` | Current date/time | `publishedAt < now()` |

**Slide 50: Full Post Query**
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
  "categories": categories[]-> { title, slug },
  seo,
  "readingTime": round(length(pt::text(body)) / 900)
}
```

**Slide 51: Author Page Query**
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

**Slide 52: Search Query**
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
  "image": coalesce(featuredImage.asset->url, avatar.asset->url)
} | order(_score)
```

---

### Section 2.4: Sanity Client (Slides 53-56)

**Slide 53: Installing Dependencies**
```bash
npm install @sanity/client @sanity/image-url @portabletext/react
```

**Slide 54: Client Configuration**
```typescript
// lib/sanity/client.ts
import { createClient } from '@sanity/client'

export const client = createClient({
  projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
  dataset: process.env.NEXT_PUBLIC_SANITY_DATASET!,
  apiVersion: '2024-01-01',
  useCdn: process.env.NODE_ENV === 'production'
})
```

**Slide 55: Image URL Builder**
```typescript
import imageUrlBuilder from '@sanity/image-url'

const builder = imageUrlBuilder(client)

export function urlFor(source: any) {
  return builder.image(source)
}
```

**Slide 56: Live Content API**
```typescript
// lib/sanity/live.ts
import { defineLive } from 'next-sanity/live'
import { client } from './client'

export const { sanityFetch, SanityLive } = defineLive({
  client
})
```

---

### Section 2.5: Sanity TypeGen (Slides 57-60)

**Slide 57: What is TypeGen?**
- Generates TypeScript types from schemas and GROQ queries
- Ensures type safety across application 
- Eliminates runtime errors
- Automatic updates when schemas change

**Slide 58: TypeGen Configuration**
```typescript
// sanity.cli.ts
export default defineCliConfig({
  api: {
    projectId: 'your-project-id',
    dataset: 'production'
  },
  typegen: {
    path: '../../frontend/src/**/*.{ts,tsx}',
    schema: '../../frontend/sanity-schemas.json',
    generates: '../../frontend/lib/sanity/types.generated.ts'
  }
})
```

**Slide 59: Running TypeGen**
```bash
npx sanity typegen generate
# Or in watch mode
npx sanity typegen generate --watch
```

**Slide 60: Using Generated Types**
```typescript
import type { Post, Author } from './types.generated'

export async function getPostBySlug(slug: string): Promise<Post | null> {
  const query = postBySlugQuery
  return client.fetch(query, { slug })
}
```

---

## MODULE 3: Extending and Customizing Sanity Studio
*Slides: 25 | Time: 90 minutes*

### Section 3.1: Studio Structure (Slides 61-63)

**Slide 61: Custom Structure**
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
      settings
    ])
}
```

**Slide 62: Custom Document Lists**
- Filtering documents
- Custom ordering
- Custom menu items
- Singleton documents

**Slide 63: Registering Structure**
```typescript
// sanity.config.ts
import { structureTool } from 'sanity/structure'
import { structure } from './structure'

export default defineConfig({
  plugins: [
    structureTool({ structure })
  ]
})
```

---

### Section 3.2: Custom Input Components (Slides 64-67)

**Slide 64: Creating a Color Picker**
```typescript
// studio/components/ColorPicker.tsx
export function ColorPicker(props: StringInputProps) {
  const { value, onChange } = props
  const [showPicker, setShowPicker] = useState(false)

  const handleSelect = (color: string) => {
    onChange(set(color))
    setShowPicker(false)
  }

  return (
    <Stack space={2}>
      <Flex align="center" gap={3}>
        <Card
          style={{
            width: 40,
            height: 40,
            backgroundColor: value || '#ffffff',
            border: '2px solid #e0e0e0',
            borderRadius: 4,
            cursor: 'pointer'
          }}
          onClick={() => setShowPicker(!showPicker)}
        />
        <Input
          {...props.elementProps}
          value={value || ''}
          onChange={(e) => onChange(set(e.currentTarget.value))}
          placeholder="Enter hex color"
        />
      </Flex>
      {showPicker && (
        <Card padding={3} radius={2}>
          <Flex wrap="wrap" gap={1}>
            {PRESET_COLORS.map((color) => (
              <Card
                key={color}
                style={{
                  width: 32,
                  height: 32,
                  backgroundColor: color,
                  border: value === color ? '3px solid #000' : '1px solid #ddd',
                  borderRadius: 4,
                  cursor: 'pointer'
                }}
                onClick={() => handleSelect(color)}
              />
            ))}
          </Flex>
        </Card>
      )}
    </Stack>
  )
}
```

**Slide 65: Slug with Live Preview**
```typescript
// studio/components/SlugWithPreview.tsx
export function SlugWithPreview(props: StringInputProps) {
  const { value, onChange, elementProps } = props
  const [preview, setPreview] = useState('')

  useEffect(() => {
    if (value && typeof value === 'string') {
      setPreview(`/blog/${value}`)
    }
  }, [value])

  return (
    <Stack space={2}>
      <TextInput
        {...elementProps}
        value={value || ''}
        onChange={(e) => onChange(set(e.currentTarget.value))}
        placeholder="Enter URL slug..."
      />
      {preview && (
        <Card padding={2} tone="primary" radius={1}>
          <Flex align="center" gap={2}>
            <Text size={1} muted>Preview:</Text>
            <Text size={1} style={{ color: '#0066cc' }}>
              {preview}
            </Text>
          </Flex>
        </Card>
      )}
    </Stack>
  )
}
```

**Slide 66: Registering Custom Inputs**
```typescript
// sanity.config.ts
export default defineConfig({
  form: {
    components: {
      input: (props) => {
        if (props.schemaType.name === 'slug' && props.path.includes('slug')) {
          return SlugWithPreview
        }
        if (props.schemaType.name === 'string' && props.schemaType.options?.isColor) {
          return ColorPicker
        }
        return undefined
      }
    }
  }
})
```

**Slide 67: Custom Input Best Practices**
- Keep components focused on single purpose
- Provide helpful defaults
- Show previews where useful
- Handle error states gracefully
- Use Sanity UI components for consistency

---

### Section 3.3: Custom Document Actions (Slides 68-70)

**Slide 68: Publish with Validation**
```typescript
// studio/actions/PublishWithValidation.tsx
export function PublishWithValidation(props: DocumentActionProps) {
  const { id, type, draft, published } = props
  const { publish } = useDocumentOperation(id, type)

  const validate = (doc: any) => {
    const errors = []
    if (!doc.title) errors.push('Title is required')
    if (!doc.slug?.current) errors.push('Slug is required')
    if (!doc.author) errors.push('Author is required')
    return errors
  }

  const handlePublish = () => {
    const doc = draft || published
    const errors = validate(doc)
    if (errors.length > 0) {
      alert(`Please fix:\n\n- ${errors.join('\n- ')}`)
      return
    }
    publish.execute()
    props.onComplete?.()
  }

  return {
    label: published ? 'Update' : 'Publish',
    disabled: !draft,
    onHandle: handlePublish
  }
}
```

**Slide 69: Registering Document Actions**
```typescript
// sanity.config.ts
export default defineConfig({
  document: {
    actions: (prev, context) => {
      if (context.schemaType === 'post') {
        return [
          ...prev.filter(action => action.action !== 'publish'),
          PublishWithValidation
        ]
      }
      return prev
    }
  }
})
```

**Slide 70: Advanced Document Actions**
- AI summary generation 
- External API integration
- Custom publishing workflows
- Document duplication
- Batch operations

---

### Section 3.4: Dashboard Widgets (Slides 71-73)

**Slide 71: Content Stats Widget**
```typescript
// studio/widgets/StatsWidget.tsx
export function StatsWidget() {
  const [stats, setStats] = useState({ posts: 0, authors: 0 })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchStats = async () => {
      const [posts, authors] = await Promise.all([
        client.fetch('count(*[_type == "post"])'),
        client.fetch('count(*[_type == "author"])')
      ])
      setStats({ posts, authors })
      setLoading(false)
    }
    fetchStats()
  }, [])

  if (loading) return <Spinner />
  
  return (
    <Card padding={4}>
      <Stack space={3}>
        <Text weight="bold">Content Overview</Text>
        <Flex gap={4}>
          <Stack>
            <Text size={4} weight="bold">{stats.posts}</Text>
            <Text size={1} muted>Posts</Text>
          </Stack>
          <Stack>
            <Text size={4} weight="bold">{stats.authors}</Text>
            <Text size={1} muted>Authors</Text>
          </Stack>
        </Flex>
      </Stack>
    </Card>
  )
}
```

**Slide 72: Registering Dashboard Widgets**
```typescript
// sanity.config.ts
import { dashboardTool } from '@sanity/dashboard'
import { StatsWidget } from './widgets/StatsWidget'

export default defineConfig({
  plugins: [
    dashboardTool({
      widgets: [
        {
          name: 'stats-widget',
          title: 'Content Stats',
          component: StatsWidget,
          layout: { width: 'small' }
        }
      ]
    })
  ]
})
```

**Slide 73: Widget Best Practices**
- Fetch data efficiently (parallel requests)
- Show loading states
- Handle errors gracefully
- Use Sanity UI components
- Auto-refresh when appropriate

---

### Section 3.5: AI-Assisted Workflows (Slides 74-76)

**Slide 74: AI Assistant Integration**
- Schema generation with Cursor/Claude 
- Automatic summaries
- Metadata generation
- Automated alt-text creation
- Translation workflows

**Slide 75: Agent Actions**
- Batteries-included schema-aware AI 
- Create, modify, translate documents using natural language 
- Reduce time spent on repetitive tasks
- Lower barrier to entry for content creation 

**Slide 76: AI Best Practices**
- Always review AI-generated content
- Use AI for suggestions, not final decisions
- Provide clear context to AI tools
- Test AI outputs before deploying
- Consider privacy implications

---

## MODULE 4: Real-Time Content & Visual Editing
*Slides: 20 | Time: 75 minutes*

### Section 4.1: Live Content API (Slides 77-79)

**Slide 77: What is the Live Content API?**
- Real-time synchronization between Studio and frontend 
- Live updates without polling 
- Automatic cache invalidation 
- Tag-based revalidation

**Slide 78: Configuring Live Content**
```typescript
// lib/sanity/live.ts
import { defineLive } from 'next-sanity/live'
import { client } from './client'

export const { sanityFetch, SanityLive } = defineLive({
  client,
  // Automatically fetches fresh data in draft mode
})
```

**Slide 79: Using Live Content in Components**
```typescript
// app/posts/page.tsx
import { sanityFetch } from '@/sanity/live'
import { POSTS_QUERY } from '@/sanity/queries'

export default async function Page() {
  const { data: posts } = await sanityFetch({
    query: POSTS_QUERY
  })
  
  return <PostList posts={posts} />
}
```

---

### Section 4.2: Visual Editing (Slides 80-83)

**Slide 80: Presentation Tool**
- Visual editing interface 
- Click on content → edit in Studio 
- Live preview with Draft Mode
- Stega encoding for secure editing

**Slide 81: Installing Presentation Tool**
```bash
npm install @sanity/presentation
```

**Slide 82: Configuring Presentation Tool**
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
          disable: '/api/draft-mode/disable'
        }
      },
      resolve: {
        mainDocuments: [
          { route: '/posts/:slug', type: 'post' }
        ]
      }
    })
  ]
})
```

**Slide 83: Draft Mode API**
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
    redirect(`/posts/${slug}`)
  }
  redirect('/')
}
```

---

### Section 4.3: Stega Encoding (Slides 84-86)

**Slide 84: What is Stega?**
- Steganographic encoding 
- Embeds editing information in content
- Enables click-to-edit in Presentation Tool
- Secure and efficient

**Slide 85: Stega Configuration**
```typescript
const client = createClient({
  projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
  dataset: process.env.NEXT_PUBLIC_SANITY_DATASET!,
  apiVersion: '2024-01-01',
  useCdn: process.env.NODE_ENV === 'production',
  stega: {
    enabled: process.env.NODE_ENV === 'development',
    studioUrl: 'http://localhost:3333'
  }
})
```

**Slide 86: stegaClean**
```typescript
import { stegaClean } from '@sanity/client/stega'

// Clean stega-encoded text for display
const cleanText = stegaClean(textWithStega)
```

---

### Section 4.4: Content Releases (Slides 87-89)

**Slide 87: Release Schema**
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
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'scheduledDate',
      title: 'Scheduled Release Date',
      type: 'datetime'
    }),
    defineField({
      name: 'posts',
      title: 'Posts',
      type: 'array',
      of: [{ type: 'reference', to: [{ type: 'post' }] }]
    }),
    defineField({
      name: 'status',
      title: 'Status',
      type: 'string',
      options: {
        list: [
          { title: 'Draft', value: 'draft' },
          { title: 'Scheduled', value: 'scheduled' },
          { title: 'Published', value: 'published' }
        ]
      }
    })
  ]
})
```

**Slide 88: Release Manager Component**
- Lists all releases
- Shows status and scheduled date
- Publish all posts in release
- Delete/cancel releases
- Filter by status

**Slide 89: Publishing Workflow**
1. Create release
2. Add posts
3. Set scheduled date
4. Click "Publish"
5. All posts updated with publishedAt
6. Release status changes to "Published"

---

## MODULE 5: React 19 & Next.js 16 Integration
*Slides: 25 | Time: 90 minutes*

### Section 5.1: Setting Up Next.js 16 (Slides 90-93)

**Slide 90: Project Setup**
```bash
npx create-next-app@latest frontend --typescript --tailwind --app
cd frontend
npm install @sanity/client @sanity/image-url @portabletext/react
npm install -D @sanity/types
```

**Slide 91: Next.js Configuration**
```typescript
// next.config.ts
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'cdn.sanity.io',
        pathname: '/images/**'
      }
    ],
    formats: ['image/avif', 'image/webp']
  },
  experimental: {
    reactCompiler: true,
    optimizeServerReact: true
  }
}
```

**Slide 92: Environment Variables**
```env
NEXT_PUBLIC_SANITY_PROJECT_ID=your-project-id
NEXT_PUBLIC_SANITY_DATASET=production
NEXT_PUBLIC_SANITY_API_VERSION=2024-01-01
```

**Slide 93: App Router Structure**
```
app/
├── (frontend)/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── posts/
│   │   ├── page.tsx
│   │   └── [slug]/
│   │       └── page.tsx
│   └── authors/
│       └── [slug]/
│           └── page.tsx
├── api/
│   ├── revalidate/
│   └── preview/
└── layout.tsx
```

---

### Section 5.2: React Server Components (Slides 94-97)

**Slide 94: What are Server Components?**
- Render on the server
- Fetch data directly
- No client-side JavaScript
- Better performance and SEO
- Automatic code splitting

**Slide 95: Fetching Content in Server Components**
```typescript
// app/posts/page.tsx
import { sanityFetch } from '@/sanity/live'
import { POSTS_QUERY } from '@/sanity/queries'

export default async function PostsPage() {
  const { data: posts } = await sanityFetch({
    query: POSTS_QUERY
  })
  
  return (
    <div>
      {posts.map(post => (
        <PostCard key={post._id} post={post} />
      ))}
    </div>
  )
}
```

**Slide 96: Async Route Parameters (Next.js 16)**
```typescript
// app/posts/[slug]/page.tsx
interface PageProps {
  params: Promise<{ slug: string }>
}

export default async function PostPage({ params }: PageProps) {
  const { slug } = await params
  const post = await getPostBySlug(slug)
  // ...
}
```

**Slide 97: generateStaticParams for ISR**
```typescript
export async function generateStaticParams() {
  const posts = await getAllPosts()
  return posts.map((post) => ({
    slug: post.slug.current
  }))
}

export const revalidate = 3600 // Revalidate every hour
```

---

### Section 5.3: Portable Text Rendering (Slides 98-101)

**Slide 98: Portable Text Components**
```typescript
// components/PortableText.tsx
import { PortableText as PortableTextComponent } from '@portabletext/react'

const components = {
  block: {
    h1: ({ children }) => (
      <h1 className="text-4xl font-bold mt-8 mb-4">{children}</h1>
    ),
    h2: ({ children }) => (
      <h2 className="text-3xl font-bold mt-6 mb-3">{children}</h2>
    ),
    normal: ({ children }) => (
      <p className="mb-4 leading-relaxed">{children}</p>
    )
  },
  types: {
    image: ({ value }) => (
      <Image
        src={urlFor(value).url()}
        alt={value.alt || ''}
        width={800}
        height={600}
        className="rounded-lg"
      />
    )
  },
  marks: {
    link: ({ value, children }) => (
      <a href={value?.href} className="text-blue-600 hover:underline">
        {children}
      </a>
    )
  }
}

export function PortableText({ value }) {
  return <PortableTextComponent value={value} components={components} />
}
```

**Slide 99: Rendering Code Blocks**
```typescript
types: {
  code: ({ value }) => (
    <div className="my-4 rounded-lg overflow-hidden">
      <div className="bg-gray-800 text-white px-4 py-2 text-sm font-mono">
        {value.language || 'code'}
      </div>
      <pre className="bg-gray-900 text-white p-4 overflow-x-auto">
        <code>{value.code}</code>
      </pre>
    </div>
  )
}
```

**Slide 100: Rendering Callouts**
```typescript
types: {
  callout: ({ value }) => {
    const colors = {
      info: 'bg-blue-50 border-blue-200',
      warning: 'bg-yellow-50 border-yellow-200',
      error: 'bg-red-50 border-red-200',
      success: 'bg-green-50 border-green-200'
    }
    return (
      <div className={`border-l-4 p-4 my-4 rounded ${colors[value.type]}`}>
        <div className="font-semibold mb-1">
          {value.type.charAt(0).toUpperCase() + value.type.slice(1)}
        </div>
        <PortableText value={value.content} />
      </div>
    )
  }
}
```

**Slide 101: Safe HTML Rendering**
- Portable Text stores structured data, not HTML
- No risk of XSS from inline HTML
- Sanitization built into the rendering process
- Control exactly what tags and attributes are allowed

---

### Section 5.4: Caching & Revalidation (Slides 102-106)

**Slide 102: Caching Strategy**
```
┌─────────────────────────────────────────────┐
│              Caching Layers                  │
├─────────────────────────────────────────────┤
│ 1. Sanity CDN (global edge cache)           │
│ 2. Next.js Data Cache (server-side)         │
│ 3. Browser Cache (client-side)              │
└─────────────────────────────────────────────┘
```

**Slide 103: Tag-Based Revalidation**
```typescript
// lib/sanity/client.ts
export const CACHE_TAGS = {
  POST: 'post',
  AUTHOR: 'author',
  CATEGORY: 'category',
  post: (id: string) => `post:${id}`,
  author: (id: string) => `author:${id}`
}

// lib/sanity/queries.ts
export async function getPostBySlug(slug: string) {
  return client.fetch(
    POST_QUERY,
    { slug },
    { next: { tags: [CACHE_TAGS.POST, CACHE_TAGS.post(slug)] } }
  )
}
```

**Slide 104: Revalidation API**
```typescript
// app/api/revalidate/route.ts
import { revalidateTag } from 'next/cache'

export async function POST(request: Request) {
  const body = await request.json()
  const { type, id, tag } = body

  if (tag) {
    revalidateTag(tag)
  } else if (type && id) {
    revalidateTag(`${type}:${id}`)
    revalidateTag(type)
  } else if (type) {
    revalidateTag(type)
  }

  return Response.json({ revalidated: true })
}
```

**Slide 105: Webhook Configuration**
```bash
# Sanity Dashboard → Settings → API → Webhooks
URL: https://your-domain.com/api/revalidate
HTTP Method: POST
Secret: your-webhook-secret
Trigger: Create, Update, Delete
Filter: Document types (post, author, category)
```

**Slide 106: Caching Best Practices**
- Use `sanityFetch` from `next-sanity/live` for automatic caching 
- Add cache tags for granular revalidation
- Use ISR with `revalidate` for static pages
- Implement on-demand revalidation for critical content
- Test cache invalidation before deployment

---

### Section 5.5: SEO & Metadata (Slides 107-110)

**Slide 107: Dynamic Metadata**
```typescript
// app/posts/[slug]/page.tsx
export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const post = await getPostBySlug(params.slug)
  
  if (!post) {
    return { title: 'Post Not Found' }
  }

  return {
    title: post.seo?.metaTitle || post.title,
    description: post.seo?.metaDescription || post.excerpt || '',
    openGraph: {
      title: post.seo?.metaTitle || post.title,
      description: post.seo?.metaDescription || post.excerpt || '',
      images: post.featuredImage ? [{
        url: urlFor(post.featuredImage).url(),
        width: 1200,
        height: 630,
        alt: post.featuredImage.alt || post.title
      }] : [],
      type: 'article',
      publishedTime: post.publishedAt
    },
    twitter: {
      card: 'summary_large_image',
      title: post.seo?.metaTitle || post.title,
      description: post.seo?.metaDescription || post.excerpt || '',
      images: post.featuredImage ? [urlFor(post.featuredImage).url()] : []
    },
    robots: {
      index: !post.seo?.noIndex,
      follow: !post.seo?.noIndex
    }
  }
}
```

**Slide 108: Sitemap Generation**
```typescript
// app/sitemap.ts
export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL
  
  const posts = await getAllPosts()
  
  const entries = [
    { url: baseUrl, priority: 1.0 },
    { url: `${baseUrl}/posts`, priority: 0.8 }
  ]
  
  for (const post of posts) {
    entries.push({
      url: `${baseUrl}/posts/${post.slug.current}`,
      lastModified: new Date(post.publishedAt),
      changeFrequency: 'monthly',
      priority: 0.6
    })
  }
  
  return entries
}
```

**Slide 109: Robots.txt**
```typescript
// app/robots.ts
export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/api/', '/studio/']
    },
    sitemap: 'https://your-domain.com/sitemap.xml'
  }
}
```

**Slide 110: SEO Best Practices**
- Unique meta titles (50-60 characters)
- Compelling meta descriptions (150-160 characters)
- Open Graph images (1200x630 recommended)
- Structured data (JSON-LD) for rich snippets
- Proper heading hierarchy (h1, h2, h3)
- Clean URL structure (/posts/slug)

---

## MODULE 6: Advanced Patterns
*Slides: 20 | Time: 75 minutes*

### Section 6.1: Multi-Language Content (Slides 111-114)

**Slide 111: Language Strategies**
| Strategy | Use Case | Pros | Cons |
|----------|----------|------|------|
| Field-level | Small sites, limited languages | Single document | Large documents |
| Document-level | Dedicated language pages | Complete separation | Duplicate content |
| Dataset-level | Enterprise, many languages | Total isolation | Complex management |

**Slide 112: Field-Level Translations**
```typescript
defineField({
  name: 'title',
  title: 'Title',
  type: 'object',
  fields: [
    { name: 'en', title: 'English', type: 'string' },
    { name: 'es', title: 'Spanish', type: 'string' },
    { name: 'fr', title: 'French', type: 'string' }
  ]
})

// Query with language parameter
`*[_type == "post" && slug.current == $slug][0] {
  "title": title[$lang]
}`
```

**Slide 113: Language Selector Component**
```typescript
'use client'

export function LanguageSelector() {
  const [currentLang, setCurrentLang] = useState('en')
  
  return (
    <select
      value={currentLang}
      onChange={(e) => {
        const url = new URL(window.location.href)
        url.searchParams.set('lang', e.target.value)
        window.location.href = url.toString()
      }}
    >
      <option value="en">🇺🇸 English</option>
      <option value="es">🇪🇸 Spanish</option>
      <option value="fr">🇫🇷 French</option>
    </select>
  )
}
```

**Slide 114: Language Detection**
```typescript
// lib/i18n.ts
export function getLanguage(request: Request) {
  // Check URL param
  const url = new URL(request.url)
  const langParam = url.searchParams.get('lang')
  if (langParam) return langParam
  
  // Check cookie
  const cookie = request.headers.get('cookie')
  if (cookie) {
    const match = cookie.match(/preferred-language=([^;]+)/)
    if (match) return match[1]
  }
  
  // Check Accept-Language header
  const accept = request.headers.get('accept-language')
  if (accept) {
    const langs = parseAcceptLanguage(accept)
    return langs[0] || 'en'
  }
  
  return 'en'
}
```

---

### Section 6.2: E-Commerce Integration (Slides 115-118)

**Slide 115: E-Commerce Schema**
```typescript
// schemas/product.ts
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
      name: 'sku',
      title: 'SKU',
      type: 'string',
      validation: Rule => Rule.required().unique()
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
      name: 'inventory',
      title: 'Inventory',
      type: 'object',
      fields: [
        { name: 'quantity', title: 'Quantity', type: 'number' },
        { name: 'inStock', title: 'In Stock', type: 'boolean' }
      ]
    }),
    defineField({
      name: 'images',
      title: 'Product Images',
      type: 'array',
      of: [{ type: 'image', options: { hotspot: true } }]
    })
  ]
})
```

**Slide 116: Shopping Cart API**
```typescript
// app/api/cart/route.ts
export async function POST(request: Request) {
  const body = await request.json()
  const { productId, quantity = 1 } = body
  
  // Fetch product details from Sanity
  const product = await client.fetch(`
    *[_type == "product" && _id == $productId][0] {
      _id, name, price, salePrice
    }
  `, { productId })
  
  if (!product) {
    return Response.json({ error: 'Product not found' }, { status: 404 })
  }
  
  // Add to cart (using a database in production)
  const cart = await getCart(request)
  cart.items.push({
    productId,
    quantity,
    product: {
      name: product.name,
      price: product.salePrice || product.price
    }
  })
  
  await saveCart(cart)
  return Response.json(cart)
}
```

**Slide 117: Product Filters**
```typescript
// app/api/products/route.ts
export async function GET(request: Request) {
  const url = new URL(request.url)
  const category = url.searchParams.get('category')
  const minPrice = url.searchParams.get('minPrice')
  const maxPrice = url.searchParams.get('maxPrice')
  const inStock = url.searchParams.get('inStock') === 'true'
  const sortBy = url.searchParams.get('sortBy') || 'popularity'
  
  let query = '*[_type == "product"'
  const params: Record<string, any> = {}
  
  if (category) {
    query += ' && $category in categories[]->slug.current'
    params.category = category
  }
  
  if (minPrice || maxPrice) {
    query += ' && price >= $minPrice && price <= $maxPrice'
    params.minPrice = Number(minPrice) || 0
    params.maxPrice = Number(maxPrice) || 1000
  }
  
  if (inStock) {
    query += ' && inventory.inStock == true'
  }
  
  query += ']'
  
  // Add sorting
  const sortMap: Record<string, string> = {
    'price-asc': ' | order(price asc)',
    'price-desc': ' | order(price desc)',
    'name-asc': ' | order(name asc)',
    'name-desc': ' | order(name desc)'
  }
  query += sortMap[sortBy] || ''
  
  const products = await client.fetch(query, params)
  return Response.json(products)
}
```

**Slide 118: Checkout Flow**
1. User adds products to cart
2. Cart stored in database or cookie
3. User proceeds to checkout
4. Sanity product data used for order summary
5. Payment processed by commerce engine
6. Order confirmation sent

---

### Section 6.3: Third-Party Integrations (Slides 119-121)

**Slide 119: Algolia Search Integration**
```typescript
// studio/scripts/index-to-algolia.ts
import algoliasearch from 'algoliasearch'
import { getCliClient } from 'sanity/cli'

const algoliaClient = algoliasearch(
  process.env.ALGOLIA_APP_ID!,
  process.env.ALGOLIA_WRITE_KEY!
)

async function initialSync() {
  const sanityClient = getCliClient()
  
  const posts = await sanityClient.fetch(`
    *[_type == "post"] {
      _id,
      title,
      slug,
      content: pt::text(body),
      _updatedAt
    }
  `)
  
  const algoliaRecords = posts.map(post => ({
    objectID: post._id,
    title: post.title,
    slug: post.slug.current,
    content: post.content,
    _updatedAt: post._updatedAt
  }))
  
  await algoliaClient.saveObjects({
    indexName: 'posts',
    objects: algoliaRecords
  })
}
```

**Slide 120: MailChimp Newsletter**
```typescript
// app/api/newsletter/route.ts
export async function POST(request: Request) {
  const { email, name } = await request.json()
  
  const response = await fetch(
    `https://${process.env.MAILCHIMP_SERVER_PREFIX}.api.mailchimp.com/3.0/lists/${process.env.MAILCHIMP_LIST_ID}/members`,
    {
      method: 'POST',
      headers: {
        'Authorization': `apikey ${process.env.MAILCHIMP_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email_address: email,
        status: 'subscribed',
        merge_fields: { FNAME: name || '' }
      })
    }
  )
  
  const data = await response.json()
  
  if (response.status >= 400 && data.title !== 'Member Exists') {
    throw new Error(data.detail || 'Subscription failed')
  }
  
  return Response.json({
    success: true,
    message: data.title === 'Member Exists' ? 'Already subscribed!' : 'Successfully subscribed!'
  })
}
```

**Slide 121: Webhook Automation**
```typescript
// studio/functions/sync-to-algolia.ts
import { defineFunction } from 'sanity/functions'
import algoliasearch from 'algoliasearch'

export default defineFunction({
  name: 'sync-to-algolia',
  docs: {
    description: 'Sync documents to Algolia search index'
  },
  on: 'document.*', // Trigger on all document changes
  execute: async ({ document, delta }) => {
    const algoliaClient = algoliasearch(
      process.env.ALGOLIA_APP_ID!,
      process.env.ALGOLIA_WRITE_KEY!
    )
    
    if (delta.operation === 'delete') {
      await algoliaClient.deleteObject({
        indexName: 'posts',
        objectID: document._id
      })
      return { success: true }
    }
    
    const record = {
      objectID: document._id,
      title: document.title,
      slug: document.slug.current,
      content: document.body ? ptText(document.body) : '',
      _updatedAt: document._updatedAt
    }
    
    await algoliaClient.saveObject({
      indexName: 'posts',
      object: record
    })
    
    return { success: true }
  }
})
```

---

## MODULE 7: Production & Deployment
*Slides: 20 | Time: 75 minutes*

### Section 7.1: Production Readiness (Slides 122-127)

**Slide 122: Security Checklist**
- ✅ API tokens as environment variables
- ✅ CORS origins restricted to production domains
- ✅ Read-only tokens for frontend
- ✅ Draft mode authentication
- ✅ Webhook secret validation
- ✅ HTTPS configured

**Slide 123: Performance Checklist**
- ✅ `useCdn: true` for production
- ✅ ISR configured with `revalidate`
- ✅ Cache tags for granular revalidation
- ✅ Image optimization with Next.js Image
- ✅ Lazy loading for images
- ✅ Bundle analysis completed

**Slide 124: CORS Configuration**
```bash
# Add production domain
sanity cors add https://your-domain.com --credentials

# Add preview domain
sanity cors add https://your-preview.vercel.app --credentials

# List CORS origins
sanity cors list
```

**Slide 125: Environment Variables**
```env
# Frontend (.env.production)
NEXT_PUBLIC_SANITY_PROJECT_ID=abc123
NEXT_PUBLIC_SANITY_DATASET=production
NEXT_PUBLIC_SANITY_API_VERSION=2024-01-01
NEXT_PUBLIC_BASE_URL=https://your-domain.com
SANITY_READ_TOKEN=sk_prod_xyz
REVALIDATION_SECRET=your-webhook-secret

# Studio (.env)
SANITY_STUDIO_PREVIEW_URL=https://your-domain.com
```

**Slide 126: Error Handling**
- React error boundaries for client components
- Custom 404 pages
- Fallback content for missing data
- Error logging (Sentry, LogRocket)
- Graceful degradation

**Slide 127: Monitoring**
- Vercel Analytics (or Google Analytics)
- Performance monitoring (Lighthouse CI)
- Uptime monitoring (Pingdom, UptimeRobot)
- Error tracking (Sentry)
- Health check endpoints

---

### Section 7.2: Deployment (Slides 128-133)

**Slide 128: Vercel Deployment**
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy to Vercel
vercel --prod

# Or connect GitHub repo:
# 1. Push to GitHub
# 2. Import project in Vercel
# 3. Add environment variables
# 4. Deploy
```

**Slide 129: Studio Deployment**
```bash
cd studio
sanity build    # Build production assets
sanity deploy   # Deploy to Sanity hosting
# Output: https://your-studio.sanity.studio
```

**Slide 130: Netlify Deployment**
- Connect GitHub repository
- Build command: `npm run build`
- Publish directory: `.next`
- Add environment variables
- Deploy

**Slide 131: Deployment Checklist**
- [ ] Build completes without errors
- [ ] All environment variables set
- [ ] CORS configured for production domain
- [ ] SSL/HTTPS enabled
- [ ] CDN enabled
- [ ] Cache headers configured
- [ ] Health check passes

**Slide 132: Post-Deployment Testing**
- [ ] All pages load correctly
- [ ] Content displays properly
- [ ] Images load from Sanity CDN
- [ ] Forms work correctly
- [ ] Search works
- [ ] Preview mode works
- [ ] Lighthouse scores > 90

**Slide 133: Rollback Strategy**
```bash
# Vercel - revert to previous deployment
vercel rollback

# Manual rollback
git revert <commit-hash>
git push
vercel --prod
```

---

### Section 7.3: Maintenance (Slides 134-136)

**Slide 134: Regular Maintenance Tasks**

| Frequency | Tasks |
|-----------|-------|
| Daily | Monitor error logs, check uptime |
| Weekly | Review Lighthouse scores, check Core Web Vitals |
| Monthly | Update dependencies, review security patches |
| Quarterly | Full performance audit, security audit, backup check |

**Slide 135: Update Process**
```bash
# 1. Update dependencies
npm update

# 2. Run tests
npm run test

# 3. Build for production
npm run build

# 4. Deploy to staging
vercel --prebuilt

# 5. Test staging

# 6. Deploy to production
vercel --prod
```

**Slide 136: Backup Strategy**
```bash
# Export dataset
sanity dataset export production backup-$(date +%Y%m%d).tar.gz

# Restore dataset
sanity dataset import backup.tar.gz production --replace

# Schedule with cron (daily at 2 AM)
0 2 * * * cd /path/to/studio && sanity dataset export production backup-$(date +\%Y\%m\%d).tar.gz
```

---

## MODULE 8: Appendices & Reference
*Slides: 30 | Time: 30 minutes (reference)*

### Section 8.1: Appendix A - Portable Text Reference (Slides 137-140)

**Slide 137: Portable Text Structure**
```typescript
// Basic Portable Text array
[
  {
    "_type": "block",
    "_key": "abc123",
    "style": "normal",
    "children": [
      {
        "_type": "span",
        "text": "Hello, ",
        "marks": []
      },
      {
        "_type": "span",
        "text": "world",
        "marks": ["strong"]
      }
    ],
    "markDefs": []  // Definitions for annotations
  }
]
```

**Slide 138: Block Types**
- `block`: Paragraph, heading, quote
- `image`: Inline images
- `code`: Code blocks with syntax highlighting
- `callout`: Info, warning, error, success
- Custom: Any React component

**Slide 139: Custom Annotations**
```typescript
marks: {
  annotations: [
    {
      name: 'internalLink',
      title: 'Internal Link',
      type: 'object',
      fields: [
        {
          name: 'reference',
          title: 'Reference',
          type: 'reference',
          to: [{ type: 'post' }, { type: 'author' }]
        }
      ]
    }
  ]
}
```

**Slide 140: Portable Text Best Practices**
- Use semantic styles (h1, h2, blockquote)
- Always provide alt text for images
- Keep custom blocks focused and reusable
- Test rendering across all platforms
- Use `pt::text()` for text extraction

---

### Section 8.2: Appendix B - GROQ Quick Reference (Slides 141-145)

**Slide 141: Query Operators**
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

**Slide 142: Special Fields**
| Field | Description |
|-------|-------------|
| `_id` | Document ID |
| `_type` | Document type |
| `_createdAt` | Creation timestamp |
| `_updatedAt` | Last update timestamp |
| `_rev` | Revision ID |
| `^` | Current document (for nested queries) |

**Slide 143: Common Query Patterns**
| Pattern | GROQ |
|---------|------|
| All posts | `*[_type == "post"]` |
| Single post | `*[_type == "post" && slug.current == $slug][0]` |
| Latest posts | `*[_type == "post"] | order(publishedAt desc)[0..9]` |
| By category | `*[_type == "post" && $cat in categories[]->slug.current]` |
| By author | `*[_type == "post" && author->slug.current == $author]` |

**Slide 144: GROQ Functions Reference**
| Function | Purpose | Example |
|----------|---------|---------|
| `count()` | Count items | `count(categories)` |
| `defined()` | Check if field exists | `defined(featuredImage)` |
| `coalesce()` | First non-null value | `coalesce(title, "Untitled")` |
| `select()` | Conditional value | `select(true => "Yes")` |
| `pt::text()` | Extract text | `pt::text(body)` |
| `round()` | Round number | `round(price)` |
| `now()` | Current date/time | `publishedAt < now()` |

**Slide 145: Vision Tool Tips**
- Use "Pretty Print" for formatted results
- Save frequently used queries
- Use "Params" for variables
- Check "History" for previous queries
- Test queries before adding to code

---

### Section 8.3: Appendix C - TypeGen Reference (Slides 146-148)

**Slide 146: TypeGen Configuration**
```typescript
// sanity.cli.ts
export default defineCliConfig({
  api: {
    projectId: process.env.SANITY_STUDIO_PROJECT_ID || '',
    dataset: process.env.SANITY_STUDIO_DATASET || 'production'
  },
  typegen: {
    path: '../../frontend/src/**/*.{ts,tsx,js,jsx}',
    schema: '../../frontend/sanity-schemas.json',
    generates: '../../frontend/lib/sanity/types.generated.ts'
  }
})
```

**Slide 147: Using Generated Types**
```typescript
import type { Post, Author } from './types.generated'

// Type-safe query
export async function getPostBySlug(slug: string): Promise<Post | null> {
  const result = await client.fetch<Post>(POST_QUERY, { slug })
  return result
}
```

**Slide 148: TypeGen Commands**
```bash
# Generate types
npx sanity typegen generate

# Watch mode
npx sanity typegen generate --watch

# Custom config path
npx sanity typegen generate --config-path ./custom-config.json
```

---

### Section 8.4: Production Checklist (Slides 149-155)

**Slide 149: Security Checklist**
- [ ] API tokens in environment variables
- [ ] CORS origins restricted
- [ ] Read-only tokens for frontend
- [ ] Draft mode authentication
- [ ] Webhook secret validation
- [ ] HTTPS configured
- [ ] Security headers set

**Slide 150: Performance Checklist**
- [ ] `useCdn: true` in production
- [ ] ISR with `revalidate`
- [ ] Cache tags configured
- [ ] Image optimization
- [ ] Lazy loading implemented
- [ ] Bundle analysis completed
- [ ] Lighthouse scores > 90

**Slide 151: SEO Checklist**
- [ ] Unique meta titles
- [ ] Compelling meta descriptions
- [ ] Open Graph images
- [ ] Twitter cards
- [ ] Sitemap generated
- [ ] Robots.txt configured
- [ ] Structured data (JSON-LD)

**Slide 152: Monitoring Checklist**
- [ ] Analytics installed
- [ ] Error tracking configured
- [ ] Performance monitoring
- [ ] Uptime monitoring
- [ ] Health check endpoint
- [ ] Alerting configured

**Slide 153: Deployment Checklist**
- [ ] Build completes without errors
- [ ] All environment variables set
- [ ] CORS configured
- [ ] SSL/HTTPS enabled
- [ ] CDN enabled
- [ ] Cache headers configured
- [ ] Health check passes

**Slide 154: Post-Deployment Testing**
- [ ] All pages load correctly
- [ ] Content displays properly
- [ ] Images load from CDN
- [ ] Forms work correctly
- [ ] Search works
- [ ] Preview mode works
- [ ] Lighthouse scores verified

**Slide 155: Maintenance Checklist**
- [ ] Regular dependency updates
- [ ] Security patches applied
- [ ] Regular backups
- [ ] Performance monitoring reviewed
- [ ] Content audits scheduled

---

### Section 8.5: Troubleshooting Guide (Slides 156-160)

**Slide 156: Common Errors**
| Error | Cause | Solution |
|-------|-------|----------|
| `'sanity' is not recognized` | CLI not installed | `npm install -g @sanity/cli` |
| `Module not found` | Missing dependency | `npm install [package]` |
| `Invalid schema` | Schema export error | Check exports |
| `CORS error` | Domain not allowed | `sanity cors add` |
| `GROQ parse error` | Syntax error | Check quotes and braces |

**Slide 157: Port Conflicts**
```bash
# Sanity Studio
sanity dev --port 3334

# Next.js
npx next dev --port 3001
```

**Slide 158: Cache Clearing**
```bash
# Clear Next.js cache
rm -rf .next

# Clear npm cache
npm cache clean --force

# Clear Sanity cache
rm -rf node_modules/.cache/sanity
```

**Slide 159: Performance Issues**
- Check image optimization
- Verify caching configuration
- Analyze bundle size
- Check server response times
- Monitor API rate limits

**Slide 160: Content Not Updating**
- Check revalidation configuration
- Verify webhook setup
- Check cache tags
- Verify `useCdn` setting
- Test with `useCdn: false`

---

## APPENDIX: Additional Resources

### Slide 161: Sanity Documentation
- [Sanity Docs](https://www.sanity.io/docs)
- [GROQ Documentation](https://www.sanity.io/docs/groq)
- [Portable Text](https://www.sanity.io/docs/portable-text)
- [Sanity TypeGen](https://www.sanity.io/docs/sanity-typegen)
- [Sanity Community](https://www.sanity.io/community)

### Slide 162: Next.js Resources
- [Next.js Docs](https://nextjs.org/docs)
- [App Router](https://nextjs.org/docs/app)
- [Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components)
- [Draft Mode](https://nextjs.org/docs/app/building-your-application/configuring/draft-mode)

### Slide 163: React Resources
- [React Docs](https://react.dev)
- [React 19 Features](https://react.dev/blog/2024/12/05/react-19)
- [Hooks Reference](https://react.dev/reference/react/hooks)

### Slide 164: Community & Support
- [Sanity Slack](https://slack.sanity.io)
- [Sanity GitHub](https://github.com/sanity-io)
- [Sanity Twitter/X](https://twitter.com/sanity_io)
- [Sanity YouTube](https://youtube.com/@sanityio)

---

## TOTAL SLIDE COUNT: ~164 Slides

### Time Distribution
- **Module 0**: 15 slides, 45 minutes
- **Module 1**: 22 slides, 90 minutes
- **Module 2**: 23 slides, 90 minutes
- **Module 3**: 16 slides, 90 minutes
- **Module 4**: 13 slides, 75 minutes
- **Module 5**: 20 slides, 90 minutes
- **Module 6**: 11 slides, 75 minutes
- **Module 7**: 15 slides, 75 minutes
- **Module 8**: 29 slides, 30 minutes (reference)
- **Total**: ~164 slides, ~10 hours

### Recommended Lab Sessions| Lab | Duration | Focus |
|-----|----------|-------|
| Lab 1 | 30 min | Create schemas (Author, Post, Category) |
| Lab 2 | 30 min | Write GROQ queries in Vision tool |
| Lab 3 | 30 min | Set up Next.js frontend with Sanity |
| Lab 4 | 30 min | Customize Studio with input components |
| Lab 5 | 30 min | Implement Visual Editing |
| Lab 6 | 30 min | Deploy to Vercel/Netlify |

---

**[END: Comprehensive Slide Outline]**
