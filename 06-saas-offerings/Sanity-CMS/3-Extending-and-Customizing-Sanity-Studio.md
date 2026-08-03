# Part 3: Extending and Customizing Sanity Studio

Welcome to Part 3! You've built robust content models and mastered querying. Now it's time to transform Sanity Studio from a generic content editor into a tailored editorial powerhouse. In this part, we'll customize every aspect of the Studio to create an exceptional experience for content creators.

By the end of this part, you'll have:
- Custom input components for specialized data entry
- Dashboard widgets for editorial insights
- Custom document actions for publishing workflows
- AI-assisted content creation tools
- Reusable plugins for your organization
- Integration with external APIs and services

Let's build the ultimate editorial experience.

---

## Step 1: Customizing the Studio Structure

### The Target
Organize the Studio's navigation and document lists for optimal editorial workflow.

### The Concept
The Structure Tool is like a filing system for your content. By default, Sanity organizes documents by type. But we can create custom views, groups, and hierarchies that match how your editorial team actually works.

**Real-world analogy**: Think of the Structure Tool as a custom filing cabinet. Instead of having all documents in one giant drawer, you can create specific drawers for different content types, with labels and organization that make sense to your team.

### The Implementation

#### 1.1 Create a Custom Structure

Update `studio/sanity.config.ts`:

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { structureTool } from 'sanity/structure'
import { visionTool } from '@sanity/vision'
import { schemaTypes } from './schemas'
import { structure } from './structure'  // We'll create this

export default defineConfig({
  projectId: process.env.SANITY_STUDIO_PROJECT_ID || '',
  dataset: process.env.SANITY_STUDIO_DATASET || 'production',
  plugins: [
    structureTool({
      // Custom structure configuration
      structure,
    }),
    visionTool(),
  ],
  schema: {
    types: schemaTypes,
  },
})
```

Create `studio/structure/index.ts`:

```typescript
// studio/structure/index.ts
import { StructureBuilder, StructureResolver } from 'sanity/structure'

/**
 * Custom Studio Structure
 * 
 * Organizes the Studio navigation for optimal editorial workflow.
 * Creates logical groupings and custom views for different content types.
 */
export const structure: StructureResolver = (S: StructureBuilder) => {
  // Define custom document lists
  const blogPosts = S.listItem()
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
          S.menuItem()
            .title('Drafts')
            .icon(() => '📝')
            .intent({ type: 'post', action: 'edit' }),
        ])
    )

  // Authors list with custom ordering
  const authors = S.listItem()
    .title('Authors')
    .schemaType('author')
    .child(
      S.documentList()
        .title('Authors')
        .filter('_type == "author"')
        .defaultOrdering([{ field: 'name', direction: 'asc' }])
    )

  // Categories list with hierarchy
  const categories = S.listItem()
    .title('Categories')
    .schemaType('category')
    .child(
      S.documentList()
        .title('Categories')
        .filter('_type == "category"')
        .defaultOrdering([{ field: 'order', direction: 'asc' }])
    )

  // Settings singleton
  const settings = S.listItem()
    .title('Site Settings')
    .schemaType('settings')
    .child(
      S.document()
        .id('settings')
        .schemaType('settings')
        .documentId('settings')  // Singleton ID
    )

  // Custom dashboard with widgets
  const dashboard = S.listItem()
    .title('Dashboard')
    .icon(() => '📊')
    .child(
      S.component()
        .id('dashboard')
        .title('Dashboard')
        .component(
          // We'll create this component in Step 2
          () => import('../components/Dashboard').then(mod => mod.Dashboard)
        )
    )

  // Create a custom view for content calendar
  const contentCalendar = S.listItem()
    .title('Content Calendar')
    .icon(() => '📅')
    .child(
      S.component()
        .id('contentCalendar')
        .title('Content Calendar')
        .component(
          () => import('../components/ContentCalendar').then(mod => mod.ContentCalendar)
        )
    )

  // Define the main structure
  return S.list()
    .title('Content')
    .items([
      dashboard,
      S.divider(),
      blogPosts,
      authors,
      categories,
      S.divider(),
      settings,
      S.divider(),
      contentCalendar,
    ])
}
```

#### 1.2 Create a Custom Document List View

Create `studio/components/PostListView.tsx`:

```typescript
// studio/components/PostListView.tsx
import React from 'react'
import { Card, Text, Stack, Badge, Flex } from '@sanity/ui'
import { DocumentList } from 'sanity/structure'

/**
 * Custom Post List View
 * 
 * Enhances the standard document list with additional visual cues
 * and information for editors.
 */
export function PostListView() {
  return (
    <DocumentList
      filter='_type == "post"'
      defaultOrdering={[{ field: 'publishedAt', direction: 'desc' }]}
      // Custom render function for each document
      renderItem={(documentId, document) => {
        // Access document data
        const post = document as any
        
        return (
          <Card padding={3} key={documentId}>
            <Flex align="center" gap={3}>
              <Stack flex={1}>
                <Text weight="bold">{post.title || 'Untitled'}</Text>
                <Flex gap={2} wrap="wrap">
                  {post.categories?.map((cat: any) => (
                    <Badge key={cat._id} tone="primary" mode="outline">
                      {cat.title}
                    </Badge>
                  ))}
                </Flex>
                {post.excerpt && (
                  <Text size={1} muted>
                    {post.excerpt}
                  </Text>
                )}
              </Stack>
              <Stack align="end">
                <Badge tone={post.publishedAt ? 'positive' : 'caution'}>
                  {post.publishedAt ? 'Published' : 'Draft'}
                </Badge>
                <Text size={1} muted>
                  {post.publishedAt ? new Date(post.publishedAt).toLocaleDateString() : 'Not published'}
                </Text>
              </Stack>
            </Flex>
          </Card>
        )
      }}
    />
  )
}
```

### The Verification

1. **Refresh your Studio** at http://localhost:3333
2. **Check the navigation**: You should see the new structure with:
   - Dashboard at the top
   - Blog Posts, Authors, Categories grouped together
   - Site Settings at the bottom
3. **Click Blog Posts**: See the enhanced list view
4. **Click Dashboard**: See the placeholder (we'll build this next)

**Your Studio is now organized for optimal workflow!**

---

## Step 2: Building Dashboard Widgets

### The Target
Create custom dashboard widgets showing content analytics and editorial tasks.

### The Concept
Dashboard widgets provide editors with at-a-glance insights into their content. Think of it like a car dashboard showing speed, fuel level, and engine temperature—but for your content.

**Real-world analogy**: Dashboard widgets are like a personal assistant who greets you each morning with key updates: "You have 3 drafts to review, 2 posts scheduled for this week, and 5 comments to moderate."

### The Implementation

#### 2.1 Create a Dashboard Component

Create `studio/components/Dashboard.tsx`:

```typescript
// studio/components/Dashboard.tsx
import React, { useEffect, useState } from 'react'
import { Card, Container, Grid, Heading, Text, Stack, Badge, Flex } from '@sanity/ui'
import { client } from '../../frontend/lib/sanity/client'

interface DashboardStats {
  totalPosts: number
  publishedPosts: number
  draftPosts: number
  scheduledPosts: number
  totalAuthors: number
  totalCategories: number
  recentPosts: any[]
  postsByMonth: { month: string; count: number }[]
}

/**
 * Dashboard Component
 * 
 * Provides editorial insights and content statistics.
 * Fetches real-time data from Sanity and displays it
 * in an easy-to-read format.
 */
export function Dashboard() {
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchDashboardData()
  }, [])

  const fetchDashboardData = async () => {
    try {
      setLoading(true)
      setError(null)

      // Fetch all data in parallel
      const [
        totalPosts,
        publishedPosts,
        draftPosts,
        scheduledPosts,
        totalAuthors,
        totalCategories,
        recentPosts,
        postsByMonth,
      ] = await Promise.all([
        // Total posts
        client.fetch<number>(`count(*[_type == "post"])`),
        
        // Published posts
        client.fetch<number>(
          `count(*[_type == "post" && defined(publishedAt)])`
        ),
        
        // Draft posts
        client.fetch<number>(
          `count(*[_type == "post" && !defined(publishedAt)])`
        ),
        
        // Scheduled posts (future publish date)
        client.fetch<number>(
          `count(*[_type == "post" && publishedAt > now()])`
        ),
        
        // Total authors
        client.fetch<number>(`count(*[_type == "author"])`),
        
        // Total categories
        client.fetch<number>(`count(*[_type == "category"])`),
        
        // Recent posts
        client.fetch<any[]>(
          `*[_type == "post"] | order(publishedAt desc) [0..5] {
            title,
            publishedAt,
            "author": author->name,
            "categories": categories[]->title
          }`
        ),
        
        // Posts by month (last 6 months)
        client.fetch<any[]>(
          `*[_type == "post" && defined(publishedAt)] {
            "month": publishedAt[0..6]
          }`
        ),
      ])

      // Process posts by month
      const monthCounts = postsByMonth.reduce((acc: any, post: any) => {
        if (post.month) {
          acc[post.month] = (acc[post.month] || 0) + 1
        }
        return acc
      }, {})

      const monthData = Object.entries(monthCounts)
        .map(([month, count]) => ({ month, count: count as number }))
        .sort((a, b) => a.month.localeCompare(b.month))
        .slice(-6) // Last 6 months

      setStats({
        totalPosts,
        publishedPosts,
        draftPosts,
        scheduledPosts,
        totalAuthors,
        totalCategories,
        recentPosts,
        postsByMonth: monthData,
      })
    } catch (err) {
      console.error('Failed to fetch dashboard data:', err)
      setError('Failed to load dashboard data')
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <Container padding={4}>
        <Card padding={4} radius={2}>
          <Text>Loading dashboard...</Text>
        </Card>
      </Container>
    )
  }

  if (error) {
    return (
      <Container padding={4}>
        <Card padding={4} radius={2} tone="critical">
          <Text>{error}</Text>
        </Card>
      </Container>
    )
  }

  if (!stats) {
    return null
  }

  return (
    <Container padding={4}>
      <Stack space={4}>
        {/* Header */}
        <Flex align="center" justify="space-between">
          <Heading>Content Dashboard</Heading>
          <Badge tone="positive">Live</Badge>
        </Flex>

        {/* Stats Grid */}
        <Grid columns={[2, 4]} gap={3}>
          <StatCard
            label="Total Posts"
            value={stats.totalPosts}
            subtitle={`${stats.publishedPosts} published`}
          />
          <StatCard
            label="Drafts"
            value={stats.draftPosts}
            subtitle={`${stats.scheduledPosts} scheduled`}
            tone="caution"
          />
          <StatCard
            label="Authors"
            value={stats.totalAuthors}
            subtitle="Content creators"
          />
          <StatCard
            label="Categories"
            value={stats.totalCategories}
            subtitle="Content organization"
          />
        </Grid>

        {/* Recent Posts */}
        <Card padding={4} radius={2} tone="transparent">
          <Heading size={2}>Recent Posts</Heading>
          <Stack space={3} marginTop={3}>
            {stats.recentPosts.map((post, index) => (
              <Card key={index} padding={3} radius={1} tone="default">
                <Stack space={1}>
                  <Flex align="center" justify="space-between">
                    <Text weight="bold">{post.title || 'Untitled'}</Text>
                    <Badge tone={post.publishedAt ? 'positive' : 'caution'}>
                      {post.publishedAt ? 'Published' : 'Draft'}
                    </Badge>
                  </Flex>
                  <Flex gap={2} wrap="wrap">
                    {post.author && (
                      <Text size={1} muted>
                        By {post.author}
                      </Text>
                    )}
                    {post.categories?.length > 0 && (
                      <Text size={1} muted>
                        in {post.categories.join(', ')}
                      </Text>
                    )}
                    {post.publishedAt && (
                      <Text size={1} muted>
                        {new Date(post.publishedAt).toLocaleDateString()}
                      </Text>
                    )}
                  </Flex>
                </Stack>
              </Card>
            ))}
          </Stack>
        </Card>

        {/* Monthly Content Calendar */}
        <Card padding={4} radius={2} tone="transparent">
          <Heading size={2}>Content Calendar</Heading>
          <Grid columns={[2, 3, 6]} gap={3} marginTop={3}>
            {stats.postsByMonth.map(({ month, count }) => (
              <Card key={month} padding={3} radius={1} tone="default">
                <Stack align="center" space={1}>
                  <Text size={2} weight="bold">
                    {count}
                  </Text>
                  <Text size={1} muted>
                    {new Date(month).toLocaleDateString('en-US', {
                      month: 'short',
                      year: 'numeric',
                    })}
                  </Text>
                </Stack>
              </Card>
            ))}
          </Grid>
        </Card>

        {/* Quick Actions */}
        <Card padding={4} radius={2} tone="transparent">
          <Heading size={2}>Quick Actions</Heading>
          <Grid columns={[2, 4]} gap={3} marginTop={3}>
            <QuickActionButton
              label="New Post"
              icon="✏️"
              onClick={() => {
                // Navigate to create post
                window.location.href = '/structure/post;create'
              }}
            />
            <QuickActionButton
              label="New Author"
              icon="👤"
              onClick={() => {
                window.location.href = '/structure/author;create'
              }}
            />
            <QuickActionButton
              label="New Category"
              icon="📁"
              onClick={() => {
                window.location.href = '/structure/category;create'
              }}
            />
            <QuickActionButton
              label="Edit Settings"
              icon="⚙️"
              onClick={() => {
                window.location.href = '/structure/settings'
              }}
            />
          </Grid>
        </Card>
      </Stack>
    </Container>
  )
}

/**
 * Stat Card Component
 * Displays a single statistic with label and value.
 */
function StatCard({ 
  label, 
  value, 
  subtitle, 
  tone = 'default' 
}: { 
  label: string
  value: number | string
  subtitle?: string
  tone?: 'default' | 'positive' | 'caution' | 'critical'
}) {
  return (
    <Card padding={4} radius={2} tone={tone}>
      <Stack space={2}>
        <Text size={1} muted>
          {label}
        </Text>
        <Text size={4} weight="bold">
          {value}
        </Text>
        {subtitle && <Text size={1} muted>{subtitle}</Text>}
      </Stack>
    </Card>
  )
}

/**
 * Quick Action Button Component
 * Creates a clickable action button for common tasks.
 */
function QuickActionButton({ 
  label, 
  icon, 
  onClick 
}: { 
  label: string
  icon: string
  onClick: () => void
}) {
  return (
    <Card 
      padding={3} 
      radius={2} 
      tone="default" 
      style={{ cursor: 'pointer' }}
      onClick={onClick}
    >
      <Flex align="center" gap={2}>
        <Text size={2}>{icon}</Text>
        <Text>{label}</Text>
      </Flex>
    </Card>
  )
}
```

### The Verification

1. **Navigate to Dashboard** in your Studio
2. **Verify statistics**: All numbers should match your content
3. **Check recent posts**: Should show your 5 most recent posts
4. **Test quick actions**: Click "New Post" and verify it navigates correctly
5. **Check content calendar**: Should show posts grouped by month

**You now have a powerful editorial dashboard!**

---

## Step 3: Creating Custom Input Components

### The Target
Build custom input components for specialized data entry needs.

### The Concept
Custom input components extend the Studio with specialized data entry interfaces. Instead of generic text fields, you can create dropdowns, color pickers, rich text editors, or any React component.

**Real-world analogy**: Custom inputs are like specialized tools in a workshop. Instead of using a hammer for everything, you have wrenches, screwdrivers, and pliers for specific tasks.

### The Implementation

#### 3.1 Create a Slug Input with Preview

Create `studio/components/SlugInput.tsx`:

```typescript
// studio/components/SlugInput.tsx
import React, { useState, useEffect } from 'react'
import { TextInput, Flex, Text, Box, Card, Stack } from '@sanity/ui'
import { set, type StringInputProps } from 'sanity'

/**
 * Custom Slug Input
 * 
 * Provides live preview of the URL as the user types.
 * Shows the full URL path with the slug.
 */
export function SlugInput(props: StringInputProps) {
  const { value, onChange, elementProps, path } = props
  
  // Extract the field name from the path
  const fieldName = path[path.length - 1]
  const isSlugField = fieldName === 'slug'
  
  // State for preview
  const [previewUrl, setPreviewUrl] = useState('')
  
  // Handle changes
  const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = event.target.value
    onChange(set(newValue))
    
    // Update preview
    updatePreview(newValue)
  }
  
  // Update preview when value changes
  useEffect(() => {
    if (value && typeof value === 'string') {
      updatePreview(value)
    } else {
      setPreviewUrl('')
    }
  }, [value])
  
  const updatePreview = (slug: string) => {
    if (!slug) {
      setPreviewUrl('')
      return
    }
    
    // Create a clean URL preview
    const cleanSlug = slug
      .toLowerCase()
      .replace(/[^a-z0-9-]/g, '')
      .replace(/-+/g, '-')
    
    setPreviewUrl(`/blog/${cleanSlug}`)
  }
  
  return (
    <Stack space={2}>
      {/* Main input */}
      <TextInput
        {...elementProps}
        value={value || ''}
        onChange={handleChange}
        placeholder="Enter URL slug..."
      />
      
      {/* Live preview */}
      {previewUrl && (
        <Card padding={2} tone="primary" radius={1}>
          <Flex align="center" gap={2}>
            <Box>
              <Text size={1} muted>
                Preview:
              </Text>
            </Box>
            <Box flex={1}>
              <Text size={1} style={{ color: '#0066cc' }}>
                {previewUrl}
              </Text>
            </Box>
          </Flex>
        </Card>
      )}
    </Stack>
  )
}
```

#### 3.2 Create a Color Picker Input

Create `studio/components/ColorPickerInput.tsx`:

```typescript
// studio/components/ColorPickerInput.tsx
import React, { useState } from 'react'
import { Card, Flex, Text, Stack, Button, Popover } from '@sanity/ui'
import { set, type StringInputProps } from 'sanity'

const PRESET_COLORS = [
  '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
  '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9',
  '#F8C471', '#82E0AA', '#F1948A', '#85929E', '#5D6D7E'
]

/**
 * Custom Color Picker Input
 * 
 * Provides a visual color picker with preset colors.
 * Great for category colors, branding colors, etc.
 */
export function ColorPickerInput(props: StringInputProps) {
  const { value, onChange, elementProps } = props
  
  const [isOpen, setIsOpen] = useState(false)
  
  const handleColorSelect = (color: string) => {
    onChange(set(color))
    setIsOpen(false)
  }
  
  return (
    <Stack space={2}>
      <Flex align="center" gap={3}>
        {/* Color preview */}
        <Card
          style={{
            width: 40,
            height: 40,
            backgroundColor: value || '#ffffff',
            border: '2px solid #e0e0e0',
            borderRadius: 4,
            cursor: 'pointer',
          }}
          onClick={() => setIsOpen(!isOpen)}
        />
        
        {/* Current value */}
        <TextInput
          {...elementProps}
          value={value || ''}
          onChange={(e) => onChange(set(e.target.value))}
          placeholder="#000000"
          style={{ flex: 1 }}
        />
      </Flex>
      
      {/* Color picker popover */}
      {isOpen && (
        <Card padding={3} radius={2} tone="default" style={{ maxWidth: 300 }}>
          <Stack space={2}>
            <Text size={1} muted>
              Select a color
            </Text>
            <Flex wrap="wrap" gap={1}>
              {PRESET_COLORS.map((color) => (
                <Card
                  key={color}
                  style={{
                    width: 32,
                    height: 32,
                    backgroundColor: color,
                    border: value === color ? '3px solid #000' : '1px solid #e0e0e0',
                    borderRadius: 4,
                    cursor: 'pointer',
                  }}
                  onClick={() => handleColorSelect(color)}
                />
              ))}
            </Flex>
            <Button
              text="Clear"
              tone="critical"
              mode="ghost"
              onClick={() => handleColorSelect('')}
              style={{ alignSelf: 'flex-end' }}
            />
          </Stack>
        </Card>
      )}
    </Stack>
  )
}
```

#### 3.3 Create an Object Input for SEO

Create `studio/components/SEOInput.tsx`:

```typescript
// studio/components/SEOInput.tsx
import React from 'react'
import { Card, Grid, Stack, Text, TextInput, TextArea, Checkbox, Label } from '@sanity/ui'
import { set, type ObjectInputProps } from 'sanity'

/**
 * Custom SEO Input
 * 
 * Provides a clean interface for SEO metadata.
 * Includes character counters and helpful tips.
 */
export function SEOInput(props: ObjectInputProps) {
  const { value, onChange } = props
  
  const handleFieldChange = (fieldName: string, newValue: any) => {
    onChange(set({ ...value, [fieldName]: newValue }))
  }
  
  return (
    <Card padding={3} radius={2} tone="transparent">
      <Stack space={4}>
        {/* Meta Title */}
        <Stack space={2}>
          <Label>Meta Title</Label>
          <TextInput
            value={value?.metaTitle || ''}
            onChange={(e) => handleFieldChange('metaTitle', e.target.value)}
            placeholder="Enter meta title for SEO"
          />
          <Flex justify="space-between">
            <Text size={1} muted>
              Recommended: 50-60 characters
            </Text>
            <Text size={1} muted>
              {value?.metaTitle?.length || 0}/60
            </Text>
          </Flex>
        </Stack>
        
        {/* Meta Description */}
        <Stack space={2}>
          <Label>Meta Description</Label>
          <TextArea
            rows={3}
            value={value?.metaDescription || ''}
            onChange={(e) => handleFieldChange('metaDescription', e.target.value)}
            placeholder="Enter meta description for SEO"
          />
          <Flex justify="space-between">
            <Text size={1} muted>
              Recommended: 150-160 characters
            </Text>
            <Text size={1} muted>
              {value?.metaDescription?.length || 0}/160
            </Text>
          </Flex>
        </Stack>
        
        {/* Keywords */}
        <Stack space={2}>
          <Label>Keywords</Label>
          <TextInput
            value={value?.keywords?.join(', ') || ''}
            onChange={(e) => {
              const keywords = e.target.value.split(',').map(k => k.trim()).filter(Boolean)
              handleFieldChange('keywords', keywords)
            }}
            placeholder="Enter keywords separated by commas"
          />
          <Text size={1} muted>
            Enter up to 10 keywords
          </Text>
        </Stack>
        
        {/* No Index */}
        <Stack space={2}>
          <Flex align="center" gap={2}>
            <Checkbox
              checked={value?.noIndex || false}
              onChange={(e) => handleFieldChange('noIndex', e.target.checked)}
            />
            <Label>Prevent search engines from indexing this page</Label>
          </Flex>
          <Text size={1} muted>
            Check this box to add a noindex meta tag to this page
          </Text>
        </Stack>
      </Stack>
    </Card>
  )
}
```

#### 3.4 Register Custom Inputs

Update `studio/sanity.config.ts` to use custom inputs:

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { structureTool } from 'sanity/structure'
import { visionTool } from '@sanity/vision'
import { schemaTypes } from './schemas'
import { structure } from './structure'
import { SlugInput } from './components/SlugInput'
import { ColorPickerInput } from './components/ColorPickerInput'
import { SEOInput } from './components/SEOInput'

export default defineConfig({
  projectId: process.env.SANITY_STUDIO_PROJECT_ID || '',
  dataset: process.env.SANITY_STUDIO_DATASET || 'production',
  plugins: [
    structureTool({ structure }),
    visionTool(),
  ],
  schema: {
    types: schemaTypes,
  },
  // Register custom components
  form: {
    components: {
      input: (props) => {
        // Use custom slug input for slug fields
        if (props.schemaType.name === 'slug' && props.path.includes('slug')) {
          return SlugInput
        }
        // Use custom color picker for color fields
        if (props.schemaType.name === 'string' && props.schemaType.options?.isColor) {
          return ColorPickerInput
        }
        // Use custom SEO input for seo objects
        if (props.schemaType.name === 'seo' && props.schemaType.title === 'SEO Settings') {
          return SEOInput
        }
        return undefined
      },
    },
  },
})
```

### The Verification

1. **Create a new post**: Check the slug field - you should see a live URL preview
2. **Add a color field**: Test the color picker with preset colors
3. **Edit SEO**: See the custom SEO interface with character counters
4. **Test each custom input**: Verify they work correctly and save data

**You now have custom inputs that enhance editorial experience!**

---

## Step 4: Creating Custom Document Actions

### The Target
Build custom document actions for publishing workflows and content operations.

### The Concept
Document actions add custom buttons to the document editor toolbar. These can trigger any logic you need—from custom publishing workflows to AI processing.

**Real-world analogy**: Document actions are like having custom shortcuts in your car. Instead of just "Drive" and "Park," you have "Sport Mode," "Eco Mode," and "Launch Control."

### The Implementation

#### 4.1 Create a Custom Publish Action

Create `studio/actions/PublishWithValidation.tsx`:

```typescript
// studio/actions/PublishWithValidation.tsx
import React, { useState } from 'react'
import { 
  useDocumentOperation, 
  type DocumentActionProps,
  type DocumentActionDescription 
} from 'sanity'
import { Button, Dialog, Text, Stack, Card, Flex, Badge } from '@sanity/ui'

/**
 * Custom Publish Action
 * 
 * Adds validation before publishing a document.
 * Checks for required fields and displays warnings.
 */
export function PublishWithValidation(props: DocumentActionProps) {
  const { id, type, draft, published } = props
  const { publish } = useDocumentOperation(id, type)
  
  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const [validationErrors, setValidationErrors] = useState<string[]>([])
  
  // Check if document has required fields
  const validateDocument = () => {
    const errors: string[] = []
    const doc = draft || published
    
    if (!doc) return []
    
    // Check for common issues
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
    
    // If validation passes, publish
    publish.execute()
    props.onComplete?.()
  }
  
  // Check if document is already published
  const isPublished = !!published
  
  return {
    // Button label
    label: isPublished ? 'Update' : 'Publish',
    
    // Button icon (optional)
    icon: () => <span>✅</span>,
    
    // Disable when draft is not available
    disabled: !draft,
    
    // Show a tooltip
    title: isPublished ? 'Update published document' : 'Publish document',
    
    // Action handler
    onHandle: handlePublish,
    
    // Dialog for validation errors
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

#### 4.2 Create an AI Summary Action

Create `studio/actions/GenerateAISummary.tsx`:

```typescript
// studio/actions/GenerateAISummary.tsx
import React, { useState } from 'react'
import { 
  useDocumentOperation, 
  type DocumentActionProps,
  type DocumentActionDescription 
} from 'sanity'
import { Dialog, Card, Text, Stack, Button, Spinner, Flex } from '@sanity/ui'

/**
 * AI Summary Generation Action
 * 
 * Uses AI to generate a summary and excerpt from the document content.
 * This is a placeholder that simulates AI processing.
 * In production, you'd integrate with OpenAI, Claude, etc.
 */
export function GenerateAISummary(props: DocumentActionProps) {
  const { id, type, draft, published } = props
  const { patch } = useDocumentOperation(id, type)
  
  const [isProcessing, setIsProcessing] = useState(false)
  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const [summary, setSummary] = useState('')
  
  const doc = draft || published
  
  // Only show for posts with body content
  const hasBody = doc?.body && doc.body.length > 0
  
  // Generate summary from content
  const generateSummary = async () => {
    if (!doc) return
    
    setIsProcessing(true)
    
    try {
      // In a real implementation, you'd call an AI API here
      // For now, we'll simulate with a simple algorithm
      const bodyText = doc.body
        .filter((block: any) => block._type === 'block')
        .map((block: any) => {
          return block.children?.map((child: any) => child.text || '').join('') || ''
        })
        .join(' ')
      
      // Simulate AI processing
      await new Promise(resolve => setTimeout(resolve, 1500))
      
      // Generate a simple summary (first 200 characters)
      const generatedSummary = bodyText
        .slice(0, 200)
        .trim()
        .split(' ')
        .slice(0, -1)
        .join(' ') + '...'
      
      setSummary(generatedSummary)
      
      // Update the document
      patch.execute([
        { set: { excerpt: generatedSummary } }
      ])
      
      setIsDialogOpen(true)
    } catch (error) {
      console.error('Failed to generate summary:', error)
    } finally {
      setIsProcessing(false)
    }
  }
  
  return {
    label: 'AI Summary',
    icon: () => <span>🤖</span>,
    disabled: !hasBody || isProcessing,
    title: 'Generate AI summary from content',
    onHandle: generateSummary,
    dialog: isDialogOpen && {
      type: 'dialog',
      title: 'AI Summary Generated',
      content: (
        <Dialog
          id="summary-dialog"
          header="AI Summary Generated"
          onClose={() => setIsDialogOpen(false)}
          width={1}
        >
          <Card padding={4}>
            <Stack space={4}>
              <Text weight="bold">Generated Summary:</Text>
              <Card padding={3} radius={2} tone="primary">
                <Text>{summary}</Text>
              </Card>
              <Flex gap={2}>
                <Button
                  text="OK"
                  tone="primary"
                  onClick={() => setIsDialogOpen(false)}
                />
                <Button
                  text="Dismiss"
                  mode="ghost"
                  onClick={() => setIsDialogOpen(false)}
                />
              </Flex>
            </Stack>
          </Card>
        </Dialog>
      ),
    },
  } as DocumentActionDescription
}
```

#### 4.3 Register Document Actions

Update `studio/sanity.config.ts`:

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { structureTool } from 'sanity/structure'
import { visionTool } from '@sanity/vision'
import { schemaTypes } from './schemas'
import { structure } from './structure'
import { SlugInput } from './components/SlugInput'
import { ColorPickerInput } from './components/ColorPickerInput'
import { SEOInput } from './components/SEOInput'
// Import document actions
import { PublishWithValidation } from './actions/PublishWithValidation'
import { GenerateAISummary } from './actions/GenerateAISummary'

export default defineConfig({
  projectId: process.env.SANITY_STUDIO_PROJECT_ID || '',
  dataset: process.env.SANITY_STUDIO_DATASET || 'production',
  plugins: [
    structureTool({ structure }),
    visionTool(),
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
  // Register document actions
  document: {
    actions: (prev, context) => {
      // Add custom actions for specific document types
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

### The Verification

1. **Open a post document**: Check the toolbar for new actions
2. **Try the validation**: Create a post without a title and try to publish
3. **Generate AI summary**: Click the AI Summary button and see it generate content
4. **Update published post**: Notice the button changes from "Publish" to "Update"

**You now have custom document actions that automate editorial workflows!**

---

## Step 5: Building a Content Calendar

### The Target
Create a visual content calendar for scheduling and planning content.

### The Concept
A content calendar shows all posts in a visual timeline, helping editors plan and schedule content. It's like a calendar app but specifically for your content.

**Real-world analogy**: A content calendar is like a wall calendar in a newsroom. Editors see what's coming up, what's been published, and where there are gaps.

### The Implementation

Create `studio/components/ContentCalendar.tsx`:

```typescript
// studio/components/ContentCalendar.tsx
import React, { useState, useEffect } from 'react'
import { 
  Card, Container, Heading, Text, Stack, Grid, Badge, 
  Flex, Button, Select, Spinner 
} from '@sanity/ui'
import { client } from '../../frontend/lib/sanity/client'

interface CalendarPost {
  _id: string
  title: string
  publishedAt: string
  status: 'published' | 'draft' | 'scheduled'
  author: string
  categories: string[]
}

/**
 * Content Calendar Component
 * 
 * Displays all posts in a visual calendar format.
 * Shows status, dates, and allows filtering.
 */
export function ContentCalendar() {
  const [posts, setPosts] = useState<CalendarPost[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState('all')
  const [currentMonth, setCurrentMonth] = useState(new Date())

  useEffect(() => {
    fetchPosts()
  }, [filter])

  const fetchPosts = async () => {
    try {
      setLoading(true)
      
      let statusFilter = ''
      switch (filter) {
        case 'published':
          statusFilter = ' && defined(publishedAt) && publishedAt <= now()'
          break
        case 'draft':
          statusFilter = ' && !defined(publishedAt)'
          break
        case 'scheduled':
          statusFilter = ' && publishedAt > now()'
          break
        default:
          statusFilter = ''
      }
      
      const query = `
        *[_type == "post"${statusFilter}] | order(publishedAt desc) {
          _id,
          title,
          publishedAt,
          "author": author->name,
          "categories": categories[]->title
        }
      `
      
      const data = await client.fetch<CalendarPost[]>(query)
      
      // Process posts with status
      const processedPosts = data.map((post: any) => ({
        ...post,
        status: !post.publishedAt ? 'draft' 
          : new Date(post.publishedAt) > new Date() ? 'scheduled' 
          : 'published'
      }))
      
      setPosts(processedPosts)
    } catch (error) {
      console.error('Failed to fetch calendar data:', error)
    } finally {
      setLoading(false)
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'published': return 'positive'
      case 'scheduled': return 'primary'
      case 'draft': return 'caution'
      default: return 'default'
    }
  }

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'published': return 'Published'
      case 'scheduled': return 'Scheduled'
      case 'draft': return 'Draft'
      default: return status
    }
  }

  const groupByMonth = (posts: CalendarPost[]) => {
    const groups: { [key: string]: CalendarPost[] } = {}
    
    posts.forEach(post => {
      if (!post.publishedAt) return
      
      const date = new Date(post.publishedAt)
      const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`
      
      if (!groups[key]) {
        groups[key] = []
      }
      groups[key].push(post)
    })
    
    return groups
  }

  const groupedPosts = groupByMonth(posts)
  const sortedMonths = Object.keys(groupedPosts).sort((a, b) => a.localeCompare(b))

  if (loading) {
    return (
      <Container padding={4}>
        <Card padding={4} radius={2}>
          <Flex align="center" gap={3}>
            <Spinner />
            <Text>Loading content calendar...</Text>
          </Flex>
        </Card>
      </Container>
    )
  }

  return (
    <Container padding={4}>
      <Stack space={4}>
        {/* Header */}
        <Flex align="center" justify="space-between" wrap="wrap" gap={2}>
          <Heading>Content Calendar</Heading>
          <Flex gap={2}>
            <Select
              value={filter}
              onChange={(e) => setFilter(e.currentTarget.value)}
            >
              <option value="all">All Posts</option>
              <option value="published">Published</option>
              <option value="scheduled">Scheduled</option>
              <option value="draft">Drafts</option>
            </Select>
            <Button
              text="Refresh"
              mode="ghost"
              onClick={fetchPosts}
            />
          </Flex>
        </Flex>

        {/* Stats */}
        <Card padding={3} radius={2} tone="transparent">
          <Grid columns={[2, 4]} gap={2}>
            <Card padding={2} radius={1} tone="positive">
              <Text align="center" size={1}>
                Published: {posts.filter(p => p.status === 'published').length}
              </Text>
            </Card>
            <Card padding={2} radius={1} tone="primary">
              <Text align="center" size={1}>
                Scheduled: {posts.filter(p => p.status === 'scheduled').length}
              </Text>
            </Card>
            <Card padding={2} radius={1} tone="caution">
              <Text align="center" size={1}>
                Drafts: {posts.filter(p => p.status === 'draft').length}
              </Text>
            </Card>
            <Card padding={2} radius={1} tone="default">
              <Text align="center" size={1}>
                Total: {posts.length}
              </Text>
            </Card>
          </Grid>
        </Card>

        {/* Calendar Grid */}
        <Grid columns={[1, 2, 3]} gap={4}>
          {sortedMonths.map(monthKey => {
            const [year, month] = monthKey.split('-')
            const date = new Date(parseInt(year), parseInt(month) - 1, 1)
            
            return (
              <Card key={monthKey} padding={3} radius={2} tone="default">
                <Stack space={3}>
                  <Text weight="bold" size={2}>
                    {date.toLocaleDateString('en-US', {
                      month: 'long',
                      year: 'numeric'
                    })}
                  </Text>
                  
                  <Stack space={2}>
                    {groupedPosts[monthKey].map(post => (
                      <Card
                        key={post._id}
                        padding={2}
                        radius={1}
                        tone={getStatusColor(post.status)}
                      >
                        <Stack space={1}>
                          <Flex align="center" justify="space-between">
                            <Text size={1} weight="bold">
                              {post.title || 'Untitled'}
                            </Text>
                            <Badge tone={getStatusColor(post.status)}>
                              {getStatusLabel(post.status)}
                            </Badge>
                          </Flex>
                          
                          <Flex gap={2} wrap="wrap">
                            {post.publishedAt && (
                              <Text size={1} muted>
                                {new Date(post.publishedAt).toLocaleDateString()}
                              </Text>
                            )}
                            {post.author && (
                              <Text size={1} muted>
                                By {post.author}
                              </Text>
                            )}
                          </Flex>
                          
                          {post.categories.length > 0 && (
                            <Flex gap={1} wrap="wrap">
                              {post.categories.map(cat => (
                                <Badge key={cat} size={0} mode="outline">
                                  {cat}
                                </Badge>
                              ))}
                            </Flex>
                          )}
                        </Stack>
                      </Card>
                    ))}
                  </Stack>
                </Stack>
              </Card>
            )
          })}
        </Grid>
      </Stack>
    </Container>
  )
}
```

### The Verification

1. **Navigate to Content Calendar** in your Studio
2. **Verify posts appear**: See posts grouped by month
3. **Test filters**: Switch between "All", "Published", "Scheduled", "Drafts"
4. **Check status badges**: Verify correct status indicators
5. **Test refresh**: Click refresh to reload the calendar

**You now have a visual content calendar for planning!**

---

## Step 6: AI-Assisted Workflows

### The Target
Implement AI-assisted content creation and editing workflows.

### The Concept
AI can dramatically speed up content workflows. From generating summaries to suggesting tags, AI tools can handle repetitive tasks, freeing editors to focus on creative work.

**Real-world analogy**: AI tools are like having an assistant who handles the mundane parts of your job—organizing, summarizing, and suggesting—while you focus on the creative work that requires human judgment.

### The Implementation

#### 6.1 Create an AI Assistant Component

Create `studio/components/AIAssistant.tsx`:

```typescript
// studio/components/AIAssistant.tsx
import React, { useState } from 'react'
import { 
  Card, Container, Heading, Text, Stack, 
  TextArea, Button, Flex, Badge, Spinner,
  Grid 
} from '@sanity/ui'

interface AIResponse {
  summary: string
  tags: string[]
  seoTitle: string
  seoDescription: string
}

/**
 * AI Assistant Component
 * 
 * Provides AI-powered content tools for editors.
 * Can generate summaries, suggest tags, and optimize SEO.
 * 
 * Note: This is a simulation. In production, integrate with
 * OpenAI API, Claude API, or other AI services.
 */
export function AIAssistant() {
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)
  const [results, setResults] = useState<AIResponse | null>(null)
  const [error, setError] = useState<string | null>(null)

  const processWithAI = async () => {
    if (!input.trim()) {
      setError('Please enter some content to process')
      return
    }

    setLoading(true)
    setError(null)

    try {
      // Simulate AI processing
      await new Promise(resolve => setTimeout(resolve, 2000))

      // Simulated AI response
      const response: AIResponse = {
        summary: `This content discusses ${input.slice(0, 50)}... It provides valuable insights and practical advice.`,
        tags: [
          input.split(' ').slice(0, 3).join(''),
          'technology',
          'best-practices',
          'guide',
        ],
        seoTitle: `${input.split(' ').slice(0, 5).join(' ')} | Expert Guide`,
        seoDescription: `Learn about ${input.slice(0, 100)} in this comprehensive guide.`,
      }

      setResults(response)
    } catch (err) {
      setError('Failed to process with AI. Please try again.')
      console.error('AI processing error:', err)
    } finally {
      setLoading(false)
    }
  }

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text)
      .then(() => {
        alert('Copied to clipboard!')
      })
      .catch(err => {
        console.error('Failed to copy:', err)
      })
  }

  return (
    <Container padding={4}>
      <Stack space={4}>
        <Heading>AI Assistant</Heading>
        
        <Card padding={4} radius={2}>
          <Stack space={4}>
            <Text>
              Enter your content below and let AI help with:
              <ul style={{ marginTop: '8px', paddingLeft: '20px' }}>
                <li>📝 Generate a compelling summary</li>
                <li>🏷️ Suggest relevant tags</li>
                <li>🔍 Optimize SEO metadata</li>
              </ul>
            </Text>

            <TextArea
              rows={6}
              value={input}
              onChange={(e) => setInput(e.currentTarget.value)}
              placeholder="Paste your content here..."
            />

            {error && (
              <Card padding={3} radius={2} tone="critical">
                <Text>{error}</Text>
              </Card>
            )}

            <Flex gap={2}>
              <Button
                text={loading ? 'Processing...' : 'Process with AI'}
                tone="primary"
                disabled={loading}
                onClick={processWithAI}
              />
              <Button
                text="Clear"
                mode="ghost"
                onClick={() => {
                  setInput('')
                  setResults(null)
                  setError(null)
                }}
              />
            </Flex>

            {loading && (
              <Flex align="center" gap={2}>
                <Spinner />
                <Text muted>Processing your content with AI...</Text>
              </Flex>
            )}
          </Stack>
        </Card>

        {results && (
          <Card padding={4} radius={2} tone="positive">
            <Stack space={4}>
              <Flex align="center" gap={2}>
                <Badge tone="positive">AI Generated</Badge>
                <Text size={1} muted>
                  Review and customize the suggestions below
                </Text>
              </Flex>

              <Grid columns={[1, 2]} gap={4}>
                {/* Summary */}
                <Card padding={3} radius={1}>
                  <Stack space={2}>
                    <Text weight="bold" size={1}>
                      📝 Summary
                    </Text>
                    <Text>{results.summary}</Text>
                    <Button
                      text="Copy"
                      size="small"
                      mode="ghost"
                      onClick={() => copyToClipboard(results.summary)}
                    />
                  </Stack>
                </Card>

                {/* Tags */}
                <Card padding={3} radius={1}>
                  <Stack space={2}>
                    <Text weight="bold" size={1}>
                      🏷️ Suggested Tags
                    </Text>
                    <Flex gap={1} wrap="wrap">
                      {results.tags.map(tag => (
                        <Badge key={tag}>{tag}</Badge>
                      ))}
                    </Flex>
                    <Button
                      text="Copy Tags"
                      size="small"
                      mode="ghost"
                      onClick={() => copyToClipboard(results.tags.join(', '))}
                    />
                  </Stack>
                </Card>

                {/* SEO Title */}
                <Card padding={3} radius={1}>
                  <Stack space={2}>
                    <Text weight="bold" size={1}>
                      🔍 SEO Title
                    </Text>
                    <Text>{results.seoTitle}</Text>
                    <Button
                      text="Copy"
                      size="small"
                      mode="ghost"
                      onClick={() => copyToClipboard(results.seoTitle)}
                    />
                  </Stack>
                </Card>

                {/* SEO Description */}
                <Card padding={3} radius={1}>
                  <Stack space={2}>
                    <Text weight="bold" size={1}>
                      📄 SEO Description
                    </Text>
                    <Text>{results.seoDescription}</Text>
                    <Button
                      text="Copy"
                      size="small"
                      mode="ghost"
                      onClick={() => copyToClipboard(results.seoDescription)}
                    />
                  </Stack>
                </Card>
              </Grid>
            </Stack>
          </Card>
        )}
      </Stack>
    </Container>
  )
}
```

#### 6.2 Integrate AI Assistant into Studio

Update `studio/structure/index.ts`:

```typescript
// studio/structure/index.ts
// Add this to the structure list
const aiAssistant = S.listItem()
  .title('AI Assistant')
  .icon(() => '🤖')
  .child(
    S.component()
      .id('aiAssistant')
      .title('AI Assistant')
      .component(
        () => import('../components/AIAssistant').then(mod => mod.AIAssistant)
      )
  )

// Add to the main structure
return S.list()
  .title('Content')
  .items([
    dashboard,
    S.divider(),
    blogPosts,
    authors,
    categories,
    S.divider(),
    settings,
    S.divider(),
    contentCalendar,
    aiAssistant,  // Add this
  ])
```

### The Verification

1. **Navigate to AI Assistant** in your Studio
2. **Paste content**: Enter some text in the text area
3. **Process with AI**: Click the button and wait for processing
4. **Review results**: Check the generated summary, tags, and SEO
5. **Copy suggestions**: Use the copy buttons to save the results

**You now have AI-powered content assistance!**

---

## Part 3 Summary

### What We've Accomplished

In this part, we:

✅ Customized Studio structure for optimal workflow
✅ Built dashboard widgets with real-time stats
✅ Created custom input components for specialized fields
✅ Implemented custom document actions for publishing
✅ Developed a visual content calendar
✅ Added AI-assisted content workflows

### Key Concepts You've Mastered

1. **Studio Structure**: Organizing the UI for editorial teams
2. **Custom Components**: Building React components for the Studio
3. **Document Actions**: Extending document editing capabilities
4. **Dashboard Widgets**: Creating data visualizations
5. **AI Integration**: Leveraging AI for content workflows
6. **Plugin Architecture**: Extending Sanity Studio

### Customization Best Practices

| Aspect | Best Practice |
|--------|---------------|
| **Structure** | Organize by editorial workflow, not technical types |
| **Inputs** | Make inputs intuitive; add previews where helpful |
| **Actions** | Validate thoroughly; provide clear feedback |
| **Widgets** | Show actionable data; update in real-time |
| **Performance** | Cache queries; use pagination for large datasets |
| **UX** | Provide loading states; handle errors gracefully |

### What's Next

In **Part 4: Real-Time Content, Visual Editing, and Production Workflows**, you'll implement:

- Live Content API for real-time updates
- Visual editing with the Presentation Tool
- Draft Mode for content previews
- Stega encoding for secure editing
- Content releases and publishing workflows
- Production deployment strategies

**Estimated time for Part 4**: 3-4 hours

### Practice Exercises

1. **Add a new widget**: Create a widget showing upcoming scheduled posts
2. **Create an action**: Build an action that sends content to external services
3. **Customize an input**: Create a rich text editor for bio fields
4. **Build a plugin**: Package your customizations as a reusable plugin
5. **Integrate real AI**: Connect to OpenAI API for actual AI features

### Resources for Further Learning

- [Sanity Studio Customization](https://www.sanity.io/docs/customizing-the-studio)
- [Sanity Input Components](https://www.sanity.io/docs/custom-input-components)
- [Sanity Document Actions](https://www.sanity.io/docs/document-actions)
- [Sanity Dashboard Widgets](https://www.sanity.io/docs/dashboard-widgets)

---

You've built a powerful editorial experience. Now it's time to enable real-time collaboration and visual editing. In Part 4, we'll implement live content updates, preview environments, and production workflows that will delight editors and developers alike.

Let's continue building!
