# Mastering Sanity CMS: Student Workbook

## Workbook Overview

Welcome to the Mastering Sanity CMS Student Workbook. This workbook is designed to accompany the tutorial series, providing you with structured exercises, reflection questions, and hands-on activities to reinforce your learning.

**How to Use This Workbook:**
- Complete each section after watching/reading the corresponding tutorial
- Use the exercises to practice what you've learned
- Reflect on your understanding using the questions provided
- Track your progress using the checklist at the end

**Student Information:**
- Name: _____________________________
- Start Date: _________________________
- Expected Completion: __________________

---

## PART 0: Introduction

### Pre-Course Self-Assessment

**Rate your current knowledge (1 = Beginner, 5 = Expert):**

1. JavaScript/TypeScript: ① ② ③ ④ ⑤
2. React: ① ② ③ ④ ⑤
3. Next.js: ① ② ③ ④ ⑤
4. Content Management Systems: ① ② ③ ④ ⑤
5. Headless CMS: ① ② ③ ④ ⑤
6. GraphQL/APIs: ① ② ③ ④ ⑤

### Course Goals

**What do you hope to achieve by completing this course?**

1. _________________________________________________________________

2. _________________________________________________________________

3. _________________________________________________________________

### Personal Project Ideas

**What kind of project do you want to build with Sanity?**

- _________________________________________________________________

- _________________________________________________________________

- _________________________________________________________________

---

## PART 1: Foundations of Structured Content

### Exercise 1.1: Content Modeling

**Instructions:** Think about a content type for a recipe website. List all the fields you would need.

```
Recipe
├── Field 1: _____________ (type: _____________)
├── Field 2: _____________ (type: _____________)
├── Field 3: _____________ (type: _____________)
├── Field 4: _____________ (type: _____________)
├── Field 5: _____________ (type: _____________)
├── Field 6: _____________ (type: _____________)
├── Field 7: _____________ (type: _____________)
└── Field 8: _____________ (type: _____________)
```

### Exercise 1.2: Schema Writing Practice

**Instructions:** Write a Sanity schema for a "Book" document type with the following fields:

| Field | Type | Validation |
|-------|------|------------|
| Title | String | Required, min 1, max 200 |
| Author | Reference to "author" | Required |
| ISBN | String | Unique, pattern: XXX-X-XXX-XXXXX-X |
| Description | Text | Optional, max 1000 |
| Cover Image | Image | Required |
| Publication Date | Date | Required |
| Pages | Number | Min 1 |
| Price | Number | Required, positive |

**Write your schema below:**

```typescript
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
```

### Exercise 1.3: Validation Practice

**Instructions:** Write validation rules for each field:

| Field | Validation Rules |
|-------|------------------|
| Title | Required, minimum 5 characters, maximum 100 characters |
| Slug | Required, generated from title, unique |
| Price | Required, positive number, maximum 9999.99 |
| Email | Required, valid email format |
| PublishedAt | Required, must be a date |
| Rating | Optional, must be between 1 and 5 |

```typescript
// Example: Title field with validation
defineField({
  name: 'title',
  title: 'Title',
  type: 'string',
  validation: (Rule) => [
    Rule.required().error('_________________________________'),
    Rule.min(5).error('_________________________________'),
    Rule.max(100).error('_________________________________'),
  ],
})

// Slug field with validation
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________

// Price field with validation
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________

// Email field with validation
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________

// PublishedAt field with validation
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________

// Rating field with validation
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
```

### Exercise 1.4: Reflection Questions

**1. Why is it important to separate content structure from presentation?**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**2. How does Portable Text differ from a traditional WYSIWYG editor?**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**3. What are the benefits of using references instead of embedding data?**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

---

## PART 2: Querying Content with GROQ

### Exercise 2.1: Basic GROQ Queries

**Instructions:** Write GROQ queries for each scenario using the following schema:
- `post` documents with fields: title, slug, publishedAt, author (reference), categories (array of references), excerpt, body (Portable Text)
- `author` documents with fields: name, slug, bio, avatar

**1. Get all posts with their titles and slugs:**

```groq
// _________________________________________________
```

**2. Get all posts published in 2024:**

```groq
// _________________________________________________
```

**3. Get all posts with their author names:**

```groq
// _________________________________________________
```

**4. Get all posts sorted by publish date (newest first):**

```groq
// _________________________________________________
```

**5. Get the 5 most recent posts:**

```groq
// _________________________________________________
```

**6. Get all posts that have at least one category:**

```groq
// _________________________________________________
```

**7. Get a single post by slug:**

```groq
// _________________________________________________
```

### Exercise 2.2: Advanced GROQ Queries

**Instructions:** Write these more complex GROQ queries:

**1. Get all posts with their categories as an array of titles:**

```groq
// _________________________________________________
```

**2. Get all posts by a specific author (use $authorSlug parameter):**

```groq
// _________________________________________________
```

**3. Get posts with their category count:**

```groq
// _________________________________________________
```

**4. Get posts with a computed "readingTime" field (assume 200 words per minute):**

```groq
// _________________________________________________
```

**5. Get posts grouped by month of publication:**

```groq
// _________________________________________________
```

**6. Get all authors with their post count:**

```groq
// _________________________________________________
```

### Exercise 2.3: Query Testing Practice

**Instructions:** In the Vision tool, test these queries and record the results:

| Query | Expected Result | Did it work? |
|-------|-----------------|--------------|
| `*[_type == "post"]` | All posts | ☐ Yes ☐ No |
| `*[_type == "post"] { title }` | Only titles | ☐ Yes ☐ No |
| `*[_type == "post"] | order(publishedAt desc)` | Posts sorted | ☐ Yes ☐ No |
| `*[_type == "post"][0..2]` | First 3 posts | ☐ Yes ☐ No |
| `*[_type == "post" && defined(publishedAt)]` | Only published | ☐ Yes ☐ No |

**What queries did you find most challenging?**

_________________________________________________________________

_________________________________________________________________

### Exercise 2.4: Reflection Questions

**1. What is the difference between `[0..9]` and `[0...10]` in GROQ?**

_________________________________________________________________

_________________________________________________________________

**2. When would you use the `coalesce` function?**

_________________________________________________________________

_________________________________________________________________

**3. How does the `->` operator work in GROQ?**

_________________________________________________________________

_________________________________________________________________

**4. What is the purpose of the `pt::text()` function?**

_________________________________________________________________

_________________________________________________________________

---

## PART 3: Extending Sanity Studio

### Exercise 3.1: Studio Structure Planning

**Instructions:** Design a custom Studio structure for a magazine website. Consider the following content types:
- Articles, Authors, Categories, Issues, Advertisers

**Draw your proposed structure:**

```
Content
├── _____________
│   ├── _____________
│   └── _____________
├── _____________
│   ├── _____________
│   └── _____________
├── _____________
│   ├── _____________
│   └── _____________
├── _____________
├── _____________
└── _____________
```

### Exercise 3.2: Custom Input Component Design

**Instructions:** Design a custom input component for a "Star Rating" field (1-5 stars).

**1. Describe the component's UI:**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**2. How would a user interact with it?**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**3. What would the component's code structure look like?**

```typescript
// Pseudo-code for StarRating component
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
```

### Exercise 3.3: Document Action Planning

**Instructions:** You want to add a "Send to Review" action for articles. Describe the workflow:

**1. When should this action appear?**

_________________________________________________________________

**2. What should happen when the action is triggered?**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**3. What validation should happen before the action executes?**

_________________________________________________________________

_________________________________________________________________

**4. What feedback should the editor receive?**

_________________________________________________________________

_________________________________________________________________

### Exercise 3.4: Reflection Questions

**1. What is the purpose of field groups in Sanity schemas?**

_________________________________________________________________

_________________________________________________________________

**2. When would you use a custom input component instead of a built-in field?**

_________________________________________________________________

_________________________________________________________________

**3. What are the benefits of using dashboard widgets?**

_________________________________________________________________

_________________________________________________________________

**4. How can AI be integrated into Sanity Studio workflows?**

_________________________________________________________________

_________________________________________________________________

---

## PART 4: Real-Time Content & Visual Editing

### Exercise 4.1: Real-Time Features Implementation

**Instructions:** Plan how to implement real-time features for a news website:

**1. What content should update in real-time?**

_________________________________________________________________

_________________________________________________________________

**2. How would you configure the Live Content API?**

_________________________________________________________________

_________________________________________________________________

**3. What frontend changes are needed to support real-time updates?**

_________________________________________________________________

_________________________________________________________________

### Exercise 4.2: Visual Editing Configuration

**Instructions:** Configure the Presentation Tool for your project:

**1. Your Studio URL:** _______________________

**2. Your Frontend URL:** _______________________

**3. Document to Route Mapping:**

| Document Type | URL Pattern | Slug Field |
|---------------|-------------|------------|
| post | /posts/:slug | ___________ |
| author | /authors/:slug | ___________ |
| category | /categories/:slug | ___________ |

**4. Write the `resolve.mainDocuments` configuration:**

```typescript
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
```

### Exercise 4.3: Draft Mode Setup

**Instructions:** Write the API endpoints for enabling and disabling Draft Mode:

**Enable Draft Mode (app/api/draft-mode/enable/route.ts):**

```typescript
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
```

**Disable Draft Mode (app/api/draft-mode/disable/route.ts):**

```typescript
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
```

### Exercise 4.4: Content Releases

**Instructions:** Plan a content release for a product launch:

**1. Release Title:** _______________________

**2. Scheduled Date:** _______________________

**3. Content Items to Include:**

| Item | Type | Status |
|------|------|--------|
| _____ | _____ | _____ |
| _____ | _____ | _____ |
| _____ | _____ | _____ |
| _____ | _____ | _____ |

**4. What is the publishing workflow?**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

### Exercise 4.5: Reflection Questions

**1. How does the Live Content API differ from traditional polling?**

_________________________________________________________________

_________________________________________________________________

**2. What is the purpose of stega encoding?**

_________________________________________________________________

_________________________________________________________________

**3. Why is Draft Mode important for editorial workflows?**

_________________________________________________________________

_________________________________________________________________

**4. What are the benefits of content releases?**

_________________________________________________________________

_________________________________________________________________

---

## PART 5: React 19 & Next.js 16 Integration

### Exercise 5.1: Next.js App Router Setup

**Instructions:** Create the folder structure for a Next.js blog:

```
app/
├── (frontend)/
│   ├── layout.tsx           # Main layout
│   ├── page.tsx             # Homepage
│   ├── posts/
│   │   ├── page.tsx         # Posts listing
│   │   └── [slug]/
│   │       ├── page.tsx     # Single post
│   │       └── loading.tsx  # Loading state
│   ├── authors/
│   │   ├── page.tsx         # Authors listing
│   │   └── [slug]/
│   │       └── page.tsx     # Single author
│   └── categories/
│       ├── page.tsx         # Categories listing
│       └── [slug]/
│           └── page.tsx     # Single category
├── api/
│   ├── revalidate/
│   │   └── route.ts         # Revalidation endpoint
│   └── preview/
│       ├── route.ts         # Enable preview
│       └── disable/
│           └── route.ts     # Disable preview
└── layout.tsx               # Root layout
```

### Exercise 5.2: Server Component Implementation

**Instructions:** Write a Server Component that fetches and displays posts:

```tsx
// app/posts/page.tsx
import { getAllPosts } from '@/lib/sanity/queries'

export default async function PostsPage() {
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
}
```

### Exercise 5.3: Dynamic Metadata

**Instructions:** Write the `generateMetadata` function for a blog post:

```typescript
// app/posts/[slug]/page.tsx
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) {
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
}
```

### Exercise 5.4: Cache Tags

**Instructions:** Design a cache tagging strategy for a blog:

**1. List the cache tags you would use:**

- Tags for collections: _________________________________

- Tags for individual items: _________________________________

- Tags for related content: _________________________________

**2. When would you revalidate each tag?**

| Tag | Revalidation Trigger |
|-----|---------------------|
| _____ | _____ |
| _____ | _____ |
| _____ | _____ |

### Exercise 5.5: Sitemap Generation

**Instructions:** Write the code to generate a dynamic sitemap:

```typescript
// app/sitemap.ts
import { getAllPosts, getAllAuthors, getAllCategories } from '@/lib/sanity/queries'

export default async function sitemap() {
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
  // _________________________________________________
}
```

### Exercise 5.6: Reflection Questions

**1. What are the benefits of Server Components over Client Components?**

_________________________________________________________________

_________________________________________________________________

**2. Why does Next.js 16 use Promise-based `params`?**

_________________________________________________________________

_________________________________________________________________

**3. How does ISR improve performance for content-heavy sites?**

_________________________________________________________________

_________________________________________________________________

**4. What is the difference between `revalidateTag` and `revalidatePath`?**

_________________________________________________________________

_________________________________________________________________

---

## APPENDIX A: Reference & Deep Dive

### Exercise A.1: Portable Text Customization

**Instructions:** Design a custom Portable Text block for an "Author Bio" that includes:
- Author name (string)
- Author image (image)
- Bio text (Portable Text)
- Social links (array of objects with platform and URL)

```typescript
// Write the custom block definition
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
```

### Exercise A.2: GROQ Functions Reference

**Instructions:** Complete the reference table:

| Function | Purpose | Example |
|----------|---------|---------|
| `count()` | Count items in an array | `_________` |
| `defined()` | Check if field exists | `_________` |
| `coalesce()` | First non-null value | `_________` |
| `select()` | Conditional value | `_________` |
| `pt::text()` | Extract text | `_________` |
| `round()` | Round a number | `_________` |
| `now()` | Current date/time | `_________` |
| `references()` | Check for references | `_________` |

### Exercise A.3: TypeGen Configuration

**Instructions:** Configure TypeGen for a project:

**1. Where is TypeGen configured?** _________________________________

**2. What is the purpose of the `path` option?** _________________________________

_________________________________________________________________

**3. What is the purpose of the `generates` option?** _________________________________

_________________________________________________________________

**4. Write a TypeGen configuration for a monorepo:**

```typescript
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
// _________________________________________________
```

---

## APPENDIX B: Production Checklist

### Exercise B.1: Security Checklist

**Instructions:** Check off each security item as you complete it:

- [ ] API tokens stored as environment variables
- [ ] CORS origins restricted to production domains
- [ ] Read-only tokens used for frontend
- [ ] Draft mode authentication implemented
- [ ] Webhook secrets validated
- [ ] HTTPS configured
- [ ] Security headers set (CSP, XSS protection, etc.)
- [ ] Environment variables not committed to Git

### Exercise B.2: Performance Checklist

**Instructions:** Check off each performance item as you complete it:

- [ ] `useCdn: true` in production client
- [ ] ISR configured with `revalidate`
- [ ] Cache tags implemented
- [ ] Image optimization with Next.js Image
- [ ] Lazy loading for images
- [ ] Bundle analysis completed
- [ ] Lighthouse scores > 90
- [ ] Core Web Vitals monitored

### Exercise B.3: Monitoring Plan

**Instructions:** Design your monitoring and maintenance plan:

**1. What uptime monitoring service will you use?** _______________________

**2. What error tracking service will you use?** _______________________

**3. What analytics service will you use?** _______________________

**4. How often will you review performance metrics?**

- [ ] Daily
- [ ] Weekly
- [ ] Monthly
- [ ] Quarterly

**5. What is your backup strategy?**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**6. What is your update schedule for dependencies?**

_________________________________________________________________

---

## APPENDIX C: Advanced Patterns

### Exercise C.1: Multi-Language Strategy

**Instructions:** Design a multi-language strategy for a global brand:

**1. Which approach will you use?**
- [ ] Field-level translations
- [ ] Document-level translations
- [ ] Dataset-level translations

**2. Why did you choose this approach?**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**3. How will you handle language detection?**

_________________________________________________________________

_________________________________________________________________

**4. How will editors manage translations?**

_________________________________________________________________

_________________________________________________________________

### Exercise C.2: E-Commerce Integration

**Instructions:** Design the content structure for an online store:

**1. List the content types needed:**

| Type | Purpose | Relationships |
|------|---------|---------------|
| _____ | _____ | _____ |
| _____ | _____ | _____ |
| _____ | _____ | _____ |
| _____ | _____ | _____ |

**2. How will products relate to categories?**

_________________________________________________________________

_________________________________________________________________

**3. How will you handle product variants (size, color, etc.)?**

_________________________________________________________________

_________________________________________________________________

**4. How will you integrate with a commerce engine (e.g., Shopify, Stripe)?**

_________________________________________________________________

_________________________________________________________________

### Exercise C.3: Third-Party Integrations

**Instructions:** Plan integrations for your project:

**1. What third-party services will you integrate?**

| Service | Purpose | Integration Method |
|---------|---------|-------------------|
| _____ | _____ | _____ |
| _____ | _____ | _____ |
| _____ | _____ | _____ |

**2. How will you handle webhook security?**

_________________________________________________________________

_________________________________________________________________

**3. What is your fallback strategy if an integration fails?**

_________________________________________________________________

_________________________________________________________________

---

## FINAL PROJECT WORKSHEET

### Project Overview

**Project Name:** _______________________________

**Project Description:**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

### Content Model

**Document Types:**

| Type | Purpose | Key Fields |
|------|---------|-----------|
| _____ | _____ | _____ |
| _____ | _____ | _____ |
| _____ | _____ | _____ |
| _____ | _____ | _____ |

**Relationships:**

| From | To | Type |
|------|-----|------|
| _____ | _____ | _____ |
| _____ | _____ | _____ |
| _____ | _____ | _____ |

### Studio Customization

**Customizations Planned:**
- [ ] Custom structure
- [ ] Custom input components
- [ ] Custom document actions
- [ ] Dashboard widgets
- [ ] Custom validation
- [ ] Field groups

**List specific customizations:**

1. _________________________________________________________________

2. _________________________________________________________________

3. _________________________________________________________________

### Frontend Architecture

**Framework:** _________________________________

**Pages Needed:**
- [ ] Homepage
- [ ] Blog listing
- [ ] Single post
- [ ] Author listing
- [ ] Single author
- [ ] Category listing
- [ ] Single category
- [ ] Search
- [ ] 404

**Additional Features:**
- [ ] Newsletter signup
- [ ] Comments
- [ ] Search
- [ ] RSS feed
- [ ] Sitemap
- [ ] Analytics

### Deployment Plan

**Hosting:** _________________________________

**Studio URL:** _________________________________

**Frontend URL:** _________________________________

**Environment Variables Needed:**

| Variable | Value | Purpose |
|----------|-------|---------|
| _____ | _____ | _____ |
| _____ | _____ | _____ |
| _____ | _____ | _____ |

**Webhooks Configured:**
- [ ] Post creation/update
- [ ] Author creation/update
- [ ] Category creation/update
- [ ] All content changes

### Post-Launch Plan

**Support Period:** _________________________________

**Maintenance Tasks:**

| Task | Frequency | Responsible |
|------|-----------|-------------|
| _____ | _____ | _____ |
| _____ | _____ | _____ |
| _____ | _____ | _____ |

**Documentation to Provide:**
- [ ] Schema documentation
- [ ] Environment variables
- [ ] Deployment instructions
- [ ] Editor guide
- [ ] Developer onboarding

---

## COMPLETION CHECKLIST

### Part 1: Foundations of Structured Content
- [ ] Completed Exercise 1.1 (Content Modeling)
- [ ] Completed Exercise 1.2 (Schema Writing)
- [ ] Completed Exercise 1.3 (Validation Practice)
- [ ] Completed Exercise 1.4 (Reflection Questions)

### Part 2: Querying Content with GROQ
- [ ] Completed Exercise 2.1 (Basic GROQ Queries)
- [ ] Completed Exercise 2.2 (Advanced GROQ Queries)
- [ ] Completed Exercise 2.3 (Query Testing Practice)
- [ ] Completed Exercise 2.4 (Reflection Questions)

### Part 3: Extending Sanity Studio
- [ ] Completed Exercise 3.1 (Studio Structure Planning)
- [ ] Completed Exercise 3.2 (Custom Input Component Design)
- [ ] Completed Exercise 3.3 (Document Action Planning)
- [ ] Completed Exercise 3.4 (Reflection Questions)

### Part 4: Real-Time Content & Visual Editing
- [ ] Completed Exercise 4.1 (Real-Time Features Implementation)
- [ ] Completed Exercise 4.2 (Visual Editing Configuration)
- [ ] Completed Exercise 4.3 (Draft Mode Setup)
- [ ] Completed Exercise 4.4 (Content Releases)
- [ ] Completed Exercise 4.5 (Reflection Questions)

### Part 5: React 19 & Next.js 16 Integration
- [ ] Completed Exercise 5.1 (App Router Setup)
- [ ] Completed Exercise 5.2 (Server Component Implementation)
- [ ] Completed Exercise 5.3 (Dynamic Metadata)
- [ ] Completed Exercise 5.4 (Cache Tags)
- [ ] Completed Exercise 5.5 (Sitemap Generation)
- [ ] Completed Exercise 5.6 (Reflection Questions)

### Appendices
- [ ] Completed Appendix A Exercises
- [ ] Completed Appendix B Checklist
- [ ] Completed Appendix C Exercises

### Final Project
- [ ] Completed Final Project Worksheet
- [ ] Built the project
- [ ] Deployed the project
- [ ] Documented the project

---

## SUPPLEMENTAL NOTES

### Troubleshooting Log

| Issue | Environment | Solution | Date Resolved |
|-------|-------------|----------|---------------|
| _____ | _____ | _____ | _____ |
| _____ | _____ | _____ | _____ |
| _____ | _____ | _____ | _____ |
| _____ | _____ | _____ | _____ |

### Key Learnings

**What were the most important concepts you learned?**

1. _________________________________________________________________

2. _________________________________________________________________

3. _________________________________________________________________

**What was the most challenging part?**

_________________________________________________________________

_________________________________________________________________

**What would you do differently next time?**

_________________________________________________________________

_________________________________________________________________

**Resources you found helpful:**

1. _________________________________________________________________

2. _________________________________________________________________

3. _________________________________________________________________

### Next Steps

**What will you build next?**

_________________________________________________________________

_________________________________________________________________

**What technologies do you want to explore further?**

_________________________________________________________________

_________________________________________________________________

**What communities or resources will you continue to use?**

_________________________________________________________________

_________________________________________________________________

---

**[END: Student Workbook]**
