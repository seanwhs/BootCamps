# Appendix L: Final Capstone Exercise

This is the culminating exercise of the series. It is deliberately broad and realistic. Completing it well requires you to apply concepts from every major part: foundations, networking, storage, caching, reliability, security, and production operations.

Treat it as a take-home design review or a final interview-style project. Allocate 2–3 hours for a thorough version (or 45–60 minutes for a timed interview simulation).

---

## The Prompt

**Design a multi-tenant, real-time collaborative task management platform** (think a simplified hybrid of Trello + Asana + linear-style issue tracking with live updates).

### Core Product Requirements

- Users belong to **workspaces** (tenants).  
- Inside a workspace, users create **projects**, and inside projects they create **tasks**.  
- Tasks have: title, description, status, assignee, due date, labels, comments, and activity history.  
- Users can **collaborate in real time**: when one user moves a task or edits a field, other members of the same project should see the change within ~1 second.  
- Support **@mentions** and **notifications** (in-app + email).  
- Support **file attachments** on tasks (up to 25 MB per file).  
- Users can **search** across projects they have access to (title, description, comments).  
- The system must support both a web application and mobile clients.

### Non-Functional Requirements & Scale Targets

- 50 000 workspaces (tenants).  
- Average 20 active users per workspace.  
- Peak concurrent connected users: 150 000.  
- Peak task-update rate: 8 000 updates/second globally.  
- Read-heavy overall (timeline/board views, search, activity feeds).  
- Strong consistency for task mutations within a project.  
- Eventual consistency acceptable for secondary views (search index, cross-project dashboards, notification fan-out).  
- Target latency:  
  - Task read / board load: < 150 ms p99  
  - Real-time update propagation: < 1 s  
  - Search: < 300 ms p99  
- Availability target: 99.9 % for core task operations.  
- Multi-region active-active is desirable but not required for the first version; justify your choice.

### Explicit Constraints

- You may use any common cloud services or open-source technologies.  
- You must justify major technology choices.  
- You must address multi-tenancy isolation (noisy-neighbor and data isolation concerns).  
- Security, authentication, and authorization are in scope.  
- Assume you have a small platform team (not unlimited headcount).

### Deliverables

Produce the following:

1. **Clarified requirements & assumptions** (including anything you added or explicitly deferred).  
2. **Back-of-the-envelope estimates** (QPS, storage, bandwidth, concurrent connections).  
3. **High-level architecture diagram** (textual or described clearly) with primary data flows.  
4. **Data model** and partitioning/sharding strategy.  
5. **Real-time collaboration design** (how you achieve low-latency live updates).  
6. **Search design**.  
7. **Notification & activity-feed design**.  
8. **File attachment handling**.  
9. **Multi-tenancy & isolation approach**.  
10. **Consistency model** decisions for each major piece of data.  
11. **Failure modes & mitigations** (at least 4–5 significant ones).  
12. **Security design** (authn, authz, tenant isolation, secrets).  
13. **Observability & SLOs**.  
14. **Deployment / rollout & migration considerations**.  
15. **Evolution path** — what changes when the system grows 5–10×.  
16. **Key trade-offs** you made and alternatives you rejected.

---

## Recommended Approach (Mirror the Series Framework)

1. **Clarify & Scope** (15–20 min)  
   Write down functional + non-functional requirements and your assumptions. Explicitly list what you are deferring.

2. **Estimates** (10–15 min)  
   Calculate peak QPS for task reads/writes, concurrent WebSocket connections, storage growth, and search index size.

3. **High-Level Design** (20–25 min)  
   Draw the major components and the primary flows (task mutation, real-time fan-out, search indexing, notification path, file upload).

4. **Deep Dives** (45–60 min)  
   Spend serious time on:  
   - Real-time delivery mechanism  
   - Data model + partitioning (especially tenant isolation)  
   - Consistency boundaries  
   - Search and secondary indexes  
   - Failure handling and multi-tenancy protections

5. **Trade-offs, Evolution, Production** (20–30 min)  
   Explicit trade-offs, how the system grows, observability, security, and deployment strategy.

---

## Evaluation Rubric (Self-Score or Peer Review)

Use the same dimensions from Appendix D, with extra weight on the areas this prompt stresses:

| Dimension | Weight | Capstone-specific expectations |
|-----------|--------|--------------------------------|
| Requirements & Scoping | 8 | Clear handling of multi-tenancy and real-time requirements |
| Estimation & Scale | 10 | Reasonable numbers for connections, update rate, storage |
| High-Level Design | 15 | Coherent end-to-end flows including real-time path |
| Depth on Critical Areas | 25 | Strong treatment of real-time, consistency, isolation, search |
| Scalability & Reliability | 15 | Partitioning, hot-tenant protection, failure modes |
| Trade-offs & Alternatives | 12 | Explicit discussion of consistency, fan-out, storage choices |
| Security & Multi-tenancy | 8 | Authz model, tenant isolation, noisy-neighbor defenses |
| Communication / Clarity | 7 | Readable structure, clear diagram description, justified decisions |

**Target**: 80+ indicates solid senior/staff-level command of the material in this series.

---

## Hidden Focus Areas (Look Only After You Finish)

- How you prevent a single large tenant from affecting others (noisy-neighbor protection at multiple layers).  
- Exact mechanism for real-time updates (WebSockets vs SSE vs polling, connection management, fan-out).  
- Whether task mutations are strongly consistent and how you enforce that across services.  
- How search stays reasonably fresh without destroying the write path.  
- Authorization model (workspace roles, project-level permissions, and how they are enforced efficiently).  
- Handling of very large projects or very high-churn boards.  
- File upload path (direct-to-object-storage vs proxied) and virus scanning / access control.  
- Observability that can answer “why did this tenant’s real-time updates become slow?”  

---

## Stretch Goals (Optional)

If you finish early or want extra depth:

- Design a cross-workspace analytics pipeline (usage metrics, without violating tenant isolation).  
- Add offline support / conflict resolution for mobile clients.  
- Design the migration path from a single-region to multi-region active-active deployment.  
- Propose an SLO + error-budget policy and the alerts that would protect it.

---

## After-Action Review

Once you complete the design, answer these questions in writing:

1. Which parts of the series did you lean on most heavily?  
2. Which areas still felt weakest or most hand-wavy?  
3. What would you want to prototype first to de-risk the design?  
4. If you had to cut scope for an MVP that still delivers core value, what would you cut and why?

---

This capstone is intentionally demanding. A complete, well-reasoned answer demonstrates that you can integrate the full stack of concerns covered in the series — from first principles and data modeling through real-time systems, multi-tenancy, reliability, security, and operational reality.

When you can produce a solid response to this prompt under reasonable time constraints, you have internalized the material at a senior/staff level.

**[END OF APPENDIX L – Final Capstone Exercise]**
