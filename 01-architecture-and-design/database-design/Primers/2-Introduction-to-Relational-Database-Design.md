# PRIMER 2 — Introduction to Relational Database Design

## Understanding How to Structure Your Data

---

## P2.1 Introduction

Welcome to the second primer! Now that you understand basic database concepts from Primer 1, we'll dive into the art and science of **relational database design**. This is where we learn how to organize data effectively.

**By the end of this primer, you will understand:**
- What a relational database is
- How to identify entities and attributes
- How to draw Entity-Relationship Diagrams (ERDs)
- The concept of relationships (1:1, 1:N, N:M)
- Why data organization matters
- Introduction to normalization

---

## P2.2 What Is a Relational Database?

### P2.2.1 The Core Idea

A **relational database** organizes data into tables that are related to each other through common columns (keys).

```
┌─────────────────────────────────────────────────────────────────────┐
│                    RELATIONAL DATABASE CONCEPT                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   A relational database is like a set of connected spreadsheets   │
│                                                                     │
│   ┌──────────────────┐       ┌──────────────────┐                │
│   │   CUSTOMERS      │       │    ORDERS        │                │
│   ├──────────────────┤       ├──────────────────┤                │
│   │ id │ name  │     │       │ id │ cust_id │   │                │
│   ├────┼───────┼─────┤       ├────┼─────────┼───┤                │
│   │ 1  │ John  │  ◄──┼───────┼───►│ 1 │  1     │   │                │
│   │ 2  │ Jane  │     │       │ 2 │  1     │   │                │
│   │ 3  │ Bob   │     │       │ 3 │  2     │   │                │
│   └──────────────────┘       └──────────────────┘                │
│           ▲                               │                        │
│           │                               │                        │
│           └───────────────────────────────┘                        │
│                     RELATED BY CUSTOMER ID                        │
│                                                                     │
│   Benefits of this approach:                                      │
│   • No data duplication (John's info appears only once)          │
│   • Data consistency (update once, update everywhere)            │
│   • Easier to maintain                                            │
│   • More powerful queries (join tables)                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P2.2.2 Why Not Just One Big Table?

**Analogy:** Imagine you run a store. You could keep all your information in one giant spreadsheet:

| Order ID | Customer Name | Customer Address | Product Name | Product Price | Quantity |
|----------|---------------|------------------|--------------|---------------|----------|
| 1001 | John Doe | 123 Main St | Laptop | $999 | 1 |
| 1002 | Jane Smith | 456 Oak Ave | Phone | $599 | 2 |
| 1003 | John Doe | 123 Main St | Mouse | $29 | 1 |
| 1004 | John Doe | 123 Main St | Keyboard | $89 | 1 |

**Problems with this approach:**
- **Redundancy**: John Doe's address appears 3 times
- **Update anomalies**: If John moves, you must update 3 rows
- **Insert anomalies**: Can't add a customer with no orders
- **Delete anomalies**: If you delete all of John's orders, you lose his information

**Solution:** Split into separate tables connected by relationships!

---

## P2.3 Entities and Attributes

### P2.3.1 Identifying Entities

An **entity** is a real-world object or concept that we want to store data about.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ENTITY IDENTIFICATION                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Question: What are the key "things" in our e-commerce system?   │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  ENTITY: CUSTOMER                                          │ │
│   │  A person who buys products from us                        │ │
│   │                                                             │ │
│   │  ENTITY: PRODUCT                                           │ │
│   │  An item that we sell                                       │ │
│   │                                                             │ │
│   │  ENTITY: ORDER                                             │ │
│   │  A transaction where a customer buys products              │ │
│   │                                                             │ │
│   │  ENTITY: CATEGORY                                          │ │
│   │  A way to group similar products                           │ │
│   │                                                             │ │
│   │  ENTITY: SUPPLIER                                          │ │
│   │  A company that provides products to us                    │ │
│   │                                                             │ │
│   │  ENTITY: INVENTORY                                         │ │
│   │  Tracking how many products we have in stock               │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P2.3.2 Identifying Attributes

An **attribute** is a property or characteristic of an entity.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ATTRIBUTE IDENTIFICATION                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ENTITY: CUSTOMER                                                │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Attributes:                                               │ │
│   │  • id (unique identifier)                                  │ │
│   │  • first_name                                              │ │
│   │  • last_name                                               │ │
│   │  • email (must be unique)                                  │ │
│   │  • phone_number                                            │ │
│   │  • registration_date                                       │ │
│   │  • address                                                 │ │
│   │  • date_of_birth                                           │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ENTITY: PRODUCT                                                 │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Attributes:                                               │ │
│   │  • id (unique identifier)                                  │ │
│   │  • name                                                    │ │
│   │  • description                                             │ │
│   │  • price                                                   │ │
│   │  • sku (stock keeping unit)                                │ │
│   │  • weight                                                  │ │
│   │  • created_date                                            │ │
│   │  • category_id (links to Category)                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P2.4 Entity-Relationship Diagrams (ERDs)

### P2.4.1 What Is an ERD?

An **Entity-Relationship Diagram (ERD)** is a visual representation of the entities in your database and how they relate to each other.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ENTITY-RELATIONSHIP DIAGRAM                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Symbol Legend:                                                  │
│   ┌──────────┐  = Entity                                        │
│   │  Entity  │                                                   │
│   └──────────┘                                                   │
│   ──────────── = Relationship                                   │
│   1──┬──N     = One-to-Many                                     │
│   N──┬──N     = Many-to-Many                                    │
│   1──┬──1     = One-to-One                                      │
│                                                                     │
│   SAMPLE ERD FOR A BOOKSTORE:                                    │
│                                                                     │
│   ┌──────────┐        ┌──────────┐        ┌──────────┐          │
│   │ AUTHOR   │───────▶│  BOOK    │◀───────│ CATEGORY │          │
│   │          │   N:M  │          │   N:1  │          │          │
│   └──────────┘        └────┬─────┘        └──────────┘          │
│                            │                                      │
│                            │ 1:N                                  │
│                            ▼                                      │
│                     ┌──────────┐        ┌──────────┐             │
│                     │ ORDER    │───────▶│ CUSTOMER │             │
│                     │  ITEM    │   N:1  │          │             │
│                     └──────────┘        └──────────┘             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P2.4.2 Reading an ERD

```
┌─────────────────────────────────────────────────────────────────────┐
│                    READING AN ERD                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Relationship: Customer ───(1:N)─── Order                       │
│                                                                     │
│   Meaning:                                                        │
│   • Each customer can place MANY orders                           │
│   • Each order belongs to EXACTLY ONE customer                    │
│                                                                     │
│   Relationship: Order ───(1:N)─── Order_Item                    │
│                                                                     │
│   Meaning:                                                        │
│   • Each order can have MANY items                                │
│   • Each item belongs to EXACTLY ONE order                        │
│                                                                     │
│   Relationship: Product ───(1:N)─── Order_Item                  │
│                                                                     │
│   Meaning:                                                        │
│   • Each product can appear in MANY order items                   │
│   • Each order item references EXACTLY ONE product                │
│                                                                     │
│   Relationship: Product ───(N:M)─── Category                    │
│                                                                     │
│   Meaning:                                                        │
│   • Each product can belong to MANY categories                    │
│   • Each category can have MANY products                          │
│   • This is a many-to-many relationship (needs junction table)   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P2.5 Types of Relationships

### P2.5.1 One-to-One (1:1)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ONE-TO-ONE RELATIONSHIP                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Person ─────(1)─────(1)───── Passport                         │
│                                                                     │
│   ┌──────────┐              ┌──────────┐                         │
│   │  Person  │              │ Passport │                         │
│   ├──────────┤              ├──────────┤                         │
│   │ id       │───(FK)───────│ person_id│                         │
│   │ name     │              │ number   │                         │
│   │ age      │              │ country  │                         │
│   └──────────┘              └──────────┘                         │
│                                                                     │
│   Rules:                                                          │
│   • Each person has exactly one passport                         │
│   • Each passport belongs to exactly one person                  │
│   • Rare in database design                                      │
│   • Often combined into one table                                │
│                                                                     │
│   Example in ScaleCart:                                           │
│   Product ───(1:1)─── Inventory                                 │
│   • Each product has exactly one inventory record                 │
│   • Each inventory record belongs to exactly one product         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P2.5.2 One-to-Many (1:N)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ONE-TO-MANY RELATIONSHIP                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Customer ─────(1)─────(N)───── Order                          │
│                                                                     │
│   ┌──────────┐              ┌──────────┐                         │
│   │ Customer │              │  Order   │                         │
│   ├──────────┤              ├──────────┤                         │
│   │ id       │───(PK)───────│ id       │                         │
│   │ name     │              │ customer │───(FK)                  │
│   │ email    │              │ _id      │                         │
│   └──────────┘              │ total    │                         │
│                             └──────────┘                         │
│                                                                     │
│   Rules:                                                          │
│   • One customer can have MANY orders                            │
│   • Each order belongs to EXACTLY ONE customer                   │
│   • The foreign key (customer_id) is in the "many" side         │
│                                                                     │
│   Examples in ScaleCart:                                          │
│   Category ───(1:N)─── Product                                  │
│   Order ───(1:N)─── Order_Item                                  │
│   Customer ───(1:N)─── Address                                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P2.5.3 Many-to-Many (N:M)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MANY-TO-MANY RELATIONSHIP                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Student ─────(N)─────(M)───── Course                          │
│                                                                     │
│   ┌──────────┐              ┌──────────┐                         │
│   │ Student  │              │  Course  │                         │
│   ├──────────┤              ├──────────┤                         │
│   │ id       │              │ id       │                         │
│   │ name     │              │ name     │                         │
│   └──────────┘              └──────────┘                         │
│        │                          │                               │
│        │      ┌──────────┐       │                               │
│        └─────▶│ JUNCTION │◀──────┘                               │
│               │  TABLE   │                                       │
│               ├──────────┤                                       │
│               │ student  │───(FK)                               │
│               │ _id      │                                       │
│               │ course   │───(FK)                               │
│               │ _id      │                                       │
│               │ grade    │                                       │
│               └──────────┘                                       │
│                                                                     │
│   Rules:                                                          │
│   • Many students can take many courses                          │
│   • Many courses can be taken by many students                   │
│   • Requires a JUNCTION TABLE (also called linking table)        │
│                                                                     │
│   Examples in ScaleCart:                                          │
│   Supplier ───(N:M)─── Product                                  │
│   • One product can have many suppliers                          │
│   • One supplier can supply many products                        │
│   • Junction table: supplier_products                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P2.6 Introduction to Normalization

### P2.6.1 What Is Normalization?

**Normalization** is the process of organizing data to reduce redundancy and improve integrity.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NORMALIZATION ANALOGY                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Imagine you have a messy garage:                               │
│   • Tools everywhere                                             │
│   • Duplicate tools you didn't know you had                     │
│   • Hard to find things                                          │
│   • Wasted space                                                 │
│                                                                     │
│   Normalization is like organizing your garage:                  │
│   • Put tools in labeled boxes                                   │
│   • Group similar items together                                 │
│   • Eliminate duplicates                                         │
│   • Everything has a place                                        │
│   • Easy to find and use things                                  │
│                                                                     │
│   In databases, normalization:                                    │
│   • Reduces data duplication                                      │
│   • Prevents data inconsistencies                                 │
│   • Makes databases easier to maintain                           │
│   • Saves storage space                                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P2.6.2 The Normalization Levels

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NORMALIZATION LEVELS                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  LEVEL 1: FIRST NORMAL FORM (1NF)                         │ │
│   │  • Each column has atomic (single) values                  │ │
│   │  • No repeating groups of columns                          │ │
│   │  • Each row is unique                                       │ │
│   │                                                             │ │
│   │  Example: Instead of storing multiple phone numbers        │ │
│   │  in one column, create separate rows or another table      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  LEVEL 2: SECOND NORMAL FORM (2NF)                        │ │
│   │  • Must be in 1NF                                           │ │
│   │  • All non-key columns depend on the entire primary key    │ │
│   │  • Applies when primary key is composite (multiple columns) │ │
│   │                                                             │ │
│   │  Example: In an order_items table with (order_id,          │ │
│   │  product_id) as primary key, all columns must depend on    │ │
│   │  both order_id AND product_id                              │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  LEVEL 3: THIRD NORMAL FORM (3NF)                         │ │
│   │  • Must be in 2NF                                           │ │
│   │  • No transitive dependencies                              │ │
│   │  • Non-key columns should depend only on the primary key   │ │
│   │                                                             │ │
│   │  Example: If Order has (customer_id, customer_name),       │ │
│   │  customer_name depends on customer_id, not the order       │ │
│   │  primary key. Customer name should be in the customers     │ │
│   │  table.                                                    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  LEVEL 4: BOYCE-CODD NORMAL FORM (BCNF)                   │ │
│   │  • A stricter version of 3NF                               │ │
│   │  • Every determinant must be a candidate key               │ │
│   │  • Addresses rare scenarios not covered by 3NF             │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P2.6.3 Normalization Example

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NORMALIZATION EXAMPLE                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   BEFORE NORMALIZATION (Denormalized):                            │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  ORDERS                                                    │ │
│   │  ┌──────┬──────────┬─────────┬──────────┬──────────┐     │ │
│   │  │OrderID│Customer  │Customer │Product   │Product   │     │ │
│   │  │       │Name      │City     │Name      │Price     │     │ │
│   │  ├──────┼──────────┼─────────┼──────────┼──────────┤     │ │
│   │  │ 1001 │ John Doe │ NYC     │ Laptop   │ 999.00   │     │ │
│   │  │ 1001 │ John Doe │ NYC     │ Mouse    │ 29.00    │     │ │
│   │  │ 1002 │ Jane Smith│ LA     │ Phone    │ 599.00   │     │ │
│   │  │ 1003 │ John Doe │ NYC     │ Keyboard │ 89.00    │     │ │
│   │  └──────┴──────────┴─────────┴──────────┴──────────┘     │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   PROBLEMS:                                                       │
│   • John Doe's name and city repeated 3 times                    │
│   • Product information repeated                                 │
│   • Hard to update customer addresses                           │
│   • Can't add customer without an order                         │
│                                                                     │
│   AFTER NORMALIZATION (3NF):                                     │
│                                                                     │
│   ┌──────────┐      ┌──────────┐      ┌──────────┐             │
│   │ CUSTOMERS│      │  ORDERS  │      │ ORDER    │             │
│   ├──────────┤      ├──────────┤      │  ITEMS   │             │
│   │ id       │───(N)─│ id       │──(1)─│ order_id │             │
│   │ name     │      │ customer │      │ product  │───(1)────┐  │
│   │ city     │      │ _id      │      │ _id      │          │  │
│   └──────────┘      │ date     │      │ quantity │          │  │
│                     └──────────┘      └──────────┘          │  │
│                                                               │  │
│                                                   ┌──────────┼──│
│                                                   │ PRODUCTS │  │
│                                                   ├──────────┤  │
│                                                   │ id       │◀─┘
│                                                   │ name     │  │
│                                                   │ price    │  │
│                                                   └──────────┘  │
│                                                                     │
│   BENEFITS:                                                       │
│   • No data duplication                                         │
│   • Easy to update customer information                          │
│   • Can add customer without orders                             │
│   • Product information stored once                              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P2.7 Designing the ScaleCart Database

### P2.7.1 ScaleCart Entities

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCALECART ENTITIES                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   CUSTOMER         ───(1:N)───  ORDER                            │
│   (People who buy)               (Purchases made)                 │
│         │                            │                            │
│         │                            │ (1:N)                      │
│         │                            ▼                            │
│         │                     ORDER_ITEM                         │
│         │                     (Products in order)                │
│         │                            │                            │
│         │                            │ (N:1)                      │
│         └───────(1:N)               ▼                            │
│                 │               PRODUCT                          │
│                 ▼              (Items for sale)                   │
│             ADDRESS               │    │                         │
│         (Shipping/Billing)        │    │                         │
│                                   │    │                         │
│                              (N:1) │    │ (N:M)                  │
│                                   ▼    ▼                         │
│                              CATEGORY  SUPPLIER                  │
│                              (Groups)  (Vendors)                 │
│                                                                     │
│                                                                    │
│   INVENTORY (Product stock tracking) - 1:1 with PRODUCT          │
│   PAYMENT (Payment records) - N:1 with ORDER                     │
│   REVIEW (Customer reviews) - N:1 with PRODUCT                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P2.7.2 Understanding Relationships in ScaleCart

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCALECART RELATIONSHIPS                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   1. Customer → Order (1:N)                                      │
│      • One customer can place many orders                        │
│      • Each order belongs to one customer                        │
│                                                                     │
│   2. Order → Order_Item (1:N)                                   │
│      • One order can have many items                              │
│      • Each item belongs to one order                            │
│                                                                     │
│   3. Product → Order_Item (1:N)                                 │
│      • One product can appear in many orders                     │
│      • Each order item references one product                    │
│                                                                     │
│   4. Category → Product (1:N)                                   │
│      • One category can have many products                       │
│      • Each product belongs to one category                      │
│                                                                     │
│   5. Supplier → Product (N:M)                                    │
│      • One product can be supplied by many suppliers             │
│      • One supplier can supply many products                     │
│      • Junction table: supplier_products                        │
│                                                                     │
│   6. Product → Inventory (1:1)                                  │
│      • Each product has one inventory record                     │
│      • Each inventory record belongs to one product              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P2.8 Practice Exercise

### P2.8.1 Identify Entities and Relationships

**Scenario:** You're designing a simple library system.

**Requirements:**
- The library has books
- Books have authors (a book can have multiple authors)
- Books have publishers
- Patrons can borrow books
- Each book has a due date when borrowed

**Try to identify:**
1. What are the entities?
2. What are the relationships?
3. What are the attributes for each entity?

**Answer:**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    LIBRARY DATABASE DESIGN                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ENTITIES:                                                       │
│   • BOOK                                                         │
│   • AUTHOR                                                       │
│   • PUBLISHER                                                    │
│   • PATRON                                                       │
│   • LOAN                                                         │
│                                                                     │
│   RELATIONSHIPS:                                                 │
│   • Book ───(N:M)─── Author                                    │
│     (One book can have many authors,                             │
│      one author can write many books)                            │
│                                                                     │
│   • Book ───(N:1)─── Publisher                                 │
│     (One publisher can publish many books,                       │
│      each book has one publisher)                                │
│                                                                     │
│   • Patron ───(1:N)─── Loan                                    │
│     (One patron can borrow many books,                           │
│      each loan belongs to one patron)                           │
│                                                                     │
│   • Book ───(1:N)─── Loan                                      │
│     (One book can be borrowed many times,                        │
│      each loan references one book)                             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P2.9 Glossary of New Terms

| Term | Definition |
|------|------------|
| **Relational Database** | A database organized into tables related by keys |
| **Entity** | A real-world object or concept in the database |
| **Attribute** | A property of an entity |
| **Relationship** | How entities are connected to each other |
| **ERD** | Entity-Relationship Diagram (visual representation) |
| **Cardinality** | The number of entities in a relationship (1:1, 1:N, N:M) |
| **Normalization** | Process of organizing data to reduce redundancy |
| **Junction Table** | Table used to implement many-to-many relationships |
| **1NF** | First Normal Form (atomic values, no repeating groups) |
| **2NF** | Second Normal Form (full dependency on primary key) |
| **3NF** | Third Normal Form (no transitive dependencies) |
| **BCNF** | Boyce-Codd Normal Form (stricter version of 3NF) |

---

## P2.10 Summary

### P2.10.1 Key Takeaways

1. **Relational databases** organize data into related tables, reducing redundancy and improving consistency.

2. **Entities** are the "things" we track (customers, products, orders).

3. **Attributes** are the details we store about entities (name, price, date).

4. **Relationships** connect entities:
   - **1:1** – Rare, like product → inventory
   - **1:N** – Most common, like customer → orders
   - **N:M** – Requires junction table, like product → supplier

5. **Normalization** is the process of eliminating redundancy:
   - **1NF**: Atomic values
   - **2NF**: Full key dependency
   - **3NF**: No transitive dependencies

6. **ERDs** help visualize the database structure before building it.

### P2.10.2 What's Next?

Now that you understand relational database design, you're ready for:

**Primer 3: Introduction to SQL Performance**
- What makes queries fast or slow
- Introduction to indexes
- Basic query optimization techniques

**Part 1 of the Main Series: Foundations of Relational Database Design**
- Complete modeling of ScaleCart
- Full normalization process
- Building the actual database schema

---

**[END OF PRIMER 2]**

*This is the second of three primers. Once you're comfortable with these concepts, proceed to Primer 3 to learn about performance.*
