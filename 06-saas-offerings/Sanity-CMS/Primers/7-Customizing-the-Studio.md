# Primer 7: Customizing the Studio

Welcome to the seventh primer. You've built your content models and created schemas. Now it's time to make the Studio truly yours. In this primer, we'll customize the editing experience to match how your team actually works.

By the end of this primer, you'll have a Studio that's tailored to your editorial workflow, with custom inputs, validation, document actions, and a personalized structure.

---

## Why Customize the Studio?

The default Studio works well, but every team has unique workflows. Customization allows you to:

- **Reduce errors**: Add validation and helpful error messages
- **Speed up editing**: Add default values and smart fields
- **Improve UX**: Hide complexity and surface what matters
- **Enforce consistency**: Standardize how content is created
- **Match your brand**: Apply your organization's design language

**Real-world analogy**: Customizing the Studio is like arranging a workshop. You put the most-used tools within easy reach, label everything clearly, and set up workstations that match how people actually work.

---

## Step 1: Basic Schema Customizations

### Field Descriptions

Add descriptions to help editors understand each field:

```typescript
// schemas/post.ts
defineField({
  name: 'title',
  title: 'Title',
  type: 'string',
  description: 'The main headline. Keep it under 60 characters for SEO.',
  // ...
})
```

### Field Groups

Group related fields together to reduce clutter:

```typescript
// schemas/post.ts
export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  
  groups: [
    {
      name: 'content',
      title: 'Content',
      default: true,
    },
    {
      name: 'metadata',
      title: 'SEO & Metadata',
    },
    {
      name: 'settings',
      title: 'Settings',
    },
  ],
  
  fields: [
    // Content group
    defineField({
      name: 'title',
      group: 'content',
      // ...
    }),
    defineField({
      name: 'body',
      group: 'content',
      // ...
    }),
    
    // Metadata group
    defineField({
      name: 'excerpt',
      group: 'metadata',
      // ...
    }),
    defineField({
      name: 'seo',
      group: 'metadata',
      // ...
    }),
    
    // Settings group
    defineField({
      name: 'publishedAt',
      group: 'settings',
      // ...
    }),
  ],
})
```

### Fieldsets

For nested grouping within a field:

```typescript
// schemas/post.ts
defineField({
  name: 'social',
  title: 'Social Media',
  type: 'object',
  fieldsets: [
    {
      name: 'general',
      title: 'General',
      options: { collapsible: true },
    },
    {
      name: 'advanced',
      title: 'Advanced',
      options: { collapsible: true, collapsed: true },
    },
  ],
  fields: [
    {
      name: 'twitter',
      title: 'Twitter Handle',
      type: 'string',
      fieldset: 'general',
    },
    {
      name: 'facebook',
      title: 'Facebook Page',
      type: 'string',
      fieldset: 'general',
    },
    {
      name: 'instagram',
      title: 'Instagram',
      type: 'string',
      fieldset: 'advanced',
    },
  ],
})
```

### Default Values

Pre-populate fields to save time:

```typescript
// schemas/post.ts
export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  
  initialValue: () => ({
    publishedAt: new Date().toISOString(),
    status: 'draft',
    tags: [],
    seo: {
      noIndex: false,
    },
  }),
  
  fields: [
    // ...
  ],
})
```

### Conditional Fields

Show or hide fields based on other field values:

```typescript
// schemas/post.ts
defineField({
  name: 'featuredImage',
  title: 'Featured Image',
  type: 'image',
  hidden: ({ parent }) => parent?.hasFeaturedImage === false,
})

defineField({
  name: 'hasFeaturedImage',
  title: 'Show Featured Image',
  type: 'boolean',
  initialValue: true,
})
```

---

## Step 2: Advanced Validation

### Custom Validation

Beyond basic validation, you can write custom logic:

```typescript
// schemas/post.ts
defineField({
  name: 'title',
  title: 'Title',
  type: 'string',
  validation: (Rule) => [
    Rule.required().error('Title is required'),
    Rule.min(5).error('Title must be at least 5 characters'),
    Rule.max(100).error('Title cannot exceed 100 characters'),
    // Custom validation
    Rule.custom((value) => {
      if (value && value.toLowerCase().includes('click here')) {
        return 'Avoid "click here" in titles. Use descriptive text instead.'
      }
      return true
    }),
  ],
})
```

### Cross-Field Validation

Validate relationships between fields:

```typescript
// schemas/post.ts
defineField({
  name: 'salePrice',
  title: 'Sale Price',
  type: 'number',
  validation: (Rule) => 
    Rule.custom((value, context) => {
      const price = context.parent?.price
      if (value && price && value >= price) {
        return 'Sale price must be less than the regular price.'
      }
      return true
    }),
})
```

### Async Validation

Validate against existing data:

```typescript
// schemas/post.ts
defineField({
  name: 'slug',
  title: 'Slug',
  type: 'slug',
  validation: (Rule) => 
    Rule.custom(async (value, context) => {
      // Check if slug already exists
      const client = context.getClient({ apiVersion: '2024-01-01' })
      const existing = await client.fetch(
        `*[_type == "post" && slug.current == $slug && _id != $id][0]`,
        { slug: value?.current, id: context.document?._id }
      )
      
      if (existing) {
        return 'This slug is already in use. Please choose a different one.'
      }
      return true
    }),
})
```

---

## Step 3: Custom Input Components

### Creating a Color Picker

When built-in fields aren't enough, create custom components.

First, create the component file:

```typescript
// studio/components/ColorPicker.tsx
import React, { useState } from 'react'
import { Card, Flex, Text, Stack, Input } from '@sanity/ui'
import { set, type StringInputProps } from 'sanity'

const PRESET_COLORS = [
  '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
  '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9',
  '#F8C471', '#82E0AA', '#F1948A', '#85929E', '#5D6D7E'
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

Register the custom input:

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { ColorPicker } from './components/ColorPicker'

export default defineConfig({
  // ... other config
  
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

### Creating a Slug Preview

A more helpful slug input:

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

### Register Custom Inputs

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { SlugWithPreview } from './components/SlugWithPreview'
import { ColorPicker } from './components/ColorPicker'

export default defineConfig({
  // ... other config
  
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

---

## Step 4: Custom Document Actions

### Adding Validation Before Publishing

Document actions are the buttons that appear when editing a document:

```typescript
// studio/actions/PublishWithValidation.tsx
import React, { useState } from 'react'
import { useDocumentOperation, type DocumentActionProps, type DocumentActionDescription } from 'sanity'
import { Button, Dialog, Text, Stack, Card, Flex, Badge } from '@sanity/ui'

export function PublishWithValidation(props: DocumentActionProps) {
  const { id, type, draft, published } = props
  const { publish } = useDocumentOperation(id, type)
  
  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const [validationErrors, setValidationErrors] = useState<string[]>([])

  const validateDocument = () => {
    const errors: string[] = []
    const doc = draft || published
    
    if (!doc) return []
    
    if (!doc.title) {
      errors.push('Document is missing a title')
    }
    
    if (!doc.slug?.current) {
      errors.push('Document is missing a slug')
    }
    
    if (!doc.publishedAt) {
      errors.push('Document is missing a publish date')
    }
    
    if (type === 'post') {
      if (!doc.author) {
        errors.push('Post is missing an author')
      }
      
      if (!doc.body || doc.body.length === 0) {
        errors.push('Post has no content in the body')
      }
    }
    
    return errors
  }

  const handlePublish = () => {
    const errors = validateDocument()
    
    if (errors.length > 0) {
      setValidationErrors(errors)
      setIsDialogOpen(true)
      return
    }
    
    publish.execute()
    props.onComplete?.()
  }

  const isPublished = !!published

  return {
    label: isPublished ? 'Update' : 'Publish',
    icon: () => <span>✅</span>,
    disabled: !draft,
    title: isPublished ? 'Update published document' : 'Publish document',
    onHandle: handlePublish,
    dialog: isDialogOpen && {
      type: 'dialog',
      title: 'Validation Errors',
      content: (
        <Dialog
          id="validation-dialog"
          header="Validation Errors"
          onClose={() => setIsDialogOpen(false)}
          width={1}
        >
          <Card padding={4}>
            <Stack space={4}>
              <Text>
                Please fix the following issues before publishing:
              </Text>
              <Stack space={2}>
                {validationErrors.map((error, index) => (
                  <Card key={index} padding={2} tone="critical" radius={1}>
                    <Flex align="center" gap={2}>
                      <Badge tone="critical">Error</Badge>
                      <Text>{error}</Text>
                    </Flex>
                  </Card>
                ))}
              </Stack>
              <Button
                text="Close"
                tone="primary"
                onClick={() => setIsDialogOpen(false)}
              />
            </Stack>
          </Card>
        </Dialog>
      ),
    },
  } as DocumentActionDescription
}
```

Register document actions:

```typescript
// studio/sanity.config.ts
import { PublishWithValidation } from './actions/PublishWithValidation'

export default defineConfig({
  // ... other config
  
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

---

## Step 5: Custom Structure

### Organizing the Sidebar

Create a custom structure to organize content:

```typescript
// studio/structure/index.ts
import { StructureBuilder } from 'sanity/structure'

export const structure = (S: StructureBuilder) => {
  // Blog posts with custom ordering
  const posts = S.listItem()
    .title('Blog Posts')
    .schemaType('post')
    .child(
      S.documentList()
        .title('Blog Posts')
        .filter('_type == "post"')
        .defaultOrdering([{ field: 'publishedAt', direction: 'desc' }])
        .canHandleCreate((id) => id === 'post')
        .menuItems([
          S.menuItem()
            .title('Create New Post')
            .icon(() => '✏️')
            .intent({ type: 'post', action: 'create' }),
        ])
    )

  // Authors
  const authors = S.listItem()
    .title('Authors')
    .schemaType('author')
    .child(
      S.documentList()
        .title('Authors')
        .filter('_type == "author"')
        .defaultOrdering([{ field: 'name', direction: 'asc' }])
    )

  // Categories
  const categories = S.listItem()
    .title('Categories')
    .schemaType('category')
    .child(
      S.documentList()
        .title('Categories')
        .filter('_type == "category"')
        .defaultOrdering([{ field: 'order', direction: 'asc' }])
    )

  // Settings (singleton)
  const settings = S.listItem()
    .title('Settings')
    .schemaType('settings')
    .child(
      S.document()
        .id('settings')
        .schemaType('settings')
        .documentId('settings')
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

Register the structure:

```typescript
// studio/sanity.config.ts
import { structure } from './structure'

export default defineConfig({
  // ... other config
  
  plugins: [
    structureTool({ structure }),
    // ... other plugins
  ],
})
```

---

## Step 6: Preview Configurations

### Custom Previews

Make document lists more informative:

```typescript
// schemas/post.ts
export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  
  preview: {
    select: {
      title: 'title',
      subtitle: 'excerpt',
      media: 'featuredImage',
      author: 'author.name',
      date: 'publishedAt',
    },
    prepare({ title, subtitle, media, author, date }) {
      const formattedDate = date ? new Date(date).toLocaleDateString() : ''
      return {
        title: title || 'Untitled',
        subtitle: `${author ? `By ${author}` : 'No author'}${formattedDate ? ` • ${formattedDate}` : ''}`,
        media: media,
      }
    },
  },
})
```

### Custom Document Badges

Add badges to show document status:

```typescript
// studio/badges/DraftBadge.ts
import { type DocumentBadgeComponent } from 'sanity'

export const DraftBadge: DocumentBadgeComponent = (props) => {
  const { draft } = props
  
  if (!draft) {
    return {
      label: 'Published',
      color: 'success',
      title: 'This document is published',
    }
  }
  
  return {
    label: 'Draft',
    color: 'warning',
    title: 'This document is a draft',
  }
}
```

Register badges:

```typescript
// studio/sanity.config.ts
import { DraftBadge } from './badges/DraftBadge'

export default defineConfig({
  // ... other config
  
  document: {
    badges: (prev) => {
      return [
        ...prev,
        DraftBadge,
      ]
    },
  },
})
```

---

## Step 7: Custom Document Badges (Continued)

### Adding Multiple Badges

```typescript
// studio/badges/CustomBadges.ts
import { type DocumentBadgeComponent } from 'sanity'

export const StatusBadge: DocumentBadgeComponent = (props) => {
  const { draft, published } = props
  
  if (draft && published) {
    return {
      label: 'Has Draft',
      color: 'warning',
      title: 'This document has an unpublished draft'
    }
  }
  
  if (draft) {
    return {
      label: 'Draft',
      color: 'caution',
      title: 'This document is a draft'
    }
  }
  
  return null
}

export const FeaturedBadge: DocumentBadgeComponent = (props) => {
  const document = props.draft || props.published
  
  if (document?.featured) {
    return {
      label: '⭐ Featured',
      color: 'primary',
      title: 'This document is featured'
    }
  }
  
  return null
}
```

---

## Step 8: Custom Dashboard Widgets

### Content Stats Widget

Create a dashboard widget to show content statistics:

```typescript
// studio/widgets/StatsWidget.tsx
import React, { useState, useEffect } from 'react'
import { Card, Flex, Text, Stack, Spinner } from '@sanity/ui'
import { client } from '../../frontend/lib/sanity/client'

export function StatsWidget() {
  const [stats, setStats] = useState({ posts: 0, authors: 0, categories: 0 })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [posts, authors, categories] = await Promise.all([
          client.fetch('count(*[_type == "post"])'),
          client.fetch('count(*[_type == "author"])'),
          client.fetch('count(*[_type == "category"])'),
        ])
        setStats({ posts, authors, categories })
      } catch (error) {
        console.error('Failed to fetch stats:', error)
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

  return (
    <Card padding={4} radius={2} tone="transparent">
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
          <Stack>
            <Text size={4} weight="bold">{stats.categories}</Text>
            <Text size={1} muted>Categories</Text>
          </Stack>
        </Flex>
      </Stack>
    </Card>
  )
}
```

### Recent Activity Widget

```typescript
// studio/widgets/RecentActivityWidget.tsx
import React, { useState, useEffect } from 'react'
import { Card, Flex, Text, Stack, Spinner } from '@sanity/ui'
import { client } from '../../frontend/lib/sanity/client'
import { formatDistanceToNow } from 'date-fns'

export function RecentActivityWidget() {
  const [activities, setActivities] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchActivity = async () => {
      try {
        const query = `
          *[_type in ["post", "author", "category"]] | order(_updatedAt desc) [0..5] {
            _type,
            title,
            name,
            _updatedAt
          }
        `
        const data = await client.fetch(query)
        setActivities(data)
      } catch (error) {
        console.error('Failed to fetch activity:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchActivity()
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

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'post': return '📝'
      case 'author': return '👤'
      case 'category': return '📁'
      default: return '📄'
    }
  }

  return (
    <Card padding={4} radius={2} tone="transparent">
      <Stack space={3}>
        <Text weight="bold">Recent Activity</Text>
        <Stack space={2}>
          {activities.map((item, index) => (
            <Card key={index} padding={2} radius={1} tone="default">
              <Flex align="center" justify="space-between">
                <Flex align="center" gap={2}>
                  <Text>{getTypeIcon(item._type)}</Text>
                  <Text size={1}>{item.title || item.name || 'Untitled'}</Text>
                  <Text size={1} muted>{item._type}</Text>
                </Flex>
                <Text size={1} muted>
                  {formatDistanceToNow(new Date(item._updatedAt), { addSuffix: true })}
                </Text>
              </Flex>
            </Card>
          ))}
        </Stack>
      </Stack>
    </Card>
  )
}
```

Register widgets:

```typescript
// studio/sanity.config.ts
import { dashboardTool } from '@sanity/dashboard'
import { StatsWidget } from './widgets/StatsWidget'
import { RecentActivityWidget } from './widgets/RecentActivityWidget'

export default defineConfig({
  // ... other config
  
  plugins: [
    dashboardTool({
      widgets: [
        {
          name: 'stats-widget',
          title: 'Content Stats',
          component: StatsWidget,
          layout: { width: 'small' },
        },
        {
          name: 'activity-widget',
          title: 'Recent Activity',
          component: RecentActivityWidget,
          layout: { width: 'medium' },
        },
      ],
    }),
    // ... other plugins
  ],
})
```

---

## Step 9: Custom Document Icons

Add custom icons to your schemas:

```typescript
// schemas/post.ts
import { DocumentIcon, UserIcon, TagIcon } from '@sanity/icons'

export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  icon: DocumentIcon,
  // ... fields
})

// schemas/author.ts
import { UserIcon } from '@sanity/icons'

export default defineType({
  name: 'author',
  title: 'Author',
  type: 'document',
  icon: UserIcon,
  // ... fields
})

// schemas/category.ts
import { TagIcon } from '@sanity/icons'

export default defineType({
  name: 'category',
  title: 'Category',
  type: 'document',
  icon: TagIcon,
  // ... fields
})
```

---

## Step 10: Theming the Studio

### Custom Theme

Create a custom theme to match your brand:

```typescript
// studio/theme.ts
import { buildTheme } from '@sanity/ui/theme'

export const theme = buildTheme({
  color: {
    light: {
      default: {
        base: {
          bg: '#ffffff',
          fg: '#1a1a1a',
        },
        primary: {
          base: {
            bg: '#2563eb',
            fg: '#ffffff',
          },
        },
        positive: {
          base: {
            bg: '#16a34a',
            fg: '#ffffff',
          },
        },
        caution: {
          base: {
            bg: '#f59e0b',
            fg: '#000000',
          },
        },
        critical: {
          base: {
            bg: '#dc2626',
            fg: '#ffffff',
          },
        },
      },
    },
    dark: {
      default: {
        base: {
          bg: '#1a1a1a',
          fg: '#ffffff',
        },
        primary: {
          base: {
            bg: '#3b82f6',
            fg: '#ffffff',
          },
        },
      },
    },
  },
  fonts: {
    heading: {
      family: 'Inter, sans-serif',
      weight: '600',
    },
    text: {
      family: 'Inter, sans-serif',
    },
  },
})
```

Register the theme:

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { theme } from './theme'

export default defineConfig({
  // ... other config
  theme,
})
```

---

## Step 11: Custom Studio Components

### Custom Branding

```typescript
// studio/components/Logo.tsx
import React from 'react'
import { Box, Text } from '@sanity/ui'

export function Logo() {
  return (
    <Box padding={2}>
      <Text weight="bold" size={2}>
        📝 My CMS
      </Text>
    </Box>
  )
}
```

### Custom Navbar

```typescript
// studio/components/CustomNavbar.tsx
import React from 'react'
import { Button, Flex } from '@sanity/ui'
import { useRouter } from 'sanity/router'

export function CustomNavbar() {
  const router = useRouter()

  return (
    <Flex align="center" gap={2}>
      <Button
        text="📊 Dashboard"
        mode="ghost"
        onClick={() => router.navigate({ path: '/dashboard' })}
      />
      <Button
        text="📝 New Post"
        tone="primary"
        onClick={() => router.navigate({ path: '/structure/post;create' })}
      />
    </Flex>
  )
}
```

Register custom components:

```typescript
// studio/sanity.config.ts
import { Logo } from './components/Logo'
import { CustomNavbar } from './components/CustomNavbar'

export default defineConfig({
  // ... other config
  
  studio: {
    components: {
      logo: Logo,
      navbar: CustomNavbar,
    },
  },
})
```

---

## Step 12: Role-Based Customizations

### User Role Checking

```typescript
// studio/hooks/useUser.ts
import { useCurrentUser } from 'sanity'

export function useUser() {
  const user = useCurrentUser()
  
  const isAdmin = user?.roles.some(r => r.name === 'administrator')
  const isEditor = user?.roles.some(r => r.name === 'editor')
  const isContributor = user?.roles.some(r => r.name === 'contributor')
  
  return {
    user,
    isAdmin,
    isEditor,
    isContributor,
  }
}
```

### Conditional Fields Based on Role

```typescript
// schemas/post.ts
defineField({
  name: 'internalNotes',
  title: 'Internal Notes',
  type: 'text',
  hidden: ({ currentUser }) => {
    const isAdmin = currentUser?.roles.some(r => r.name === 'administrator')
    return !isAdmin
  },
})
```

### Conditional Structure Items

```typescript
// studio/structure/index.ts
import type { StructureResolver } from 'sanity/structure'

export const structure: StructureResolver = (S, context) => {
  const user = context.currentUser
  const isAdmin = user?.roles.some(r => r.name === 'administrator')
  
  return S.list()
    .title('Content')
    .items([
      S.listItem()
        .title('Blog Posts')
        .schemaType('post')
        .child(
          S.documentList()
            .title('Blog Posts')
            .filter('_type == "post"')
            .defaultOrdering([{ field: 'publishedAt', direction: 'desc' }])
        ),
      S.listItem()
        .title('Authors')
        .schemaType('author')
        .child(
          S.documentList()
            .title('Authors')
            .filter('_type == "author"')
            .defaultOrdering([{ field: 'name', direction: 'asc' }])
        ),
      // Only show settings to admins
      isAdmin && S.listItem()
        .title('Settings')
        .schemaType('settings')
        .child(
          S.document()
            .id('settings')
            .schemaType('settings')
            .documentId('settings')
        ),
    ].filter(Boolean))
}
```

---

## Common Customization Patterns

### Dark Mode Toggle

```typescript
// studio/components/DarkModeToggle.tsx
import React, { useState } from 'react'
import { Button } from '@sanity/ui'

export function DarkModeToggle() {
  const [isDark, setIsDark] = useState(() => {
    return document.documentElement.dataset.scheme === 'dark'
  })

  const toggle = () => {
    const newIsDark = !isDark
    setIsDark(newIsDark)
    document.documentElement.dataset.scheme = newIsDark ? 'dark' : 'light'
  }

  return (
    <Button
      text={isDark ? '☀️' : '🌙'}
      onClick={toggle}
      mode="bleed"
      title={isDark ? 'Switch to light mode' : 'Switch to dark mode'}
    />
  )
}
```

### Quick Create Button

```typescript
// studio/components/QuickCreate.tsx
import React from 'react'
import { Button, Menu, MenuItem } from '@sanity/ui'

export function QuickCreate() {
  const [isOpen, setIsOpen] = useState(false)

  const createDocument = (type: string) => {
    window.location.href = `/structure/${type};create`
    setIsOpen(false)
  }

  return (
    <Menu
      open={isOpen}
      onOpenChange={setIsOpen}
      placement="bottom-end"
      menuButton={
        <Button
          text="✨ Quick Create"
          tone="primary"
          onClick={() => setIsOpen(!isOpen)}
        />
      }
    >
      <MenuItem text="New Post" onClick={() => createDocument('post')} />
      <MenuItem text="New Author" onClick={() => createDocument('author')} />
      <MenuItem text="New Category" onClick={() => createDocument('category')} />
    </Menu>
  )
}
```

---

## Summary

In this primer, you've learned how to:

✅ Add field descriptions and groups
✅ Implement default values and conditional fields
✅ Write custom validation rules
✅ Create custom input components
✅ Build custom document actions
✅ Customize the Studio structure
✅ Add dashboard widgets
✅ Configure custom previews and badges
✅ Apply theming and branding
✅ Implement role-based customizations

### Customization Principles

1. **Start simple**: Add customizations one at a time
2. **Test with editors**: Get feedback and iterate
3. **Keep it intuitive**: Customizations should make the Studio easier to use
4. **Document everything**: Explain customizations for other developers
5. **Maintain performance**: Avoid heavy customizations that slow down the Studio

### Next Steps

Now that you can customize the Studio, you're ready to:

1. **Add AI workflows**: Integrate AI for content generation
2. **Build plugins**: Package your customizations as reusable plugins
3. **Implement real-time features**: Add live collaboration
