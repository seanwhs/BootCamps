# Serverless Postgres with Neon: From Zero to Production
## References & Resources Guide

### Overview

This comprehensive reference guide consolidates all the resources, documentation, tools, and further reading materials you'll need throughout the course and beyond. Use this as your go-to reference for finding answers, exploring advanced topics, and staying up-to-date with the latest developments in PostgreSQL and Neon.

---

## TABLE OF CONTENTS

1. [Neon Resources](#neon-resources)
2. [PostgreSQL Resources](#postgresql-resources)
3. [SQL Learning Resources](#sql-learning-resources)
4. [Development Tools](#development-tools)
5. [Database Design Resources](#database-design-resources)
6. [Performance & Optimization](#performance-optimization)
7. [Security Resources](#security-resources)
8. [CI/CD & DevOps Resources](#cicd-devops-resources)
9. [Community & Support](#community-support)
10. [Books & Publications](#books-publications)
11. [Online Courses & Tutorials](#online-courses)
12. [Code Examples & Repositories](#code-examples)
13. [Cheat Sheets & Quick References](#cheat-sheets)
14. [Browser Extensions & Tools](#browser-extensions)
15. [Glossary & Acronyms](#glossary-acronyms)
16. [My Personal Resource Collection](#personal-collection)

---

## NEON RESOURCES {#neon-resources}

### Official Documentation

| Resource | URL | Description |
|----------|-----|-------------|
| **Neon Documentation** | https://neon.tech/docs | Complete official documentation |
| **Neon Getting Started** | https://neon.tech/docs/get-started-with-neon | Quick start guide |
| **Neon Connection Guide** | https://neon.tech/docs/connect/connect | Connection string reference |
| **Neon Branching** | https://neon.tech/docs/guides/branching | Database branching documentation |
| **Neon Connection Pooling** | https://neon.tech/docs/connect/connection-pooling | Connection pooler documentation |
| **Neon CLI Reference** | https://neon.tech/docs/reference/cli | CLI command reference |
| **Neon API Reference** | https://neon.tech/docs/reference/api | REST API documentation |
| **Neon Pricing** | https://neon.tech/pricing | Pricing plans and details |
| **Neon Status** | https://status.neon.tech | Service status dashboard |

### Neon Blog & Updates

| Resource | URL | Description |
|----------|-----|-------------|
| **Neon Blog** | https://neon.tech/blog | Product updates and tutorials |
| **Neon Changelog** | https://neon.tech/changelog | Recent changes and features |
| **Neon Twitter** | https://twitter.com/neondatabase | Latest updates |
| **Neon YouTube** | https://youtube.com/@neon_tech | Video tutorials |

### Neon Reference Architectures

| Resource | URL | Description |
|----------|-----|-------------|
| **E-Commerce Template** | https://neon.tech/docs/templates/ecommerce | E-commerce reference |
| **SaaS Template** | https://neon.tech/docs/templates/saas | SaaS application template |
| **Real-time Analytics** | https://neon.tech/docs/templates/analytics | Analytics reference |
| **Branching Workflows** | https://neon.tech/docs/guides/branching-workflows | Advanced branching patterns |

---

## POSTGRESQL RESOURCES {#postgresql-resources}

### Official PostgreSQL Documentation

| Resource | URL | Description |
|----------|-----|-------------|
| **PostgreSQL Official Docs** | https://www.postgresql.org/docs/ | Complete reference |
| **PostgreSQL Tutorial** | https://www.postgresql.org/docs/tutorial.html | Beginner tutorial |
| **PostgreSQL SQL Language** | https://www.postgresql.org/docs/sql.html | SQL reference |
| **PostgreSQL Functions** | https://www.postgresql.org/docs/functions.html | Function reference |
| **PostgreSQL Indexes** | https://www.postgresql.org/docs/indexes.html | Indexing guide |
| **PostgreSQL Transactions** | https://www.postgresql.org/docs/transaction-iso.html | Transaction documentation |
| **PostgreSQL Extensions** | https://www.postgresql.org/docs/contrib.html | Extension reference |

### PostgreSQL Versions

| Version | Release Date | End of Support | Notes |
|---------|--------------|----------------|-------|
| PostgreSQL 17 | Sept 2024 | Nov 2029 | Latest version |
| PostgreSQL 16 | Sept 2023 | Nov 2028 | Current stable |
| PostgreSQL 15 | Oct 2022 | Nov 2027 | Well-supported |
| PostgreSQL 14 | Sept 2021 | Nov 2026 | Legacy support |

### PostgreSQL Tools & Utilities

| Tool | URL | Description |
|------|-----|-------------|
| **pgAdmin** | https://www.pgadmin.org | GUI administration tool |
| **psql** | https://www.postgresql.org/docs/current/app-psql.html | Command-line tool |
| **pg_dump** | https://www.postgresql.org/docs/current/app-pgdump.html | Backup tool |
| **pg_restore** | https://www.postgresql.org/docs/current/app-pgrestore.html | Restore tool |
| **pg_stat_statements** | https://www.postgresql.org/docs/current/pgstatstatements.html | Query performance |
| **pg_cron** | https://github.com/citusdata/pg_cron | Scheduled jobs |
| **pg_trgm** | https://www.postgresql.org/docs/current/pgtrgm.html | Fuzzy search |
| **pgcrypto** | https://www.postgresql.org/docs/current/pgcrypto.html | Encryption |
| **btree_gin** | https://www.postgresql.org/docs/current/btree-gin.html | Index extensions |
| **uuid-ossp** | https://www.postgresql.org/docs/current/uuid-ossp.html | UUID generation |

---

## SQL LEARNING RESOURCES {#sql-learning-resources}

### Interactive SQL Learning

| Resource | URL | Description |
|----------|-----|-------------|
| **SQLZoo** | https://sqlzoo.net | Interactive tutorials |
| **W3Schools SQL** | https://www.w3schools.com/sql | Beginner-friendly reference |
| **Mode Analytics SQL** | https://mode.com/sql-tutorial | Business-oriented SQL |
| **Khan Academy SQL** | https://www.khanacademy.org/computing/computer-programming/sql | Video tutorials |
| **Codecademy SQL** | https://www.codecademy.com/learn/learn-sql | Interactive course |
| **SQL Fiddle** | http://sqlfiddle.com | Online SQL playground |
| **DB Fiddle** | https://www.db-fiddle.com | SQL sandbox environment |
| **PostgreSQL Online** | https://sqlfiddle.com/postgresql | PostgreSQL online playground |

### Advanced SQL Topics

| Resource | URL | Description |
|----------|-----|-------------|
| **PostgreSQL Query Optimization** | https://www.postgresql.org/docs/current/performance-tips.html | Performance guide |
| **Window Functions Tutorial** | https://www.postgresql.org/docs/current/tutorial-window.html | Window function guide |
| **Common Table Expressions** | https://www.postgresql.org/docs/current/queries-with.html | CTE documentation |
| **Recursive Queries** | https://www.postgresql.org/docs/current/queries-with.html#QUERIES-WITH-RECURSIVE | Recursive CTE guide |
| **JSON Functions** | https://www.postgresql.org/docs/current/functions-json.html | JSONB function reference |

### SQL Pattern Libraries

| Resource | URL | Description |
|----------|-----|-------------|
| **SQL for Data Analysis** | https://github.com/josephmisiti/awesome-sql | SQL resources collection |
| **SQL Style Guide** | https://www.sqlstyle.guide | SQL best practices |
| **Awesome PostgreSQL** | https://github.com/dhamaniasad/awesome-postgres | PostgreSQL resources |

---

## DEVELOPMENT TOOLS {#development-tools}

### Database GUIs

| Tool | URL | Description | Platform |
|------|-----|-------------|----------|
| **DBeaver** | https://dbeaver.io | Universal database tool | Windows, Mac, Linux |
| **DataGrip** | https://www.jetbrains.com/datagrip | JetBrains IDE | Windows, Mac, Linux |
| **pgAdmin** | https://www.pgadmin.org | PostgreSQL specific | Windows, Mac, Linux |
| **TablePlus** | https://tableplus.com | Modern database GUI | Windows, Mac |
| **Beekeeper Studio** | https://www.beekeeperstudio.io | Open-source SQL client | Windows, Mac, Linux |
| **Postico** | https://eggerapps.at/postico | Mac PostgreSQL client | Mac |
| **Navicat** | https://www.navicat.com | Advanced database tool | Windows, Mac, Linux |
| **HeidiSQL** | https://www.heidisql.com | Lightweight client | Windows |

### Node.js/JavaScript Tools

| Tool | URL | Description |
|------|-----|-------------|
| **node-postgres (pg)** | https://node-postgres.com | PostgreSQL client for Node.js |
| **Knex.js** | https://knexjs.org | SQL query builder |
| **Prisma** | https://www.prisma.io | ORM for Node.js |
| **TypeORM** | https://typeorm.io | TypeScript ORM |
| **Sequelize** | https://sequelize.org | Node.js ORM |
| **Postgres.js** | https://github.com/porsager/postgres | Fast PostgreSQL client |
| **Slonik** | https://github.com/gajus/slonik | PostgreSQL client with utilities |

### Python Tools

| Tool | URL | Description |
|------|-----|-------------|
| **psycopg2** | https://www.psycopg.org | PostgreSQL adapter for Python |
| **SQLAlchemy** | https://www.sqlalchemy.org | Python SQL toolkit |
| **Django ORM** | https://docs.djangoproject.com/en/stable/topics/db | Django database layer |
| **asyncpg** | https://github.com/MagicStack/asyncpg | Async PostgreSQL client |
| **PyGreSQL** | https://www.pygresql.org | PostgreSQL client for Python |

### Other Language Tools

| Tool | Language | URL |
|------|----------|-----|
| **pq** | Go | https://github.com/lib/pq |
| **Rust-Postgres** | Rust | https://github.com/sfackler/rust-postgres |
| **JDBC** | Java | https://jdbc.postgresql.org |
| **NPGSQL** | .NET | https://www.npgsql.org |
| **Ruby-PG** | Ruby | https://bitbucket.org/ged/ruby-pg |

### IDE Extensions

| Extension | IDE | URL | Description |
|-----------|-----|-----|-------------|
| **SQLTools** | VS Code | https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools | SQL client for VS Code |
| **PostgreSQL** | VS Code | https://marketplace.visualstudio.com/items?itemName=ckolkman.vscode-postgres | PostgreSQL support |
| **Database Client** | VS Code | https://marketplace.visualstudio.com/items?itemName=cweijan.vscode-database-client2 | Universal database client |
| **SQL Plugin** | IntelliJ | Built-in | Database tools for IntelliJ |
| **Database Navigator** | Sublime | Built-in | Database plugin for Sublime |

---

## DATABASE DESIGN RESOURCES {#database-design-resources}

### Design Theory

| Resource | URL | Description |
|----------|-----|-------------|
| **Database Normalization** | https://www.guru99.com/database-normalization.html | Normalization guide |
| **ERD Tutorial** | https://www.lucidchart.com/pages/er-diagrams | Entity Relationship Diagrams |
| **Database Design Best Practices** | https://www.vertabelo.com/blog/database-design-best-practices | Design guidelines |
| **Data Modeling 101** | https://www.agiledata.org/essays/dataModeling101.html | Data modeling fundamentals |

### Diagramming Tools

| Tool | URL | Description | Platform |
|------|-----|-------------|----------|
| **Lucidchart** | https://www.lucidchart.com | Online diagram tool | Web |
| **Draw.io** | https://draw.io | Free diagram tool | Web, Desktop |
| **DBDiagram** | https://dbdiagram.io | Database diagram tool | Web |
| **DbSchema** | https://dbschema.com | Visual database designer | Windows, Mac, Linux |
| **SQLDBM** | https://sqldbm.com | Online database modeling | Web |
| **Vertabelo** | https://www.vertabelo.com | Online database design | Web |

---

## PERFORMANCE & OPTIMIZATION {#performance-optimization}

### Performance Tuning

| Resource | URL | Description |
|----------|-----|-------------|
| **PostgreSQL Performance Tuning** | https://www.postgresql.org/docs/current/performance-tips.html | Official guide |
| **PostgreSQL Explain** | https://www.postgresql.org/docs/current/using-explain.html | EXPLAIN guide |
| **pganalyze** | https://pganalyze.com | Performance monitoring |
| **pg_stat_statements** | https://www.postgresql.org/docs/current/pgstatstatements.html | Query statistics |
| **PostgreSQL Indexing** | https://use-the-index-luke.com/postgresql | Indexing guide |
| **VACUUM Guide** | https://www.postgresql.org/docs/current/routine-vacuuming.html | VACUUM documentation |

### Query Optimization

| Resource | URL | Description |
|----------|-----|-------------|
| **SQL Performance Explained** | https://use-the-index-luke.com | SQL performance guide |
| **PostgreSQL Query Optimization** | https://pgexplain.io | Visual EXPLAIN tool |
| **Explain.depesz.com** | https://explain.depesz.com | EXPLAIN output viewer |
| **Slow Query Log** | https://www.postgresql.org/docs/current/runtime-config-logging.html | Logging configuration |

### Monitoring Tools

| Tool | URL | Description |
|------|-----|-------------|
| **Prometheus** | https://prometheus.io | Metrics collection |
| **Grafana** | https://grafana.com | Visualization dashboard |
| **Datadog** | https://www.datadog.com | Monitoring platform |
| **New Relic** | https://newrelic.com | Application monitoring |
| **pgBadger** | https://github.com/dalibo/pgbadger | Log analyzer |
| **pg_top** | https://github.com/MarkKrause/pg_top | Real-time monitoring |

---

## SECURITY RESOURCES {#security-resources}

### PostgreSQL Security

| Resource | URL | Description |
|----------|-----|-------------|
| **PostgreSQL Security** | https://www.postgresql.org/docs/current/security.html | Official guide |
| **Row Level Security** | https://www.postgresql.org/docs/current/ddl-rowsecurity.html | RLS documentation |
| **Password Encryption** | https://www.postgresql.org/docs/current/password-encryption.html | Password hashing |
| **SSL Configuration** | https://www.postgresql.org/docs/current/ssl-tcp.html | SSL/TLS setup |

### Security Best Practices

| Resource | URL | Description |
|----------|-----|-------------|
| **SQL Injection Prevention** | https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html | OWASP guide |
| **Database Security Checklist** | https://www.enterprisedb.com/blog/postgresql-security-checklist | Security checklist |
| **Data Encryption** | https://www.postgresql.org/docs/current/encryption.html | Encryption guide |
| **Audit Logging** | https://www.postgresql.org/docs/current/event-triggers.html | Audit triggers |

---

## CICD & DEVOPS RESOURCES {#cicd-devops-resources}

### GitHub Actions

| Resource | URL | Description |
|----------|-----|-------------|
| **GitHub Actions Docs** | https://docs.github.com/en/actions | Official documentation |
| **GitHub Actions for PostgreSQL** | https://github.com/marketplace/actions/postgresql-github-action | PostgreSQL actions |
| **Neon GitHub Action** | https://github.com/marketplace/actions/neon-branch | Neon branching action |
| **Workflow Examples** | https://docs.github.com/en/actions/examples | Example workflows |

### CI/CD Platforms

| Platform | URL | Description |
|----------|-----|-------------|
| **GitHub Actions** | https://github.com/features/actions | CI/CD platform |
| **GitLab CI/CD** | https://docs.gitlab.com/ee/ci | GitLab CI/CD |
| **Vercel** | https://vercel.com | Frontend deployment |
| **Netlify** | https://www.netlify.com | Web deployment |
| **AWS CodePipeline** | https://aws.amazon.com/codepipeline | AWS CI/CD |
| **Azure DevOps** | https://azure.microsoft.com/en-us/services/devops | Microsoft CI/CD |

### Automation Tools

| Tool | URL | Description |
|------|-----|-------------|
| **Terraform** | https://www.terraform.io | Infrastructure as Code |
| **Ansible** | https://www.ansible.com | Configuration management |
| **Docker** | https://www.docker.com | Containerization |
| **Kubernetes** | https://kubernetes.io | Container orchestration |
| **Helm** | https://helm.sh | Kubernetes package manager |

---

## COMMUNITY & SUPPORT {#community-support}

### Official Communities

| Resource | URL | Description |
|----------|-----|-------------|
| **Neon Discord** | https://discord.gg/neon | Neon community |
| **Neon GitHub** | https://github.com/neondatabase/neon | Neon open source |
| **PostgreSQL Community** | https://www.postgresql.org/community | PostgreSQL community |
| **PostgreSQL Mailing Lists** | https://www.postgresql.org/list | Mailing lists |
| **PostgreSQL IRC** | https://www.postgresql.org/community/irc | IRC chat |

### Forums & Q&A

| Resource | URL | Description |
|----------|-----|-------------|
| **Stack Overflow** | https://stackoverflow.com/questions/tagged/postgresql | PostgreSQL Q&A |
| **DBA Stack Exchange** | https://dba.stackexchange.com/questions/tagged/postgresql | Database Q&A |
| **Reddit r/PostgreSQL** | https://www.reddit.com/r/PostgreSQL | PostgreSQL subreddit |
| **Neon Community** | https://github.com/orgs/neondatabase/discussions | Neon discussions |

### News & Updates

| Resource | URL | Description |
|----------|-----|-------------|
| **PostgreSQL Weekly** | https://postgresweekly.com | Weekly newsletter |
| **Planet PostgreSQL** | https://planet.postgresql.org | Blog aggregation |
| **PostgreSQL News** | https://www.postgresql.org/about/news | Official news |
| **Neon Twitter** | https://twitter.com/neondatabase | Neon updates |

---

## BOOKS & PUBLICATIONS {#books-publications}

### Recommended Books

| Title | Author | ISBN | Description |
|-------|--------|------|-------------|
| **PostgreSQL 16 Administration Cookbook** | Simon Riggs, Gianni Ciolli | 978-1803241320 | Administration guide |
| **SQL for Data Analysis** | Cathy Tanimura | 978-1492088764 | SQL for analytics |
| **The Art of PostgreSQL** | Dimitri Fontaine | 979-8612488037 | PostgreSQL advanced |
| **PostgreSQL Up and Running** | Regina Obe, Leo Hsu | 978-1491963401 | Practical guide |
| **Mastering PostgreSQL** | Hans-Jürgen Schönig | 978-1788477101 | In-depth reference |
| **Database Internals** | Alex Petrov | 978-1492040344 | Database architecture |
| **Designing Data-Intensive Applications** | Martin Kleppmann | 978-1449373320 | Distributed systems |

### Online Publications

| Resource | URL | Description |
|----------|-----|-------------|
| **PostgreSQL Documentation** | https://www.postgresql.org/docs | Official docs |
| **Use The Index Luke** | https://use-the-index-luke.com | Performance guide |
| **PgFriendly** | https://www.pgfriendly.com | PostgreSQL blog |
| **Cybertec Blog** | https://www.cybertec-postgresql.com/en/blog | PostgreSQL blog |
| **Percona Blog** | https://www.percona.com/blog/tag/postgresql | Performance blog |

---

## ONLINE COURSES & TUTORIALS {#online-courses}

### Free Courses

| Course | Platform | URL | Description |
|--------|----------|-----|-------------|
| **SQL for Beginners** | Codecademy | https://www.codecademy.com/learn/learn-sql | Interactive SQL |
| **PostgreSQL Tutorial** | W3Schools | https://www.w3schools.com/postgresql | Basic PostgreSQL |
| **PostgreSQL Learning** | Khan Academy | https://www.khanacademy.org/computing/computer-programming/sql | Video lessons |
| **PostgreSQL Bootcamp** | YouTube | https://youtube.com/watch?v=qw--VYLpxG4 | Video series |

### Paid Courses

| Course | Platform | URL | Description |
|--------|----------|-----|-------------|
| **The Complete SQL Bootcamp** | Udemy | https://www.udemy.com/course/the-complete-sql-bootcamp | Comprehensive SQL |
| **PostgreSQL Bootcamp** | Udemy | https://www.udemy.com/course/postgresql-bootcamp | PostgreSQL specific |
| **Advanced PostgreSQL** | Coursera | https://www.coursera.org/learn/postgresql-advanced | Advanced concepts |
| **PostgreSQL for Developers** | Pluralsight | https://www.pluralsight.com/courses/postgresql-developer | Developer-focused |

### YouTube Channels

| Channel | URL | Description |
|---------|-----|-------------|
| **Neon Tech** | https://youtube.com/@neon_tech | Neon tutorials |
| **PostgreSQL** | https://youtube.com/@postgresql | Official videos |
| **Coding Tech** | https://youtube.com/@CodingTech | Conference talks |
| **freeCodeCamp** | https://youtube.com/@freecodecamp | Full courses |

---

## CODE EXAMPLES & REPOSITORIES {#code-examples}

### Sample Projects

| Repository | URL | Description |
|------------|-----|-------------|
| **Neon E-Commerce** | https://github.com/neondatabase/examples/tree/main/e-commerce | Official example |
| **Neon Next.js Starter** | https://github.com/neondatabase/next.js-starter | Next.js with Neon |
| **Express Postgres Template** | https://github.com/neondatabase/express-postgres-starter | Express API template |
| **Django Neon Starter** | https://github.com/neondatabase/django-neon-starter | Django with Neon |

### Boilerplates

| Repository | URL | Description |
|------------|-----|-------------|
| **Modern SQL Boilerplate** | https://github.com/neondatabase/sql-boilerplate | SQL project starter |
| **Serverless Postgres** | https://github.com/neondatabase/serverless-app | Serverless template |
| **Neon Lambda** | https://github.com/neondatabase/neon-lambda | AWS Lambda with Neon |

### Practice Datasets

| Resource | URL | Description |
|----------|-----|-------------|
| **PostgreSQL Sample Data** | https://www.postgresqltutorial.com/postgresql-sample-database | Official samples |
| **Kaggle Datasets** | https://www.kaggle.com/datasets | Real datasets |
| **GitHub Datasets** | https://github.com/awesomedata/awesome-public-datasets | Public datasets |

---

## CHEAT SHEETS & QUICK REFERENCES {#cheat-sheets}

### PostgreSQL Cheat Sheets

| Resource | URL | Description |
|----------|-----|-------------|
| **PostgreSQL Cheat Sheet** | https://www.postgresqltutorial.com/postgresql-cheat-sheet | Quick reference |
| **SQL Command Cheat Sheet** | https://www.geeksforgeeks.org/sql-cheat-sheet | SQL commands |
| **psql Cheat Sheet** | https://www.postgresql.org/docs/current/app-psql.html | psql commands |
| **Index Cheat Sheet** | https://www.postgresql.org/docs/current/indexes.html | Index reference |

### Keyboard Shortcuts

| Tool | Resource | URL |
|------|----------|-----|
| **VS Code SQL** | https://code.visualstudio.com/docs/languages/sql | VS Code shortcuts |
| **DataGrip** | https://www.jetbrains.com/help/datagrip/mastering-keyboard-shortcuts.html | DataGrip shortcuts |
| **pgAdmin** | https://www.pgadmin.org/docs/pgadmin4/latest/keyboard_shortcuts.html | pgAdmin shortcuts |

---

## BROWSER EXTENSIONS & TOOLS {#browser-extensions}

### Chrome Extensions

| Extension | URL | Description |
|-----------|-----|-------------|
| **SQL Formatter** | https://chrome.google.com/webstore/detail/sql-formatter | SQL formatting |
| **PostgreSQL Manager** | https://chrome.google.com/webstore/detail/postgresql-manager | Management tool |
| **JSON Viewer** | https://chrome.google.com/webstore/detail/json-viewer | JSON formatting |

### Online SQL Tools

| Tool | URL | Description |
|------|-----|-------------|
| **Explain.depesz** | https://explain.depesz.com | EXPLAIN formatter |
| **PostgreSQL Explain** | https://explain.dalibo.com | Visual EXPLAIN |
| **SQLPad** | https://sqlpad.io | SQL playground |
| **DBDiagram** | https://dbdiagram.io | ER diagramming |

---

## GLOSSARY & ACRONYMS {#glossary-acronyms}

### Common PostgreSQL Terms

| Term | Definition |
|------|------------|
| **ACID** | Atomicity, Consistency, Isolation, Durability |
| **CTE** | Common Table Expression (WITH clause) |
| **DDL** | Data Definition Language (CREATE, ALTER, DROP) |
| **DML** | Data Manipulation Language (INSERT, UPDATE, DELETE) |
| **DCL** | Data Control Language (GRANT, REVOKE) |
| **GIN** | Generalized Inverted Index |
| **BRIN** | Block Range Index |
| **MVCC** | Multi-Version Concurrency Control |
| **RLS** | Row Level Security |
| **TOAST** | The Oversized-Attribute Storage Technique |
| **WAL** | Write-Ahead Logging |
| **JSONB** | Binary JSON Storage |

### Neon-Specific Terms

| Term | Definition |
|------|------------|
| **Branch** | An instant copy of your database |
| **Compute** | The processing resources for your database |
| **Endpoint** | The connection point for your database |
| **Pooler** | Connection pooling service |
| **PITR** | Point-In-Time Recovery |
| **Storage** | S3-backed persistent storage |

### Acronyms

| Acronym | Full Form |
|---------|-----------|
| **API** | Application Programming Interface |
| **CI/CD** | Continuous Integration / Continuous Deployment |
| **CLI** | Command Line Interface |
| **CORS** | Cross-Origin Resource Sharing |
| **CRUD** | Create, Read, Update, Delete |
| **ERD** | Entity Relationship Diagram |
| **FK** | Foreign Key |
| **HTTP** | Hypertext Transfer Protocol |
| **IDE** | Integrated Development Environment |
| **JSON** | JavaScript Object Notation |
| **ORM** | Object-Relational Mapping |
| **PK** | Primary Key |
| **PR** | Pull Request |
| **RDS** | Relational Database Service |
| **REST** | Representational State Transfer |
| **SDK** | Software Development Kit |
| **SSL** | Secure Sockets Layer |
| **SaaS** | Software as a Service |
| **SQL** | Structured Query Language |
| **SSH** | Secure Shell |
| **TLS** | Transport Layer Security |
| **UUID** | Universally Unique Identifier |

---

## MY PERSONAL RESOURCE COLLECTION {#personal-collection}

### Useful URLs I Keep Handy

```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

### Favorite Code Snippets

```sql
-- Add your favorite snippets here
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

### Books I Want to Read

```
1. _______________________________________________________________________
2. _______________________________________________________________________
3. _______________________________________________________________________
```

### People to Follow

```
1. _______________________________________________________________________
2. _______________________________________________________________________
3. _______________________________________________________________________
```

### Upcoming Conferences

```
1. _______________________________________________________________________
2. _______________________________________________________________________
3. _______________________________________________________________________
```

---

## QUICK REFERENCE CARDS

### Connection String Template
```
postgresql://[user]:[password]@[host]:[port]/[database]?sslmode=require
```

### Common CLI Commands
```bash
# Neon
neonctl auth
neonctl branches create --name branch-name --parent main
neonctl branches get-connection-string branch-name
neonctl branches merge branch-name --target main

# psql
psql "$DATABASE_URL"
\l
\dt
\d table_name
\q

# PostgreSQL
pg_dump "$DATABASE_URL" > backup.sql
psql "$DATABASE_URL" < backup.sql
```

### Key SQL Patterns
```sql
-- Pagination
SELECT * FROM table ORDER BY id LIMIT 20 OFFSET 40;

-- Upsert
INSERT INTO table (id, name) VALUES (1, 'value')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- Window Function
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rank
FROM products;

-- CTE
WITH cte AS (
    SELECT * FROM table WHERE condition
)
SELECT * FROM cte;
```

### Ports & Services
| Service | Port |
|---------|------|
| PostgreSQL | 5432 |
| Neon Pooler | 5432 |
| pgAdmin | 5050 |
| Grafana | 3000 |
| Prometheus | 9090 |

---

## COURSE RESOURCES INDEX

| Resource | Location |
|----------|----------|
| Slide Deck | [Link] |
| Workbook | [Link] |
| Notes | [Link] |
| Quizzes | [Link] |
| Projects | [Link] |
| Code Examples | [Link] |

---

## NOTES

```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

**[END OF REFERENCES & RESOURCES GUIDE]**

*Keep this guide handy throughout the course and beyond. It's your gateway to the wider PostgreSQL and Neon ecosystem!* 📚
