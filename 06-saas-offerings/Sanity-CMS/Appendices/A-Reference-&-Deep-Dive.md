# Appendix A: Reference & Deep Dive

Welcome to the reference appendix for the Mastering Sanity CMS series. This appendix serves as a comprehensive reference guide, diving deeper into the core technologies and providing additional configuration details that complement the main tutorial. Use this section as a reference when building your own projects or troubleshooting issues.

---

## A.1 Portable Text Deep Dive

### The Concept

Portable Text is Sanity's structured content format for rich text. Unlike HTML or Markdown, Portable Text stores content as structured JSON, making it queryable, extensible, and presentation-agnostic .

**Real-world analogy**: Think of Portable Text as a LEGO blueprint versus a photograph of a finished model. The blueprint (JSON) tells you exactly how to build something, while the photograph (HTML) only shows you what it looks like. With the blueprint, you can build the same model in different colors or materials .

### Core Architecture

Portable Text is built on three core concepts :

1. **Blocks**: Units representing paragraphs, headings, or other block-level elements
2. **Spans**: The text content within blocks with optional formatting marks
3. **Marks**: Labels on text sections, either simple decorators (bold, italic) or complex annotations (links with structured data)

The fundamental shape of Portable Text is an array of blocks :

```typescript
// Basic Portable Text structure
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

### Customizing the Portable Text Editor

The Portable Text Editor (PTE) in Sanity Studio is highly configurable. You can customize styles, decorators, annotations, and even the toolbar itself .

#### Adding Custom Block Styles

```typescript
// studio/schemas/portableText.ts
export const blockContent = defineArrayMember({
  type: 'block',
  styles: [
    {title: 'Normal', value: 'normal'},
    {title: 'Heading 1', value: 'h1'},
    {title: 'Heading 2', value: 'h2'},
    {title: 'Quote', value: 'blockquote'},
    // Custom styles
    {title: 'Pull Quote', value: 'pullQuote'},
    {title: 'Code Block', value: 'codeBlock'},
    {title: 'Small Text', value: 'smallText'},
  ],
  // ... rest of configuration
})
```

#### Creating Custom Annotations

```typescript
// studio/schemas/portableText.ts
export const blockContent = defineArrayMember({
  type: 'block',
  marks: {
    annotations: [
      // Internal link annotation
      defineField({
        name: 'internalLink',
        title: 'Internal Link',
        type: 'object',
        fields: [
          {
            name: 'reference',
            title: 'Reference',
            type: 'reference',
            to: [
              {type: 'post'},
              {type: 'author'},
              {type: 'category'},
            ],
          },
        ],
      }),
      // Custom tooltip annotation
      defineField({
        name: 'tooltip',
        title: 'Tooltip',
        type: 'object',
        fields: [
          {
            name: 'text',
            title: 'Tooltip Text',
            type: 'string',
            description: 'Text that appears on hover',
          },
        ],
      }),
    ],
  },
})
```

### Disabling Markdown Behaviors

You can disable specific Markdown behaviors in the Portable Text Editor, such as automatic conversion of `#` to headings or `*` to bold/italic. This is useful when you want stricter control over content formatting .

```typescript
// studio/sanity.config.ts
export default defineConfig({
  // ... rest of config
  form: {
    components: {
      portableText: {
        plugins: (props) => {
          return props.renderDefault({
            ...props,
            plugins: {
              ...props.plugins,
              markdown: {
                enabled: false  // Disable all Markdown behaviors
              }
            }
          })
        }
      },
    },
  }
})
```

#### Disable Individual Typography Behaviors

```typescript
export default defineType({
  type: 'array',
  name: 'content',
  of: [{ type: 'block' }],
  components: {
    portableText: {
      plugins: (props) => {
        return props.renderDefault({
          ...props,
          plugins: {
            ...props.plugins,
            typography: {
              preset: 'all',  // Enable all presets
              disable: [
                'openingDoubleQuote',
                'closingDoubleQuote'
              ]
            }
          }
        })
      }
    }
  }
})
```

### Rendering Portable Text in React

When rendering Portable Text in your React or Next.js application, you can provide custom component definitions for every block type :

```typescript
// frontend/components/PortableTextComponents.tsx
import { PortableTextComponents } from '@portabletext/react'

export const components: PortableTextComponents = {
  // Block styles
  block: {
    h1: ({ children }) => <h1 className="text-4xl font-bold">{children}</h1>,
    pullQuote: ({ children }) => (
      <blockquote className="border-l-4 border-blue-500 pl-4 italic text-2xl">
        {children}
      </blockquote>
    ),
  },
  
  // Marks
  marks: {
    internalLink: ({ value, children }) => (
      <Link href={`/posts/${value.reference.slug.current}`}>
        {children}
      </Link>
    ),
    tooltip: ({ value, children }) => (
      <span className="group relative">
        {children}
        <span className="opacity-0 group-hover:opacity-100 absolute bottom-full left-1/2 transform -translate-x-1/2 bg-gray-800 text-white text-sm px-3 py-1 rounded">
          {value.text}
        </span>
      </span>
    ),
  },
}
```

---

## A.2 GROQ Reference

### The Concept

GROQ (Graph-Relational Object Queries) is Sanity's query language. It allows you to describe exactly what information your application needs, joining multiple documents and stitching together precise responses .

**Real-world analogy**: Think of GROQ as a custom order form at a restaurant. Instead of getting a fixed meal, you specify exactly what ingredients you want, how they should be prepared, and what should be excluded .

### Query Structure

A typical GROQ query follows this pattern :

```
*[ <filter> ]{ <projection> }
```

- `*` returns all documents the user can read 
- `[<filter>]` retains only documents where the filter evaluates to true
- `{<projection>}` determines how results are formatted

### Core Syntax Components

#### Filters

Filters select specific documents based on criteria :

```groq
// Select all movies from 1979 or later
*[_type == "movie" && releaseYear >= 1979]

// Select with multiple conditions
*[_type == "post" && publishedAt < now() && defined(author)]
```

#### Projections

Projections define what fields to return :

```groq
// Return only specific fields
*[_type == "movie"]{ _id, title, releaseYear }

// Create new fields with computed values
*[_type == "movie"]{
  _id,
  title,
  "decade": releaseYear - (releaseYear % 10),
  "fullTitle": title + " (" + releaseYear + ")"
}
```

#### Joins and Dereferencing

Use `->` to follow references :

```groq
// Follow a single reference
*[_type == "movie"]{
  title,
  "director": director->name
}

// Follow array of references
*[_type == "movie"]{
  title,
  "producers": producers[]->name
}
```

#### Ordering and Slicing

```groq
// Sort results
*[_type == "movie"] | order(releaseYear desc, title asc)

// Limit results
*[_type == "movie"] | order(releaseYear desc)[0...10]
```

### Perspectives

Perspectives control which version of a document is returned—published, draft, or from a content release :

```typescript
// Set perspective in client configuration
const client = createClient({
  projectId: 'YOUR_PROJECT_ID',
  dataset: 'YOUR_DATASET',
  apiVersion: '2025-02-19',
  perspective: 'published',  // Return published documents
  useCdn: true,
})

// Override per query
const drafts = await client.fetch(
  '*[_type == "article"]',
  {},
  { perspective: 'drafts', useCdn: false }
)
```

### Common GROQ Functions

| Function | Description | Example |
|----------|-------------|---------|
| `count()` | Count items in an array | `count(categories)` |
| `order()` | Sort results | `order(publishedAt desc)` |
| `references()` | Check if document references a specific ID | `references($id)` |
| `defined()` | Check if a field exists | `defined(featuredImage)` |
| `coalesce()` | Return first non-null value | `coalesce(seo.metaTitle, title)` |
| `pt::text()` | Extract plain text from Portable Text | `pt::text(body)` |

---

## A.3 Sanity TypeGen Reference

### The Concept

Sanity TypeGen generates TypeScript type definitions from your Sanity schema and GROQ queries, ensuring type safety across your entire application .

**Real-world analogy**: TypeGen is like having a personal translator who automatically converts all your content rules into TypeScript types. As your content model changes, your types update automatically.

### Configuration

#### TypeGen Configuration in `sanity.cli.ts`

Starting from Sanity v4.19.0, TypeGen configurations are managed in `sanity.cli.ts` :

```typescript
// studio/sanity.cli.ts
import { defineCliConfig } from 'sanity/cli'

export default defineCliConfig({
  api: {
    projectId: process.env.SANITY_STUDIO_PROJECT_ID || '',
    dataset: process.env.SANITY_STUDIO_DATASET || 'production',
  },
  typegen: {
    path: '../../frontend/src/**/*.{ts,tsx,js,jsx}',
    schema: '../../frontend/sanity-schemas.json',
    generates: '../../frontend/lib/sanity/types.generated.ts',
  },
})
```

### CLI Commands

```bash
# Generate types
npx sanity typegen generate

# Run in watch mode
npx sanity typegen generate --watch
```

### Using Generated Types

```typescript
// frontend/lib/sanity/queries.ts
import type { Post, Author } from './types.generated'

// Your query functions are now fully type-safe
export async function getPostBySlug(slug: string): Promise<Post | null> {
  // ...
}
```

---

## A.4 Studio Configuration Reference

### The Concept

The Configuration API is the primary mechanism for customizing Sanity Studio v3 and v5. It allows you to define workspaces, plugins, tools, schemas, and UI components .

### Top-Level Configuration Properties

| Property | Type | Description |
|----------|------|-------------|
| `projectId` | `string` | Required: The ID of the Sanity project |
| `dataset` | `string` | Required: The dataset name |
| `plugins` | `PluginOptions[]` | Studio plugins and tools |
| `schema` | `SchemaPluginOptions` | Schema types and templates |
| `document` | `DocumentPluginOptions` | Document actions and badges |
| `form` | `SanityFormConfig` | Form customizations |
| `studio` | `StudioComponentPluginOptions` | UI component overrides |
| `theme` | `StudioTheme` | Theming configuration |
| `auth` | `AuthConfig` | Custom authentication |

### Minimal Configuration

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { structureTool } from 'sanity/structure'

export default defineConfig({
  projectId: 'your-project-id',
  dataset: 'production',
  plugins: [structureTool()],
  schema: {
    types: [
      // Your schema types
    ],
  },
})
```

### Multiple Workspaces

For projects requiring multiple datasets or configurations :

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { structureTool } from 'sanity/structure'
import { visionTool } from '@sanity/vision'

export default defineConfig([
  {
    name: 'production',
    title: 'Production Workspace',
    basePath: '/production',
    projectId: 'your-project-id',
    dataset: 'production',
    plugins: [structureTool()],
  },
  {
    name: 'staging',
    title: 'Staging Workspace',
    basePath: '/staging',
    projectId: 'your-project-id',
    dataset: 'staging',
    plugins: [structureTool(), visionTool()],
  },
])
```

### Studio Component Overrides

You can override parts of the Studio UI with custom React components :

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { CustomNavbar } from './components/CustomNavbar'

export default defineConfig({
  // ... rest of config
  studio: {
    components: {
      navbar: CustomNavbar,
    },
  },
})
```

---

## A.5 Role-Based Customizations

### The Concept

Sanity Studio customizations can be based on user roles, enabling personalized experiences for different user types .

**Real-world analogy**: Role-based customizations are like different access cards in a building. Administrators can access all floors, managers have access to specific sections, and regular users have limited access.

### Accessing User Information

User information is available through the `currentUser` object in various APIs :

```typescript
interface CurrentUser {
  email: string
  id: string
  name: string
  profileImage?: string
  provider?: string
  roles: Role[]
}

interface Role {
  name: string
  title: string
  description?: string
}
```

### Checking User Roles

```typescript
// Helper function
function userHasRole(user: CurrentUser, roleName: string): boolean {
  return user.roles.some(role => role.name === roleName)
}

// In React components
import { useCurrentUser } from 'sanity'

function MyComponent() {
  const user = useCurrentUser()
  
  if (userHasRole(user, 'administrator')) {
    return <AdminOnlyContent />
  }
  
  return <RegularContent />
}
```

### Customizing Document List Views

```typescript
// studio/structure/index.ts
import type { StructureResolver } from 'sanity/structure'

export const structure: StructureResolver = (S, context) => {
  const user = context.currentUser
  const isEditor = user?.roles.some(r => r.name === 'article-editor')
  
  return S.list()
    .title('Content')
    .items([
      S.listItem()
        .title('Articles')
        .schemaType('article')
        .child(
          S.documentTypeList('article')
            .filter(
              isEditor 
                ? `_type == "article" && createdBy == $userId`
                : `_type == "article"`
            )
            .params({ userId: user?.id })
        ),
      // ... other items
    ])
}
```

### Role-Based Field Visibility

```typescript
// studio/schemas/article.ts
import { defineField } from 'sanity'

export const article = defineType({
  name: 'article',
  // ... rest of schema
  fields: [
    defineField({
      name: 'internalNotes',
      title: 'Internal Notes',
      type: 'text',
      hidden: ({ currentUser }) => {
        const isAdmin = currentUser?.roles.some(r => r.name === 'administrator')
        return !isAdmin  // Only visible to administrators
      },
    }),
  ],
})
```

---

## A.6 Common CLI Commands Reference

### Project Commands

```bash
# Initialize a new Sanity project
sanity init

# Start the Studio development server
sanity dev

# Build the Studio for production
sanity build

# Deploy the Studio to Sanity's hosting
sanity deploy
```

### Schema Commands

```bash
# Extract schema to JSON (for TypeGen)
sanity schema extract

# Validate schema
sanity schema validate
```

### TypeGen Commands

```bash
# Generate TypeScript types
npx sanity typegen generate

# Generate in watch mode
npx sanity typegen generate --watch

# Custom configuration path
npx sanity typegen generate --config-path ./custom-config.json
```

### CORS Configuration

```bash
# Add CORS origin
sanity cors add http://localhost:3000 --credentials

# List CORS origins
sanity cors list

# Remove CORS origin
sanity cors remove http://localhost:3000
```

---

## A.7 Troubleshooting Quick Reference

### Common Error Messages and Solutions

| Error Message | Likely Cause | Solution |
|---------------|--------------|----------|
| `'sanity' is not recognized` | Sanity CLI not installed | `npm install -g @sanity/cli` |
| `Module not found` | Missing dependency | `npm install [package-name]` |
| `Invalid schema` | Schema export error | Check your schema exports |
| `CORS error` | Domain not allowed | `sanity cors add` |
| `GROQ parse error` | Query syntax error | Check quotes and braces |
| `Port already in use` | Running process on port | Kill process or change port |
| `TypeGen: No schema found` | Missing schema extraction | Run `sanity schema extract` first |
| `Expected type but got: null` | Missing field value | Add validation or set default |

### Port Conflicts

```bash
# Sanity Studio uses port 3333
sanity dev --port 3334

# Next.js uses port 3000
npx next dev --port 3001
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
