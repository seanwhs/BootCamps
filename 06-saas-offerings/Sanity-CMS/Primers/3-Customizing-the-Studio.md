# Primer 3: Customizing the Studio

Welcome to the fifth primer. You've set up your Studio, created schemas, and mastered GROQ queries. Now it's time to make the Studio truly yours. In this primer, we'll customize the editing experience to match how your team actually works.

---

## Why Customize the Studio?

The default Studio works well, but every team has unique workflows. Customization allows you to:

- **Reduce errors**: Add validation and helpful error messages
- **Speed up editing**: Add default values and smart fields
- **Improve UX**: Hide complexity and surface what matters
- **Enforce consistency**: Standardize how content is created

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

---

## Step 3: Custom Input Components

### Creating a Color Picker

When built-in fields aren't enough, create custom components.

First, create the component:

```typescript
// studio/components/ColorPicker.tsx
import React, { useState } from 'react'
import { Card, Flex, Text, Stack, Input } from '@sanity/ui'
import { set, type StringInputProps } from 'sanity'

const PRESET_COLORS = [
  '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
  '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9',
]

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
            cursor: 'pointer',
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
    if (value) {
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

---

## Step 4: Custom Document Actions

### Adding a Publish Button with Validation

Document actions are the buttons that appear when editing a document:

```typescript
// studio/actions/PublishWithValidation.ts
import { useDocumentOperation, type DocumentActionProps } from 'sanity'

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
      alert(`Please fix these issues:\n\n- ${errors.join('\n- ')}`)
      return
    }
    
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
        .defaultOrdering([{ field: 'title', direction: 'asc' }])
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

## Step 7: Custom Dashboard Widgets

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

Register the widget:

```typescript
// studio/sanity.config.ts
import { dashboardTool } from '@sanity/dashboard'
import { StatsWidget } from './widgets/StatsWidget'

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
      ],
    }),
    // ... other plugins
  ],
})
```

---

## Step 8: Common Customization Patterns

### Dark Mode Toggle

Add a dark mode toggle to the Studio:

```typescript
// studio/desk/customNavbar.tsx
import React from 'react'
import { Button } from '@sanity/ui'
import { useTheme } from '@sanity/ui/theme'

export function CustomNavbar() {
  const theme = useTheme()
  const toggleDarkMode = () => {
    const isDark = theme.sanity.color.dark
    document.documentElement.dataset.scheme = isDark ? 'light' : 'dark'
  }

  return (
    <Button
      text="Toggle Dark Mode"
      onClick={toggleDarkMode}
      mode="bleed"
    />
  )
}
```

### Custom Document Icons

```typescript
// schemas/post.ts
import { DocumentIcon } from '@sanity/icons'

export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  icon: DocumentIcon,
  // ...
})
```

---

## Summary

In this primer, you've learned how to:

✅ Add field descriptions and groups
✅ Implement default values
✅ Create conditional fields
✅ Write custom validation
✅ Build custom input components
✅ Create custom document actions
✅ Customize Studio structure
✅ Add dashboard widgets
✅ Configure custom previews

**Customization principles**:

1. **Start simple**: Add customizations one at a time
2. **Test with editors**: Get feedback and iterate
3. **Keep it intuitive**: Customizations should make the Studio easier to use
4. **Document everything**: Explain customizations for other developers
