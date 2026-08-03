# Primer 6: Modeling Your First Content Types

Welcome to the sixth primer. You've installed Sanity, explored the Studio, and understand the basics of structured content. Now it's time to roll up your sleeves and build your first content models. This is where the rubber meets the road—you'll create the actual schemas that will power your application.

By the end of this primer, you'll have built a complete content model for a blog, complete with authors, posts, categories, and settings.

---

## The Building Blocks: Documents, Objects, and Fields

Before we start coding, let's understand Sanity's three primary building blocks:

| Building Block | Purpose | Example |
|----------------|---------|---------|
| **Document** | A top-level content item, typically with its own URL | A blog post, a product, an author page |
| **Object** | A reusable group of fields, often embedded in documents | SEO metadata, social links, address |
| **Field** | A single piece of information | Title (string), Price (number), Body (rich text) |

**Real-world analogy**: Think of documents as filing cabinets, objects as drawers within those cabinets, and fields as the individual files inside each drawer.

---

## Step 1: Creating Your First Document — The Author

Let's start with the simplest document type: the author. Authors are content creators who write posts, create videos, or otherwise contribute content.

### Create the Author Schema

Create `schemas/author.ts`:

```typescript
// schemas/author.ts
import { defineType, defineField } from 'sanity'

/**
 * Author Schema
 * 
 * Represents content creators - writers, editors, contributors.
 * This model stores profile information and social links.
 */
export default defineType({
  // Unique identifier for this type
  name: 'author',
  
  // Display name in the Studio
  title: 'Author',
  
  // Document type (as opposed to object type)
  type: 'document',
  
  fields: [
    /**
     * NAME FIELD
     * The author's full name.
     */
    defineField({
      name: 'name',
      title: 'Name',
      type: 'string',
      description: 'The full name of the author.',
      validation: (Rule) => Rule.required()
        .error('Author name is required'),
    }),
    
    /**
     * SLUG FIELD
     * URL-friendly version of the name.
     * Used for author archive pages.
     */
    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      description: 'URL-friendly version of the author name.',
      options: {
        source: 'name',  // Auto-generate from name
        maxLength: 96,
        slugify: (input: string) => input
          .toLowerCase()
          .replace(/\s+/g, '-')
          .replace(/[^\w-]+/g, '')
          .slice(0, 96),
      },
      validation: (Rule) => Rule.required()
        .error('Slug is required for author URLs'),
    }),
    
    /**
     * BIO FIELD
     * Brief biography of the author.
     */
    defineField({
      name: 'bio',
      title: 'Bio',
      type: 'text',
      description: 'Short biography of the author.',
      rows: 3,
      validation: (Rule) => Rule.max(500)
        .error('Bio should be concise, under 500 characters'),
    }),
    
    /**
     * AVATAR FIELD
     * Profile photo of the author.
     */
    defineField({
      name: 'avatar',
      title: 'Avatar',
      type: 'image',
      description: 'Profile photo for the author.',
      options: {
        hotspot: true,  // Enable responsive cropping
      },
      fields: [
        {
          name: 'alt',
          title: 'Alt Text',
          type: 'string',
          description: 'Describe the avatar for accessibility.',
          validation: (Rule) => Rule.required()
            .error('Alt text is required for accessibility'),
        },
      ],
    }),
    
    /**
     * SOCIAL LINKS FIELD
     * Object storing various social media URLs.
     */
    defineField({
      name: 'socialLinks',
      title: 'Social Links',
      type: 'object',
      description: 'Links to the author\'s social media profiles.',
      fields: [
        {
          name: 'twitter',
          title: 'Twitter/X',
          type: 'url',
          validation: (Rule) => Rule.uri({
            scheme: ['https'],
            allowRelative: false,
          }),
        },
        {
          name: 'linkedin',
          title: 'LinkedIn',
          type: 'url',
          validation: (Rule) => Rule.uri({
            scheme: ['https'],
            allowRelative: false,
          }),
        },
        {
          name: 'github',
          title: 'GitHub',
          type: 'url',
          validation: (Rule) => Rule.uri({
            scheme: ['https'],
            allowRelative: false,
          }),
        },
        {
          name: 'personalWebsite',
          title: 'Personal Website',
          type: 'url',
          validation: (Rule) => Rule.uri({
            scheme: ['https', 'http'],
            allowRelative: false,
          }),
        },
      ],
    }),
    
    /**
     * ROLE FIELD
     * Author's role (Writer, Editor, etc.)
     */
    defineField({
      name: 'role',
      title: 'Role',
      type: 'string',
      description: 'Author role (Writer, Editor, etc.)',
      options: {
        list: [
          {title: 'Writer', value: 'writer'},
          {title: 'Senior Writer', value: 'senior-writer'},
          {title: 'Editor', value: 'editor'},
          {title: 'Contributor', value: 'contributor'},
          {title: 'Guest Author', value: 'guest'},
        ],
      },
    }),
  ],
  
  // Preview configuration — controls how authors appear in lists
  preview: {
    select: {
      title: 'name',
      media: 'avatar',
      subtitle: 'role',
    },
    prepare(selection) {
      const { title, media, subtitle } = selection
      return {
        title: title || 'Unnamed Author',
        media: media,
        subtitle: subtitle || 'Author',
      }
    },
  },
  
  // Order by name
  orderings: [
    {
      title: 'Name, A-Z',
      name: 'nameAsc',
      by: [{ field: 'name', direction: 'asc' }],
    },
  ],
})
```

### Understanding Each Part

**`defineType` and `defineField`**: These helpers provide TypeScript type safety. They're optional but highly recommended.

**`name`**: The unique identifier for your schema type. This is used in queries and references.

**`title`**: The display name in the Studio.

**`type`**: Either `'document'` (top-level content) or `'object'` (embedded content).

**`fields`**: An array of field definitions. Each field has a name, title, type, and optional validation.

**`validation`**: Rules that ensure data quality. Sanity will show friendly error messages when validation fails.

**`preview`**: Controls how documents appear in lists. You can select which fields to show and format them.

---

## Step 2: Creating the Blog Post Document

Now let's create the heart of our content platform: the blog post.

Create `schemas/post.ts`:

```typescript
// schemas/post.ts
import { defineType, defineField } from 'sanity'

/**
 * Blog Post Schema
 * 
 * This defines the structure for blog posts in our platform.
 * Each field is carefully designed to support rich content
 * while maintaining structured, queryable data.
 */
export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  
  fields: [
    /**
     * TITLE FIELD
     * The post's headline. This is the most important field
     * for SEO and user engagement.
     */
    defineField({
      name: 'title',
      title: 'Title',
      type: 'string',
      description: 'The main headline of your blog post. Keep it compelling and clear.',
      validation: (Rule) => [
        Rule.required().error('Every post needs a title!'),
        Rule.min(5).error('Title must be at least 5 characters long'),
        Rule.max(100).error('Title cannot exceed 100 characters'),
      ],
    }),
    
    /**
     * SLUG FIELD
     * The URL-friendly version of the title.
     * Used for routing and SEO.
     */
    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      description: 'The URL-friendly version of the title. Automatically generated from the title.',
      options: {
        source: 'title',
        maxLength: 96,
        slugify: (input: string) => input
          .toLowerCase()
          .replace(/\s+/g, '-')
          .replace(/[^\w-]+/g, '')
          .slice(0, 96),
      },
      validation: (Rule) => Rule.required()
        .error('Every post needs a slug for its URL'),
    }),
    
    /**
     * EXCERPT FIELD
     * A short summary used in listings, SEO meta descriptions,
     * and social media previews.
     */
    defineField({
      name: 'excerpt',
      title: 'Excerpt',
      type: 'text',
      description: 'A brief summary of the post. Used in article listings and SEO.',
      rows: 3,
      validation: (Rule) => Rule.max(200)
        .error('Excerpt cannot exceed 200 characters'),
    }),
    
    /**
     * FEATURED IMAGE FIELD
     * The main image that represents the post.
     * Used in listings, social sharing, and as a hero image.
     */
    defineField({
      name: 'featuredImage',
      title: 'Featured Image',
      type: 'image',
      description: 'The main image for this post. Appears in listings and social sharing.',
      options: {
        hotspot: true,  // Enable responsive cropping
        metadata: ['blurhash', 'lqip', 'palette'],
      },
      fields: [
        defineField({
          name: 'alt',
          title: 'Alt Text',
          type: 'string',
          description: 'Description of the image for accessibility and SEO.',
          validation: (Rule) => Rule.required()
            .error('Alt text is required for accessibility'),
        }),
        defineField({
          name: 'caption',
          title: 'Caption',
          type: 'string',
          description: 'Optional caption that appears below the image.',
        }),
      ],
    }),
    
    /**
     * PUBLISH DATE FIELD
     * When the post should be considered published.
     * Used for ordering and display.
     */
    defineField({
      name: 'publishedAt',
      title: 'Published Date',
      type: 'datetime',
      description: 'When this post was or will be published.',
      initialValue: () => new Date().toISOString(),
      validation: (Rule) => Rule.required()
        .error('Publish date is required'),
    }),
    
    /**
     * AUTHOR FIELD
     * Reference to the author of this post.
     * Enables author pages and attribution.
     */
    defineField({
      name: 'author',
      title: 'Author',
      type: 'reference',
      description: 'Who wrote this post?',
      to: [{ type: 'author' }],
      validation: (Rule) => Rule.required()
        .error('Every post needs an author'),
    }),
    
    /**
     * CATEGORIES FIELD
     * References to category documents.
     * Allows posts to be organized and filtered.
     */
    defineField({
      name: 'categories',
      title: 'Categories',
      type: 'array',
      description: 'Select categories for this post.',
      of: [
        {
          type: 'reference',
          to: [{ type: 'category' }],
        },
      ],
    }),
    
    /**
     * BODY FIELD
     * The main content of the post. Uses Portable Text
     * for rich, structured content.
     */
    defineField({
      name: 'body',
      title: 'Body',
      type: 'array',
      description: 'The main content of your blog post.',
      
      // 'of' defines what types of content can go in the body
      of: [
        // Standard text blocks with formatting
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
              { title: 'Underline', value: 'underline' },
              { title: 'Strike', value: 'strike-through' },
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
                    validation: (Rule) => Rule.uri({
                      scheme: ['http', 'https', 'mailto', 'tel'],
                    }),
                  },
                ],
              },
            ],
          },
        },
        // Inline images within the content
        {
          type: 'image',
          options: { hotspot: true },
          fields: [
            {
              name: 'alt',
              title: 'Alt Text',
              type: 'string',
              description: 'Describe the image for accessibility',
              validation: (Rule) => Rule.required(),
            },
            {
              name: 'caption',
              title: 'Caption',
              type: 'string',
            },
          ],
        },
        // Code blocks for technical content
        {
          type: 'code',
          title: 'Code Block',
          options: {
            language: 'javascript',
            languages: [
              { title: 'JavaScript', value: 'javascript' },
              { title: 'TypeScript', value: 'typescript' },
              { title: 'HTML', value: 'html' },
              { title: 'CSS', value: 'css' },
              { title: 'Python', value: 'python' },
              { title: 'Bash', value: 'bash' },
              { title: 'JSON', value: 'json' },
              { title: 'Markdown', value: 'markdown' },
            ],
          },
        },
      ],
    }),
    
    /**
     * SEO FIELD
     * Search Engine Optimization metadata.
     * Controls how the post appears in search results.
     */
    defineField({
      name: 'seo',
      title: 'SEO Settings',
      type: 'object',
      description: 'Search engine optimization settings for this post.',
      fields: [
        {
          name: 'metaTitle',
          title: 'Meta Title',
          type: 'string',
          description: 'Title for search engine results. Defaults to post title.',
          validation: (Rule) => Rule.max(60)
            .error('Meta titles should be 60 characters or less for optimal SEO'),
        },
        {
          name: 'metaDescription',
          title: 'Meta Description',
          type: 'text',
          description: 'Description for search engine results. Defaults to excerpt.',
          rows: 2,
          validation: (Rule) => Rule.max(160)
            .error('Meta descriptions should be 160 characters or less for optimal SEO'),
        },
        {
          name: 'keywords',
          title: 'Keywords',
          type: 'array',
          description: 'Target keywords for this post.',
          of: [{ type: 'string' }],
        },
        {
          name: 'noIndex',
          title: 'No Index',
          type: 'boolean',
          description: 'Prevent search engines from indexing this post.',
          initialValue: false,
        },
      ],
    }),
    
    /**
     * TAGS FIELD
     * Free-form tags for additional categorization.
     * Unlike categories, tags are created on the fly.
     */
    defineField({
      name: 'tags',
      title: 'Tags',
      type: 'array',
      description: 'Free-form tags for flexible categorization.',
      of: [{ type: 'string' }],
      options: {
        layout: 'tags',
      },
    }),
  ],
  
  // Order documents by publish date in the Studio
  orderings: [
    {
      title: 'Published Date, Newest',
      name: 'publishedAtDesc',
      by: [{ field: 'publishedAt', direction: 'desc' }],
    },
  ],
  
  // Preview configuration shows useful info in listings
  preview: {
    select: {
      title: 'title',
      author: 'author.name',
      media: 'featuredImage',
      date: 'publishedAt',
    },
    prepare(selection) {
      const { title, author, media, date } = selection
      const formattedDate = date ? new Date(date).toLocaleDateString() : ''
      return {
        title: title || 'Untitled Post',
        subtitle: `By ${author || 'Unknown'} • ${formattedDate}`,
        media: media,
      }
    },
  },
})
```

### Understanding Relationships: References

Notice the `author` and `categories` fields use `type: 'reference'`. This is how you create relationships between documents in Sanity.

```typescript
defineField({
  name: 'author',
  title: 'Author',
  type: 'reference',
  to: [{ type: 'author' }],  // Points to the author document type
})
```

When a user creates a post in the Studio, they'll see a dropdown of existing authors. Select one, and the post is linked to that author document.

**Why use references instead of typing in a name?**

1. **Consistency**: One place to update author information
2. **Query power**: Get all posts by a specific author
3. **Relation data**: Fetch author details along with post data

---

## Step 3: Creating the Category Document

Categories are simpler but essential for organizing content.

Create `schemas/category.ts`:

```typescript
// schemas/category.ts
import { defineType, defineField } from 'sanity'

/**
 * Category Schema
 * 
 * High-level content organization.
 * Categories are curated and limited in number.
 */
export default defineType({
  name: 'category',
  title: 'Category',
  type: 'document',
  
  fields: [
    defineField({
      name: 'title',
      title: 'Title',
      type: 'string',
      description: 'Name of the category.',
      validation: (Rule) => Rule.required()
        .error('Category title is required'),
    }),
    
    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      description: 'URL-friendly version of the category name.',
      options: {
        source: 'title',
        maxLength: 96,
      },
      validation: (Rule) => Rule.required()
        .error('Category slug is required'),
    }),
    
    defineField({
      name: 'description',
      title: 'Description',
      type: 'text',
      description: 'Brief description of what this category covers.',
      rows: 2,
      validation: (Rule) => Rule.max(200)
        .error('Category description cannot exceed 200 characters'),
    }),
    
    defineField({
      name: 'image',
      title: 'Image',
      type: 'image',
      description: 'Optional image representing this category.',
      options: {
        hotspot: true,
      },
      fields: [
        {
          name: 'alt',
          title: 'Alt Text',
          type: 'string',
          validation: (Rule) => Rule.required()
            .error('Alt text is required for accessibility'),
        },
      ],
    }),
    
    defineField({
      name: 'order',
      title: 'Display Order',
      type: 'number',
      description: 'Order in which this category should appear.',
      validation: (Rule) => Rule.integer().positive(),
    }),
  ],
  
  preview: {
    select: {
      title: 'title',
      subtitle: 'description',
      media: 'image',
    },
    prepare({ title, subtitle, media }) {
      return {
        title: title || 'Untitled Category',
        subtitle: subtitle || '',
        media: media,
      }
    },
  },
  
  orderings: [
    {
      title: 'Display Order',
      name: 'orderAsc',
      by: [
        { field: 'order', direction: 'asc' },
        { field: 'title', direction: 'asc' },
      ],
    },
  ],
})
```

---

## Step 4: Creating the Settings Document (Singleton)

A singleton is a document that should only have one instance. Settings is perfect for this—it stores global site configuration.

Create `schemas/settings.ts`:

```typescript
// schemas/settings.ts
import { defineType, defineField } from 'sanity'

/**
 * Settings Schema
 * 
 * Singleton document for global site configuration.
 * There should only be one settings document.
 */
export default defineType({
  name: 'settings',
  title: 'Site Settings',
  type: 'document',
  
  fields: [
    defineField({
      name: 'siteTitle',
      title: 'Site Title',
      type: 'string',
      description: 'The main title of your site.',
      validation: (Rule) => Rule.required()
        .error('Site title is required'),
    }),
    
    defineField({
      name: 'siteDescription',
      title: 'Site Description',
      type: 'text',
      description: 'Brief description of your site.',
      rows: 2,
      validation: (Rule) => Rule.max(160)
        .error('Description should be 160 characters or less for SEO'),
    }),
    
    defineField({
      name: 'logo',
      title: 'Logo',
      type: 'image',
      description: 'Main site logo.',
      options: {
        hotspot: true,
      },
      fields: [
        {
          name: 'alt',
          title: 'Alt Text',
          type: 'string',
          validation: (Rule) => Rule.required()
            .error('Alt text is required for accessibility'),
        },
      ],
    }),
    
    defineField({
      name: 'socialLinks',
      title: 'Social Media Links',
      type: 'object',
      description: 'Site-wide social media links.',
      fields: [
        { name: 'twitter', title: 'Twitter/X', type: 'url' },
        { name: 'linkedin', title: 'LinkedIn', type: 'url' },
        { name: 'github', title: 'GitHub', type: 'url' },
        { name: 'youtube', title: 'YouTube', type: 'url' },
        { name: 'instagram', title: 'Instagram', type: 'url' },
      ],
    }),
    
    defineField({
      name: 'defaultSeo',
      title: 'Default SEO Settings',
      type: 'object',
      description: 'Default SEO settings used when not overridden.',
      fields: [
        { name: 'metaTitle', title: 'Default Meta Title', type: 'string' },
        { name: 'metaDescription', title: 'Default Meta Description', type: 'text', rows: 2 },
        {
          name: 'ogImage',
          title: 'Default OG Image',
          type: 'image',
          description: 'Default image for social sharing.',
          options: { hotspot: true },
        },
      ],
    }),
  ],
  
  preview: {
    select: {
      title: 'siteTitle',
    },
    prepare({ title }) {
      return {
        title: title || 'Site Settings',
      }
    },
  },
})
```

---

## Step 5: Register Your Schemas

Now you need to register all your schemas in the central index file.

Update `schemas/index.ts`:

```typescript
// schemas/index.ts
import { SchemaTypeDefinition } from 'sanity'

// Import your schemas
import author from './author'
import post from './post'
import category from './category'
import settings from './settings'

// Export them as an array
export const schemaTypes: SchemaTypeDefinition[] = [
  author,
  post,
  category,
  settings,
]
```

---

## Step 6: Add Initial Values

Initial values pre-populate fields when creating new documents. This saves time and ensures consistency.

### Update Post Schema with Initial Values

```typescript
// schemas/post.ts
export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  
  // Add initial values
  initialValue: () => ({
    publishedAt: new Date().toISOString(),
    tags: [],
    seo: {
      noIndex: false,
    },
  }),
  
  // ... rest of fields
})
```

### Update Author Schema with Initial Values

```typescript
// schemas/author.ts
export default defineType({
  name: 'author',
  title: 'Author',
  type: 'document',
  
  initialValue: () => ({
    role: 'writer',
  }),
  
  // ... rest of fields
})
```

### Update Category Schema with Initial Values

```typescript
// schemas/category.ts
export default defineType({
  name: 'category',
  title: 'Category',
  type: 'document',
  
  initialValue: () => ({
    order: 0,
  }),
  
  // ... rest of fields
})
```

---

## Step 7: Add Helpful Validation Messages

Good validation messages guide editors and prevent errors. Let's enhance our validations:

### Post Schema Validation Example

```typescript
// schemas/post.ts - Enhanced validation
defineField({
  name: 'title',
  title: 'Title',
  type: 'string',
  validation: (Rule) => [
    Rule.required().error('Every post needs a title—it\'s the first thing readers see!'),
    Rule.min(5).error('Make your title at least 5 characters long to be descriptive.'),
    Rule.max(100).error('Keep your title under 100 characters for best display in search results.'),
  ],
}),
```

### Author Schema Validation Example

```typescript
// schemas/author.ts - Enhanced validation
defineField({
  name: 'name',
  title: 'Name',
  type: 'string',
  validation: (Rule) => Rule.required()
    .error('Please enter the author\'s name. Readers want to know who wrote this!'),
}),
```

### Category Schema Validation Example

```typescript
// schemas/category.ts - Enhanced validation
defineField({
  name: 'title',
  title: 'Title',
  type: 'string',
  validation: (Rule) => Rule.required()
    .error('Give your category a clear, descriptive title.'),
}),
```

---

## Step 8: Test Your Schemas

Start the Studio and test your schemas:

```bash
cd studio
sanity dev
```

### Create Test Content

1. **Create an author**:
   - Name: "Jane Doe"
   - Bio: "Jane is a senior writer covering technology and innovation."
   - Upload an avatar
   - Role: "Senior Writer"

2. **Create categories**:
   - "Technology" - "Posts about technology, software, and innovation"
   - "Design" - "UX, UI, and design thinking"
   - "Business" - "Business strategy, leadership, and entrepreneurship"

3. **Create a blog post**:
   - Title: "Getting Started with Sanity CMS"
   - Categories: Technology, Web Development
   - Author: Jane Doe
   - Body: Add some rich text with formatting, lists, and maybe an image
   - Published Date: Today

### Verify Everything Works

- [ ] All document types appear in the Studio
- [ ] Fields are organized properly
- [ ] Validation messages appear correctly
- [ ] References work (you can select authors and categories)
- [ ] Preview shows useful information
- [ ] Initial values pre-populate fields

---

## Step 9: Common Schema Patterns

### Reusable Field Groups (Objects)

Instead of repeating fields, create reusable objects:

```typescript
// schemas/objects/seo.ts
export default {
  name: 'seo',
  title: 'SEO Settings',
  type: 'object',
  fields: [
    { name: 'metaTitle', title: 'Meta Title', type: 'string' },
    { name: 'metaDescription', title: 'Meta Description', type: 'text' },
    { name: 'keywords', title: 'Keywords', type: 'array', of: [{ type: 'string' }] },
    { name: 'noIndex', title: 'No Index', type: 'boolean' },
  ],
}

// Use it in post.ts
defineField({
  name: 'seo',
  title: 'SEO Settings',
  type: 'seo',  // Reference the object type
})
```

### Field Groups (UI Organization)

Group fields for better editor experience:

```typescript
// schemas/post.ts
export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  
  groups: [
    { name: 'content', title: 'Content', default: true },
    { name: 'metadata', title: 'SEO & Metadata' },
    { name: 'settings', title: 'Settings' },
  ],
  
  fields: [
    // Content group
    defineField({ name: 'title', group: 'content', /* ... */ }),
    defineField({ name: 'body', group: 'content', /* ... */ }),
    
    // Metadata group
    defineField({ name: 'excerpt', group: 'metadata', /* ... */ }),
    defineField({ name: 'seo', group: 'metadata', /* ... */ }),
    
    // Settings group
    defineField({ name: 'publishedAt', group: 'settings', /* ... */ }),
    defineField({ name: 'tags', group: 'settings', /* ... */ }),
  ],
})
```

---

## Step 10: Version Control Your Schemas

Now that you have working schemas, commit them to version control:

```bash
# Add all schema files
git add schemas/

# Commit with a descriptive message
git commit -m "feat: add core content schemas

- Add author schema with name, slug, bio, avatar, social links
- Add post schema with title, slug, excerpt, body, author references
- Add category schema with title, slug, description
- Add settings schema for global configuration
- Add validation rules and initial values
- Configure field groups for better UX"

# Push to remote repository
git push
```

---

## Summary

### What You've Built

In this primer, you've created:

✅ **Author schema**: Name, slug, bio, avatar, social links, role
✅ **Post schema**: Title, slug, excerpt, featured image, body, author, categories, SEO, tags
✅ **Category schema**: Title, slug, description, image, order
✅ **Settings schema**: Site title, description, logo, social links, default SEO

### Key Concepts You've Mastered

1. **Documents vs Objects**: Documents are top-level content; objects are reusable groups
2. **References**: Create relationships between documents
3. **Validation**: Ensure data quality with rules and friendly messages
4. **Portable Text**: Rich text as structured data
5. **Initial Values**: Pre-populate fields to save time
6. **Preview Configuration**: Show useful information in lists
7. **Field Groups**: Organize fields for better UX

### Next Steps

Now that you have schemas, you're ready to:

1. **Query content**: Learn GROQ to fetch your content
2. **Build a frontend**: Integrate with React and Next.js
3. **Customize the Studio**: Add custom components and document actions

### Practice Exercises

1. **Add a new field**: Add an "email" field to the author schema
2. **Create a new document**: Create a "Video" document type for video content
3. **Add validation**: Add custom validation that checks if a slug is unique
4. **Create a reusable object**: Move the "SEO" fields to a reusable object
5. **Add a computed field**: Add a "wordCount" field that counts words in the body
