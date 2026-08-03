# Mastering Sanity CMS: Complete Lab Book

## Lab Book Overview

This lab book contains hands-on exercises that accompany the Mastering Sanity CMS tutorial series. Each lab builds on previous exercises, creating a complete content platform from scratch.

**Prerequisites:**
- Node.js 20+ installed
- VS Code or preferred editor
- Git installed
- Sanity account (free tier)

**Lab Structure:**
- Each lab has clear objectives
- Step-by-step instructions with code
- Verification tasks to confirm success
- Troubleshooting tips

---

## Lab 1: Studio Setup & First Schema

### Objectives
- Install Sanity CLI
- Create a new Sanity project
- Create and register your first schema
- Start the Studio and create content

### Duration: 30 minutes

### Step 1: Install Sanity CLI

Open your terminal and run:

```bash
npm install -g @sanity/cli
```

Verify the installation:

```bash
sanity --version
# Should output: @sanity/cli 3.x.x
```

**If you encounter permission errors on macOS/Linux:**
```bash
sudo npm install -g @sanity/cli
```

### Step 2: Create a New Project

```bash
# Create project directory
mkdir sanity-lab-1
cd sanity-lab-1

# Initialize Sanity project
sanity init
```

**Answer the prompts:**
- Select template: "Clean project with no predefined schemas"
- Project output path: `.` (current directory)
- Create new dataset: Yes
- Name your project: "Sanity Lab 1"
- Dataset name: "production"
- Dataset visibility: "Public"
- TypeScript: Yes
- Package manager: npm

### Step 3: Create Your First Schema

Create `schemas/author.ts`:

```typescript
// schemas/author.ts
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
      validation: (Rule) => Rule.required()
        .error('Author name is required'),
    }),
    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      options: {
        source: 'name',
        maxLength: 96,
      },
      validation: (Rule) => Rule.required()
        .error('Slug is required for author URLs'),
    }),
    defineField({
      name: 'bio',
      title: 'Biography',
      type: 'text',
      rows: 3,
      validation: (Rule) => Rule.max(500)
        .error('Bio must be under 500 characters'),
    }),
  ],
  preview: {
    select: {
      title: 'name',
    },
  },
})
```

### Step 4: Register the Schema

Update `schemas/index.ts`:

```typescript
// schemas/index.ts
import { SchemaTypeDefinition } from 'sanity'
import author from './author'

export const schemaTypes: SchemaTypeDefinition[] = [
  author,
]
```

### Step 5: Start the Studio

```bash
sanity dev
```

Navigate to `http://localhost:3333`

### Verification Tasks

- [ ] Studio loads without errors
- [ ] "Author" appears in document creation dropdown
- [ ] Click "Author" and see the form fields
- [ ] Create an author:
  - Name: "Jane Doe"
  - Slug: "jane-doe" (auto-generated)
  - Bio: "Jane is a writer covering technology."

✅ **Lab 1 Complete!**

### Troubleshooting

| Issue | Solution |
|-------|----------|
| `sanity: command not found` | Reinstall CLI: `npm install -g @sanity/cli` |
| Port 3333 already in use | `sanity dev --port 3334` |
| Schema doesn't appear | Check `schemas/index.ts` exports |
| Cannot save document | Check validation rules |

---

## Lab 2: Building Blog Post Schema

### Objectives
- Create a blog post schema with Portable Text
- Add validation and initial values
- Create relationships with references
- Test the schema in the Studio

### Duration: 45 minutes

### Step 1: Create the Post Schema

Create `schemas/post.ts`:

```typescript
// schemas/post.ts
import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  
  initialValue: () => ({
    publishedAt: new Date().toISOString(),
    tags: [],
  }),
  
  fields: [
    defineField({
      name: 'title',
      title: 'Title',
      type: 'string',
      validation: (Rule) => [
        Rule.required().error('Title is required'),
        Rule.min(5).error('Title must be at least 5 characters'),
        Rule.max(100).error('Title cannot exceed 100 characters'),
      ],
    }),
    
    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      options: { source: 'title' },
      validation: (Rule) => Rule.required(),
    }),
    
    defineField({
      name: 'excerpt',
      title: 'Excerpt',
      type: 'text',
      rows: 3,
      validation: (Rule) => Rule.max(200),
    }),
    
    defineField({
      name: 'publishedAt',
      title: 'Published Date',
      type: 'datetime',
      validation: (Rule) => Rule.required(),
    }),
    
    defineField({
      name: 'author',
      title: 'Author',
      type: 'reference',
      to: [{ type: 'author' }],
      validation: (Rule) => Rule.required(),
    }),
    
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
            { title: 'Heading 2', value: 'h2' },
            { title: 'Heading 3', value: 'h3' },
            { title: 'Quote', value: 'blockquote' },
          ],
          lists: [
            { title: 'Bullet', value: 'bullet' },
            { title: 'Numbered', value: 'number' },
          ],
          marks: {
            decorators: [
              { title: 'Bold', value: 'strong' },
              { title: 'Italic', value: 'em' },
              { title: 'Code', value: 'code' },
            ],
            annotations: [
              {
                name: 'link',
                title: 'URL',
                type: 'object',
                fields: [
                  {
                    name: 'href',
                    title: 'URL',
                    type: 'url',
                  },
                ],
              },
            ],
          },
        },
        {
          type: 'image',
          options: { hotspot: true },
          fields: [
            {
              name: 'alt',
              title: 'Alt Text',
              type: 'string',
              validation: (Rule) => Rule.required(),
            },
          ],
        },
      ],
    }),
  ],
  
  preview: {
    select: {
      title: 'title',
      author: 'author.name',
      date: 'publishedAt',
    },
    prepare({ title, author, date }) {
      return {
        title: title || 'Untitled',
        subtitle: author ? `By ${author} • ${date ? new Date(date).toLocaleDateString() : ''}` : '',
      }
    },
  },
})
```

### Step 2: Create Category Schema

Create `schemas/category.ts`:

```typescript
// schemas/category.ts
import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'category',
  title: 'Category',
  type: 'document',
  
  fields: [
    defineField({
      name: 'title',
      title: 'Title',
      type: 'string',
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      options: { source: 'title' },
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'description',
      title: 'Description',
      type: 'text',
    }),
  ],
})
```

### Step 3: Add Categories to Post

Update the post schema to include categories:

```typescript
// schemas/post.ts - Add this field
defineField({
  name: 'categories',
  title: 'Categories',
  type: 'array',
  of: [
    {
      type: 'reference',
      to: [{ type: 'category' }],
    },
  ],
}),
```

### Step 4: Update Schema Registry

Update `schemas/index.ts`:

```typescript
// schemas/index.ts
import { SchemaTypeDefinition } from 'sanity'
import author from './author'
import post from './post'
import category from './category'

export const schemaTypes: SchemaTypeDefinition[] = [
  author,
  post,
  category,
]
```

### Verification Tasks

- [ ] Studio starts without errors
- [ ] Post, Author, Category appear in document creation
- [ ] Create 3 categories:
  - Technology
  - Design
  - Business
- [ ] Create a post with:
  - Title: "Getting Started with Sanity"
  - Author: Jane Doe
  - Categories: Technology, Web Development
  - Body: Rich text with formatting and an image
- [ ] Post preview shows title and author

✅ **Lab 2 Complete!**

### Troubleshooting

| Issue | Solution |
|-------|----------|
| References not showing | Ensure schemas are registered in correct order |
| Body editor not working | Check Portable Text configuration syntax |
| Validation errors | Check field names and validation rules |

---

## Lab 3: Writing GROQ Queries

### Objectives
- Write basic GROQ queries in Vision tool
- Create complex queries with filtering and projection
- Query relationships between documents
- Build a search query

### Duration: 45 minutes

### Step 1: Basic Query in Vision

1. Open your Studio at `http://localhost:3333`
2. Click "Vision" in the sidebar
3. Run these queries:

**Query 1: Get all posts**
```groq
*[_type == "post"]
```

**Query 2: Get only titles and authors**
```groq
*[_type == "post"] {
  title,
  "author": author->name
}
```

**Query 3: Get published posts only**
```groq
*[_type == "post" && defined(publishedAt)] {
  title,
  publishedAt,
  "author": author->name
} | order(publishedAt desc)
```

### Step 2: Query with References

**Query 1: Get posts by category**
```groq
*[_type == "post" && "technology" in categories[]->slug.current] {
  title,
  "author": author->name,
  "categories": categories[]->title
}
```

**Query 2: Get full post with author and categories**
```groq
*[_type == "post" && slug.current == "getting-started-with-sanity"][0] {
  _id,
  title,
  slug,
  publishedAt,
  "author": author-> {
    name,
    bio,
    slug
  },
  "categories": categories[]-> {
    title,
    slug
  },
  body[] {
    ...,
    _type == "image" => {
      ...,
      asset-> {
        url,
        metadata {
          lqip,
          dimensions
        }
      }
    }
  }
}
```

### Step 3: Advanced Query

**Query 1: Posts grouped by month**
```groq
*[_type == "post"] {
  title,
  "month": publishedAt[0..6]
} | order(publishedAt desc)
```

**Query 2: Content summary**
```groq
*[_type == "post"] {
  title,
  "wordCount": length(pt::text(body)),
  "readingTime": round(length(pt::text(body)) / 900),
  "categories": categories[]->title,
  "author": author->name
}
```

**Query 3: Search query**
```groq
*[
  _type == "post" &&
  (
    title match "sanity*" ||
    pt::text(body) match "sanity*"
  )
] {
  title,
  slug,
  excerpt,
  "author": author->name,
  "categories": categories[]->title,
  "_score": score
} | order(_score desc)
```

### Step 4: Parameterized Queries

**Query with $slug parameter:**
```groq
*[_type == "post" && slug.current == $slug][0] {
  title,
  publishedAt,
  "author": author->name
}
```

**Set params in Vision:**
```json
{
  "slug": "getting-started-with-sanity"
}
```

### Verification Tasks

- [ ] All queries return expected results
- [ ] References are properly resolved (→ operator)
- [ ] Pagination queries return correct slices
- [ ] Search query returns relevant results

### Save Queries

Save your favorite queries in Vision by clicking the "Save" button. Name them:
- "All Posts"
- "Post by Slug"
- "Search Posts"

✅ **Lab 3 Complete!**

---

## Lab 4: Next.js Frontend Integration

### Objectives
- Set up a Next.js 16 project
- Configure the Sanity client
- Fetch content in Server Components
- Render Portable Text

### Duration: 60 minutes

### Step 1: Create Next.js Project

```bash
# Navigate to your project root
cd ../  # Go back to parent directory

# Create frontend
npx create-next-app@latest frontend --typescript --tailwind --app

cd frontend
```

### Step 2: Install Dependencies

```bash
npm install @sanity/client @sanity/image-url @portabletext/react
npm install -D @sanity/types
```

### Step 3: Configure Sanity Client

Create `lib/sanity/client.ts`:

```typescript
// lib/sanity/client.ts
import { createClient } from '@sanity/client'
import imageUrlBuilder from '@sanity/image-url'

// Get your project ID from sanity.json in the studio folder
// or from the Sanity dashboard
const projectId = process.env.NEXT_PUBLIC_SANITY_PROJECT_ID || 'your-project-id'
const dataset = process.env.NEXT_PUBLIC_SANITY_DATASET || 'production'
const apiVersion = '2024-01-01'

export const client = createClient({
  projectId,
  dataset,
  apiVersion,
  useCdn: process.env.NODE_ENV === 'production',
})

const builder = imageUrlBuilder(client)

export function urlFor(source: any) {
  return builder.image(source)
}
```

### Step 4: Create Environment File

Create `.env.local`:

```env
NEXT_PUBLIC_SANITY_PROJECT_ID=your-project-id
NEXT_PUBLIC_SANITY_DATASET=production
NEXT_PUBLIC_SANITY_API_VERSION=2024-01-01
```

### Step 5: Write GROQ Queries

Create `lib/sanity/queries.ts`:

```typescript
// lib/sanity/queries.ts
import { client } from './client'

export const allPostsQuery = `
  *[_type == "post"] | order(publishedAt desc) {
    _id,
    title,
    slug,
    excerpt,
    publishedAt,
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

export const postBySlugQuery = `
  *[_type == "post" && slug.current == $slug][0] {
    _id,
    title,
    slug,
    excerpt,
    publishedAt,
    body[] {
      ...,
      _type == "image" => {
        ...,
        asset-> {
          url,
          metadata {
            lqip,
            dimensions
          }
        }
      }
    },
    "author": author-> {
      name,
      slug,
      bio,
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
  }
`

export async function getAllPosts() {
  return client.fetch(allPostsQuery)
}

export async function getPostBySlug(slug: string) {
  return client.fetch(postBySlugQuery, { slug })
}
```

### Step 6: Create Portable Text Components

Create `components/PortableText.tsx`:

```typescript
// components/PortableText.tsx
import { PortableText as PortableTextComponent } from '@portabletext/react'
import Image from 'next/image'
import Link from 'next/link'
import { urlFor } from '@/lib/sanity/client'

const components = {
  block: {
    h1: ({ children }: any) => (
      <h1 className="text-4xl font-bold mt-8 mb-4">{children}</h1>
    ),
    h2: ({ children }: any) => (
      <h2 className="text-3xl font-bold mt-6 mb-3">{children}</h2>
    ),
    h3: ({ children }: any) => (
      <h3 className="text-2xl font-bold mt-4 mb-2">{children}</h3>
    ),
    normal: ({ children }: any) => (
      <p className="mb-4 leading-relaxed">{children}</p>
    ),
    blockquote: ({ children }: any) => (
      <blockquote className="border-l-4 border-gray-300 pl-4 italic my-4">
        {children}
      </blockquote>
    ),
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
      if (!value?.asset) return null
      return (
        <figure className="my-8">
          <Image
            src={urlFor(value).url()}
            alt={value.alt || ''}
            width={800}
            height={600}
            className="rounded-lg"
            placeholder="blur"
            blurDataURL={value.asset.metadata?.lqip}
          />
          {value.caption && (
            <figcaption className="text-center text-sm text-gray-500 mt-2">
              {value.caption}
            </figcaption>
          )}
        </figure>
      )
    },
  },
}

export function PortableText({ value }: { value: any }) {
  return <PortableTextComponent value={value} components={components} />
}
```

### Step 7: Create Blog Listing Page

Create `app/posts/page.tsx`:

```typescript
// app/posts/page.tsx
import { getAllPosts } from '@/lib/sanity/queries'
import Link from 'next/link'

export default async function PostsPage() {
  const posts = await getAllPosts()

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-8">All Posts</h1>
      
      <div className="space-y-6">
        {posts.map((post) => (
          <article key={post._id} className="border-b pb-6">
            <h2 className="text-2xl font-semibold">
              <Link 
                href={`/posts/${post.slug.current}`}
                className="hover:text-blue-600 transition-colors"
              >
                {post.title}
              </Link>
            </h2>
            {post.excerpt && (
              <p className="text-gray-600 mt-2">{post.excerpt}</p>
            )}
            <div className="flex gap-4 mt-2 text-sm text-gray-500">
              {post.author && <span>By {post.author.name}</span>}
              {post.publishedAt && (
                <span>{new Date(post.publishedAt).toLocaleDateString()}</span>
              )}
              {post.categories && post.categories.length > 0 && (
                <span>
                  in {post.categories.map(c => c.title).join(', ')}
                </span>
              )}
            </div>
          </article>
        ))}
      </div>
    </div>
  )
}
```

### Step 8: Create Post Detail Page

Create `app/posts/[slug]/page.tsx`:

```typescript
// app/posts/[slug]/page.tsx
import { getPostBySlug, getAllPosts } from '@/lib/sanity/queries'
import { PortableText } from '@/components/PortableText'
import { notFound } from 'next/navigation'
import Link from 'next/link'

// Generate static params at build time
export async function generateStaticParams() {
  const posts = await getAllPosts()
  return posts.map((post) => ({
    slug: post.slug.current,
  }))
}

export default async function PostPage({ params }: { params: { slug: string } }) {
  const post = await getPostBySlug(params.slug)

  if (!post) {
    notFound()
  }

  return (
    <article className="max-w-3xl mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-4">{post.title}</h1>
      
      <div className="flex flex-wrap items-center gap-4 text-sm text-gray-500 mb-8">
        {post.author && (
          <Link 
            href={`/authors/${post.author.slug.current}`}
            className="hover:text-blue-600"
          >
            {post.author.name}
          </Link>
        )}
        {post.publishedAt && (
          <span>{new Date(post.publishedAt).toLocaleDateString()}</span>
        )}
        {post.categories && post.categories.length > 0 && (
          <span>
            Categories:{' '}
            {post.categories.map((category, i) => (
              <span key={category._id}>
                <Link 
                  href={`/categories/${category.slug.current}`}
                  className="text-blue-600 hover:underline"
                >
                  {category.title}
                </Link>
                {i < post.categories.length - 1 ? ', ' : ''}
              </span>
            ))}
          </span>
        )}
      </div>

      {post.excerpt && (
        <div className="text-xl text-gray-600 border-l-4 border-gray-300 pl-4 italic mb-8">
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

### Step 9: Update Layout

Update `app/layout.tsx`:

```typescript
// app/layout.tsx
import './globals.css'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import Link from 'next/link'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'My Sanity Blog',
  description: 'A blog built with Sanity and Next.js',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <header className="border-b">
          <nav className="max-w-6xl mx-auto px-4 py-4 flex items-center gap-6">
            <Link href="/" className="text-xl font-bold hover:text-blue-600">
              My Blog
            </Link>
            <Link href="/posts" className="hover:text-blue-600">
              Posts
            </Link>
          </nav>
        </header>
        <main className="min-h-screen">
          {children}
        </main>
      </body>
    </html>
  )
}
```

### Verification Tasks

- [ ] Run `npm run dev` - no errors
- [ ] Visit `http://localhost:3000/posts` - shows all posts
- [ ] Click a post - shows full content
- [ ] Portable Text renders correctly
- [ ] Images display with blur placeholders

✅ **Lab 4 Complete!**

---

## Lab 5: Custom Studio Inputs

### Objectives
- Create a custom color picker input
- Create a slug input with preview
- Register custom inputs in the Studio
- Test custom inputs in the editor

### Duration: 45 minutes

### Step 1: Create Color Picker Component

Create `studio/components/ColorPicker.tsx`:

```typescript
// studio/components/ColorPicker.tsx
import React, { useState } from 'react'
import { Card, Flex, Text, Stack, Input } from '@sanity/ui'
import { set, type StringInputProps } from 'sanity'

const PRESET_COLORS = [
  '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
  '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9',
  '#F8C471', '#82E0AA', '#F1948A', '#85929E', '#5D6D7E',
]

export function ColorPicker(props: StringInputProps) {
  const { value, onChange, elementProps } = props
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
            cursor: 'pointer',
          }}
          onClick={() => setShowPicker(!showPicker)}
        />
        <Input
          {...elementProps}
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
                  cursor: 'pointer',
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

### Step 2: Create Slug Preview Component

Create `studio/components/SlugWithPreview.tsx`:

```typescript
// studio/components/SlugWithPreview.tsx
import React, { useState, useEffect } from 'react'
import { TextInput, Flex, Text, Box, Card, Stack } from '@sanity/ui'
import { set, type StringInputProps } from 'sanity'

export function SlugWithPreview(props: StringInputProps) {
  const { value, onChange, elementProps } = props
  const [preview, setPreview] = useState('')

  useEffect(() => {
    if (value && typeof value === 'string') {
      setPreview(`/blog/${value}`)
    } else {
      setPreview('')
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
            <Box>
              <Text size={1} muted>
                Preview:
              </Text>
            </Box>
            <Box flex={1}>
              <Text size={1} style={{ color: '#0066cc' }}>
                {preview}
              </Text>
            </Box>
          </Flex>
        </Card>
      )}
    </Stack>
  )
}
```

### Step 3: Register Custom Inputs

Update `studio/sanity.config.ts`:

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { structureTool } from 'sanity/structure'
import { visionTool } from '@sanity/vision'
import { schemaTypes } from './schemas'
import { ColorPicker } from './components/ColorPicker'
import { SlugWithPreview } from './components/SlugWithPreview'

export default defineConfig({
  projectId: process.env.SANITY_STUDIO_PROJECT_ID || '',
  dataset: process.env.SANITY_STUDIO_DATASET || 'production',
  plugins: [structureTool(), visionTool()],
  schema: {
    types: schemaTypes,
  },
  form: {
    components: {
      input: (props) => {
        // Use custom slug input for slug fields
        if (props.schemaType.name === 'slug' && props.path.includes('slug')) {
          return SlugWithPreview
        }
        // Use custom color picker for color fields
        if (props.schemaType.name === 'string' && props.schemaType.options?.isColor) {
          return ColorPicker
        }
        return undefined
      },
    },
  },
})
```

### Step 4: Add Color Field to Category

Update `schemas/category.ts`:

```typescript
// schemas/category.ts - Add this field
defineField({
  name: 'color',
  title: 'Category Color',
  type: 'string',
  description: 'Color for this category',
  options: { isColor: true },
}),
```

### Step 5: Test Custom Inputs

1. Start the Studio: `sanity dev`
2. Create/edit a post - check the slug field with preview
3. Create/edit a category - check the color picker
4. Select a color and save

### Verification Tasks

- [ ] Slug field shows URL preview
- [ ] Color picker displays preset colors
- [ ] Selected color appears in the preview box
- [ ] Values save correctly

✅ **Lab 5 Complete!**

---

## Lab 6: Visual Editing & Draft Mode

### Objectives
- Configure Presentation Tool
- Set up Draft Mode
- Create API endpoints
- Test visual editing workflow

### Duration: 45 minutes

### Step 1: Install Presentation Tool

```bash
cd studio
npm install @sanity/presentation
```

### Step 2: Configure Presentation Tool

Update `studio/sanity.config.ts`:

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { structureTool } from 'sanity/structure'
import { visionTool } from '@sanity/vision'
import { presentationTool } from '@sanity/presentation'
import { schemaTypes } from './schemas'

export default defineConfig({
  projectId: process.env.SANITY_STUDIO_PROJECT_ID || '',
  dataset: process.env.SANITY_STUDIO_DATASET || 'production',
  plugins: [
    structureTool(),
    visionTool(),
    presentationTool({
      previewUrl: {
        origin: process.env.SANITY_STUDIO_PREVIEW_URL || 'http://localhost:3000',
        previewMode: {
          enable: '/api/draft-mode/enable',
          disable: '/api/draft-mode/disable',
        },
      },
      resolve: {
        mainDocuments: [
          { route: '/posts/:slug', type: 'post' },
          { route: '/authors/:slug', type: 'author' },
        ],
      },
    }),
  ],
  schema: {
    types: schemaTypes,
  },
})
```

### Step 3: Set Environment Variables

Add to `studio/.env`:

```env
SANITY_STUDIO_PREVIEW_URL=http://localhost:3000
```

### Step 4: Create Draft Mode API

Create `frontend/app/api/draft-mode/enable/route.ts`:

```typescript
// frontend/app/api/draft-mode/enable/route.ts
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

Create `frontend/app/api/draft-mode/disable/route.ts`:

```typescript
// frontend/app/api/draft-mode/disable/route.ts
import { draftMode } from 'next/headers'
import { redirect } from 'next/navigation'

export async function GET() {
  const draft = await draftMode()
  draft.disable()
  redirect('/')
}
```

### Step 5: Update Sanity Client for Preview

Update `frontend/lib/sanity/client.ts`:

```typescript
// frontend/lib/sanity/client.ts
import { createClient } from '@sanity/client'
import { draftMode } from 'next/headers'

export async function getClient() {
  const { isEnabled: isDraftMode } = await draftMode()
  
  return createClient({
    projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
    dataset: process.env.NEXT_PUBLIC_SANITY_DATASET!,
    apiVersion: process.env.NEXT_PUBLIC_SANITY_API_VERSION || '2024-01-01',
    useCdn: !isDraftMode,
    token: isDraftMode ? process.env.SANITY_READ_TOKEN : undefined,
    perspective: isDraftMode ? 'previewDrafts' : 'published',
  })
}
```

### Step 6: Update Query Functions

Update `frontend/lib/sanity/queries.ts`:

```typescript
// frontend/lib/sanity/queries.ts
import { getClient } from './client'

export async function getPostBySlug(slug: string) {
  const client = await getClient()
  return client.fetch(postBySlugQuery, { slug })
}

export async function getAllPosts() {
  const client = await getClient()
  return client.fetch(allPostsQuery)
}
```

### Step 7: Test Visual Editing

1. **Start both servers**:
   ```bash
   # Terminal 1
   cd studio
   sanity dev
   
   # Terminal 2
   cd frontend
   npm run dev
   ```

2. **Open Studio**: `http://localhost:3333`

3. **Open Presentation Tool**: Click "Presentation" in sidebar

4. **Navigate to a post**: The preview should show in the iframe

5. **Edit content**: Click on text in the preview, edit in Studio

6. **Create draft**: Create a new post (don't publish)

7. **View in Presentation**: Draft appears with "Draft" badge

8. **Disable draft mode**: Click "Exit preview" button

### Verification Tasks

- [ ] Presentation tool loads preview
- [ ] Click-to-edit works
- [ ] Draft mode enabled
- [ ] Drafts appear with badge
- [ ] Draft mode can be disabled

✅ **Lab 6 Complete!**

---

## Lab 7: Production Deployment

### Objectives
- Build the application for production
- Deploy Next.js to Vercel
- Deploy Studio to Sanity
- Test production deployment

### Duration: 45 minutes

### Step 1: Prepare for Deployment

**Update environment variables:**

Create `frontend/.env.production`:

```env
NEXT_PUBLIC_SANITY_PROJECT_ID=your-project-id
NEXT_PUBLIC_SANITY_DATASET=production
NEXT_PUBLIC_SANITY_API_VERSION=2024-01-01
NEXT_PUBLIC_BASE_URL=https://your-domain.com
```

### Step 2: Build the Studio

```bash
cd studio

# Build production assets
sanity build

# Deploy to Sanity
sanity deploy
```

**Note your Studio URL:** `https://your-studio-name.sanity.studio`

### Step 3: Configure CORS

```bash
# Add production domain
sanity cors add https://your-domain.com --credentials

# Add preview domain (Vercel preview)
sanity cors add https://your-preview.vercel.app --credentials
```

### Step 4: Deploy to Vercel

**Option A: Using CLI**

```bash
cd frontend

# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod
```

**Option B: Using GitHub**

1. Push code to GitHub
2. Go to [Vercel](https://vercel.com)
3. Click "Add New" → "Project"
4. Import your repository
5. Configure environment variables:
   - `NEXT_PUBLIC_SANITY_PROJECT_ID`
   - `NEXT_PUBLIC_SANITY_DATASET`
   - `NEXT_PUBLIC_SANITY_API_VERSION`
   - `NEXT_PUBLIC_BASE_URL`
   - `SANITY_READ_TOKEN` (for draft mode)
6. Click "Deploy"

### Step 5: Test Production

1. **Visit your deployed site**
2. **Check all pages**:
   - Homepage
   - Posts listing
   - Individual posts
   - Author pages
3. **Test preview mode**
4. **Check performance** (Lighthouse)

### Step 6: Monitor Deployment

**Set up monitoring:**

```bash
# Add health check endpoint
# frontend/app/api/health/route.ts
import { getClient } from '@/lib/sanity/client'

export async function GET() {
  try {
    const client = await getClient()
    await client.fetch('count(*[_type == "post"])')
    return Response.json({ status: 'healthy' })
  } catch (error) {
    return Response.json({ status: 'unhealthy' }, { status: 500 })
  }
}
```

### Verification Tasks

- [ ] Studio deployed successfully
- [ ] Site deployed to Vercel
- [ ] All pages load correctly
- [ ] Content displays properly
- [ ] Images load from CDN
- [ ] Preview mode works
- [ ] Health check returns 200

### Post-Deployment Checklist

- [ ] SSL/HTTPS enabled
- [ ] CORS configured
- [ ] Environment variables set
- [ ] Lighthouse scores > 90
- [ ] Analytics installed
- [ ] Error tracking configured
- [ ] Backup strategy in place

✅ **Lab 7 Complete!**

---

## Lab 8: Building a Custom Plugin

### Objectives
- Create a Studio plugin structure
- Add custom dashboard widgets
- Package and share the plugin

### Duration: 60 minutes

### Step 1: Create Plugin Structure

```bash
mkdir sanity-plugin-stats
cd sanity-plugin-stats

npm init -y
```

Update `package.json`:

```json
{
  "name": "sanity-plugin-stats-widget",
  "version": "1.0.0",
  "description": "Content statistics widget for Sanity Studio",
  "main": "lib/index.js",
  "exports": {
    ".": "./lib/index.js",
    "./package.json": "./package.json"
  },
  "scripts": {
    "build": "tsc"
  },
  "devDependencies": {
    "@sanity/types": "^3.0.0",
    "typescript": "^5.0.0"
  },
  "peerDependencies": {
    "react": "^18.0.0",
    "sanity": "^3.0.0"
  }
}
```

Create `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "jsx": "react",
    "declaration": true,
    "outDir": "lib",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "lib"]
}
```

### Step 2: Create Plugin Component

Create `src/index.tsx`:

```typescript
// src/index.tsx
import React, { useState, useEffect } from 'react'
import { Card, Flex, Text, Stack, Spinner } from '@sanity/ui'
import { definePlugin } from 'sanity'

const StatsWidget = () => {
  const [stats, setStats] = useState({ posts: 0, authors: 0, categories: 0 })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchStats = async () => {
      try {
        // In a real plugin, you'd use the Sanity client
        // This is a simplified example
        const response = await fetch('/api/stats')
        const data = await response.json()
        setStats(data)
      } catch (err) {
        setError('Failed to load stats')
        console.error(err)
      } finally {
        setLoading(false)
      }
    }

    fetchStats()
  }, [])

  if (loading) {
    return (
      <Card padding={4}>
        <Flex align="center" justify="center">
          <Spinner />
        </Flex>
      </Card>
    )
  }

  if (error) {
    return (
      <Card padding={4} tone="critical">
        <Text>{error}</Text>
      </Card>
    )
  }

  return (
    <Card padding={4} radius={2}>
      <Stack space={3}>
        <Text weight="bold" size={1}>
          Content Overview
        </Text>
        <Flex gap={4}>
          <Stack align="center">
            <Text size={4} weight="bold">{stats.posts}</Text>
            <Text size={1} muted>Posts</Text>
          </Stack>
          <Stack align="center">
            <Text size={4} weight="bold">{stats.authors}</Text>
            <Text size={1} muted>Authors</Text>
          </Stack>
          <Stack align="center">
            <Text size={4} weight="bold">{stats.categories}</Text>
            <Text size={1} muted>Categories</Text>
          </Stack>
        </Flex>
      </Stack>
    </Card>
  )
}

export const statsPlugin = definePlugin({
  name: 'sanity-plugin-stats-widget',
  dashboard: {
    widgets: [
      {
        name: 'stats-widget',
        title: 'Content Stats',
        component: StatsWidget,
        layout: { width: 'small' },
      },
    ],
  },
})
```

### Step 3: Build the Plugin

```bash
npm run build
```

### Step 4: Install Plugin in Studio

```bash
cd ../studio
npm install ../sanity-plugin-stats-widget
```

Update `studio/sanity.config.ts`:

```typescript
// studio/sanity.config.ts
import { statsPlugin } from 'sanity-plugin-stats-widget'

export default defineConfig({
  // ... other config
  plugins: [
    // ... other plugins
    statsPlugin(),
  ],
})
```

### Step 5: Test the Plugin

```bash
sanity dev
```

Open the dashboard - you should see the stats widget.

### Verification Tasks

- [ ] Plugin builds without errors
- [ ] Plugin installs correctly
- [ ] Dashboard widget appears
- [ ] Stats display correctly
- [ ] Widget is responsive

✅ **Lab 8 Complete!**

---

## Final Project

### Build a Complete Content Platform

Combine everything you've learned to build a complete content platform:

**Requirements:**

1. **Content Models** (from Labs 1-2)
   - Author
   - Post with Portable Text
   - Category
   - Settings (singleton)

2. **GROQ Queries** (from Lab 3)
   - Homepage query
   - Post detail query
   - Search query

3. **Frontend** (from Lab 4)
   - Next.js 16 with App Router
   - All pages working
   - Portable Text rendering
   - Image optimization

4. **Custom Studio** (from Lab 5)
   - Custom input components
   - Custom document actions
   - Studio structure

5. **Visual Editing** (from Lab 6)
   - Draft Mode
   - Presentation Tool
   - Real-time updates

6. **Production** (from Lab 7)
   - Deployed site
   - Deployed Studio
   - Monitoring

**Bonus Features:**
- Search functionality
- Author archive pages
- Category pages
- RSS feed
- Newsletter signup

---

## Troubleshooting Guide

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| `sanity: command not found` | `npm install -g @sanity/cli` |
| Port conflicts | `sanity dev --port 3334` |
| CORS errors | `sanity cors add http://localhost:3000` |
| Invalid schema | Check import/export syntax |
| GROQ parse errors | Check quotes and braces |
| Missing references | Ensure schemas are registered |
| Build failures | Check TypeScript errors |

### Getting Help

- [Sanity Documentation](https://www.sanity.io/docs)
- [Sanity Community](https://www.sanity.io/community)
- [Sanity Slack](https://slack.sanity.io)
- [GitHub Issues](https://github.com/sanity-io/sanity/issues)

---

## License

This lab book is provided for educational purposes. Feel free to use the code in your own projects.

---

**[END: Lab Book]**
