# Primer 1: Structured Content Fundamentals

Welcome to the first of our hands-on primers. Think of this as the "why" before the "how." Before we dive into code, we need to understand what makes Sanity different from every other CMS you've used—and why that difference matters.

---

## The Problem with Traditional CMS

Remember the last time you used a traditional CMS like WordPress? You probably thought in terms of pages: you built a "Homepage," a "Blog Page," a "Contact Page." Your content was locked into those specific page templates.

Now imagine you want to show your blog posts on your mobile app, or on a digital kiosk at a conference, or in a chatbot. With a traditional CMS, you'd have to rebuild everything for each new channel.

**That's the problem**: traditional CMS ties your content to a specific presentation.

## What is Structured Content?

Structured content flips this model on its head. Instead of building pages, you build **content components** that can be assembled in countless ways.

> "Structured content turns your content into data — the equivalent of LEGO bricks — that can be used over and over in different formations." 

Let's look at an example. Consider a blog post. In a traditional CMS, you'd fill in:

- A title field
- A body field (usually a big HTML blob)
- A featured image

In a structured approach, that same blog post becomes:

```
Blog Post
├── Title (string)
├── Slug (URL-friendly string)
├── Author (reference to an Author document)
├── Categories (array of references to Category documents)
├── Publish Date (datetime)
├── Body (Portable Text — structured rich text)
│   ├── Paragraph blocks
│   ├── Heading blocks
│   ├── Image blocks (with alt text, caption, alignment)
│   ├── Code blocks (with language support)
│   └── Callout blocks (info, warning, success)
├── Featured Image (image with alt text and caption)
├── SEO Settings (meta title, meta description, keywords)
└── Tags (array of strings)
```

**Why does this matter?**

- The same blog post can power your website, mobile app, email newsletter, and AI assistant—without rewriting anything
- You can query specific parts of the content (e.g., "find all posts with a "tutorial" tag")
- Your content is future-proof—when AR glasses or voice assistants become mainstream, your content is already structured for them

## Headless vs. Traditional CMS

This is where the term "headless CMS" comes in. In a traditional CMS, the "head" (the presentation layer) and the "body" (the content) are fused together. It's one monolithic system.

In a headless CMS like Sanity, the content and the presentation are separated. The content becomes a pure API—a service that delivers data without any opinion about how it should be displayed.

> "A content management system (CMS) or other software product that separates where content is stored (the 'body') from where it is presented (the 'head')." 

This separation gives you enormous freedom:

- **Choose your frontend framework**: React, Vue, Svelte, or vanilla HTML/CSS/JS—Sanity doesn't care
- **Deliver to multiple channels**: Your content is just data—you can send it anywhere
- **Iterate independently**: Change your frontend without touching your content, or vice versa

## Sanity's Three Layers

Sanity is built on three interconnected layers that make this all work :

1. **Content Lake**: This is the database. All your content lives here, stored as structured JSON.

2. **Studio**: This is the editing interface. It's a React application that your editorial team uses to create and manage content. It's fully customizable.

3. **APIs and SDKs**: These are the tools you use to fetch content and build your frontend. You can use GROQ queries, GraphQL, or the JavaScript client.

## From "Blobs to Chunks"

One of the best ways to understand structured content is to think of it as moving from "blobs" to "chunks."

- **Unstructured content (blobs)**: You have a big block of HTML or text. It's tied to the presentation. You can't easily reuse or query it. 

- **Structured content (chunks)**: You've broken your content into its smallest meaningful pieces. Each piece is explicitly defined, labeled, and understood by computers and humans. 

Let's make this concrete:

**Unstructured approach**: You write a full blog post in a giant WYSIWYG editor. The result is HTML. You can't easily ask "how many images are in this post?" or "what's the third heading?"

**Structured approach**: You have separate fields for title, excerpt, body (with defined block types), featured image (with alt text), and so on. You can query: "Get me the featured image URL for all posts published in October." That's power.

## A Real-World Example

Imagine you're running an online store . You have:

- Product listings
- Category pages
- Marketing landing pages
- Email newsletters
- A mobile app

With unstructured content, you'd need to maintain separate content for each channel. A product description changes? Update the website, the app, the email, and so on.

With structured content, you store:

- Product name
- Product description (rich text)
- Price
- Categories
- Images
- Specifications

Now you can assemble this content anywhere. The website shows product cards. The mobile app shows a simplified version. The email newsletter shows a teaser with a link. One source, infinite presentations.

## The Shift in Thinking

This approach requires a mental shift. Instead of asking "What will this page look like?" you ask: 

- What are the concepts our business works with?
- What information do we need to store about each concept?
- How might this content be used in the future?

> "Step back from 'What will this page look like?' and ask 'What does our business offer and how do people think about it?'" 

---

**[END: Primer 1]**

---

**[STARTING: Primer 2]**

# Primer 2: First Steps with Sanity

Welcome to the second primer. Now that you understand the "why," let's get our hands dirty with the "how."

---

## Prerequisites

Before we begin, make sure you have:

1. **A Sanity Account**: Sign up at [sanity.io](https://www.sanity.io)

2. **Node.js Installed**: Version 20 or higher. Check with `node --version`

3. **A Terminal**: You'll be using the command line extensively

4. **A Code Editor**: We recommend VS Code

## Step 1: Install the Sanity CLI

The CLI is your command-line interface for managing Sanity projects. Think of it as the control panel for all your Sanity operations.

Open your terminal and run:

```bash
npm install -g @sanity/cli
```

Verify the installation:

```bash
sanity --version
```

**What this does**: The `-g` flag installs the CLI globally, meaning you can use the `sanity` command from anywhere on your system.

**If you encounter permission errors on macOS/Linux**:

```bash
sudo npm install -g @sanity/cli
```

**If you'd prefer not to install globally**, you can use `npx`:

```bash
npx @sanity/cli --version
```

## Step 2: Log In to Sanity

You need to authenticate before creating projects:

```bash
sanity login
```

This will open your browser and prompt you to authorize the CLI. Once you grant permission, the CLI is connected to your account.

## Step 3: Create Your First Sanity Project

Navigate to where you want your project to live:

```bash
mkdir my-first-sanity
cd my-first-sanity
```

Initialize the project:

```bash
sanity init
```

You'll be prompted with several questions:

| Prompt | Recommended Answer |
|--------|-------------------|
| **Project template** | "Clean project with no predefined schemas" (we'll build from scratch) |
| **Project output path** | Accept the default (current directory) |
| **Dataset configuration** | "Create new dataset" |
| **Project name** | "My First Sanity Project" |
| **Dataset name** | "production" |
| **Dataset visibility** | "Public" (we'll secure it later) |
| **TypeScript** | "Yes" |

## Step 4: Understand the Project Structure

Sanity creates several files and folders. Here's what each does:

| File/Folder | Purpose |
|-------------|---------|
| **sanity.config.ts** | The main configuration file for your Studio |
| **sanity.cli.ts** | CLI configuration |
| **.env** | Environment variables (API keys, project IDs) — **never commit this** |
| **schemas/** | All your content model definitions |
| **schemas/index.ts** | The registry that lists all your schemas |
| **package.json** | Project dependencies and scripts |

**Important**: The `.env` file contains sensitive information. Never commit it to Git.

## Step 5: Start the Studio

Run the development server:

```bash
sanity dev
```

This will start the Studio at `http://localhost:3333`. Open this in your browser.

You should see the Sanity Studio login screen. Sign in with your Sanity credentials. The Studio is now running, but it's empty—we haven't created any content models yet.

## Step 6: Create Your First Schema

Open your project in your code editor. Create a new file: `schemas/author.js` (or `.ts` if you're using TypeScript).

```javascript
// schemas/author.js
export default {
  name: 'author',
  title: 'Author',
  type: 'document',
  fields: [
    {
      name: 'name',
      title: 'Name',
      type: 'string',
      validation: Rule => Rule.required()
    },
    {
      name: 'bio',
      title: 'Bio',
      type: 'text',
      validation: Rule => Rule.max(200)
    }
  ]
}
```

Now register this schema in `schemas/index.js`:

```javascript
// schemas/index.js
import author from './author'

export const schemaTypes = [author]
```

## Step 7: See Your Schema in the Studio

Restart the Studio:

```bash
sanity dev
```

You should now see "Author" as an option when you click "Create new document." Try creating an author.

## Step 8: Fetch Your Content with Vanilla JavaScript

Here's the beautiful part—you don't need React or Next.js to use your content. Sanity is just an HTTP API. 

Create a simple HTML file anywhere:

```html
<!DOCTYPE html>
<html>
<head>
    <title>My First Sanity Site</title>
</head>
<body>
    <h1>Authors</h1>
    <ul id="authors"></ul>

    <script>
        // Get your project ID from the Studio URL or sanity.json
        const projectId = 'YOUR_PROJECT_ID';
        const dataset = 'production';

        // GROQ query — think of it as SQL for content
        const query = '*[_type == "author"]';
        const encodedQuery = encodeURIComponent(query);

        const url = `https://${projectId}.api.sanity.io/v2021-10-21/data/query/${dataset}?query=${encodedQuery}`;

        fetch(url)
            .then(response => response.json())
            .then(data => {
                const authors = data.result;
                const container = document.getElementById('authors');

                authors.forEach(author => {
                    const li = document.createElement('li');
                    li.textContent = author.name + ': ' + (author.bio || '');
                    container.appendChild(li);
                });
            });
    </script>
</body>
</html>
```

Replace `YOUR_PROJECT_ID` with your actual project ID from `sanity.json`.

**What's happening here?** We're using a plain HTTP request to fetch content from Sanity's Query API. No frameworks, no build tools—just HTML and JavaScript.

## Step 9: Understanding GROQ

GROQ stands for Graph-Relational Object Queries. It's the query language you use to fetch data from Sanity.

A simple GROQ query looks like:

```
*[_type == "author"]
```

**Breakdown**:

- `*` = Select all documents the user can read 
- `[_type == "author"]` = Filter to only documents of type "author"

Want only specific fields?

```
*[_type == "author"]{ name, bio }
```

Want the first 3 authors?

```
*[_type == "author"][0..2]
```

Want to sort by name?

```
*[_type == "author"] | order(name asc)
```

**You don't need React or a framework to use Sanity**. At its core, Sanity is just an API that returns JSON. You can use it with anything: HTML/JS, React, Vue, Svelte, or even just a curl command.

## Step 10: Deploy Your Studio

Ready to share your Studio with others? Deploy it:

```bash
sanity deploy
```

You'll be prompted to choose a name for your Studio. Once deployed, your Studio will be available at:

```
https://YOUR-STUDIO-NAME.sanity.studio
```

Anyone with access can now edit content. 

## Summary: What You've Learned

In this primer, you've:

✅ Installed the Sanity CLI
✅ Created your first Sanity project
✅ Started the Studio locally
✅ Created your first schema
✅ Queried your content with plain JavaScript
✅ Deployed your Studio

**The key takeaway**: Sanity is not a monolithic CMS. It's a platform—a Content Operating System—that gives you the tools to store, manage, and deliver structured content anywhere.

---

**[END: Primer 2]**

---

**[STARTING: Primer 3]**

# Primer 3: Modeling Your First Content Types

Welcome to the third primer. Now that you can run a Studio and fetch content, let's dig into the heart of any Sanity project: the schemas.

Think of schemas as the blueprints for your content. They define what fields exist, what types of data they store, and what constraints apply.

---

## The Building Blocks: Documents, Objects, and Fields

Sanity has three primary building blocks: 

| Building Block | Purpose | Example |
|----------------|---------|---------|
| **Document** | A top-level content item, typically with its own URL | A blog post, a product, an author |
| **Object** | A reusable group of fields, often embedded in documents | SEO metadata, social links, address |
| **Field** | A single piece of information | Title (string), Price (number), Body (rich text) |

Let's build each of these in practice.

## Step 1: Create an Author Document

We'll start with an author document. Create `schemas/author.ts`:

```typescript
// schemas/author.ts
import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'author',          // Unique identifier
  title: 'Author',         // Display name in Studio
  type: 'document',        // This is a document type

  fields: [
    defineField({
      name: 'name',
      title: 'Name',
      type: 'string',
      description: 'The full name of the author',
      validation: Rule => Rule.required().error('Name is required')
    }),

    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      description: 'The URL-friendly version of the name',
      options: {
        source: 'name',        // Automatically generate from name
        maxLength: 96
      },
      validation: Rule => Rule.required().error('Slug is required')
    }),

    defineField({
      name: 'bio',
      title: 'Biography',
      type: 'text',
      description: 'A short biography',
      rows: 3,
      validation: Rule => Rule.max(500).error('Bio must be under 500 characters')
    }),

    defineField({
      name: 'avatar',
      title: 'Avatar',
      type: 'image',
      description: 'Profile photo',
      options: { hotspot: true },  // Enable responsive cropping
      fields: [
        defineField({
          name: 'alt',
          title: 'Alt Text',
          type: 'string',
          description: 'Describe the image for accessibility',
          validation: Rule => Rule.required().error('Alt text is required')
        })
      ]
    }),

    defineField({
      name: 'socialLinks',
      title: 'Social Links',
      type: 'object',
      fields: [
        defineField({ name: 'twitter', title: 'Twitter', type: 'url' }),
        defineField({ name: 'linkedin', title: 'LinkedIn', type: 'url' }),
        defineField({ name: 'github', title: 'GitHub', type: 'url' })
      ]
    })
  ],

  // Preview configuration—controls how authors appear in lists
  preview: {
    select: {
      title: 'name',
      subtitle: 'role',
      media: 'avatar'
    }
  }
})
```

## Step 2: Create a Blog Post Document

Now let's create a blog post schema. This is the heart of most content sites.

Create `schemas/post.ts`:

```typescript
// schemas/post.ts
import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'post',
  title: 'Blog Post',
  type: 'document',

  fields: [
    defineField({
      name: 'title',
      title: 'Title',
      type: 'string',
      validation: Rule => Rule.required().min(5).max(100)
    }),

    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      options: { source: 'title' },
      validation: Rule => Rule.required()
    }),

    defineField({
      name: 'excerpt',
      title: 'Excerpt',
      type: 'text',
      description: 'A short summary used in listings',
      rows: 3,
      validation: Rule => Rule.max(200)
    }),

    defineField({
      name: 'author',
      title: 'Author',
      type: 'reference',      // References another document
      to: [{ type: 'author' }],
      validation: Rule => Rule.required()
    }),

    defineField({
      name: 'publishedAt',
      title: 'Published Date',
      type: 'datetime',
      validation: Rule => Rule.required()
    }),

    defineField({
      name: 'categories',
      title: 'Categories',
      type: 'array',
      of: [
        {
          type: 'reference',
          to: [{ type: 'category' }]
        }
      ]
    }),

    defineField({
      name: 'featuredImage',
      title: 'Featured Image',
      type: 'image',
      options: { hotspot: true },
      fields: [
        defineField({
          name: 'alt',
          title: 'Alt Text',
          type: 'string',
          validation: Rule => Rule.required()
        }),
        defineField({
          name: 'caption',
          title: 'Caption',
          type: 'string'
        })
      ]
    }),

    defineField({
      name: 'body',
      title: 'Body',
      type: 'array',          // Portable Text—Sanity's rich text
      of: [
        {
          type: 'block',
          styles: [
            { title: 'Normal', value: 'normal' },
            { title: 'Heading 1', value: 'h1' },
            { title: 'Heading 2', value: 'h2' },
            { title: 'Heading 3', value: 'h3' },
            { title: 'Quote', value: 'blockquote' }
          ],
          lists: [
            { title: 'Bullet', value: 'bullet' },
            { title: 'Numbered', value: 'number' }
          ],
          marks: {
            decorators: [
              { title: 'Bold', value: 'strong' },
              { title: 'Italic', value: 'em' },
              { title: 'Code', value: 'code' }
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
                    type: 'url'
                  }
                ]
              }
            ]
          }
        },
        {
          type: 'image',
          fields: [
            { name: 'alt', title: 'Alt Text', type: 'string' },
            { name: 'caption', title: 'Caption', type: 'string' }
          ]
        },
        {
          type: 'code',
          title: 'Code Block'
        }
      ]
    }),

    defineField({
      name: 'seo',
      title: 'SEO Settings',
      type: 'object',
      fields: [
        defineField({
          name: 'metaTitle',
          title: 'Meta Title',
          type: 'string',
          validation: Rule => Rule.max(60)
        }),
        defineField({
          name: 'metaDescription',
          title: 'Meta Description',
          type: 'text',
          validation: Rule => Rule.max(160)
        })
      ]
    })
  ],

  // Order by publication date
  orderings: [
    {
      title: 'Published Date, Newest',
      name: 'publishedAtDesc',
      by: [{ field: 'publishedAt', direction: 'desc' }]
    }
  ]
})
```

## Step 3: Create a Category Document

Categories are simpler but important for organizing content:

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
      validation: Rule => Rule.required()
    }),

    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      options: { source: 'title' },
      validation: Rule => Rule.required()
    }),

    defineField({
      name: 'description',
      title: 'Description',
      type: 'text'
    })
  ]
})
```

## Step 4: Register Your Schemas

Update `schemas/index.ts` to include all your schemas:

```typescript
// schemas/index.ts
import author from './author'
import post from './post'
import category from './category'

export const schemaTypes = [author, post, category]
```

## Step 5: Understanding References

References are how you connect documents in Sanity. They're the database relationships of the content world. 

In a blog post, the `author` field is a reference:

```typescript
defineField({
  name: 'author',
  title: 'Author',
  type: 'reference',
  to: [{ type: 'author' }]  // Points to the author document type
})
```

When you create a post in the Studio, you'll see a dropdown of existing authors. Select one, and the post is linked to that author document.

**Why use references instead of typing in a name?** References give you:

- Consistency (one place to update author names)
- Query power (get all posts by a specific author)
- Relation data (fetch author details along with post data)

## Step 6: Understanding Portable Text

The `body` field in the post schema uses `type: 'array'` with `type: 'block'`. This is Sanity's Portable Text editor.

Portable Text stores rich text as structured JSON rather than HTML. This might seem complex at first, but it gives you enormous power:

- **Queries**: You can ask "Find all posts with images" or "Find all links in this content"
- **Flexible rendering**: You can display the same content differently on different platforms
- **Future-proof**: When new display formats emerge, you don't need to change your content

The Portable Text editor in the Studio looks like a WYSIWYG, but the data it produces is structured JSON. 

## Step 7: Create Some Content

Now start your Studio:

```bash
sanity dev
```

Create:

1. An author (e.g., "Jane Smith")
2. A category (e.g., "Technology")
3. A blog post that links to both

You now have a fully functional content system with relationships and rich text!

---

## Summary

In this primer, you've:

✅ Created document schemas for authors, posts, and categories
✅ Used references to create relationships between documents
✅ Implemented Portable Text for flexible rich content
✅ Registered schemas with the Studio
✅ Created and connected content

**Core concepts you've mastered**:

- **Documents**: Top-level content items
- **Objects**: Reusable groups of fields
- **Fields**: Individual data points
- **References**: Document relationships
- **Portable Text**: Structured rich text
