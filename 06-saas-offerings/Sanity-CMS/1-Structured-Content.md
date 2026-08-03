# Part 1: Foundations of Structured Content

Welcome to the hands-on portion of our series! In this part, we'll build the foundation of your content platform. We'll start from absolute zero and create a complete Sanity Studio with structured content models ready for production.

By the end of this part, you'll have:
- A fully configured Sanity Studio v5 project
- Content models for blog posts, authors, categories, and settings
- Validation rules ensuring data quality
- Portable Text configured with custom blocks
- A Studio that's ready for editorial use

Let's build something amazing.

---

## Step 1: Installing Sanity Studio v5

### The Target
Install Sanity CLI and create a new Sanity Studio project.

### The Concept
Think of Sanity CLI (Command Line Interface) as your remote control for managing Sanity projects. Instead of clicking through a web interface, you use terminal commands to create, configure, and deploy your Studio. This is faster, more repeatable, and essential for professional workflows.

### The Implementation

#### 1.1 Install Sanity CLI Globally

Open your terminal and run:

```bash
# Install Sanity CLI globally on your system
npm install -g @sanity/cli

# Verify the installation
sanity --version
# You should see output like: @sanity/cli 3.x.x
```

**Why global installation?** Installing globally makes the `sanity` command available anywhere in your terminal, similar to how `git` or `node` commands work. This speeds up your workflow for creating new projects.

**If you get permission errors on macOS/Linux:**
```bash
# Use sudo for global installation
sudo npm install -g @sanity/cli
```

**If you prefer not to use global packages:**
```bash
# Use npx (comes with npm) - this runs the command without installing globally
npx @sanity/cli --version
```

#### 1.2 Create Your Project Directory

Create a dedicated folder for your project. We'll use a monorepo structure where both the Studio and frontend live in one repository.

```bash
# Create project folder and navigate into it
mkdir mastering-sanity-cms
cd mastering-sanity-cms

# Create a folder for the Studio
mkdir studio
cd studio
```

**Why a monorepo?** Keeping your Studio and frontend in one repository simplifies development, ensures version consistency, and makes it easier to share code between them.

#### 1.3 Initialize the Sanity Studio

Run the initialization command:

```bash
# Initialize a new Sanity project
sanity init
```

You'll be prompted with several questions. Here are the recommended answers:

```
✔ Select project template: Clean project with no predefined schemas
✔ Project output path: . (current directory)
✔ Select project dataset configuration: Create new dataset
✔ Name your project: Mastering Sanity CMS
✔ Dataset name: production
✔ Select default dataset configuration: Public (we'll configure security later)
✔ Project visibility: Public (for learning; we'll secure it later)
✔ Do you want to use TypeScript? Yes
✔ Package manager: npm (or yarn if you prefer)
```

**What's happening here?**

- **Project template**: We chose "Clean project" because we'll build schemas from scratch, learning each concept deeply.
- **Dataset**: Think of a dataset as a database. We're creating a "production" dataset for live content. Later, we'll create "development" and "staging" datasets.
- **TypeScript**: Yes! TypeScript adds type safety, making our code more reliable and easier to maintain. It's like having a spell-checker for your code.

#### 1.4 Verify the Installation

After initialization completes, your Studio is ready. Start it to verify everything works:

```bash
# Start the development server
sanity dev
```

Your terminal should show:
```
✔ Server running on http://localhost:3333
✔ Studio built successfully
```

Open your browser to `http://localhost:3333`. You should see the Sanity Studio login screen. Log in with your Sanity credentials.

**What you're seeing**: The Sanity Studio interface is a React application. Right now, it's empty because we haven't defined any content schemas.

### The Verification

```bash
# Stop the dev server with Ctrl+C
# Check that the project structure was created
ls -la
# You should see:
# - .env                     (environment variables)
# - .sanity/                 (Sanity configuration)
# - sanity.config.ts         (Studio configuration)
# - sanity.cli.ts            (CLI configuration)
# - schemas/                 (Schema definitions)
# - package.json             (Project dependencies)
```

**Success!** You have a working Sanity Studio. Leave the dev server running; we'll use it throughout the tutorial.

---

## Step 2: Understanding the Project Structure

### The Target
Understand the files and folders Sanity created and how they work together.

### The Concept
Think of your Sanity project as a kitchen. Different areas serve different purposes:
- `sanity.config.ts` is your kitchen layout—where everything goes
- `schemas/` is your ingredient storage—all the types of content you can create
- `package.json` is your pantry inventory—all the tools you need

### The Implementation

Let's examine each file:

#### 2.1 `sanity.config.ts` - The Studio Configuration

This is the main configuration file. It tells Sanity how to build your Studio.

```typescript
// studio/sanity.config.ts
import { defineConfig } from 'sanity'
import { structureTool } from 'sanity/structure'
import { visionTool } from '@sanity/vision'
import { schemaTypes } from './schemas'

export default defineConfig({
  // Project ID from your Sanity project
  projectId: process.env.SANITY_STUDIO_PROJECT_ID || '',
  
  // Dataset name (production, development, etc.)
  dataset: process.env.SANITY_STUDIO_DATASET || 'production',
  
  // Plugins enable additional functionality
  plugins: [
    // Structure tool provides the main content editing interface
    structureTool(),
    
    // Vision tool enables GROQ query testing in the Studio
    visionTool(),
  ],
  
  // Schema types define your content models
  schema: {
    types: schemaTypes,
  },
})
```

**Key concepts explained:**

- **`projectId`**: A unique identifier for your Sanity project. Think of it like your building's address.
- **`dataset`**: The specific database in your project. Like different rooms in your building.
- **`plugins`**: Add-on features. Like appliances in your kitchen.
- **`schema`**: Your content models. Like your recipe collection.

#### 2.2 `sanity.cli.ts` - The CLI Configuration

Configures the Sanity CLI behavior.

```typescript
// studio/sanity.cli.ts
import { defineCliConfig } from 'sanity/cli'

export default defineCliConfig({
  api: {
    projectId: process.env.SANITY_STUDIO_PROJECT_ID || '',
    dataset: process.env.SANITY_STUDIO_DATASET || 'production',
  },
})
```

#### 2.3 `.env` - Environment Variables

Contains secrets and environment-specific settings. **Never commit this file to Git!**

```
# studio/.env
SANITY_STUDIO_PROJECT_ID=your-project-id-here
SANITY_STUDIO_DATASET=production
```

#### 2.4 `schemas/index.ts` - Schema Registry

This file imports all your schema types and exports them as an array.

```typescript
// studio/schemas/index.ts
import { SchemaTypeDefinition } from 'sanity'

// We'll create these files in the next steps
import post from './post'
import author from './author'
import category from './category'
import settings from './settings'

export const schemaTypes: SchemaTypeDefinition[] = [
  post,
  author, 
  category,
  settings,
]
```

#### 2.5 `package.json` - Dependencies and Scripts

Lists all packages your project needs and provides helpful scripts.

```json
{
  "name": "studio",
  "private": true,
  "version": "1.0.0",
  "scripts": {
    "dev": "sanity dev",
    "build": "sanity build",
    "deploy": "sanity deploy",
    "start": "sanity start"
  },
  "dependencies": {
    "@sanity/cli": "^3.0.0",
    "@sanity/vision": "^3.0.0",
    "sanity": "^3.0.0",
    "styled-components": "^6.0.0"
  }
}
```

### The Verification

```bash
# Open the Studio in your browser
sanity dev

# Navigate to http://localhost:3333
# You should see a clean Studio interface with:
# - "Create new document" button (currently empty)
# - "Vision" tool in the navigation (for querying)
```

**Understanding the interface**:
- **Structure**: The content management area (empty for now)
- **Vision**: A query playground where you can test GROQ queries
- **Settings**: Project settings (advanced)

---

## Step 3: Creating Your First Schema - Blog Post

### The Target
Create the `post` document schema, the heart of our content platform.

### The Concept
A schema defines what fields a document has. Think of it as a blueprint for your content. Just as a house blueprint specifies rooms, dimensions, and materials, a schema specifies fields, types, and validation rules.

**Real-world analogy**: Imagine you're creating a form for a job application. You decide:
- Name field (required, text)
- Email field (required, email format)
- Resume field (required, file upload)
- Cover letter (optional, text area)

That's exactly what we're doing with content schemas, but for content objects instead of job applications.

### The Implementation

#### 3.1 Create the Post Schema File

Create a new file at `studio/schemas/post.ts`:

```typescript
// studio/schemas/post.ts
import { defineField, defineType } from 'sanity'

/**
 * Blog Post Schema
 * 
 * This defines the structure for blog posts in our platform.
 * Each field is carefully designed to support rich content
 * while maintaining structured, queryable data.
 */
export default defineType({
  // Unique identifier for this type
  name: 'post',
  
  // Display name in the Studio
  title: 'Blog Post',
  
  // Document type (as opposed to object type)
  type: 'document',
  
  // Main fields that make up a blog post
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
      
      // Validation ensures data quality
      validation: (Rule) => [
        Rule.required()
          .error('Every post needs a title!'),
        Rule.min(5)
          .error('Title must be at least 5 characters long'),
        Rule.max(100)
          .error('Title cannot exceed 100 characters'),
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
      
      // 'source' tells Sanity which field to use as the basis
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
      
      // Options for the image upload
      options: {
        // Enable hotspot for responsive cropping
        hotspot: true,
        
        // Metadata to store with the image
        metadata: ['blurhash', 'lqip', 'palette'],
      },
      
      // Additional fields that can be associated with the image
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
            {title: 'Normal', value: 'normal'},
            {title: 'Heading 1', value: 'h1'},
            {title: 'Heading 2', value: 'h2'},
            {title: 'Heading 3', value: 'h3'},
            {title: 'Quote', value: 'blockquote'},
          ],
          lists: [
            {title: 'Bullet', value: 'bullet'},
            {title: 'Numbered', value: 'number'},
          ],
          marks: {
            decorators: [
              {title: 'Bold', value: 'strong'},
              {title: 'Italic', value: 'em'},
              {title: 'Underline', value: 'underline'},
              {title: 'Strike', value: 'strike-through'},
              {title: 'Code', value: 'code'},
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
          options: {hotspot: true},
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
              {title: 'JavaScript', value: 'javascript'},
              {title: 'TypeScript', value: 'typescript'},
              {title: 'HTML', value: 'html'},
              {title: 'CSS', value: 'css'},
              {title: 'Python', value: 'python'},
              {title: 'Bash', value: 'bash'},
              {title: 'JSON', value: 'json'},
              {title: 'Markdown', value: 'markdown'},
            ],
          },
        },
      ],
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
          to: [{type: 'category'}],
        },
      ],
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
      to: [{type: 'author'}],
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
      of: [{type: 'string'}],
      options: {
        layout: 'tags',
      },
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
          of: [{type: 'string'}],
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
  ],
  
  // Order documents by publish date in the Studio
  orderings: [
    {
      title: 'Published Date, Newest',
      name: 'publishedAtDesc',
      by: [
        {field: 'publishedAt', direction: 'desc'}
      ],
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
      const {title, author, media, date} = selection
      const formattedDate = date ? new Date(date).toLocaleDateString() : ''
      return {
        title: title,
        subtitle: `By ${author || 'Unknown'} • ${formattedDate}`,
        media: media,
      }
    },
  },
})
```

**Important concepts explained:**

- **`defineType`**: A helper function that provides TypeScript types for your schema
- **`defineField`**: Helper for defining individual fields with type safety
- **`validation`**: Rules that ensure data quality. Like a bouncer at a club checking IDs.
- **`type: 'document'`**: Documents are top-level content types that get their own URLs
- **`type: 'object'`**: Objects are reusable field groups within documents
- **`type: 'reference'`**: Creates relationships between documents
- **`preview`**: Controls how documents appear in Studio lists

### The Verification

#### 3.2 Add the Post Schema to the Registry

Open `studio/schemas/index.ts` and update it:

```typescript
// studio/schemas/index.ts
import { SchemaTypeDefinition } from 'sanity'

// Import our schemas
import post from './post'
// We'll create these in the next steps
// import author from './author'
// import category from './category'
// import settings from './settings'

export const schemaTypes: SchemaTypeDefinition[] = [
  post,
  // Temporarily comment out the others until they exist
  // author,
  // category,
  // settings,
]
```

#### 3.3 Test the Studio

```bash
# If the dev server isn't running, start it
sanity dev

# Open http://localhost:3333 in your browser
```

You should now see:

1. **"Create new document"** button
2. When you click it, **"Blog Post"** appears as an option
3. Clicking "Blog Post" opens a form with all the fields we defined

**Test the form**:
1. Try creating a post with all fields filled
2. Test the validation (try leaving title empty - you'll see an error)
3. Upload a featured image
4. Add some rich text in the body
5. Save the document (Save button at the top right)

**You should see**:
- The post appears in the document list with your title
- The preview shows the title, author (if set), and date
- All fields work as expected

**Congratulations! You've created your first content model.**

---

## Step 4: Creating the Author Schema

### The Target
Create the `author` schema to represent content creators.

### The Concept
Authors are content creators. They write posts, create videos, or otherwise contribute content. Having a separate author model means:
1. You can store detailed information about each author
2. You can display author bios on posts
3. You can create author archive pages showing all their work
4. You can attribute multiple posts to the same author

**Real-world analogy**: Think of authors as profile pages on social media. Each author has a name, photo, bio, and social links—just like a LinkedIn or Twitter profile.

### The Implementation

Create `studio/schemas/author.ts`:

```typescript
// studio/schemas/author.ts
import { defineField, defineType } from 'sanity'

/**
 * Author Schema
 * 
 * Represents content creators - writers, editors, contributors.
 * This model stores profile information and social links.
 */
export default defineType({
  name: 'author',
  title: 'Author',
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
        source: 'name',
        maxLength: 96,
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
      type: 'array',
      description: 'Short biography of the author.',
      of: [
        {
          type: 'block',
          styles: [{title: 'Normal', value: 'normal'}],
          marks: {
            decorators: [
              {title: 'Bold', value: 'strong'},
              {title: 'Italic', value: 'em'},
            ],
          },
        },
      ],
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
        hotspot: true,
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
      validation: (Rule) => Rule.required()
        .error('Author avatar is required'),
    }),
    
    /**
     * SOCIAL LINKS FIELD
     * JSON object storing various social media URLs.
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
            scheme: ['https'],
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
    
    /**
     * BIOGRAPHY LONG FIELD
     * Extended biography for a dedicated author page.
     */
    defineField({
      name: 'biographyLong',
      title: 'Extended Biography',
      type: 'array',
      description: 'Detailed biography for the author\'s page.',
      of: [{type: 'block'}],
    }),
  ],
  
  // Preview configuration
  preview: {
    select: {
      title: 'name',
      media: 'avatar',
      subtitle: 'role',
    },
    prepare(selection) {
      const {title, media, subtitle} = selection
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
      by: [{field: 'name', direction: 'asc'}],
    },
  ],
})
```

### The Verification

Update `studio/schemas/index.ts` to include the author schema:

```typescript
// studio/schemas/index.ts
import { SchemaTypeDefinition } from 'sanity'

import post from './post'
import author from './author'  // Add this line

export const schemaTypes: SchemaTypeDefinition[] = [
  post,
  author,  // Add this line
  // category,  // Coming soon
  // settings,  // Coming soon
]
```

**Test the author schema**:

1. Go to your Studio (http://localhost:3333)
2. Click "Create new document" → "Author"
3. Fill in:
   - Name: "Jane Doe"
   - Bio: "Jane is a senior writer covering technology and innovation."
   - Upload an avatar image
   - Add a social link (e.g., Twitter)
4. Save the author

**Verify**:
- The author appears in your list
- Click the author to see the detail view
- Try creating a post and selecting Jane as the author (you should see "Jane Doe" in the author dropdown)

---

## Step 5: Creating the Category Schema

### The Target
Create the `category` schema for organizing content.

### The Concept
Categories are high-level content organization. Unlike tags (which are free-form), categories are curated and limited. Think of categories like sections in a bookstore: Fiction, Non-Fiction, Science, History. Each book goes in one or more sections, and sections help readers find what they're looking for.

**Real-world analogy**: Categories are like folders in your email. You create a few main folders (Work, Personal, Bills), and every email goes into one folder. Tags are like labels—you can add multiple labels to the same email for more granular organization.

### The Implementation

Create `studio/schemas/category.ts`:

```typescript
// studio/schemas/category.ts
import { defineField, defineType } from 'sanity'

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
    /**
     * TITLE FIELD
     * The category name.
     */
    defineField({
      name: 'title',
      title: 'Title',
      type: 'string',
      description: 'Name of the category.',
      validation: (Rule) => Rule.required()
        .error('Category title is required'),
    }),
    
    /**
     * SLUG FIELD
     * URL-friendly version of the title.
     */
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
    
    /**
     * DESCRIPTION FIELD
     * Brief description of the category.
     */
    defineField({
      name: 'description',
      title: 'Description',
      type: 'text',
      description: 'Brief description of what this category covers.',
      rows: 2,
      validation: (Rule) => Rule.max(200)
        .error('Category description cannot exceed 200 characters'),
    }),
    
    /**
     * IMAGE FIELD
     * Optional image representing the category.
     */
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
    
    /**
     * PARENT CATEGORY FIELD
     * Allows hierarchical categorization.
     */
    defineField({
      name: 'parentCategory',
      title: 'Parent Category',
      type: 'reference',
      description: 'Parent category for hierarchical organization.',
      to: [{type: 'category'}],
      options: {
        disableNew: true,  // Prevent creating parent from within child
      },
    }),
    
    /**
     * ORDER FIELD
     * Manual ordering of categories.
     */
    defineField({
      name: 'order',
      title: 'Display Order',
      type: 'number',
      description: 'Order in which this category should appear.',
      validation: (Rule) => Rule.integer()
        .positive(),
    }),
  ],
  
  // Preview configuration
  preview: {
    select: {
      title: 'title',
      subtitle: 'description',
      media: 'image',
    },
    prepare({title, subtitle, media}) {
      return {
        title: title || 'Untitled Category',
        subtitle: subtitle || '',
        media: media,
      }
    },
  },
  
  // Order by the order field, then title
  orderings: [
    {
      title: 'Display Order',
      name: 'orderAsc',
      by: [
        {field: 'order', direction: 'asc'},
        {field: 'title', direction: 'asc'},
      ],
    },
  ],
})
```

### The Verification

Update `studio/schemas/index.ts`:

```typescript
// studio/schemas/index.ts
import { SchemaTypeDefinition } from 'sanity'

import post from './post'
import author from './author'
import category from './category'  // Add this line

export const schemaTypes: SchemaTypeDefinition[] = [
  post,
  author,
  category,  // Add this line
  // settings,  // Coming soon
]
```

**Test the category schema**:

1. Create a few categories:
   - "Technology" (with description: "Posts about technology, software, and innovation")
   - "Design" (description: "UX, UI, and design thinking")
   - "Business" (description: "Business strategy, leadership, and entrepreneurship")

2. Create a new post and select categories for it
3. Verify you can select multiple categories

---

## Step 6: Creating the Settings Schema

### The Target
Create a singleton `settings` document for global site configuration.

### The Concept
A singleton is a document that should only have one instance. In our case, `settings` will store global site information like site title, description, logo, and social media links.

**Real-world analogy**: Settings are like the control panel in your car. You don't have multiple control panels—just one dashboard that controls everything.

### The Implementation

Create `studio/schemas/settings.ts`:

```typescript
// studio/schemas/settings.ts
import { defineField, defineType } from 'sanity'

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
  
  // Singleton: Only one document of this type
  // We can enforce this in the Studio structure configuration later
  
  fields: [
    /**
     * SITE TITLE FIELD
     * Main site title, used in header and SEO.
     */
    defineField({
      name: 'siteTitle',
      title: 'Site Title',
      type: 'string',
      description: 'The main title of your site.',
      validation: (Rule) => Rule.required()
        .error('Site title is required'),
    }),
    
    /**
     * SITE DESCRIPTION FIELD
     * Tagline or brief description of the site.
     */
    defineField({
      name: 'siteDescription',
      title: 'Site Description',
      type: 'text',
      description: 'Brief description of your site.',
      rows: 2,
      validation: (Rule) => Rule.max(160)
        .error('Description should be 160 characters or less for SEO'),
    }),
    
    /**
     * LOGO FIELD
     * Site logo image.
     */
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
    
    /**
     * SOCIAL LINKS FIELD
     * Site-wide social media links.
     */
    defineField({
      name: 'socialLinks',
      title: 'Social Media Links',
      type: 'object',
      description: 'Site-wide social media links.',
      fields: [
        {
          name: 'twitter',
          title: 'Twitter/X',
          type: 'url',
        },
        {
          name: 'linkedin',
          title: 'LinkedIn',
          type: 'url',
        },
        {
          name: 'github',
          title: 'GitHub',
          type: 'url',
        },
        {
          name: 'youtube',
          title: 'YouTube',
          type: 'url',
        },
        {
          name: 'instagram',
          title: 'Instagram',
          type: 'url',
        },
      ],
    }),
    
    /**
     * DEFAULT SEO SETTINGS
     * Site-wide SEO defaults.
     */
    defineField({
      name: 'defaultSeo',
      title: 'Default SEO Settings',
      type: 'object',
      description: 'Default SEO settings used when not overridden.',
      fields: [
        {
          name: 'metaTitle',
          title: 'Default Meta Title',
          type: 'string',
        },
        {
          name: 'metaDescription',
          title: 'Default Meta Description',
          type: 'text',
          rows: 2,
        },
        {
          name: 'ogImage',
          title: 'Default OG Image',
          type: 'image',
          description: 'Default image for social sharing.',
          options: {
            hotspot: true,
          },
        },
      ],
    }),
    
    /**
     * CONTACT INFORMATION
     * Site contact details.
     */
    defineField({
      name: 'contactInfo',
      title: 'Contact Information',
      type: 'object',
      fields: [
        {
          name: 'email',
          title: 'Email',
          type: 'string',
        },
        {
          name: 'phone',
          title: 'Phone',
          type: 'string',
        },
        {
          name: 'address',
          title: 'Address',
          type: 'text',
          rows: 3,
        },
      ],
    }),
  ],
  
  // Preview configuration
  preview: {
    select: {
      title: 'siteTitle',
    },
    prepare({title}) {
      return {
        title: title || 'Site Settings',
      }
    },
  },
})
```

### The Verification

Update `studio/schemas/index.ts`:

```typescript
// studio/schemas/index.ts
import { SchemaTypeDefinition } from 'sanity'

import post from './post'
import author from './author'
import category from './category'
import settings from './settings'  // Add this line

export const schemaTypes: SchemaTypeDefinition[] = [
  post,
  author,
  category,
  settings,  // Add this line
]
```

**Test the settings schema**:

1. Create a new "Site Settings" document
2. Fill in:
   - Site Title: "Mastering Sanity CMS"
   - Site Description: "Learn modern content platforms with Sanity, React, and Next.js"
   - Upload a logo
   - Add social media links
3. Save the settings

**Important note**: Since this is a singleton (only one instance), you should create only one settings document. We'll configure the Studio structure to enforce this in Part 3.

---

## Step 7: Configuring Portable Text

### The Target
Enhance the Portable Text configuration with custom blocks and annotations.

### The Concept
Portable Text is Sanity's rich text editor. Unlike a traditional WYSIWYG editor that saves HTML, Portable Text saves structured JSON. This is like the difference between taking a photo of a document (HTML) and saving the actual text with formatting instructions (JSON).

**Why Portable Text matters**:

1. **Structure over presentation**: Content is stored semantically, not visually
2. **Multi-channel ready**: Same content works on web, mobile, and other platforms
3. **Future-proof**: You can change presentation without changing content
4. **Queryable**: You can query specific parts of the content (all links, all images, etc.)

### The Implementation

#### 7.1 Create a Portable Text Configuration

Create `studio/schemas/portableText.ts`:

```typescript
// studio/schemas/portableText.ts
import { defineArrayMember, defineField } from 'sanity'

/**
 * Portable Text Configuration
 * 
 * Central configuration for all Portable Text fields.
 * This ensures consistency across all rich text fields.
 */
export const blockContent = defineArrayMember({
  type: 'block',
  styles: [
    {title: 'Normal', value: 'normal'},
    {title: 'Heading 1', value: 'h1'},
    {title: 'Heading 2', value: 'h2'},
    {title: 'Heading 3', value: 'h3'},
    {title: 'Heading 4', value: 'h4'},
    {title: 'Quote', value: 'blockquote'},
  ],
  lists: [
    {title: 'Bullet', value: 'bullet'},
    {title: 'Numbered', value: 'number'},
  ],
  marks: {
    decorators: [
      {title: 'Bold', value: 'strong'},
      {title: 'Italic', value: 'em'},
      {title: 'Underline', value: 'underline'},
      {title: 'Strike', value: 'strike-through'},
      {title: 'Code', value: 'code'},
      {title: 'Highlight', value: 'highlight'},
    ],
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
      // External link annotation
      defineField({
        name: 'externalLink',
        title: 'External Link',
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
          {
            name: 'openInNewTab',
            title: 'Open in New Tab',
            type: 'boolean',
            initialValue: false,
          },
        ],
      }),
    ],
  },
})

/**
 * Custom image component for Portable Text
 */
export const portableTextImage = defineArrayMember({
  type: 'image',
  title: 'Image',
  options: {hotspot: true},
  fields: [
    {
      name: 'alt',
      title: 'Alt Text',
      type: 'string',
      description: 'Describe the image for accessibility',
      validation: (Rule) => Rule.required()
        .error('Alt text is required for accessibility'),
    },
    {
      name: 'caption',
      title: 'Caption',
      type: 'string',
    },
    {
      name: 'alignment',
      title: 'Alignment',
      type: 'string',
      options: {
        list: [
          {title: 'Left', value: 'left'},
          {title: 'Center', value: 'center'},
          {title: 'Right', value: 'right'},
          {title: 'Full Width', value: 'full'},
        ],
        layout: 'radio',
      },
      initialValue: 'center',
    },
  ],
})

/**
 * Code block component for Portable Text
 */
export const portableTextCode = defineArrayMember({
  type: 'code',
  title: 'Code Block',
  options: {
    language: 'javascript',
    languages: [
      {title: 'JavaScript', value: 'javascript'},
      {title: 'TypeScript', value: 'typescript'},
      {title: 'HTML', value: 'html'},
      {title: 'CSS', value: 'css'},
      {title: 'Python', value: 'python'},
      {title: 'Bash', value: 'bash'},
      {title: 'JSON', value: 'json'},
      {title: 'Markdown', value: 'markdown'},
      {title: 'Go', value: 'go'},
      {title: 'Rust', value: 'rust'},
    ],
  },
})

/**
 * Callout / Alert component
 */
export const portableTextCallout = defineArrayMember({
  name: 'callout',
  title: 'Callout',
  type: 'object',
  fields: [
    {
      name: 'type',
      title: 'Type',
      type: 'string',
      options: {
        list: [
          {title: 'Info', value: 'info'},
          {title: 'Warning', value: 'warning'},
          {title: 'Error', value: 'error'},
          {title: 'Success', value: 'success'},
        ],
        layout: 'radio',
      },
    },
    {
      name: 'content',
      title: 'Content',
      type: 'array',
      of: [{type: 'block'}],
    },
  ],
  preview: {
    select: {
      type: 'type',
    },
    prepare({type}) {
      return {
        title: `Callout: ${type || 'Info'}`,
      }
    },
  },
})
```

#### 7.2 Update Post Schema to Use the Configuration

Now update `studio/schemas/post.ts` to use the central configuration:

```typescript
// studio/schemas/post.ts
import { defineField, defineType } from 'sanity'
// Import the portable text configuration
import { 
  blockContent, 
  portableTextImage, 
  portableTextCode,
  portableTextCallout 
} from './portableText'

export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  fields: [
    // ... all previous fields remain the same ...
    
    /**
     * BODY FIELD - UPDATED
     * Now using the central Portable Text configuration
     */
    defineField({
      name: 'body',
      title: 'Body',
      type: 'array',
      description: 'The main content of your blog post.',
      of: [
        blockContent,
        portableTextImage,
        portableTextCode,
        portableTextCallout,
      ],
    }),
    
    // ... rest of fields ...
  ],
  // ... rest of configuration ...
})
```

### The Verification

**Test the enhanced Portable Text**:

1. Create a new blog post
2. In the body field, test all the features:
   - Add text with different styles (H1, H2, etc.)
   - Create bullet and numbered lists
   - Add bold, italic, and code formatting
   - Insert an image with alt text and caption
   - Add a code block with syntax highlighting
   - Add a callout (info/warning/error/success)
   - Create internal links (link to another post)
   - Create external links

**Everything should work seamlessly** in the Studio.

---

## Step 8: Adding Initial Values

### The Target
Add smart initial values to your schemas for better user experience.

### The Concept
Initial values pre-populate fields when creating new documents. This saves time and ensures consistency. Think of it like a form that already has common answers filled in—you can change them, but usually you don't need to.

### The Implementation

#### 8.1 Add Initial Values to Post Schema

Update `studio/schemas/post.ts`:

```typescript
// studio/schemas/post.ts - Add initial values
import { defineField, defineType } from 'sanity'

export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  
  // Add initial values
  initialValue: () => ({
    // Set published date to now
    publishedAt: new Date().toISOString(),
    // Default tags
    tags: [],
    // Default SEO settings
    seo: {
      noIndex: false,
    },
  }),
  
  fields: [
    // ... all fields remain the same ...
  ],
  
  // ... rest of configuration ...
})
```

#### 8.2 Add Initial Values to Author Schema

Update `studio/schemas/author.ts`:

```typescript
// studio/schemas/author.ts - Add initial values
export default defineType({
  name: 'author',
  title: 'Author',
  type: 'document',
  
  initialValue: () => ({
    role: 'writer',
  }),
  
  // ... fields remain the same ...
})
```

#### 8.3 Add Initial Values to Category Schema

Update `studio/schemas/category.ts`:

```typescript
// studio/schemas/category.ts - Add initial values
export default defineType({
  name: 'category',
  title: 'Category',
  type: 'document',
  
  initialValue: () => ({
    order: 0,
  }),
  
  // ... fields remain the same ...
})
```

### The Verification

1. Create a new post
2. Notice the "Published Date" is automatically set to the current date/time
3. Create a new author
4. Notice "Role" defaults to "Writer"
5. Create a new category
6. Notice "Display Order" defaults to 0

**The form now works faster for your editors!**

---

## Step 9: Setting Up Validation Messages

### The Target
Add human-readable validation messages to all schemas.

### The Concept
Validation is your first line of defense against bad data. But technical-sounding validation messages confuse editors. We want messages that explain the problem in plain English.

**Real-world analogy**: Instead of saying "FieldError: Input length < 5," we say "Please enter at least 5 characters for the title."

### The Implementation

Go through each schema and ensure validations have clear error messages:

#### 9.1 Post Schema Validation (Review)

```typescript
// studio/schemas/post.ts - Validation examples
validation: (Rule) => [
  Rule.required().error('Every post needs a title!'),
  Rule.min(5).error('Make your title at least 5 characters long.'),
  Rule.max(100).error('Keep your title under 100 characters for readability.'),
],
```

#### 9.2 Author Schema Validation (Review)

```typescript
// studio/schemas/author.ts - Validation examples
validation: (Rule) => Rule.required()
  .error('Each author needs a name!')
```

#### 9.3 Category Schema Validation (Review)

```typescript
// studio/schemas/category.ts - Validation examples
validation: (Rule) => Rule.required()
  .error('Give your category a title so editors can find it.'),
```

### The Verification

1. Try creating a post with a title that's too short
2. See the friendly error message
3. Try leaving a required field empty
4. See the helpful error message guiding you to fix it

**Your Studio now provides helpful guidance to editors!**

---

## Step 10: Testing the Complete Data Model

### The Target
Test the entire content model with sample data.

### The Concept
Before we start building our frontend, we need realistic content. Populating your Studio with sample data helps you understand your model's strengths and weaknesses.

### The Implementation

#### 10.1 Create Sample Data

**Create Sample Categories**:
1. "Technology" - "Posts about technology, software, and innovation"
2. "Design" - "UX, UI, and design thinking"
3. "Business" - "Business strategy, leadership, and entrepreneurship"
4. "Web Development" - "Building for the web with modern tools"

**Create Sample Authors**:
1. "Jane Doe" - "Senior Writer" - Bio: "Jane has been covering technology for 10 years..."
2. "John Smith" - "Editor" - Bio: "John is the editorial director..."
3. "Sarah Johnson" - "Contributor" - Bio: "Sarah is a freelance writer..."

**Create Sample Posts**:

**Post 1**:
- Title: "Getting Started with Sanity CMS"
- Categories: Technology, Web Development
- Author: Jane Doe
- Body: A rich text post with headings, lists, images, and code blocks
- Published Date: Today

**Post 2**:
- Title: "Designing Content Models for Scale"
- Categories: Design, Business
- Author: John Smith
- Body: Another rich text post
- Published Date: Yesterday

**Post 3**:
- Title: "The Future of Headless CMS"
- Categories: Technology, Business
- Author: Sarah Johnson
- Body: Include a callout and internal links
- Published Date: 3 days ago

#### 10.2 Create Site Settings

Create one "Site Settings" document:
- Site Title: "Mastering Sanity CMS"
- Site Description: "Building modern content platforms with Sanity, React, and Next.js"
- Logo: Upload a sample logo
- Social Links: Add at least Twitter and LinkedIn

### The Verification

**Check the Studio**:

1. All documents appear in their respective lists
2. Document previews show meaningful information
3. Relationships work correctly (posts show authors, authors show posts)
4. The Studio search works across all content

**Check Data Relationships**:
- Go to a post → you should see the author and categories
- Go to an author → you should see posts they've written (in the references panel)
- Go to a category → you should see posts in that category

**All your content is now connected!**

---

## Step 11: Version Control Your Project

### The Target
Initialize Git and commit your project.

### The Concept
Version control is essential for professional development. It tracks changes, enables collaboration, and provides a safety net. You can always go back to a working state if something breaks.

### The Implementation

#### 11.1 Initialize Git

```bash
# From the project root (mastering-sanity-cms)
cd ..  # Navigate back to the project root
git init

# Create .gitignore
touch .gitignore
```

Add to `.gitignore`:

```gitignore
# studio/.gitignore
# Node modules
node_modules/
.sanity/

# Environment variables
.env
.env.local
.env.*.local

# Build outputs
dist/
build/
.next/
out/

# Editor files
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db

# Logs
logs/
*.log
npm-debug.log*
```

#### 11.2 Commit the Project

```bash
# Stage all files
git add .

# First commit
git commit -m "feat: initialize Sanity Studio v5 with complete content models

- Add post, author, category, and settings schemas
- Configure Portable Text with custom blocks and annotations
- Add validation rules and initial values
- Set up project structure for monorepo"

# If you have a GitHub repository, add it as remote
# git remote add origin https://github.com/yourusername/mastering-sanity-cms.git
# git push -u origin main
```

### The Verification

```bash
# Check git status
git status
# Should say: "nothing to commit, working tree clean"

# View commit history
git log --oneline
# Should show your first commit
```

---

## Step 12: Deployment Preparation

### The Target
Prepare your Studio for production deployment.

### The Concept
Your development Studio is great for building, but you need a production version for your editorial team. Production deployment includes building static assets and deploying to Sanity's hosting.

### The Implementation

#### 12.1 Build the Studio

```bash
cd studio

# Build the production version
npm run build
# or
sanity build

# This creates a 'dist' folder with static files
```

#### 12.2 Deploy to Sanity

```bash
# Deploy to Sanity's hosting
npm run deploy
# or
sanity deploy

# You'll be prompted to set a name for your Studio
# Example: mastering-sanity-cms-studio
```

#### 12.3 Set Up Environment Variables for Production

If you're deploying elsewhere (Vercel, Netlify), ensure environment variables are set:

```
# Required environment variables
SANITY_STUDIO_PROJECT_ID=your-project-id
SANITY_STUDIO_DATASET=production
```

### The Verification

1. Visit your deployed Studio URL (e.g., `https://mastering-sanity-cms-studio.sanity.studio`)
2. Log in with your Sanity credentials
3. Verify all content appears correctly
4. Try creating a new post in production

**Your Studio is now live!**

---

## Part 1 Summary

### What We've Accomplished

In this part, we:

✅ Installed and configured Sanity Studio v5
✅ Created four core document schemas (post, author, category, settings)
✅ Configured Portable Text with custom blocks and annotations
✅ Added validation rules and helpful error messages
✅ Set up initial values for better editorial experience
✅ Populated sample data to test our model
✅ Version controlled our project with Git
✅ Deployed to production

### Understanding Your Achievement

You've built a complete content platform from scratch. This is the same architecture pattern used by:

- **Enterprise CMS implementations**: The structured content approach scales to millions of documents
- **E-commerce platforms**: Product data, categories, and rich descriptions
- **Documentation portals**: Technical content with code blocks and versioning
- **Marketing websites**: Landing pages, campaigns, and A/B testing
- **Knowledge bases**: Articles, categories, and search

### Key Concepts You've Mastered

1. **Structured Content**: Content as data, not presentation
2. **Schema Design**: Document types, fields, and relationships
3. **Validation**: Data quality through explicit rules
4. **Portable Text**: Structured rich text without the HTML mess
5. **Document References**: Building connections between content types
6. **Studio Customization**: Making the Studio work for your editors

### Common Pitfalls and How to Avoid Them

| Pitfall | Solution |
|---------|----------|
| **Overly complex schemas** | Start simple, add complexity as needed |
| **Missing validation** | Always validate required fields |
| **Bad field descriptions** | Write descriptions for editors, not developers |
| **Not using references** | Build relationships, don't duplicate data |
| **No preview configuration** | Configure preview to save editors time |
| **Forgetting .gitignore** | Never commit .env or node_modules |

### What's Next

In **Part 2: Querying Content with GROQ**, you'll learn to retrieve this content efficiently. You'll discover how to:

- Write powerful GROQ queries to get exactly the data you need
- Filter, sort, and paginate content
- Traverse relationships (get posts with their authors and categories)
- Optimize query performance
- Generate TypeScript types with Sanity TypeGen
- Build a robust API layer

**Estimated time for Part 2**: 2-3 hours

### Practice Exercises

Before moving to Part 2, try these exercises:

1. **Add a new schema**: Create a "Video" schema for video content
2. **Modify the post schema**: Add a "readingTime" field
3. **Customize validation**: Add custom validation logic
4. **Extend Portable Text**: Add a "YouTube embed" block
5. **Create a custom preview**: Use all available preview fields

### Resources for Further Learning

- [Sanity Schema Documentation](https://www.sanity.io/docs/schema-types)
- [Portable Text Documentation](https://www.sanity.io/docs/portable-text)
- [Validation Documentation](https://www.sanity.io/docs/validation)
- [Sanity Structure Documentation](https://www.sanity.io/docs/structure)

You've built the content models. Now it's time to retrieve that content efficiently. In Part 2, we'll dive deep into GROQ (Graph-Relational Object Queries) and build a type-safe query layer that powers your frontend applications.

Let's continue building!
