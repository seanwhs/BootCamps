# Mastering Sanity CMS: Comprehensive Quiz and Test Bank

Welcome to the comprehensive quiz and test bank for the Mastering Sanity CMS series. This document contains assessment materials for each major topic covered in the series, designed to reinforce learning and validate understanding. 

---

## How to Use This Test Bank

- **Self-Assessment**: Test your knowledge after completing each section
- **Teaching Tool**: Use questions for classroom discussions
- **Skill Validation**: Identify areas needing review
- **Interview Preparation**: Practice common Sanity interview questions 

---

# MODULE 1: Structured Content Fundamentals

## Section 1.1: Content Modeling Basics

### Multiple Choice

**1. What is the primary difference between structured content and traditional page-based content?**
- A) Structured content is easier to write
- B) Structured content separates meaning from presentation, making it reusable across channels
- C) Structured content only works for blogs
- D) There is no significant difference

**Answer: B**

*Explanation: Structured content treats content as data that can be assembled in multiple ways, rather than locking it into specific page templates.* 

---

**2. In Sanity, what is a "document"?**
- A) A file attachment
- B) A top-level content item that typically has its own URL
- C) A type of field
- D) A user profile

**Answer: B**

*Explanation: Documents are top-level content items like blog posts, products, or author pages. They are the primary content units in Sanity.*

---

**3. Which of the following is an example of a "reference" relationship in Sanity?**
- A) A post containing a title field
- B) A post linking to an author document
- C) A post having an array of tags
- D) A post storing its body as Portable Text

**Answer: B**

*Explanation: References create relationships between documents. A post referencing an author means the post is connected to that author document.*

---

**4. What does the `hotspot: true` option do on an image field?**
- A) Makes the image load faster
- B) Enables responsive cropping by allowing editors to select a focal point
- C) Adds a filter to the image
- D) Forces the image to be square

**Answer: B**

*Explanation: The hotspot feature allows editors to select a focal point on an image, ensuring responsive cropping keeps the important part visible.* 

---

**5. What is a singleton in Sanity?**
- A) A document that should only have one instance
- B) A field that can only be used once
- C) A user with special permissions
- D) A type of image

**Answer: A**

*Explanation: A singleton is a document type designed to have only one instance, typically used for site settings or global configuration.*

---

### True/False

**1. Validation rules in Sanity schemas are optional and only affect the Studio interface.**
- True
- **False**

**Answer: False**

*Explanation: Validation rules enforce data quality at the schema level, preventing invalid data from being saved in the first place.*

---

**2. Portable Text stores content as HTML for easy rendering.**
- True
- **False**

**Answer: False**

*Explanation: Portable Text stores content as structured JSON, not HTML. This makes it queryable and presentation-agnostic.* 

---

**3. Field groups in Sanity schemas help organize the Studio interface but do not affect data storage.**
- **True**
- False

**Answer: True**

*Explanation: Field groups only affect how fields are displayed in the Studio UI. They do not change the underlying data structure.*

---

**4. References in Sanity allow you to create one-to-many relationships between documents.**
- **True**
- False

**Answer: True**

*Explanation: References enable relationships between documents. A post can reference one author (one-to-one), and an author can be referenced by many posts (one-to-many).*

---

### Short Answer

**1. Describe the three building blocks of Sanity schemas and provide an example of each.**

*Model Answer:*

- **Document**: A top-level content item (e.g., a blog post, author, or product)
- **Object**: A reusable group of fields (e.g., SEO metadata, social links)
- **Field**: A single piece of information (e.g., title (string), price (number), body (array))

---

**2. What are the benefits of using references instead of embedding content directly?**

*Model Answer:*

- **Consistency**: One source of truth for shared content
- **Query power**: Ability to query across relationships
- **Maintainability**: Changes to referenced content propagate automatically
- **Reduced duplication**: Content is stored once and referenced many times 

---

## Section 1.2: Portable Text

### Multiple Choice

**1. What format does the Portable Text editor write content in?** 
- A) Markdown
- B) HTML
- C) **Portable Text (JSON)**
- D) Textile

**Answer: C**

*Explanation: The Portable Text editor saves content as structured JSON, not HTML or Markdown.* 

---

**2. What is the purpose of the PortableText React component?** 
- A) To convert Portable Text to MDX
- B) To author Portable Text
- C) **To serialize Portable Text into components**
- D) To query Portable Text

**Answer: C**

*Explanation: The PortableText React component renders Portable Text JSON into React components, allowing you to customize how each block type appears.* 

---

**3. Which of the following is NOT a component of Portable Text?**
- A) Blocks
- B) Spans
- C) Marks
- D) **Attributes**

**Answer: D**

*Explanation: Portable Text consists of blocks, spans (text with marks), and marks (formatting and annotations). "Attributes" is not a standard term in Portable Text architecture.*

---

**4. When would you use an annotation in Portable Text?**
- A) To bold text
- B) **To create a link with structured data**
- C) To create a heading
- D) To add a list item

**Answer: B**

*Explanation: Annotations are marks that contain structured data, such as links with additional metadata. Simple formatting like bold uses decorators.*

---

### True/False

**1. Portable Text can be queried to find all images or links within content.**
- **True**
- False

**Answer: True**

*Explanation: Because Portable Text is stored as structured JSON, you can use GROQ to query for specific elements within Portable Text content.*

---

**2. You cannot add custom block types to Portable Text beyond the defaults.**
- True
- **False**

**Answer: False**

*Explanation: Sanity allows you to define custom block types (e.g., callouts, embedded videos) and render them with custom React components.*

---

## Section 1.3: Validation

### Multiple Choice

**1. What is the purpose of validation in Sanity schemas?** 
- A) To make the Studio slower
- B) To ensure data quality and prevent invalid content
- C) To automatically format content
- D) To generate SEO metadata

**Answer: B**

*Explanation: Validation rules enforce data quality, preventing editors from saving invalid content and providing helpful error messages.* 

---

**2. Which of the following is a valid validation chain in Sanity?**
- A) `Rule.required().max(100).custom()`
- B) `Rule.minLength(5).maxLength(100).required()`
- C) `Rule.required().min(5).max(100)`
- D) `Rule.setLength(5).setLength(100)`

**Answer: C**

*Explanation: The correct syntax uses `required()`, `min()`, and `max()` methods. `minLength` and `maxLength` are not valid methods in Sanity validation.*

---

**3. What does `Rule.custom()` allow you to do?**
- A) Create a custom field type
- B) Write custom validation logic
- C) Add a custom CSS class
- D) Define a custom component

**Answer: B**

*Explanation: `Rule.custom()` allows you to write custom validation functions for complex business rules that can't be expressed with built-in validators.*

---

### Short Answer

**1. Write a validation rule for a "slug" field that ensures it is required, unique, and follows a URL-friendly format.**

*Model Answer:*

```typescript
defineField({
  name: 'slug',
  title: 'Slug',
  type: 'slug',
  validation: (Rule) => [
    Rule.required().error('Slug is required'),
    Rule.custom((value) => {
      if (value && !/^[a-z0-9-]+$/.test(value.current)) {
        return 'Slug must contain only lowercase letters, numbers, and hyphens'
      }
      return true
    })
  ]
})
```

---

# MODULE 2: GROQ Fundamentals

## Section 2.1: Basic GROQ

### Multiple Choice

**1. What does the `*` symbol represent in a GROQ query?** 
- A) All fields
- B) **All documents the user can read**
- C) All characters
- D) All references

**Answer: B**

*Explanation: In GROQ, `*` selects all documents that the current user has permission to read.* 

---

**2. Which clause in a GROQ query is used to filter documents?** 
- A) `where`
- B) **`[filter]`**
- C) `select`
- D) `order`

**Answer: B**

*Explanation: Filters are placed inside square brackets `[ ]` in GROQ. Common filter syntax includes conditions like `_type == "post"`.* 

---

**3. What is the correct syntax for ordering results by publish date in descending order?** 
- A) `order(publishDate descending)`
- B) `sort(publishDate:-1)`
- C) `order by publishDate DESC`
- D) **`order(publishedAt desc)`**

**Answer: D**

*Explanation: The correct GROQ syntax for ordering is `order(field desc)`. `order(publishedAt desc)` sorts by the publishedAt field in descending order.* 

---

**4. Which symbol is used to follow a reference in GROQ?** 
- A) `.`
- B) `>`
- C) `=>`
- D) **`->`**

**Answer: D**

*Explanation: The `->` operator is used in GROQ to dereference a reference and access fields from the referenced document.* 

---

**5. What does the `coalesce` function do in GROQ?** 
- A) Combines two values
- B) **Returns the first non-null value**
- C) Type-checks a value
- D) Compares two fields

**Answer: B**

*Explanation: `coalesce` returns the first non-null value from its arguments, useful for providing fallback values.* 

---

**6. How would you select only the `title` and `slug` fields from all posts?** 
- A) `*[_type == "post"] title, slug`
- B) `*[_type == "post"] { "title": title, "slug": slug }`
- C) `*[_type == "post"] { title, slug }`
- D) `*[_type == "post"] | fields(title, slug)`

**Answer: C**

*Explanation: Projections use curly braces `{ }` to specify which fields to return. `{ title, slug }` returns only those two fields.* 

---

**7. Which operator checks if a value exists inside an array in GROQ?** 
- A) `matches`
- B) `contains`
- C) **`in`**
- D) `[]`

**Answer: C**

*Explanation: The `in` operator checks if a value exists within an array, such as `"technology" in categories[]->slug.current`.* 

---

### True/False

**1. GROQ queries cannot be parameterized with variables.**
- True
- **False**

**Answer: False**

*Explanation: GROQ supports parameters using the `$variable` syntax, allowing you to create reusable queries.*

---

**2. The `count()` function in GROQ counts the number of documents in a dataset.**
- True
- **False**

**Answer: False**

*Explanation: `count()` counts items within an array or a filtered set, but for counting all documents you would use `count(*[_type == "post"])`.*

---

**3. GROQ is case-sensitive for field names.**
- **True**
- False

**Answer: True**

*Explanation: Field names in GROQ queries are case-sensitive and must match the exact field names in your schema.*

---

**4. `pt::text(body)` extracts plain text from Portable Text for searching or display.**
- **True**
- False

**Answer: True**

*Explanation: `pt::text()` is a GROQ function that extracts plain text from Portable Text arrays, useful for search or word counting.*

---

### Short Answer

**1. Write a GROQ query to get all published blog posts with their title, slug, author name, and categories, ordered by publish date (newest first).**

*Model Answer:*

```groq
*[_type == "post" && defined(publishedAt) && publishedAt < now()] | order(publishedAt desc) {
  title,
  slug,
  "author": author->name,
  "categories": categories[]->title
}
```

---

**2. Write a GROQ query that retrieves a single post by its slug and includes the full author object and all category details.**

*Model Answer:*

```groq
*[_type == "post" && slug.current == $slug][0] {
  _id,
  title,
  slug,
  excerpt,
  publishedAt,
  "author": author-> {
    _id,
    name,
    slug,
    bio,
    avatar { asset-> { url }, alt }
  },
  "categories": categories[]-> {
    _id,
    title,
    slug
  },
  body
}
```

---

## Section 2.2: Advanced GROQ

### Multiple Choice

**1. What is the difference between `[0..9]` and `[0...10]` in GROQ pagination?**
- A) They are identical
- B) `[0..9]` is inclusive on both ends; `[0...10]` is inclusive on the first, exclusive on the second
- C) `[0...10]` is not valid GROQ syntax
- D) Both are invalid

**Answer: B**

*Explanation: `[0..9]` returns items at indices 0 through 9 (10 items). `[0...10]` uses the exclusive syntax, returning items 0 through 9 as well.*

---

**2. Which function would you use to extract plain text from a Portable Text field?**
- A) `html::text()`
- B) **`pt::text()`**
- C) `text::plain()`
- D) `convert::text()`

**Answer: B**

*Explanation: `pt::text()` is the GROQ function for extracting plain text from Portable Text content.* 

---

**3. What does the `_score` field represent in search results?**
- A) The document's internal ID
- B) **The relevance score of the match**
- C) The number of times the document was viewed
- D) The document's position in the dataset

**Answer: B**

*Explanation: `_score` is available when using search operators like `match` or `score`, representing how relevant the result is to the search query.* 

---

**4. How do you filter documents where an array contains a specific value?** 
- A) `"value" in arrayField`
- B) `arrayField == "value"`
- C) `arrayField contains "value"`
- D) `arrayField.matches("value")`

**Answer: A**

*Explanation: The `in` operator checks for membership in an array: `"value" in arrayField`.* 

---

### True/False

**1. The `select()` function in GROQ is used to conditionally include fields based on document properties.**
- **True**
- False

**Answer: True**

*Explanation: `select()` allows for conditional logic in projections, returning different values based on conditions.*

---

**2. GROQ queries can reference the current document using the `^` symbol.**
- **True**
- False

**Answer: True**

*Explanation: The `^` symbol represents the current document in nested queries, useful for filtering related content.*

---

**3. The `defined()` function checks if a field exists and has a non-null value.**
- **True**
- False

**Answer: True**

*Explanation: `defined(field)` returns true if the field exists and is not null.*

---

### Short Answer

**1. Write a GROQ query that returns all posts with at least 2 categories, including a computed field for word count and reading time.**

*Model Answer:*

```groq
*[_type == "post" && count(categories) >= 2] {
  title,
  slug,
  publishedAt,
  "wordCount": length(pt::text(body)),
  "readingTime": round(length(pt::text(body)) / 900),
  "categories": categories[]->title
}
```

---

## Section 2.3: Sanity TypeGen

### Multiple Choice

**1. What is the primary purpose of Sanity TypeGen?** 
- A) To generate HTML from schemas
- B) **To generate TypeScript types from schemas and GROQ queries**
- C) To create database migrations
- D) To build React components

**Answer: B**

*Explanation: Sanity TypeGen generates TypeScript types from your schema and GROQ queries, providing type safety across your application.* 

---

**2. Which command runs Sanity TypeGen?**
- A) `sanity generate`
- B) `sanity types`
- C) **`sanity typegen generate`**
- D) `sanity build --types`

**Answer: C**

*Explanation: The `sanity typegen generate` command generates TypeScript types from your schemas and queries.*

---

**3. Where is TypeGen configuration typically defined?**
- A) In `package.json`
- B) **In `sanity.cli.ts`**
- C) In `sanity.config.ts`
- D) In a separate `typegen.json`

**Answer: B**

*Explanation: TypeGen configuration is typically defined in the `sanity.cli.ts` file under the `typegen` property.* 

---

### True/False

**1. Sanity TypeGen requires you to manually define all types.**
- True
- **False**

**Answer: False**

*Explanation: Sanity TypeGen automatically generates types from your schemas and queries, eliminating the need for manual type definitions.* 

---

**2. TypeGen types update automatically when your schema changes.**
- **True**
- False

**Answer: True**

*Explanation: Running TypeGen with the `--watch` flag will regenerate types whenever your schemas change.*

---

# MODULE 3: Studio Customization

## Section 3.1: Schema Customization

### Multiple Choice

**1. What is the purpose of field groups in a Sanity schema?**
- A) To change how data is stored
- B) **To organize fields in the Studio interface**
- C) To add validation rules
- D) To create database indexes

**Answer: B**

*Explanation: Field groups organize related fields in the Studio UI, making the editing interface more intuitive for content creators.* 

---

**2. Which function is used to check the current user and validate their role in a Sanity Studio customization?** 
- A) `getUser()` and `hasPermission()`
- B) **`useCurrentUser()` and `userHasRole()`**
- C) `fetchUser()` and `roleChecker()`
- D) `whoAmI()` and `canIHazRole()`

**Answer: B**

*Explanation: `useCurrentUser()` is a React hook that returns the current user object, and `userHasRole()` is a helper function to check roles.* 

---

**3. What are custom roles in Sanity useful for?** 
- A) Only for visual themes
- B) **Ensuring security, compliance, and tailored editing experiences**
- C) Only for localization
- D) Only for billing purposes

**Answer: B**

*Explanation: Custom roles support security, compliance, content workflows, and tailored editing experiences.* 

---

### True/False

**1. Role-based customizations can conditionally hide fields from certain users.**
- **True**
- False

**Answer: True**

*Explanation: You can use `hidden: ({ currentUser }) => !userHasRole(currentUser, 'admin')` to conditionally show or hide fields based on the user's role.* 

---

**2. Document actions are limited to publish and unpublish functionality.**
- True
- **False**

**Answer: False**

*Explanation: Custom document actions allow you to add any functionality, such as AI summarization, external API calls, or custom publishing workflows.*

---

**3. Custom input components can only be used with text fields.**
- True
- **False**

**Answer: False**

*Explanation: Custom input components can be created for any field type, including arrays, objects, and custom field types.*

---

## Section 3.2: Document Actions & Dashboard Widgets

### Multiple Choice

**1. What is a common use case for custom document actions?**
- A) Changing the Studio theme
- B) **Adding pre-publish validation checks**
- C) Modifying the database schema
- D) Creating new user accounts

**Answer: B**

*Explanation: Custom document actions are often used to add validation before publishing, trigger external services, or implement custom workflows.*

---

**2. Dashboard widgets in Sanity Studio are built using:**
- A) Plain JavaScript
- B) **React components**
- C) HTML templates
- D) CSS only

**Answer: B**

*Explanation: Dashboard widgets are React components that can fetch and display data from the Sanity client.* 

---

**3. What do custom roles allow you to do with content resources?** 
- A) Only change color schemes
- B) **Restrict visibility of documents based on GROQ filters**
- C) Only affect billing
- D) Only change language settings

**Answer: B**

*Explanation: Content resources in the roles system allow restricting document visibility based on GROQ filters, providing granular access control.* 

---

### Short Answer

**1. Describe the process of creating a custom document action that validates required fields before publishing.**

*Model Answer:*

1. Create a React component that implements the `DocumentActionProps` interface
2. Use `useDocumentOperation` to access the publish operation
3. Define a validation function that checks required fields
4. If validation passes, call `publish.execute()`
5. If validation fails, show a dialog with error messages
6. Register the action in `sanity.config.ts` under `document.actions`

---

## Section 3.3: AI-Assisted Workflows

### Multiple Choice

**1. When would you use a Sanity AI Assist context?** 
- A) Only for image generation
- B) **To provide more information about your business, add writing style, or reference reused information**
- C) Only for translation
- D) Only for SEO optimization

**Answer: B**

*Explanation: Sanity AI Assist contexts allow you to provide business information, writing style, and reusable reference information.* 

---

**2. What is the recommended way to structure SEO fields in a Sanity schema?** 
- A) Create unique schema types for each document type
- B) Add SEO fields directly without structure
- C) **Create a reusable SEO object type that can be referenced across different document types**
- D) Store all SEO fields in a single global configuration document

**Answer: C**

*Explanation: Creating a reusable SEO object type promotes consistency and reduces duplication across document types.* 

---

# MODULE 4: Real-Time Content & Visual Editing

## Section 4.1: Live Content API

### Multiple Choice

**1. What is the Live Content API primarily used for?**
- A) Batch content import
- B) **Real-time synchronization between the Studio and frontend**
- C) Image optimization
- D) User authentication

**Answer: B**

*Explanation: The Live Content API enables real-time synchronization, pushing updates from the Studio to the frontend without polling.*

---

**2. In the Sanity SDK, what is the advantage of `useDocuments` over `client.fetch`?** 
- A) It fetches faster
- B) **Built-in batching and real-time updates**
- C) Hooks are the only way to fetch data in React
- D) It's cheaper

**Answer: B**

*Explanation: `useDocuments` provides built-in batching and real-time updates, making it preferable for applications requiring live content.* 

---

**3. What does `useDocumentEvent` listen to?** 
- A) Webhooks firing
- B) **Mutations to documents**
- C) User log-ins
- D) API requests

**Answer: B**

*Explanation: `useDocumentEvent` listens for mutations (changes) to documents, enabling real-time UI updates.* 

---

### True/False

**1. The Live Content API requires periodic polling to function.**
- True
- **False**

**Answer: False**

*Explanation: The Live Content API uses WebSocket connections for real-time updates, eliminating the need for polling.*

---

**2. Stega encoding is used to enable click-to-edit functionality in the Presentation Tool.**
- **True**
- False

**Answer: True**

*Explanation: Stega (steganographic) encoding embeds editing information in the content, enabling click-to-edit functionality.*

---

**3. `useDocumentProjection` is a hook for fetching future values of documents.** 
- True
- **False**

**Answer: False**

*Explanation: `useDocumentProjection` is a hook for fetching specific projected values from documents, not future values.* 

---

## Section 4.2: Visual Editing & Draft Mode

### Multiple Choice

**1. What is the purpose of Next.js Draft Mode?**
- A) To speed up development
- B) **To preview unpublished content**
- C) To enable dark mode
- D) To disable caching

**Answer: B**

*Explanation: Next.js Draft Mode allows editors to preview unpublished content without affecting the live site.*

---

**2. When using the Presentation Tool, what does the `resolve` configuration define?**
- A) The color scheme of the preview
- B) **Which document types map to which routes**
- C) The API endpoint for content
- D) The user authentication method

**Answer: B**

*Explanation: The `resolve.mainDocuments` configuration maps document types to URL routes for the Presentation Tool.* 

---

**3. What does `useApplyDocumentActions` provide in the Sanity SDK?** 
- A) Access to webhooks
- B) **A way to perform actions like publishing a document**
- C) User authentication
- D) Image optimization

**Answer: B**

*Explanation: `useApplyDocumentActions` provides a hook for performing document actions such as publish, unpublish, and delete.* 

---

### Short Answer

**1. Describe the flow from an editor publishing content in Sanity Studio to it appearing on a live Next.js site.**

*Model Answer:* 

1. Editor publishes content in Sanity Studio
2. A webhook is triggered, sending a payload to the configured endpoint
3. The endpoint validates the webhook using a shared secret
4. Next.js revalidates the specific content using `revalidateTag()` or `revalidatePath()`
5. The updated content is served to users on the next request
6. For critical content, ISR (Incremental Static Regeneration) can rebuild the page in the background 

---

# MODULE 5: Next.js 16 & React 19 Integration

## Section 5.1: Server Components & App Router

### Multiple Choice

**1. What enables route-level fetching in async components?** 
- A) React Query
- B) **React Server Components**
- C) Sanity Client
- D) Promises

**Answer: B**

*Explanation: React Server Components enable route-level data fetching directly in components, with automatic Suspense boundaries.* 

---

**2. What is the recommended way to structure SEO fields in your Sanity schema?** 
- A) Create unique schema types for each document type's SEO fields
- B) Add SEO fields directly to the document type without any structure
- C) **Create a reusable SEO object type that can be referenced across different document types**
- D) Store all SEO fields in a single global configuration document

**Answer: C**

*Explanation: Creating a reusable SEO object type promotes consistency and reduces duplication across different document types.* 

---

**3. Why does Next.js include significant validation within redirects?** 
- A) To make the development process more complex
- B) To slow down the build process
- C) Because Next.js is overly cautious
- D) **Because providing incorrect redirect data can break your deployment pipeline**

**Answer: D**

*Explanation: Incorrect redirects can cause deployment failures, so Next.js validates redirect configurations thoroughly.* 

---

**4. What is the benefit of using dynamic metadata in Next.js?** 
- A) It reduces the website's loading time
- B) It improves the server's performance
- C) It automatically creates backlinks
- D) **It allows for page-specific SEO optimization based on content**

**Answer: D**

*Explanation: Dynamic metadata enables page-specific SEO optimization, allowing each page to have customized meta tags based on its content.* 

---

### True/False

**1. In Next.js 16, `params` is a Promise that must be awaited when using the App Router.**
- **True**
- False

**Answer: True**

*Explanation: Next.js 16 introduces async `params` and `searchParams` that must be awaited in page components.*

---

**2. The `generateStaticParams` function is only used for static site generation (SSG).**
- **True**
- False

**Answer: True**

*Explanation: `generateStaticParams` determines which pages are pre-rendered at build time, working alongside `revalidate` for ISR.*

---

**3. `generateMetadata` runs on the client side in Next.js 16.**
- True
- **False**

**Answer: False**

*Explanation: `generateMetadata` runs on the server during rendering, generating SEO metadata for each page.*

---

## Section 5.2: Caching & Revalidation

### Multiple Choice

**1. What is the key advantage of implementing a dynamic sitemap in a Sanity + Next.js project?** 
- A) It makes the website load faster
- B) **It automatically updates when content changes**
- C) It improves the website's visual design
- D) It automatically generates meta descriptions

**Answer: B**

*Explanation: A dynamic sitemap automatically updates when content changes, ensuring search engines always have the latest content structure.* 

---

**2. What is the recommended data format for implementing schema markup with Next.js and Sanity?** 
- A) XML
- B) **JSON-LD**
- C) JavaScript
- D) HTML microdata

**Answer: B**

*Explanation: JSON-LD is the recommended format for schema markup, as it's the standard supported by major search engines.* 

---

**3. What is considered best practice when implementing SEO features in a Sanity + Next.js project?** 
- A) Hardcoding all SEO values in the Next.js files
- B) **Creating reusable schemas and components that can be managed by content creators**
- C) Managing everything through external SEO tools
- D) Letting search engines handle everything automatically

**Answer: B**

*Explanation: Creating reusable schemas and components empowers content creators to manage SEO while maintaining consistency.* 

---

**4. What is the main purpose of implementing on-page schema in your website?** 
- A) To make your website look better on social media
- B) **To increase your chance of search engines displaying rich results**
- C) To improve website loading speed
- D) To create better URLs

**Answer: B**

*Explanation: On-page schema markup increases the likelihood of search engines displaying rich results with enhanced features.* 

---

### True/False

**1. `useDocument` should be used sparingly because it resolves both local and remote states of the document.** 
- **True**
- False

**Answer: True**

*Explanation: `useDocument` resolves both local and remote document states, which can lead to performance overhead if used heavily.* 

---

**2. Webhooks need to be secured so random requests cannot trigger rebuilds.** 
- **True**
- False

**Answer: True**

*Explanation: Securing webhooks prevents unauthorized requests from triggering expensive rebuilds or exposing internal information.* 

---

**3. `useEditDocument` creates better UI than `client.patch` because it handles versions.** 
- **True**
- False

**Answer: True**

*Explanation: `useEditDocument` provides version handling and better UI integration compared to raw `client.patch` operations.* 

---

### Short Answer

**1. Describe how you would implement on-demand revalidation for a blog post in a Next.js + Sanity application.**

*Model Answer:* 

1. In Sanity Studio, configure a webhook that triggers when a post is created, updated, or deleted
2. In Next.js, create a webhook endpoint (`/api/revalidate`) that validates the webhook secret
3. Inside the endpoint, use `revalidateTag('post')` or `revalidatePath('/posts/[slug]')` to revalidate specific content
4. The webhook can also trigger `revalidateTag('posts')` to update listing pages
5. For optimal performance, the next user visit will see the updated content without a full rebuild
6. For critical content, consider using ISR with `revalidate` for automatic background regeneration 

---

# MODULE 6: Deployment & Production

## Section 6.1: Production Best Practices

### Multiple Choice

**1. What is the recommended way to handle API tokens in production?**
- A) Hardcode them in the source code
- B) **Store them as environment variables**
- C) Include them in the frontend bundle
- D) Use a single token for all environments

**Answer: B**

*Explanation: API tokens should always be stored as environment variables to keep them out of version control and enable environment-specific configuration.*

---

**2. What is the primary benefit of using `useCdn: true` in production?**
- A) It reduces database connections
- B) **Content is cached globally for faster delivery**
- C) It enables real-time editing
- D) It reduces storage costs

**Answer: B**

*Explanation: Enabling the CDN caches content at edge locations, reducing latency and improving delivery speed globally.*

---

**3. What is the advantage of a headless CMS architecture for multichannel delivery?** 
- A) It requires less development effort
- B) **It allows distributing content to web, mobile apps, and other channels from a single source**
- C) It's always cheaper
- D) It works with any hosting provider automatically

**Answer: B**

*Explanation: Headless architecture separates content management from presentation, enabling delivery to multiple channels from a single content source.* 

---

### True/False

**1. CORS origins should be restricted to your production domains only.**
- **True**
- False

**Answer: True**

*Explanation: Restricting CORS origins to production domains prevents unauthorized domains from accessing your API.*

---

**2. A full rebuild on a large site can take 5-10 minutes, which may be unacceptable for time-sensitive content.** 
- **True**
- False

**Answer: True**

*Explanation: Full rebuilds on large sites can take significant time. For breaking news or time-sensitive content, ISR with incremental revalidation is recommended.* 

---

**3. Environment variables should be committed to Git for easier deployment.**
- True
- **False**

**Answer: False**

*Explanation: Environment variables contain sensitive information and should never be committed to Git. Use `.env.example` for documentation instead.*

---

## Section 6.2: Monitoring & Maintenance

### Short Answer

**1. What should a post-launch support plan include for a Sanity CMS project?** 

*Model Answer:*

- Clearly scoped support period (30-90 days)
- Defined response times
- Explicit description of what's included vs. what would be a separate engagement
- Schema change handling
- Query adjustments for new page layouts
- Webhook monitoring and troubleshooting
- Documentation of schema decisions, environment variables, and deployment notes 

---

**2. Why is it important to document schema decisions and environment variables in a Sanity CMS project?** 

*Model Answer:*

- Facilitates onboarding of new developers
- Reduces the impact when original developers move on to new projects
- Provides a reference for troubleshooting issues
- Ensures consistent deployment practices
- Documents assumptions made during development
- Helps editors understand the content structure 

---

# BONUS: Hiring and Interview Questions

These questions are designed for evaluating Sanity CMS developers. 

## Interview Questions

**1. How do you approach schema design before writing any code?** 

*Model Answer:*

A good answer includes:
- Asking about content governance (who creates content, who approves it)
- Understanding content types and publishing frequency
- Separating content from presentation
- Using references rather than embedding everything directly
- Planning for reuse across pages and channels 

---

**2. Can you show me a GROQ query you wrote and explain why you structured it that way?** 

*Model Answer:*

A good answer includes:
- Walking through a real query from a past project
- Explaining the projection and why certain fields are included
- Describing a problem the query solved
- Mentioning GROQ projections, conditional fields, or query typing with Sanity TypeGen
- Discussing performance considerations 

---

**3. Walk me through how a content change in Sanity gets to my live site.** 

*Model Answer:*

A good answer includes:
- Editor publishes in Sanity Studio
- Webhook fires to the hosting platform
- Relevant pages are revalidated (not rebuilt entirely)
- Visitors see fresh content within seconds, not hours
- Understanding the difference between revalidating a single page vs. a full rebuild
- Securing webhooks to prevent unauthorized rebuilds 

---

**4. How do you train editors to use the CMS you build?** 

*Model Answer:*

A good answer includes:
- Customizing the Studio layout to show only relevant document types
- Adding field descriptions and validation messages in plain language
- Offering short handoff sessions (recorded or live)
- Providing a written guide tailored to the specific setup
- Not simply pointing to generic Sanity documentation 

---

**5. What does post-launch support look like with you?** 

*Model Answer:*

A good answer includes:
- Clearly scoped support period with defined response times
- Clear explanation of what's included vs. separate engagement
- Transparent availability and scope boundaries
- Documentation of schema decisions, environment variables, and deployment notes
- Formal process rather than informal "message me on Slack" arrangements 

---

# ANSWER KEY SUMMARY

| Question Type | Total | Notes |
|---------------|-------|-------|
| Multiple Choice | 50+ | One correct answer per question |
| True/False | 25+ | Explanation provided for each |
| Short Answer | 15+ | Model answers provided |
| Interview Questions | 5 | For evaluating developers |

---

# RECOMMENDED PASSING SCORES

| Level | Score Required |
|-------|----------------|
| Beginner | 60%+ |
| Intermediate | 75%+ |
| Advanced | 85%+ |
| Expert | 95%+ |

---

**[END: Quiz and Test Bank]**
