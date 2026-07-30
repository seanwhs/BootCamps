## Mastering AI Integration with MCP and A2A Using JavaScript

---

# SERIES INTRODUCTION BLOCK

## Block 0: Series Overview (15 Slides)

### Slide S0.1: Title Slide
```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│              MASTERING AI INTEGRATION WITH MCP AND A2A              │
│                     USING JAVASCRIPT                                │
│                                                                     │
│                    A 9-Stage, 36-Part Journey                      │
│                                                                     │
│              From AI Integration Fundamentals to                    │
│              Production Multi-Agent Systems                        │
│                                                                     │
│                    ═══════════════════════                          │
│                                                                     │
│                       [Presenter Name]                             │
│                       [Date/Event]                                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Welcome to the most comprehensive training series on AI integration. Over the next X hours/days, we'll transform you from an AI integration novice into an architect of intelligent, collaborative AI systems. This isn't just theory—we're building real, working systems that you can deploy in production.

---

### Slide S0.2: What This Series Will Build
```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE ULTIMATE ARCHITECTURE                        │
│                                                                     │
│  By the end of this journey, you will have built:                  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │           1. MULTIPLE MCP SERVERS                           │   │
│  │   • Filesystem operations                                   │   │
│  │   • Database queries (SQLite, PostgreSQL)                  │   │
│  │   • API integrations (GitHub, REST)                        │   │
│  │   • Development tools (Docker, Kubernetes)                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │           2. REUSABLE MCP CLIENT LIBRARY                    │   │
│  │   • Dynamic capability discovery                            │   │
│  │   • Multi-server orchestration                              │   │
│  │   • Error recovery and retry logic                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │           3. ENTERPRISE KNOWLEDGE SERVER                    │   │
│  │   • Aggregates multiple data sources                        │   │
│  │   • Unified interface for AI agents                         │   │
│  │   • Cross-source search and analysis                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
This isn't a toy project. We're building a complete enterprise-grade platform. Each component is production-ready with proper error handling, logging, and security. By the end, you'll have a system that could actually be deployed in a real organization.

---

### Slide S0.3: The System in Action
```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE SYSTEM IN ACTION                            │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                AI APPLICATION LAYER                          │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐           │   │
│  │  │  Research  │  │   Coding   │  │  Database  │           │   │
│  │  │   Agent    │◄─┼──► Agent   │◄─┼──► Agent   │           │   │
│  │  └────────────┘  └────────────┘  └────────────┘           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              ▲                                     │
│                              │                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                  A2A PROTOCOL LAYER                          │   │
│  │     Agent-to-Agent Communication & Collaboration            │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              ▲                                     │
│                              │                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                  MCP PROTOCOL LAYER                          │   │
│  │        AI-to-Tool Communication & Discovery                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              ▲                                     │
│                              │                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                EXTERNAL SYSTEMS                              │   │
│  │  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │   │
│  │  │Database│  │ GitHub │  │ Docker │  │  APIs  │           │   │
│  │  └────────┘  └────────┘  └────────┘  └────────┘           │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
This is the final architecture you'll build. Notice the clear separation of concerns: MCP handles tool access, A2A handles agent communication, and the external systems are the real-world services your AI will interact with.

---

### Slide S0.4: The Learning Journey (9 Stages)
```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE LEARNING JOURNEY                             │
│                    9 Stages, 36+ Parts                              │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ STAGE 1: UNDERSTANDING AI INTEGRATION                       │   │
│  │ Parts 1-3: MCP fundamentals, architecture, first server    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ STAGE 2: BUILDING REUSABLE MCP SERVERS                     │   │
│  │ Parts 4-7: Tools, resources, prompts, advanced features    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ STAGE 3: BUILDING INTELLIGENT MCP CLIENTS                  │   │
│  │ Parts 8-10: Discovery, invocation, multi-server orchestration│   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ STAGE 4: CONNECTING ENTERPRISE SYSTEMS                      │   │
│  │ Parts 11-14: SQLite, PostgreSQL, REST APIs, GitHub          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ STAGE 5: BUILDING AUTONOMOUS AI AGENTS                      │   │
│  │ Parts 15-18: Planning, reasoning, memory, reflection        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The series follows a carefully designed progression. Each stage builds on the previous one. By Stage 4, you'll have working enterprise integrations. By Stage 5, you'll have agents that can think and act autonomously.

---

### Slide S0.5: The Learning Journey (Continued)
```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE LEARNING JOURNEY (CONT.)                     │
│                    9 Stages, 36+ Parts                              │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ STAGE 6: AGENT-TO-AGENT (A2A) COLLABORATION                │   │
│  │ Parts 19-22: Discovery, delegation, multi-agent teams       │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ STAGE 7: MULTI-AGENT ARCHITECTURES                         │   │
│  │ Parts 23-26: Coordinator, supervisor, planner-worker        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ STAGE 8: PRODUCTION ENGINEERING                             │   │
│  │ Parts 27-30: Docker, Kubernetes, monitoring, CI/CD          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ STAGE 9: REAL-WORLD AI PROJECTS                            │   │
│  │ Parts 31-36: GitHub Assistant, DevOps Engineer, Data Analyst│   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The final stages focus on production engineering and real-world applications. This ensures you don't just understand the concepts—you can actually deploy and use these systems in production environments.

---

### Slide S0.6: Who This Is For
```
┌─────────────────────────────────────────────────────────────────────┐
│                    TARGET AUDIENCE                                  │
│                                                                     │
│  ████████████████████████████████████████████████████████████████ │
│  │                                                                   │
│  │  ✅ JavaScript/Node.js developers (intermediate level)           │
│  │  ✅ Familiar with async/await, promises, callbacks              │
│  │  ✅ Built REST APIs or CLI tools before                         │
│  │  ✅ Basic understanding of AI/LLM concepts                      │
│  │  ✅ Comfortable with terminal/command line                       │
│  │  ✅ Want to build real AI systems, not just consume them        │
│  │                                                                   │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ████████████████████████████████████████████████████████████████ │
│  │                                                                   │
│  │  ❌ NOT required: AI/ML degree                                   │
│  │  ❌ NOT required: Understanding neural networks                 │
│  │  ❌ NOT required: Prior MCP/A2A experience                     │
│  │  ❌ NOT required: TypeScript expertise                         │
│  │                                                                   │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
This series is designed for developers who build things. You don't need to be an AI researcher. You need to be comfortable writing code, debugging, and learning new concepts. All the AI-specific knowledge will be taught.

---

### Slide S0.7: What Makes This Series Different
```
┌─────────────────────────────────────────────────────────────────────┐
│                    WHAT MAKES THIS SERIES DIFFERENT                 │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 1. CODE-FIRST, NOT THEORY-FIRST                             │   │
│  │    Aggressively code-heavy. Complete, runnable code.        │   │
│  │    No placeholders like "// implement here"                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 2. BEGINNER-FRIENDLY PROSE, EXPERT-LEVEL CODE               │   │
│  │    Explanations use simple analogies.                       │   │
│  │    Code is production-quality (error handling, security)    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 3. PROGRESSIVE COMPLEXITY                                   │   │
│  │    Each part builds directly on the previous one.           │   │
│  │    No unexplained jumps.                                    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 4. REAL-WORLD APPLICATIONS                                  │   │
│  │    Not toy examples. Solutions to real problems.            │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
This isn't a "watch me code" series where you're left with unfinished examples. Every single line of code is provided. Every concept is explained with analogies that make it accessible. And everything you build solves actual problems you'll encounter professionally.

---

### Slide S0.8: Prerequisites & Setup
```
┌─────────────────────────────────────────────────────────────────────┐
│                    PREREQUISITES & SETUP                            │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ REQUIRED TOOLS                                              │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  Node.js      │ 20.x or higher │ https://nodejs.org         │   │
│  │  npm          │ 9.x or higher  │ Included with Node.js     │   │
│  │  Git          │ 2.40+          │ https://git-scm.com       │   │
│  │  Code Editor  │ Any            │ VS Code, WebStorm, etc.   │   │
│  │  Terminal     │ Any            │ Built-in to OS            │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ VERIFICATION COMMANDS                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  $ node --version    # Should be v20.x or higher                   │
│  $ npm --version     # Should be 9.x or higher                    │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ CREATE PROJECT DIRECTORY                                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  $ mkdir ai-integration-javascript                                 │
│  $ cd ai-integration-javascript                                    │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Take a moment now to ensure your environment is set up correctly. The verification commands will confirm you have the right versions. The entire series assumes this base setup, so it's worth getting it right from the start.

---

### Slide S0.9: Project Structure Overview
```
┌─────────────────────────────────────────────────────────────────────┐
│                    PROJECT STRUCTURE                                │
│                                                                     │
│  ai-integration-javascript/                                        │
│  │                                                                  │
│  ├── mcp-protocol/              # Stage 1-3                        │
│  │   ├── servers/                                                  │
│  │   │   ├── first-server/                                         │
│  │   │   ├── database-server/                                      │
│  │   │   ├── postgres-server/                                      │
│  │   │   └── knowledge-server/                                     │
│  │   └── clients/                                                   │
│  │       └── mcp-client-lib/                                       │
│  │                                                                  │
│  ├── enterprise-integration/    # Stage 4                         │
│  │   ├── knowledge-server/                                         │
│  │   ├── data-aggregator/                                          │
│  │   └── integrations/                                             │
│  │                                                                  │
│  ├── ai-agents/                 # Stage 5                         │
│  │   └── research-assistant/                                       │
│  │                                                                  │
│  ├── a2a-protocol/             # Stage 6                          │
│  │   └── a2a-library/                                              │
│  │       ├── registry/                                             │
│  │       ├── router/                                               │
│  │       └── agents/                                               │
│  │                                                                  │
│  ├── multi-agent/              # Stage 7                          │
│  │   └── advanced-architecture/                                    │
│  │                                                                  │
│  └── production/               # Stage 8                          │
│      ├── docker/                                                   │
│      ├── kubernetes/                                               │
│      ├── monitoring/                                               │
│      └── ci-cd/                                                    │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
This is the complete project structure you'll build. Each directory corresponds to a major stage of the series. By the end, this will be a fully functional monorepo with multiple servers, clients, agents, and production infrastructure.

---

### Slide S0.10: Series Rules & Style Guide
```
┌─────────────────────────────────────────────────────────────────────┐
│                    SERIES RULES & STYLE GUIDE                       │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ CODING CONVENTIONS                                           │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  • Files: kebab-case.ts                                     │   │
│  │  • Classes: PascalCase                                      │   │
│  │  • Functions/Variables: camelCase                          │   │
│  │  • Constants: UPPER_SNAKE_CASE                             │   │
│  │  • Types/Interfaces: PascalCase                            │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ FOLLOW-ALONG RULES                                          │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  1. Type every line. Don't copy-paste blindly.              │   │
│  │  2. Run every verification step.                            │   │
│  │  3. Keep a learning log of errors and solutions.            │   │
│  │  4. Experiment. Extend. Break things. Fix them.             │   │
│  │  5. Ask questions. There are no stupid questions.           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ CODE BLOCK LABELS                                            │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  • File paths shown at top of code blocks                   │   │
│  │  • Verification steps highlighted                          │   │
│  │  • Terminal commands prefixed with $                        │   │
│  │  • Expected output shown for each verification             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Consistency matters. These conventions ensure all our code looks and feels the same. It also prepares you for working in real production codebases where coding standards are essential.

---

# STAGE 1: UNDERSTANDING AI INTEGRATION

## Block 1: MCP Fundamentals (20 Slides)

### Slide S1.1: The Evolution of AI-Powered Software
```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE EVOLUTION OF AI-POWERED SOFTWARE             │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    TIMELINE                                  │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │   2018-2020        2020-2022        2022-2024      2024+    │   │
│  │     │                │                │             │       │   │
│  │     ▼                ▼                ▼             ▼       │   │
│  │  ┌──────┐       ┌──────────┐    ┌─────────┐  ┌──────────┐ │   │
│  │  │ Chat │──────►│ Function │───►│   MCP   │─►│   A2A    │ │   │
│  │  │ Bots │       │  Calling │    │Protocol │  │Protocol  │ │   │
│  │  └──────┘       └──────────┘    └─────────┘  └──────────┘ │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    PHASE DESCRIPTIONS                        │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  Phase 1: Simple Chatbots                                    │   │
│  │  • Single prompt-response                                   │   │
│  │  • No external interactions                                 │   │
│  │  • Limited to training data                                │   │
│  │                                                             │   │
│  │  Phase 2: Function Calling                                  │   │
│  │  • Custom integrations per service                         │   │
│  │  • Proprietary formats                                     │   │
│  │  • No standardization                                      │   │
│  │                                                             │   │
│  │  Phase 3: MCP Protocol                                     │   │
│  │  • Standardized tool access                                │   │
│  │  • Universal compatibility                                 │   │
│  │  • Dynamic discovery                                       │   │
│  │                                                             │   │
│  │  Phase 4: A2A Protocol                                     │   │
│  │  • Multi-agent collaboration                               │   │
│  │  • Task delegation                                         │   │
│  │  • Autonomous workflows                                    │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:** 
The AI landscape has evolved rapidly. In the early days, chatbots could only respond based on their training data. Then function calling allowed AI to interact with APIs, but every integration was custom. MCP standardized this process. Now A2A is taking it further by enabling multi-agent collaboration.

---

### Slide S1.2: The Problem MCP Solves
```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE PROBLEM MCP SOLVES                           │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              BEFORE MCP: CUSTOM INTEGRATIONS                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │   Slack  │  │  GitHub  │  │Database  │  │   API   │          │
│  │  ┌──────┐│  │ ┌──────┐ │  │ ┌──────┐ │  │ ┌──────┐│          │
│  │  │Custom││  │ │Custom│ │  │ │Custom│ │  │ │Custom││          │
│  │  │Code  ││  │ │Code  │ │  │ │Code  │ │  │ │Code  ││          │
│  │  └──────┘│  │ └──────┘ │  │ └──────┘ │  │ └──────┘│          │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘          │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    PROBLEMS                                  │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  ❌ Every integration required custom code                   │   │
│  │  ❌ No standardization of capabilities                      │   │
│  │  ❌ Security handled differently per service                │   │
│  │  ❌ Hard to add new integrations                            │   │
│  │  ❌ No discovery mechanism                                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Before MCP, every integration was a one-off. The Slack integration had its own code, its own authentication, its own error handling. The GitHub integration had the same. Adding a new integration meant starting from scratch. This was costly, brittle, and unscalable.

---

### Slide S1.3: The Solution MCP Provides
```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE SOLUTION MCP PROVIDES                        │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              WITH MCP: STANDARDIZED INTERFACE                │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│                    ┌──────────────────────┐                        │
│                    │     AI Application    │                        │
│                    │    (MCP Client)      │                        │
│                    └──────────┬───────────┘                        │
│                               │                                     │
│                               ▼                                     │
│                    ┌──────────────────────┐                        │
│                    │   JSON-RPC Messages  │                        │
│                    └──────────┬───────────┘                        │
│                               │                                     │
│                               ▼                                     │
│                    ┌──────────────────────┐                        │
│                    │    MCP Server        │                        │
│                    │ (Standard Protocol)  │                        │
│                    └──────────┬───────────┘                        │
│                               │                                     │
│        ┌──────────────────────┼──────────────────────┐             │
│        │                      │                      │             │
│        ▼                      ▼                      ▼             │
│  ┌──────────┐          ┌──────────┐          ┌──────────┐         │
│  │  Slack   │          │  GitHub  │          │Database  │         │
│  └──────────┘          └──────────┘          └──────────┘         │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    BENEFITS                                  │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  ✅ Single protocol for all integrations                    │   │
│  │  ✅ Dynamic capability discovery                            │   │
│  │  ✅ Consistent security model                               │   │
│  │  ✅ Easy to add new servers                                 │   │
│  │  ✅ Standardized error handling                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
With MCP, all tools use the same interface. The AI application only knows MCP. Any tool that supports MCP can be integrated. This is the power of standardization—it turns bespoke integrations into plug-and-play components.

---

### Slide S1.4: MCP Definition & Official Description
```
┌─────────────────────────────────────────────────────────────────────┐
│                    MCP DEFINITION                                   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    OFFICIAL DEFINITION                       │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  "MCP is an open protocol that standardizes how             │   │
│  │   applications provide context to LLMs. Think of MCP        │   │
│  │   like a USB-C port for AI applications. Just as            │   │
│  │   USB-C provides a standardized way to connect your         │   │
│  │   devices to various peripherals and accessories,           │   │
│  │   MCP provides a standardized way to connect AI             │   │
│  │   models to different data sources and tools."              │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    KEY TAKEAWAYS                             │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  1. It's an OPEN PROTOCOL (not proprietary)                 │   │
│  │  2. It STANDARDIZES how AI connects to tools               │   │
│  │  3. It's like USB-C for AI                                 │   │
│  │  4. It supports ANY data source or tool                    │   │
│  │  5. It works with ANY LLM                                  │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The USB-C analogy is key here. Before USB-C, every device had its own charger. You needed a drawer full of different cables. USB-C standardized everything. MCP does the same for AI—one protocol that works with any tool and any LLM.

---

### Slide S1.5: MCP Architecture Diagram
```
┌─────────────────────────────────────────────────────────────────────┐
│                    MCP ARCHITECTURE                                 │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    AI APPLICATION LAYER                      │   │
│  │  ┌───────────────────────────────────────────────────────┐ │   │
│  │  │                    MCP Client                         │ │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │ │   │
│  │  │  │Discovery │  │Invocation│  │Resources │           │ │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘           │ │   │
│  │  └───────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                               │                                     │
│                               ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    TRANSPORT LAYER                           │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │   │
│  │  │  stdio   │  │WebSocket │  │   HTTP   │  │   SSE    │  │   │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                               │                                     │
│                               ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    JSON-RPC 2.0                              │   │
│  │  ┌───────────────────────────────────────────────────────┐ │   │
│  │  │  Request │ Response │ Error │ Notification           │ │   │
│  │  └───────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                               │                                     │
│                               ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    MCP SERVER                                │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │   │
│  │  │  Tools   │  │Resources │  │ Prompts  │                  │   │
│  │  └──────────┘  └──────────┘  └──────────┘                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                               │                                     │
│                               ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    EXTERNAL SYSTEMS                          │   │
│  │  APIs  │  Databases  │  Filesystems  │  Services            │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
This architecture diagram shows the complete MCP stack. At the top, you have your AI application with its MCP client. The client communicates over a transport layer using JSON-RPC. The MCP server receives these requests, executes the appropriate tools, resources, or prompts, and interacts with external systems as needed.

---

### Slide S1.6: The Three Pillars of MCP
```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE THREE PILLARS OF MCP                         │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │                    TOOLS                            │   │   │
│  │  ├─────────────────────────────────────────────────────┤   │   │
│  │  │  • Executable functions that the AI can call      │   │   │
│  │  │  • Represent ACTIONS the AI can take              │   │   │
│  │  │  • Example: send_email(to, subject, body)         │   │   │
│  │  │  • Input schema validation                        │   │   │
│  │  │  • Can have side effects                          │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │                  RESOURCES                          │   │   │
│  │  ├─────────────────────────────────────────────────────┤   │   │
│  │  │  • Data that the AI can READ                       │   │   │
│  │  │  • Represent INFORMATION the AI can access         │   │   │
│  │  │  • URI-based identification                        │   │   │
│  │  │  • Example: system://info                          │   │   │
│  │  │  • MIME type specified                             │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │                  PROMPTS                            │   │   │
│  │  ├─────────────────────────────────────────────────────┤   │   │
│  │  │  • Templates that guide AI behavior                │   │   │
│  │  │  • Represent STRUCTURE for AI interactions         │   │   │
│  │  │  • Variables for customization                     │   │   │
│  │  │  • Example: code_review_prompt                     │   │   │
│  │  │  • Reusable across sessions                        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
These three pillars are the foundation of MCP. Tools are what the AI can do. Resources are what the AI can know. Prompts are how the AI is guided. Together, they give AI applications the capabilities they need to be truly useful.

---

### Slide S1.7: Tools Deep Dive
```
┌─────────────────────────────────────────────────────────────────────┐
│                    TOOLS DEEP DIVE                                  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    TOOL DEFINITION                           │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  {                                                         │   │
│  │    "name": "send_email",                                    │   │
│  │    "description": "Send an email to a recipient",           │   │
│  │    "inputSchema": {                                         │   │
│  │      "type": "object",                                      │   │
│  │      "properties": {                                        │   │
│  │        "to": { "type": "string", "description": "..." },   │   │
│  │        "subject": { "type": "string" },                    │   │
│  │        "body": { "type": "string" }                        │   │
│  │      },                                                     │   │
│  │      "required": ["to", "subject", "body"]                 │   │
│  │    }                                                         │   │
│  │  }                                                         │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    TOOL CHARACTERISTICS                      │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  🔹 Named operations with descriptions              │   │   │
│  │  │  🔹 Input schema (JSON Schema) for validation       │   │   │
│  │  │  🔹 Output format (text, JSON, binary)              │   │   │
│  │  │  🔹 Can have side effects                           │   │   │
│  │  │  🔹 Error handling built in                         │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    COMMON TOOL EXAMPLES                      │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  • Database operations (query, insert, update)              │   │
│  │  • API calls (fetch data, send requests)                    │   │
│  │  • File operations (read, write, delete)                    │   │
│  │  • Communication (send email, post to Slack)               │   │
│  │  • Development (build, deploy, test)                       │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Tools are the most important part of MCP for enabling AI to take action. Each tool is self-describing—the AI knows what it does, what parameters it takes, and what it returns. This is what enables autonomous AI to use tools without human guidance.

---

### Slide S1.8: Resources Deep Dive
```
┌─────────────────────────────────────────────────────────────────────┐
│                    RESOURCES DEEP DIVE                              │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    RESOURCE URI SCHEMES                      │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  File Resources                                      │   │   │
│  │  │  file:///path/to/document.txt                        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Database Resources                                  │   │   │
│  │  │  database://table/users/row/123                     │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  API Resources                                       │   │   │
│  │  │  api://users/current                                 │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  System Resources                                    │   │   │
│  │  │  system://info                                       │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Knowledge Resources                                 │   │   │
│  │  │  knowledge://search?q=artificial+intelligence       │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    RESOURCE CHARACTERISTICS                 │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  🔹 URI-based identification                        │   │   │
│  │  │  🔹 Content can be text, binary, or structured    │   │   │
│  │  │  🔹 MIME type specified for content type            │   │   │
│  │  │  🔹 May be static or dynamic                        │   │   │
│  │  │  🔹 Can include metadata                           │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Resources are different from tools—they're read-only. The AI can access data through resources, but it can't modify them. This is important for security. Resources use URIs, similar to URLs on the web, which makes them discoverable and linkable.

---

### Slide S1.9: Prompts Deep Dive
```
┌─────────────────────────────────────────────────────────────────────┐
│                    PROMPTS DEEP DIVE                                │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    PROMPT TEMPLATE                           │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  {                                                         │   │
│  │    "name": "code_review",                                   │   │
│  │    "description": "Generate a code review",                 │   │
│  │    "arguments": [                                           │   │
│  │      {                                                      │   │
│  │        "name": "code",                                      │   │
│  │        "description": "The code to review",                 │   │
│  │        "required": true                                     │   │
│  │      },                                                     │   │
│  │      {                                                      │   │
│  │        "name": "language",                                  │   │
│  │        "description": "Programming language",               │   │
│  │        "default": "JavaScript"                              │   │
│  │      }                                                      │   │
│  │    ]                                                         │   │
│  │  }                                                         │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    PROMPT CHARACTERISTICS                    │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  🔹 Template-based with variables                    │   │   │
│  │  │  🔹 Multiple messages (system, user, assistant)      │   │   │
│  │  │  🔹 Arguments for customization                     │   │   │
│  │  │  🔹 Can include examples                            │   │   │
│  │  │  🔹 Reusable across sessions                        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    COMMON PROMPT USE CASES                   │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  • Code review templates                                    │   │
│  │  • Onboarding guides                                        │   │
│  │  • Documentation templates                                  │   │
│  │  • Analysis frameworks                                      │   │
│  │  • Decision-making guides                                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Prompts are one of the most powerful features of MCP because they encode best practices and expertise. Instead of relying on the AI to figure out how to do a code review, you provide a template that guides it step by step. This ensures consistency and quality.

---

### Slide S1.10: MCP Hosts & Servers Ecosystem
```
┌─────────────────────────────────────────────────────────────────────┐
│                    MCP HOSTS & SERVERS ECOSYSTEM                    │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    MCP HOSTS                                 │   │
│  │      (Applications that use MCP)                            │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  🔹 Cursor — AI code editor with MCP integration   │   │   │
│  │  │  🔹 GitHub Copilot — AI pair programmer             │   │   │
│  │  │  🔹 Claude Code — CLI coding assistant              │   │   │
│  │  │  🔹 Gemini CLI — Google's AI assistant              │   │   │
│  │  │  🔹 Codex CLI — Command-line AI                    │   │   │
│  │  │  🔹 OpenAI Agents SDK — Agent framework             │   │   │
│  │  │  🔹 Google ADK — Agent Development Kit              │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    MCP SERVERS                               │   │
│  │      (Ready-to-use capabilities)                            │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  🔹 Playwright — Browser automation                 │   │   │
│  │  │  🔹 Fetch — Web data retrieval                     │   │   │
│  │  │  🔹 Memory — Conversation memory                   │   │   │
│  │  │  🔹 Sequential Thinking — Step-by-step reasoning   │   │   │
│  │  │  🔹 DeepWiki — Knowledge base                     │   │   │
│  │  │  🔹 Tavily — Search API                           │   │   │
│  │  │  🔹 Zapier — Workflow automation                  │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The MCP ecosystem is growing rapidly. Many popular AI tools already support MCP, and new servers are being created all the time. This means your MCP server can be used by any of these hosts—you write it once, and it works everywhere.

---

### Slide S1.11: JSON-RPC Fundamentals
```
┌─────────────────────────────────────────────────────────────────────┐
│                    JSON-RPC FUNDAMENTALS                            │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    WHAT IS JSON-RPC?                         │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  • A lightweight remote procedure call protocol            │   │
│  │  • Uses JSON for data encoding                             │   │
│  │  • Language-agnostic                                       │   │
│  │  • Simple and human-readable                               │   │
│  │  • Standardized (JSON-RPC 2.0 Specification)              │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    MESSAGE TYPES                             │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  REQUEST                                             │   │   │
│  │  │  {                                                  │   │   │
│  │  │    "jsonrpc": "2.0",                                 │   │   │
│  │  │    "id": "req-123",                                  │   │   │
│  │  │    "method": "tools/call",                           │   │   │
│  │  │    "params": {                                       │   │   │
│  │  │      "name": "add",                                  │   │   │
│  │  │      "arguments": { "a": 5, "b": 3 }                │   │   │
│  │  │    }                                                 │   │   │
│  │  │  }                                                  │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  RESPONSE                                            │   │   │
│  │  │  {                                                  │   │   │
│  │  │    "jsonrpc": "2.0",                                 │   │   │
│  │  │    "id": "req-123",                                  │   │   │
│  │  │    "result": {                                       │   │   │
│  │  │      "content": [{ "type": "text", "text": "8" }]   │   │   │
│  │  │    }                                                 │   │   │
│  │  │  }                                                  │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
JSON-RPC is the language that MCP speaks. It's a simple, well-defined protocol that uses JSON for all messages. This makes it easy to implement in any programming language and easy to debug since the messages are human-readable.

---

### Slide S1.12: Common JSON-RPC Methods
```
┌─────────────────────────────────────────────────────────────────────┐
│                    COMMON JSON-RPC METHODS                          │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    DISCOVERY METHODS                         │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Method          │  Purpose                         │   │   │
│  │  ├─────────────────────────────────────────────────────┤   │   │
│  │  │  tools/list     │  Get all available tools          │   │   │
│  │  │  resources/list │  Get all available resources     │   │   │
│  │  │  prompts/list   │  Get all available prompts       │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    INVOCATION METHODS                        │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Method          │  Purpose                         │   │   │
│  │  ├─────────────────────────────────────────────────────┤   │   │
│  │  │  tools/call     │  Execute a tool                   │   │   │
│  │  │  resources/read │  Read a resource                 │   │   │
│  │  │  prompts/get    │  Get a prompt template           │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    LIFECYCLE METHODS                         │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Method          │  Purpose                         │   │   │
│  │  ├─────────────────────────────────────────────────────┤   │   │
│  │  │  initialize     │  Handshake between client/server │   │   │
│  │  │  shutdown       │  Graceful server shutdown        │   │   │
│  │  │  ping           │  Keep-alive check                │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
These methods form the complete API of MCP. Discovery methods allow the client to understand what the server can do. Invocation methods execute operations. Lifecycle methods manage the connection. This is everything you need to build a fully functional MCP implementation.

---

### Slide S1.13: Transport Mechanisms
```
┌─────────────────────────────────────────────────────────────────────┐
│                    TRANSPORT MECHANISMS                             │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    STDIO TRANSPORT                           │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Use Case: Local process execution                  │   │   │
│  │  │  How it works: Client spawns server process         │   │   │
│  │  │  Communication: stdin/stdout                        │   │   │
│  │  │  Best for: Development, local tools                │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    WEBSOCKET TRANSPORT                       │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Use Case: Real-time web applications               │   │   │
│  │  │  Features: Persistent bidirectional communication   │   │   │
│  │  │  Best for: Browser-based clients, streaming        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    HTTP TRANSPORT                            │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Use Case: Production APIs, stateless operations   │   │   │
│  │  │  Features: REST-style requests, caching support    │   │   │
│  │  │  Best for: Serverless deployments, REST APIs      │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
MCP supports multiple transport mechanisms because different use cases require different approaches. stdio is great for local development, WebSocket is ideal for real-time web applications, and HTTP works well for stateless production APIs. Choose the transport that fits your deployment scenario.

---

### Slide S1.14: Error Handling in MCP
```
┌─────────────────────────────────────────────────────────────────────┐
│                    ERROR HANDLING IN MCP                            │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    JSON-RPC ERROR CODES                      │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Code    │  Name              │  Description        │   │   │
│  │  ├─────────────────────────────────────────────────────┤   │   │
│  │  │  -32700  │  Parse Error       │  Invalid JSON      │   │   │
│  │  │  -32600  │  Invalid Request   │  Not a valid req  │   │   │
│  │  │  -32601  │  Method Not Found  │  Method doesn't exist │ │   │
│  │  │  -32602  │  Invalid Params    │  Wrong parameters │   │   │
│  │  │  -32603  │  Internal Error    │  Server error     │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    MCP-SPECIFIC ERROR CODES                  │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Code    │  Name              │  Description        │   │   │
│  │  ├─────────────────────────────────────────────────────┤   │   │
│  │  │  -32001  │  Tool Not Found    │  Tool doesn't exist│   │   │
│  │  │  -32002  │  Resource Not Found│  Resource missing │   │   │
│  │  │  -32003  │  Prompt Not Found  │  Prompt missing   │   │   │
│  │  │  -32004  │  Tool Execution    │  Tool failed      │   │   │
│  │  │  -32005  │  Resource Read     │  Resource read failed │ │   │
│  │  │  -32008  │  Connection Error  │  Network issue    │   │   │
│  │  │  -32009  │  Authentication    │  Invalid credentials │ │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Error handling is critical in production systems. JSON-RPC provides a standard error format with well-defined error codes. MCP extends this with its own specific error codes for MCP-related issues. This makes debugging and error handling consistent across all MCP implementations.

---

### Slide S1.15: Error Response Example
```
┌─────────────────────────────────────────────────────────────────────┐
│                    ERROR RESPONSE EXAMPLE                           │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    TOOL NOT FOUND                            │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  {                                                             │   │
│    "jsonrpc": "2.0",                                           │   │
│    "id": "req-123",                                            │   │
│    "error": {                                                  │   │
│      "code": -32001,                                           │   │
│      "message": "Tool not found: unknown_tool",                │   │
│      "data": {                                                 │   │
│        "requestedTool": "unknown_tool",                       │   │
│        "availableTools": ["add", "subtract", "multiply"]      │   │
│      }                                                         │   │
│    }                                                           │   │
│  }                                                             │   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    INVALID PARAMETERS                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  {                                                             │   │
│    "jsonrpc": "2.0",                                           │   │
│    "id": "req-124",                                            │   │
│    "error": {                                                  │   │
│      "code": -32602,                                           │   │
│      "message": "Invalid params",                              │   │
│      "data": {                                                 │   │
│        "validationErrors": [                                   │   │
│          {                                                     │   │
│            "path": ["b"],                                      │   │
│            "message": "Expected number, received string",     │   │
│            "value": "not-a-number"                             │   │
│          }                                                     │   │
│        ]                                                       │   │
│      }                                                         │   │
│    }                                                           │   │
│  }                                                             │   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Notice how error responses provide not just an error code and message, but also contextual data. In the "Tool Not Found" example, the server returns the list of available tools. In the "Invalid Parameters" example, it returns detailed validation errors. This makes debugging much easier.

---

### Slide S1.16: The Initialize Handshake
```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE INITIALIZE HANDSHAKE                         │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    CLIENT REQUEST                            │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  {                                                         │   │
│  │    "jsonrpc": "2.0",                                        │   │
│  │    "id": "init-1",                                          │   │
│  │    "method": "initialize",                                  │   │
│  │    "params": {                                              │   │
│  │      "protocolVersion": "2024-11-05",                       │   │
│  │      "clientInfo": {                                        │   │
│  │        "name": "my-client",                                 │   │
│  │        "version": "1.0.0"                                   │   │
│  │      }                                                      │   │
│  │    }                                                        │   │
│  │  }                                                         │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    SERVER RESPONSE                           │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  {                                                         │   │
│  │    "jsonrpc": "2.0",                                        │   │
│  │    "id": "init-1",                                          │   │
│  │    "result": {                                              │   │
│  │      "protocolVersion": "2024-11-05",                       │   │
│  │      "serverInfo": {                                        │   │
│  │        "name": "my-server",                                 │   │
│  │        "version": "1.0.0"                                   │   │
│  │      },                                                     │   │
│  │      "capabilities": {                                      │   │
│  │        "tools": {},                                         │   │
│  │        "resources": {},                                     │   │
│  │        "prompts": {}                                        │   │
│  │      }                                                      │   │
│  │    }                                                        │   │
│  │  }                                                         │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The initialize handshake is the first thing that happens when a client connects to a server. It negotiates the protocol version and exchanges information about both parties. The server's response includes its capabilities, which tells the client what features are available.

---

### Slide S1.17: The Complete Discovery Flow
```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE COMPLETE DISCOVERY FLOW                      │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    SEQUENCE DIAGRAM                          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌──────────┐                    ┌──────────┐                     │
│  │  Client  │                    │  Server  │                     │
│  └────┬─────┘                    └────┬─────┘                     │
│       │                               │                            │
│       │ 1. Connect                   │                            │
│       │─────────────────────────────►│                            │
│       │                               │                            │
│       │ 2. initialize                │                            │
│       │─────────────────────────────►│                            │
│       │                               │                            │
│       │ 3. initialize response       │                            │
│       │◄─────────────────────────────│                            │
│       │                               │                            │
│       │ 4. tools/list                │                            │
│       │─────────────────────────────►│                            │
│       │                               │                            │
│       │ 5. tools/list response       │                            │
│       │◄─────────────────────────────│                            │
│       │                               │                            │
│       │ 6. resources/list            │                            │
│       │─────────────────────────────►│                            │
│       │                               │                            │
│       │ 7. resources/list response   │                            │
│       │◄─────────────────────────────│                            │
│       │                               │                            │
│       │ 8. prompts/list              │                            │
│       │─────────────────────────────►│                            │
│       │                               │                            │
│       │ 9. prompts/list response     │                            │
│       │◄─────────────────────────────│                            │
│       │                               │                            │
│       │ 10. tools/call (add)         │                            │
│       │─────────────────────────────►│                            │
│       │                               │                            │
│       │ 11. tools/call response      │                            │
│       │◄─────────────────────────────│                            │
│       │                               │                            │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
This is the complete sequence of messages between a client and server. After the initialize handshake, the client discovers all capabilities (tools, resources, prompts) before making any actual calls. This is why MCP clients are so flexible—they discover everything at runtime.

---

### Slide S1.18: MCP vs. Function Calling
```
┌─────────────────────────────────────────────────────────────────────┐
│                    MCP VS. FUNCTION CALLING                         │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    FUNCTION CALLING                          │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  ✅ Works with specific LLM providers               │   │   │
│  │  │  ✅ Simple to implement                            │   │   │
│  │  │  ❌ Proprietary to each provider                   │   │   │
│  │  │  ❌ No discovery mechanism                         │   │   │
│  │  │  ❌ No standardization                             │   │   │
│  │  │  ❌ Limited to a single tool per request           │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    MCP PROTOCOL                             │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  ✅ Works with any LLM                              │   │   │
│  │  │  ✅ Discovery mechanism                             │   │   │
│  │  │  ✅ Standardized protocol                           │   │   │
│  │  │  ✅ Multiple tools per request                      │   │   │
│  │  │  ✅ Resources and prompts as well                   │   │   │
│  │  │  ✅ Independent of provider                         │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Function calling is a great feature, but it's limited to specific providers and doesn't provide discovery. MCP builds on the concept of function calling but standardizes it and makes it work with any provider. It also adds resources and prompts, which function calling doesn't support.

---

### Slide S1.19: When to Use MCP
```
┌─────────────────────────────────────────────────────────────────────┐
│                    WHEN TO USE MCP                                  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    USE MCP IF:                               │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ You want your AI to interact with external systems      │   │
│  │  ✅ You need to support multiple LLM providers              │   │
│  │  ✅ You want dynamic discovery of capabilities             │   │
│  │  ✅ You need to provide resources and prompts               │   │
│  │  ✅ You want a standardized interface                       │   │
│  │  ✅ You're building reusable AI tools                       │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    USE FUNCTION CALLING IF:                  │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ You're only using one provider (e.g., OpenAI)          │   │
│  │  ✅ You need a simple, quick integration                   │   │
│  │  ✅ You don't need discovery                                │   │
│  │  ✅ You're building a prototype                            │   │
│  │  ✅ You don't need resources or prompts                    │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Both MCP and function calling have their place. If you're building a production system that needs to be flexible and support multiple AI providers, MCP is the way to go. If you're building a quick prototype with a single provider, function calling might be simpler.

---

### Slide S1.20: Section Summary & Next Steps
```
┌─────────────────────────────────────────────────────────────────────┐
│                    SECTION SUMMARY                                  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    KEY TAKEAWAYS                             │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  1. MCP is an open protocol for standardizing AI-to-tool   │   │
│  │     connections                                             │   │
│  │                                                             │   │
│  │  2. Three pillars: Tools (actions), Resources (data),      │   │
│  │     Prompts (templates)                                    │   │
│  │                                                             │   │
│  │  3. Uses JSON-RPC 2.0 for communication                   │   │
│  │                                                             │   │
│  │  4. Supports multiple transports (stdio, WebSocket, HTTP)  │   │
│  │                                                             │   │
│  │  5. Client-server architecture with dynamic discovery      │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    NEXT STEPS                                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ➡️ Next: Building Your First MCP Server                   │   │
│  │  ➡️ We'll implement a complete server with tools,          │   │
│  │     resources, and prompts                                  │   │
│  │  ➡️ We'll test it with a client                           │   │
│  │  ➡️ We'll inspect the JSON-RPC messages                   │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
We've covered the fundamentals of MCP—what it is, how it works, and why it matters. Now it's time to get hands-on. In the next section, we'll build our first MCP server from scratch. Make sure your development environment is ready!

---

# STAGE 1: BUILDING YOUR FIRST MCP SERVER

## Block 2: First Server Implementation (20 Slides)

### Slide S2.1: Building Your First MCP Server
```
┌─────────────────────────────────────────────────────────────────────┐
│                    BUILDING YOUR FIRST MCP SERVER                   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    WHAT WE'RE BUILDING                       │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  A complete MCP server with:                               │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  📐 TOOLS                                            │   │   │
│  │  │  • add(a, b) — Add two numbers                      │   │   │
│  │  │  • subtract(a, b) — Subtract two numbers            │   │   │
│  │  │  • multiply(a, b) — Multiply two numbers            │   │   │
│  │  │  • divide(a, b) — Divide two numbers                │   │   │
│  │  │  • read_file(path) — Read a file                   │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  📚 RESOURCES                                        │   │   │
│  │  │  • system://info — System information               │   │   │
│  │  │  • server://status — Server status                 │   │   │
│  │  │  • config://environment — Environment config       │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  🎯 PROMPTS                                          │   │   │
│  │  │  • welcome — Welcome message with capabilities      │   │   │
│  │  │  • help — Help with using the server               │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Our first server will be a calculator and file server. It demonstrates all three MCP pillars: tools for arithmetic, resources for system information, and prompts for guiding the AI. This is the "Hello World" of MCP.

---

### Slide S2.2: Project Setup & Dependencies
```
┌─────────────────────────────────────────────────────────────────────┐
│                    PROJECT SETUP & DEPENDENCIES                     │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    CREATE PROJECT DIRECTORY                   │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  $ mkdir mcp-first-server                                   │   │
│  │  $ cd mcp-first-server                                      │   │
│  │  $ npm init -y                                              │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    INSTALL DEPENDENCIES                      │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  $ npm install @modelcontextprotocol/sdk zod dotenv         │   │
│  │  $ npm install -D typescript @types/node tsx               │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    DEPENDENCY EXPLANATIONS                   │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  @modelcontextprotocol/sdk   │  Official MCP SDK   │   │   │
│  │  │  zod                         │  Schema validation  │   │   │
│  │  │  dotenv                      │  Environment vars   │   │   │
│  │  │  typescript                  │  Type safety        │   │   │
│  │  │  tsx                         │  Run TypeScript    │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
We're using the official MCP SDK from npm. Zod provides schema validation for our tool inputs. dotenv manages environment variables. TypeScript and tsx give us type safety and direct execution. This is the standard stack for MCP development.

---

### Slide S2.3: tsconfig.json Configuration
```
┌─────────────────────────────────────────────────────────────────────┐
│                    TSCONFIG.JSON CONFIGURATION                      │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    TS CONFIG                                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  {                                                         │   │
│  │    "compilerOptions": {                                     │   │
│  │      "target": "ES2022",              // Modern features   │   │
│  │      "module": "NodeNext",            // ESM modules       │   │
│  │      "moduleResolution": "NodeNext",  // Node resolution   │   │
│  │      "outDir": "./dist",              // Output directory  │   │
│  │      "rootDir": "./src",              // Source directory  │   │
│  │      "strict": true,                  // Full type safety  │   │
│  │      "esModuleInterop": true,         // CommonJS support  │   │
│  │      "skipLibCheck": true,            // Faster builds     │   │
│  │      "declaration": true,             // .d.ts files      │   │
│  │      "sourceMap": true                // Debugging         │   │
│  │    },                                                      │   │
│  │    "include": ["src/**/*"],                               │   │
│  │    "exclude": ["node_modules", "dist"]                    │   │
│  │  }                                                         │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    KEY SETTINGS EXPLAINED                    │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  "target": "ES2022"                                 │   │   │
│  │  │  Uses modern JavaScript features                    │   │   │
│  │  │                                                     │   │   │
│  │  │  "module": "NodeNext"                              │   │   │
│  │  │  Uses ESM (import/export) for better tree-shaking │   │   │
│  │  │                                                     │   │   │
│  │  │  "strict": true                                    │   │   │
│  │  │  Enables all type checking features                │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The tsconfig.json is crucial for TypeScript projects. We're using ESM modules (import/export) rather than CommonJS (require/module.exports). The strict settings catch many potential bugs at compile time. This is the same configuration used in production-grade TypeScript projects.

---

### Slide S2.4: Package.json Scripts
```
┌─────────────────────────────────────────────────────────────────────┐
│                    PACKAGE.JSON SCRIPTS                             │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    SCRIPTS                                   │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  {                                                         │   │
│  │    "scripts": {                                             │   │
│  │      "build": "tsc",                                       │   │
│  │      "start": "node dist/index.js",                       │   │
│  │      "start:dev": "tsx src/index.ts"                      │   │
│  │    }                                                       │   │
│  │  }                                                         │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    SCRIPT EXPLANATIONS                       │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  "build": "tsc"                                     │   │   │
│  │  │  Compiles TypeScript to JavaScript                   │   │   │
│  │  │  Output goes to ./dist                              │   │   │
│  │  │                                                     │   │   │
│  │  │  "start": "node dist/index.js"                     │   │   │
│  │  │  Runs the compiled JavaScript                      │   │   │
│  │  │  For production use                                │   │   │
│  │  │                                                     │   │   │
│  │  │  "start:dev": "tsx src/index.ts"                   │   │   │
│  │  │  Runs TypeScript directly                           │   │   │
│  │  │  For development (auto-reload)                     │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The scripts make development and deployment straightforward. `npm run build` compiles the TypeScript. `npm start` runs the production build. `npm run start:dev` runs TypeScript directly with tsx, which is great for development since it doesn't require a build step.

---

### Slide S2.5: Creating the Logger
```
┌─────────────────────────────────────────────────────────────────────┐
│                    CREATING THE LOGGER                              │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    LOGGER IMPLEMENTATION                     │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/logger.ts                                           │   │
│  │                                                             │   │
│  │  import pino from 'pino';                                   │   │
│  │  import { randomUUID } from 'crypto';                      │   │
│  │                                                             │   │
│  │  export function createLogger() {                          │   │
│  │    const logger = pino({                                   │   │
│  │      level: process.env.LOG_LEVEL || 'info',              │   │
│  │      base: {                                               │   │
│  │        service: 'mcp-server',                              │   │
│  │        requestId: randomUUID()                            │   │
│  │      },                                                    │   │
│  │      transport: {                                          │   │
│  │        target: 'pino-pretty',                             │   │
│  │        options: { colorize: true }                        │   │
│  │      }                                                     │   │
│  │    });                                                     │   │
│  │    return logger;                                          │   │
│  │  }                                                         │   │
│  │                                                             │   │
│  │  export const logger = createLogger();                    │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    WHY STRUCTURED LOGGING?                   │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Machine-readable (JSON)                                │   │
│  │  ✅ Includes timestamps, severity, context                 │   │
│  │  ✅ Works with logging systems (ELK, Datadog)              │   │
│  │  ✅ Human-readable with pino-pretty                        │   │
│  │  ✅ Consistent across all components                       │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
We're using pino because it's the fastest JSON logger for Node.js. The pino-pretty transport makes logs human-readable during development. Each log entry includes a unique request ID, which helps trace requests across the system. This is the same logging pattern used in production systems.

---

### Slide S2.6: Defining Tools
```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEFINING TOOLS                                   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    TOOL STRUCTURE                            │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  const tool = {                                             │   │
│  │    name: 'add',                                             │   │
│  │    description: 'Add two numbers together',                 │   │
│  │    schema: {                                                │   │
│  │      a: z.number().describe('First number'),               │   │
│  │      b: z.number().describe('Second number')               │   │
│  │    },                                                       │   │
│  │    handler: async ({ a, b }) => {                          │   │
│  │      const result = a + b;                                 │   │
│  │      return {                                              │   │
│  │        content: [{ type: 'text', text: `${a}+${b}=${result}` }] │   │
│  │      };                                                     │   │
│  │    }                                                       │   │
│  │  };                                                        │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    TOOL COMPONENTS EXPLAINED                 │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  name          │  Unique identifier                 │   │   │
│  │  │  description   │  What the tool does               │   │   │
│  │  │  schema        │  Input validation (Zod)            │   │   │
│  │  │  handler       │  The actual logic                 │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
This is the template for defining MCP tools. Each tool has a name, description, input schema (using Zod for validation), and a handler function. The handler returns a ToolResult with content that will be displayed to the user. Notice how the schema is self-describing—the AI knows what parameters to provide.

---

### Slide S2.7: Full Tools Implementation
```
┌─────────────────────────────────────────────────────────────────────┐
│                    FULL TOOLS IMPLEMENTATION                        │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    ARITHMETIC TOOLS                          │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/tools.ts                                            │   │
│  │                                                             │   │
│  │  import { z } from 'zod';                                   │   │
│  │                                                             │   │
│  │  export const arithmeticTools = {                          │   │
│  │    add: {                                                   │   │
│  │      name: 'add',                                           │   │
│  │      description: 'Add two numbers together',               │   │
│  │      schema: { a: z.number(), b: z.number() },             │   │
│  │      handler: async ({ a, b }) => ({                        │   │
│  │        content: [{ type: 'text', text: `${a}+${b}=${a+b}` }] │   │
│  │      })                                                     │   │
│  │    },                                                       │   │
│  │    subtract: {                                              │   │
│  │      name: 'subtract',                                      │   │
│  │      description: 'Subtract one number from another',       │   │
│  │      schema: { a: z.number(), b: z.number() },             │   │
│  │      handler: async ({ a, b }) => ({                        │   │
│  │        content: [{ type: 'text', text: `${a}-${b}=${a-b}` }] │   │
│  │      })                                                     │   │
│  │    },                                                       │   │
│  │    multiply: {                                              │   │
│  │      name: 'multiply',                                      │   │
│  │      description: 'Multiply two numbers',                   │   │
│  │      schema: { a: z.number(), b: z.number() },             │   │
│  │      handler: async ({ a, b }) => ({                        │   │
│  │        content: [{ type: 'text', text: `${a}×${b}=${a*b}` }] │   │
│  │      })                                                     │   │
│  │    },                                                       │   │
│  │    divide: {                                                │   │
│  │      name: 'divide',                                        │   │
│  │      description: 'Divide one number by another',           │   │
│  │      schema: { a: z.number(), b: z.number() },             │   │
│  │      handler: async ({ a, b }) => {                         │   │
│  │        if (b === 0) return {                                │   │
│  │          content: [{ type: 'text', text: 'Cannot divide by zero' }], │   │
│  │          isError: true                                      │   │
│  │        };                                                   │   │
│  │        return {                                             │   │
│  │          content: [{ type: 'text', text: `${a}÷${b}=${a/b}` }] │   │
│  │        };                                                   │   │
│  │      }                                                      │   │
│  │    }                                                        │   │
│  │  };                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Our arithmetic tools are simple but demonstrate the pattern perfectly. Notice the divide tool includes error handling for division by zero. When an error occurs, we return `isError: true` along with the error message. This allows the AI to understand that the tool call failed.

---

### Slide S2.8: File System Tools
```
┌─────────────────────────────────────────────────────────────────────┐
│                    FILE SYSTEM TOOLS                                │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    READ FILE TOOL                            │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/tools.ts (continued)                                 │   │
│  │                                                             │   │
│  │  import { promises as fs } from 'fs';                      │   │
│  │  import path from 'path';                                   │   │
│  │                                                             │   │
│  │  export const fileTools = {                                │   │
│  │    readFile: {                                              │   │
│  │      name: 'read_file',                                     │   │
│  │      description: 'Read a file from the filesystem',        │   │
│  │      schema: { path: z.string() },                         │   │
│  │      handler: async ({ path: filePath }) => {              │   │
│  │        // Security: Prevent path traversal                 │   │
│  │        const fullPath = path.join(process.cwd(), filePath);│   │
│  │        const normalized = path.normalize(fullPath);        │   │
│  │        if (!normalized.startsWith(process.cwd())) {        │   │
│  │          return { content: [{ type: 'text', text: 'Access denied' }], │   │
│  │                   isError: true };                          │   │
│  │        }                                                    │   │
│  │        try {                                                │   │
│  │          const content = await fs.readFile(normalized, 'utf-8'); │   │
│  │          return { content: [{ type: 'text', text: content }] }; │   │
│  │        } catch {                                            │   │
│  │          return { content: [{ type: 'text', text: 'File not found' }], │   │
│  │                   isError: true };                          │   │
│  │        }                                                    │   │
│  │      }                                                      │   │
│  │    }                                                        │   │
│  │  };                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    SECURITY CONSIDERATIONS                   │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  🔒 Path traversal prevention                              │   │
│  │  🔒 Only allow files within project directory              │   │
│  │  🔒 Error handling for missing files                       │   │
│  │  🔒 No file write capabilities (read-only)                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The file system tool demonstrates important security considerations. We prevent path traversal attacks by ensuring the file path stays within the project directory. This is critical when allowing AI to access the filesystem. We also handle errors gracefully when files don't exist.

---

### Slide S2.9: Defining Resources
```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEFINING RESOURCES                               │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    RESOURCE STRUCTURE                        │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  const resource = {                                         │   │
│  │    uri: 'system://info',                                    │   │
│  │    name: 'system_info',                                     │   │
│  │    description: 'System information',                       │   │
│  │    mimeType: 'application/json',                            │   │
│  │    handler: async () => {                                   │   │
│  │      const data = { hostname: os.hostname() };             │   │
│  │      return {                                               │   │
│  │        contents: [{                                         │   │
│  │          uri: 'system://info',                              │   │
│  │          text: JSON.stringify(data),                        │   │
│  │          mimeType: 'application/json'                       │   │
│  │        }]                                                   │   │
│  │      };                                                     │   │
│  │    }                                                       │   │
│  │  };                                                        │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    RESOURCE COMPONENTS EXPLAINED             │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  uri        │  Unique identifier (like a URL)       │   │   │
│  │  │  name       │  Human-readable name                  │   │   │
│  │  │  description│  What the resource provides           │   │   │
│  │  │  mimeType   │  Content type (JSON, text, etc.)     │   │   │
│  │  │  handler    │  Returns the data                    │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Resources are structured similarly to tools but serve a different purpose—they provide data that the AI can read. Each resource has a URI that uniquely identifies it, similar to a URL on the web. The handler returns the resource content, which can be text, JSON, or binary data.

---

### Slide S2.10: Full Resources Implementation
```
┌─────────────────────────────────────────────────────────────────────┐
│                    FULL RESOURCES IMPLEMENTATION                    │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    RESOURCES IMPLEMENTATION                  │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/resources.ts                                        │   │
│  │                                                             │   │
│  │  import os from 'os';                                       │   │
│  │                                                             │   │
│  │  export const systemInfoResource = {                       │   │
│  │    uri: 'system://info',                                    │   │
│  │    name: 'system_info',                                     │   │
│  │    description: 'System information including OS, CPU',     │   │
│  │    mimeType: 'application/json',                            │   │
│  │    handler: async () => ({                                  │   │
│  │      const systemInfo = {                                   │   │
│  │        hostname: os.hostname(),                             │   │
│  │        platform: os.platform(),                             │   │
│  │        arch: os.arch(),                                     │   │
│  │        cpus: os.cpus().length,                              │   │
│  │        memory: { total: os.totalmem(), free: os.freemem() } │   │
│  │      };                                                     │   │
│  │      return {                                               │   │
│  │        contents: [{                                         │   │
│  │          uri: 'system://info',                              │   │
│  │          text: JSON.stringify(systemInfo, null, 2),        │   │
│  │          mimeType: 'application/json'                       │   │
│  │        }]                                                   │   │
│  │      };                                                     │   │
│  │    })                                                       │   │
│  │  };                                                        │   │
│  │                                                             │   │
│  │  export const serverStatusResource = {                     │   │
│  │    uri: 'server://status',                                  │   │
│  │    name: 'server_status',                                   │   │
│  │    description: 'Current server status',                    │   │
│  │    mimeType: 'application/json',                            │   │
│  │    handler: async () => ({                                  │   │
│  │      const status = {                                       │   │
│  │        name: process.env.MCP_SERVER_NAME || 'mcp-server',  │   │
│  │        status: 'running',                                   │   │
│  │        startTime: new Date().toISOString()                 │   │
│  │      };                                                     │   │
│  │      return { contents: [{ uri: 'server://status',         │   │
│  │        text: JSON.stringify(status, null, 2),              │   │
│  │        mimeType: 'application/json' }] }                   │   │
│  │    })                                                       │   │
│  │  };                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Our resources provide useful system information. The system://info resource gives hardware and OS information. The server://status resource gives application status. Both return JSON, which makes them easy for the AI to parse and understand.

---

### Slide S2.11: Defining Prompts
```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEFINING PROMPTS                                 │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    PROMPT STRUCTURE                          │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  const prompt = {                                           │   │
│  │    name: 'welcome',                                         │   │
│  │    description: 'Welcome message with capabilities',        │   │
│  │    schema: {                                                │   │
│  │      name: z.string().optional()                           │   │
│  │    },                                                       │   │
│  │    handler: ({ name }) => ({                                │   │
│  │      const userName = name || 'User';                      │   │
│  │      return {                                               │   │
│  │        messages: [{                                         │   │
│  │          role: 'assistant',                                 │   │
│  │          content: {                                         │   │
│  │            type: 'text',                                    │   │
│  │            text: `Welcome ${userName}! I can help you with: │   │
│  │                   - Arithmetic operations                   │   │
│  │                   - File operations`                       │   │
│  │          }                                                  │   │
│  │        }]                                                   │   │
│  │      };                                                     │   │
│  │    })                                                       │   │
│  │  };                                                        │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   ││                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    PROMPT COMPONENTS EXPLAINED               │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  name        │  Unique identifier                   │   │   │
│  │  │  description │  What the prompt does               │   │   │
│  │  │  schema      │  Arguments the prompt accepts       │   │   │
│  │  │  handler     │  Returns the prompt text            │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Prompts are reusable templates that guide AI behavior. Unlike tools (which perform actions) and resources (which provide data), prompts shape the AI's response. The welcome prompt includes a list of capabilities, helping the AI understand what it can do.

---

### Slide S2.12: Full Prompts Implementation
```
┌─────────────────────────────────────────────────────────────────────┐
│                    FULL PROMPTS IMPLEMENTATION                      │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    PROMPTS IMPLEMENTATION                    │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/prompts.ts                                          │   │
│  │                                                             │   │
│  │  import { z } from 'zod';                                   │   │
│  │                                                             │   │
│  │  export const welcomePrompt = {                            │   │
│  │    name: 'welcome',                                         │   │
│  │    description: 'Welcome message with capabilities',        │   │
│  │    schema: { name: z.string().optional() },                │   │
│  │    handler: ({ name }) => {                                 │   │
│  │      const userName = name || 'User';                      │   │
│  │      return {                                               │   │
│  │        messages: [{                                         │   │
│  │          role: 'assistant',                                 │   │
│  │          content: {                                         │   │
│  │            type: 'text',                                    │   │
│  │            text: `Welcome to the MCP Calculator Server, ${userName}! │   │
│  │                   I can help you with:                     │   │
│  │                   - Arithmetic operations (add, subtract,   │   │
│  │                     multiply, divide)                       │   │
│  │                   - File operations (read_file)            │   │
│  │                   - System information (resources)         │   │
│  │                   What would you like to do today?`       │   │
│  │          }                                                  │   │
│  │        }]                                                   │   │
│  │      };                                                     │   │
│  │    }                                                        │   │
│  │  };                                                        │   │
│  │                                                             │   │
│  │  export const helpPrompt = {                               │   │
│  │    name: 'help',                                            │   │
│  │    description: 'Help with using the server',               │   │
│  │    schema: { topic: z.string().optional() },               │   │
│  │    handler: ({ topic }) => ({ /* ... */ })                │   │
│  │  };                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The welcome prompt provides a friendly introduction and lists all available capabilities. The help prompt can provide specific help based on a topic. Notice how prompts use the same Zod schema validation as tools—this ensures the AI provides the right arguments.

---

### Slide S2.13: Creating the Main Server
```
┌─────────────────────────────────────────────────────────────────────┐
│                    CREATING THE MAIN SERVER                         │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    SERVER IMPLEMENTATION                     │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/server.ts                                           │   │
│  │                                                             │   │
│  │  import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js'; │   │
│  │  import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js'; │   │
│  │  import { createLogger } from './logger.js';               │   │
│  │  import { arithmeticTools, fileTools } from './tools.js';  │   │
│  │  import { allResources } from './resources.js';            │   │
│  │  import { allPrompts } from './prompts.js';               │   │
│  │                                                             │   │
│  │  const logger = createLogger();                            │   │
│  │                                                             │   │
│  │  export class CalculatorServer {                          │   │
│  │    private server: McpServer;                              │   │
│  │    private isRunning: boolean = false;                    │   │
│  │                                                             │   │
│  │    constructor() {                                          │   │
│  │      logger.info('Initializing Calculator Server');       │   │
│  │      this.server = new McpServer({                        │   │
│  │        name: process.env.MCP_SERVER_NAME || 'calculator', │   │
│  │        version: process.env.MCP_SERVER_VERSION || '1.0.0' │   │
│  │      });                                                   │   │
│  │      this.registerTools();                                │   │
│  │      this.registerResources();                            │   │
│  │      this.registerPrompts();                              │   │
│  │    }                                                       │   │
│  │  }                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The server class is the heart of our MCP server. It creates a McpServer instance, registers all tools, resources, and prompts, and manages the server lifecycle. Notice how we use environment variables for configuration—this makes the server portable across environments.

---

### Slide S2.14: Registering Tools
```
┌─────────────────────────────────────────────────────────────────────┐
│                    REGISTERING TOOLS                                │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    TOOL REGISTRATION                         │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/server.ts (continued)                               │   │
│  │                                                             │   │
│  │  private registerTools(): void {                           │   │
│  │    logger.info('Registering tools');                       │   │
│  │                                                             │   │
│  │    // Register arithmetic tools                           │   │
│  │    for (const tool of Object.values(arithmeticTools)) {   │   │
│  │      this.server.tool(                                     │   │
│  │        tool.name,                                          │   │
│  │        tool.schema,                                        │   │
│  │        tool.handler                                        │   │
│  │      );                                                    │   │
│  │      logger.debug(`Registered tool: ${tool.name}`);       │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    // Register file tools                                 │   │
│  │    for (const tool of Object.values(fileTools)) {         │   │
│  │      this.server.tool(tool.name, tool.schema, tool.handler); │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    logger.info('All tools registered');                    │   │
│  │  }                                                         │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    REGISTRATION PROCESS                      │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Tool definitions are imported                          │   │
│  │  ✅ Each tool is registered with the server                │   │
│  │  ✅ The SDK handles the rest                               │   │
│  │  ✅ Tools are now discoverable via tools/list             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Registration is straightforward—we simply call `server.tool()` with the tool's name, schema, and handler. The SDK handles everything else: making the tool discoverable via `tools/list`, validating inputs, and calling the handler when the tool is invoked.

---

### Slide S2.15: Registering Resources and Prompts
```
┌─────────────────────────────────────────────────────────────────────┐
│                    REGISTERING RESOURCES & PROMPTS                  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    RESOURCE REGISTRATION                     │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/server.ts (continued)                               │   │
│  │                                                             │   │
│  │  private registerResources(): void {                       │   │
│  │    logger.info('Registering resources');                   │   │
│  │                                                             │   │
│  │    for (const resource of allResources) {                  │   │
│  │      this.server.resource(                                 │   │
│  │        resource.name,                                      │   │
│  │        resource.uri,                                       │   │
│  │        { description: resource.description,                │   │
│  │          mimeType: resource.mimeType },                   │   │
│  │        resource.handler                                    │   │
│  │      );                                                    │   │
│  │    }                                                       │   │
│  │    logger.info('All resources registered');               │   │
│  │  }                                                         │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    PROMPT REGISTRATION                       │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/server.ts (continued)                               │   │
│  │                                                             │   │
│  │  private registerPrompts(): void {                         │   │
│  │    logger.info('Registering prompts');                     │   │
│  │                                                             │   │
│  │    for (const prompt of allPrompts) {                     │   │
│  │      this.server.prompt(                                   │   │
│  │        prompt.name,                                        │   │
│  │        prompt.schema,                                      │   │
│  │        prompt.handler                                      │   │
│  │      );                                                    │   │
│  │    }                                                       │   │
│  │    logger.info('All prompts registered');                 │   │
│  │  }                                                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Resources and prompts are registered similarly to tools. For resources, we provide the URI and metadata. For prompts, we provide the schema and handler. Once registered, they become discoverable via `resources/list` and `prompts/list`.

---

### Slide S2.16: Starting the Server
```
┌─────────────────────────────────────────────────────────────────────┐
│                    STARTING THE SERVER                              │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    START METHOD                              │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/server.ts (continued)                               │   │
│  │                                                             │   │
│  │  async start(): Promise<void> {                            │   │
│  │    if (this.isRunning) {                                   │   │
│  │      logger.warn('Server is already running');             │   │
│  │      return;                                               │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    logger.info('Starting server...');                      │   │
│  │                                                             │   │
│  │    try {                                                   │   │
│  │      const transport = new StdioServerTransport();        │   │
│  │      await this.server.connect(transport);                │   │
│  │      this.isRunning = true;                               │   │
│  │                                                             │   │
│  │      logger.info('Server started successfully');          │   │
│  │      console.error('🚀 MCP Server is running...');        │   │
│  │    } catch (error) {                                       │   │
│  │      logger.error('Failed to start server', { error });   │   │
│  │      throw error;                                          │   │
│  │    }                                                       │   │
│  │  }                                                         │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    STOP METHOD                               │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  async stop(): Promise<void> { /* Clean shutdown */ }     │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The start method creates a stdio transport and connects the server to it. The stdio transport uses standard input/output for communication—this is the most common transport for MCP servers. We use `console.error` for status messages because stdout is used for JSON-RPC communication.

---

### Slide S2.17: Entry Point (index.ts)
```
┌─────────────────────────────────────────────────────────────────────┐
│                    ENTRY POINT (INDEX.TS)                           │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    ENTRY POINT                               │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/index.ts                                            │   │
│  │                                                             │   │
│  │  #!/usr/bin/env node                                       │   │
│  │                                                             │   │
│  │  import dotenv from 'dotenv';                              │   │
│  │  dotenv.config();                                          │   │
│  │                                                             │   │
│  │  import { CalculatorServer } from './server.js';           │   │
│  │  import { createLogger } from './logger.js';              │   │
│  │                                                             │   │
│  │  const logger = createLogger();                            │   │
│  │                                                             │   │
│  │  const handleShutdown = async (server: CalculatorServer) => { │   │
│  │    logger.info('Shutting down...');                        │   │
│  │    await server.stop();                                    │   │
│  │    process.exit(0);                                        │   │
│  │  };                                                        │   │
│  │                                                             │   │
│  │  const main = async () => {                                │   │
│  │    try {                                                   │   │
│  │      const server = new CalculatorServer();               │   │
│  │      process.on('SIGINT', () => handleShutdown(server));  │   │
│  │      process.on('SIGTERM', () => handleShutdown(server)); │   │
│  │      await server.start();                                │   │
│  │    } catch (error) {                                       │   │
│  │      logger.error('Fatal error', { error });              │   │
│  │      process.exit(1);                                     │   │
│  │    }                                                       │   │
│  │  };                                                        │   │
│  │                                                             │   │
│  │  main();                                                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The entry point is responsible for loading environment variables, creating the server instance, and handling graceful shutdown. We handle SIGINT and SIGTERM signals (Ctrl+C and system shutdown) to ensure the server stops cleanly. The `#!/usr/bin/env node` shebang makes the file executable.

---

### Slide S2.18: Testing with a Client
```
┌─────────────────────────────────────────────────────────────────────┐
│                    TESTING WITH A CLIENT                            │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    TEST CLIENT                               │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/client-test.ts                                      │   │
│  │                                                             │   │
│  │  import { McpClient } from '@modelcontextprotocol/sdk/client/mcp.js'; │   │
│  │  import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js'; │   │
│  │                                                             │   │
│  │  const client = new McpClient({ name: 'test-client', version: '1.0.0' }); │   │
│  │                                                             │   │
│  │  const transport = new StdioClientTransport({              │   │
│  │    command: 'node',                                         │   │
│  │    args: ['dist/index.js']                                  │   │
│  │  });                                                        │   │
│  │                                                             │   │
│  │  await client.connect(transport);                          │   │
│  │                                                             │   │
│  │  // List tools                                             │   │
│  │  const { tools } = await client.listTools();              │   │
│  │  console.log('Tools:', tools.map(t => t.name));           │   │
│  │                                                             │   │
│  │  // Call a tool                                           │   │
│  │  const result = await client.callTool('add', { a: 5, b: 3 }); │   │
│  │  console.log('Result:', result.content[0].text);          │   │
│  │                                                             │   │
│  │  await client.close();                                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The test client demonstrates how to connect to our server. It spawns the server process using stdio, connects to it, lists tools, and calls a tool. This is the same pattern that AI applications use to interact with MCP servers.

---

### Slide S2.19: Running and Verifying
```
┌─────────────────────────────────────────────────────────────────────┐
│                    RUNNING AND VERIFYING                            │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    BUILD AND RUN                             │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  # Build the server                                        │   │
│  │  $ npm run build                                           │   │
│  │                                                             │   │
│  │  # Run the server in one terminal                         │   │
│  │  $ npm start                                               │   │
│  │  🚀 MCP Server is running...                              │   │
│  │                                                             │   │
│  │  # Run the test client in another terminal                │   │
│  │  $ npx tsx src/client-test.ts                             │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    EXPECTED OUTPUT                           │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  Test Client Output:                                       │   │
│  │  ────────────────────────────────────────────────────────── │   │
│  │  Tools: ['add', 'subtract', 'multiply', 'divide', 'read_file'] │   │
│  │  Result: 5 + 3 = 8                                        │   │
│  │                                                             │   │
│  │  Server Logs (pino-pretty):                               │   │
│  │  ────────────────────────────────────────────────────────── │   │
│  │  [00:00:00] INFO: Server started successfully            │   │
│  │  [00:00:05] DEBUG: Executing add tool                    │   │
│  │  [00:00:05] INFO: Add tool completed                     │   │
│  │  [00:00:05] DEBUG: Sending response                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
This slide shows the complete workflow—building, running the server, and testing with the client. The expected output demonstrates that the server is working correctly. The pino-pretty logs make it easy to see what's happening under the hood.

---

### Slide S2.20: Section Summary
```
┌─────────────────────────────────────────────────────────────────────┐
│                    SECTION SUMMARY                                  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    WHAT WE BUILT                             │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ A complete MCP server with:                            │   │
│  │  ✅ 5 tools (arithmetic + file operations)                 │   │
│  │  ✅ 3 resources (system info, server status, config)       │   │
│  │  ✅ 2 prompts (welcome, help)                              │   │
│  │  ✅ Proper logging and error handling                      │   │
│  │  ✅ Security (path traversal protection)                   │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    KEY LEARNINGS                             │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  1. Tools = Actions the AI can perform                     │   │
│  │  2. Resources = Data the AI can read                       │   │
│  │  3. Prompts = Templates that guide AI behavior            │   │
│  │  4. Registration makes capabilities discoverable           │   │
│  │  5. stdio is the most common transport                     │   │
│  │  6. TypeScript + Zod = Type-safe MCP development          │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    NEXT STEPS                                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ➡️ Next: Add advanced features (caching, auth, retries)   │   │
│  │  ➡️ Build a production-grade MCP client                    │   │
│  │  ➡️ Connect to enterprise systems (databases, APIs)        │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
We've successfully built our first MCP server. It's a complete implementation with all three MCP pillars. The code is production-quality with proper error handling and security. This is the foundation for everything that follows in the series.

---

# COMPREHENSIVE SLIDE OUTLINES — CONTINUED
## Stages 3-9: Complete Expanded Content

**[GENERATED: SLIDE OUTLINES — STAGES 3-9]**

---

# STAGE 2: BUILDING REUSABLE MCP SERVERS

## Block 3: Advanced MCP Features (25 Slides)

### Slide S3.1: Advanced MCP Server Features
```
┌─────────────────────────────────────────────────────────────────────┐
│              ADVANCED MCP SERVER FEATURES                          │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              WHAT WE'RE ADDING                               │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ HTTP Client with retry logic                            │   │
│  │  ✅ Data transformation utilities (JSON↔CSV)               │   │
│  │  ✅ Caching with multiple eviction policies                 │   │
│  │  ✅ Authentication (API keys, JWT)                          │   │
│  │  ✅ Structured output and validation                        │   │
│  │  ✅ Comprehensive error handling                            │   │
│  │  ✅ Security guardrails                                     │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              WHY THESE FEATURES MATTER                       │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  🔹 Production-ready vs. prototype                         │   │
│  │  🔹 Enterprises require security & reliability             │   │
│  │  🔹 Caching improves performance                           │   │
│  │  🔹 Retry logic handles transient failures                 │   │
│  │  🔹 Authentication prevents unauthorized access            │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Now that we have a basic server, it's time to make it production-ready. These features transform a prototype into an enterprise-grade system. Each feature addresses a real production concern: caching for performance, retry logic for reliability, authentication for security.

---

### Slide S3.2: HTTP Client with Retry Logic
```
┌─────────────────────────────────────────────────────────────────────┐
│              HTTP CLIENT WITH RETRY LOGIC                          │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              HTTP CLIENT IMPLEMENTATION                      │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/utils/http-client.ts                                │   │
│  │                                                             │   │
│  │  import axios from 'axios';                                 │   │
│  │                                                             │   │
│  │  export class HttpClient {                                 │   │
│  │    private client = axios.create();                        │   │
│  │    private maxRetries = 3;                                 │   │
│  │    private retryDelay = 1000;                              │   │
│  │                                                             │   │
│  │    async request<T>(config: any): Promise<T> {            │   │
│  │      let lastError: Error | null = null;                  │   │
│  │      let delay = this.retryDelay;                          │   │
│  │                                                             │   │
│  │      for (let attempt = 1; attempt <= this.maxRetries + 1; attempt++) { │   │
│  │        try {                                               │   │
│  │          const response = await this.client.request<T>(config); │   │
│  │          return response.data;                             │   │
│  │        } catch (error) {                                   │   │
│  │          lastError = error as Error;                      │   │
│  │          if (!this.isRetryable(error)) break;             │   │
│  │          if (attempt > this.maxRetries) break;            │   │
│  │                                                             │   │
│  │          // Exponential backoff                           │   │
│  │          await this.sleep(delay);                          │   │
│  │          delay *= 2;                                       │   │
│  │        }                                                   │   │
│  │      }                                                     │   │
│  │      throw lastError;                                      │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    private isRetryable(error: any): boolean {            │   │
│  │      if (!error.response) return true; // Network error  │   │
│  │      const status = error.response.status;               │   │
│  │      return status >= 500 || status === 429;             │   │
│  │    }                                                       │   │
│  │  }                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              RETRY STRATEGY EXPLAINED                        │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Attempt 1 │  Immediate                            │   │   │
│  │  │  Attempt 2 │  Wait 1s (exponential backoff)       │   │   │
│  │  │  Attempt 3 │  Wait 2s                             │   │   │
│  │  │  Attempt 4 │  Wait 4s                             │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The HTTP client uses exponential backoff for retries. This means we wait 1s, then 2s, then 4s between retries. This prevents overwhelming a struggling service. The retry logic also distinguishes between retryable errors (5xx, 429) and non-retryable errors (4xx client errors).

---

### Slide S3.3: Circuit Breaker Pattern
```
┌─────────────────────────────────────────────────────────────────────┐
│              CIRCUIT BREAKER PATTERN                                │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              CIRCUIT BREAKER STATES                          │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │                    CLOSED                          │   │   │
│  │  │  Requests flow normally                           │   │   │
│  │  │  Failures are counted                             │   │   │
│  │  │  ┌─────────────────────────────────────────────┐ │   │   │
│  │  │  │  Threshold reached → OPEN                   │ │   │   │
│  │  │  └─────────────────────────────────────────────┘ │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │                    OPEN                            │   │   │
│  │  │  All requests fail fast (no retries)              │   │   │
│  │  │  ┌─────────────────────────────────────────────┐ │   │   │
│  │  │  │  Timeout elapsed → HALF-OPEN               │ │   │   │
│  │  │  └─────────────────────────────────────────────┘ │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │                    HALF-OPEN                       │   │   │
│  │  │  Allow limited requests                           │   │   │
│  │  │  ┌─────────────────────────────────────────────┐ │   │   │
│  │  │  │  Success → CLOSED                          │ │   │   │
│  │  │  │  Failure → OPEN                            │ │   │   │
│  │  │  └─────────────────────────────────────────────┘ │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              IMPLEMENTATION                                 │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  class CircuitBreaker {                                    │   │
│  │    private state: 'closed' | 'open' | 'half-open' = 'closed'; │   │
│  │    private failures = 0;                                   │   │
│  │    private threshold = 5;                                  │   │
│  │    private timeout = 30000;                                │   │
│  │                                                             │   │
│  │    async execute<T>(operation: () => Promise<T>): Promise<T> { │   │
│  │      if (this.state === 'open') {                         │   │
│  │        throw new Error('Circuit breaker is open');       │   │
│  │      }                                                     │   │
│  │      try {                                                 │   │
│  │        const result = await operation();                  │   │
│  │        this.onSuccess();                                   │   │
│  │        return result;                                      │   │
│  │      } catch (error) {                                     │   │
│  │        this.onFailure();                                   │   │
│  │        throw error;                                        │   │
│  │      }                                                     │   │
│  │    }                                                       │   │
│  │  }                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The circuit breaker pattern prevents cascading failures. When a service is failing, the circuit breaker "opens" and all requests fail fast without attempting retries. After a timeout, it allows limited requests (half-open) to test if the service has recovered. This prevents your system from being overwhelmed by retry storms.

---

### Slide S3.4: Data Transformation Utilities
```
┌─────────────────────────────────────────────────────────────────────┐
│              DATA TRANSFORMATION UTILITIES                         │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              DATA TRANSFORMER CLASS                          │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/utils/data-transformer.ts                          │   │
│  │                                                             │   │
│  │  import { parse } from 'csv-parse/sync';                   │   │
│  │  import { stringify } from 'json2csv';                     │   │
│  │                                                             │   │
│  │  export class DataTransformer {                            │   │
│  │    static jsonToCsv(jsonData: any[]): string {            │   │
│  │      return stringify(jsonData, { header: true });        │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    static csvToJson(csvData: string): any[] {             │   │
│  │      return parse(csvData, { columns: true });            │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    static paginate<T>(data: T[], page: number = 1,        │   │
│  │                        pageSize: number = 10) {           │   │
│  │      const start = (page - 1) * pageSize;                 │   │
│  │      const end = start + pageSize;                        │   │
│  │      return {                                              │   │
│  │        data: data.slice(start, end),                      │   │
│  │        total: data.length,                                 │   │
│  │        page,                                              │   │
│  │        pageSize,                                          │   │
│  │        totalPages: Math.ceil(data.length / pageSize)      │   │
│  │      };                                                    │   │
│  │    }                                                       │   │
│  │  }                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              USE CASES                                       │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  🔹 CSV → JSON │  Import spreadsheet data           │   │   │
│  │  │  🔹 JSON → CSV │  Export data for reports           │   │   │
│  │  │  🔹 Pagination  │  Handle large result sets         │   │   │
│  │  │  🔹 Search     │  Filter data by keywords           │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Data transformation utilities are essential for enterprise MCP servers. Many AI tasks involve converting data between formats (JSON↔CSV) or handling pagination. These utilities make it easy to build tools that process structured data.

---

### Slide S3.5: Caching Implementation
```
┌─────────────────────────────────────────────────────────────────────┐
│              CACHING IMPLEMENTATION                                 │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              CACHE CLASS                                     │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/utils/cache.ts                                     │   │
│  │                                                             │   │
│  │  export class Cache<K, V> {                                │   │
│  │    private cache = new Map<K, {                            │   │
│  │      value: V;                                             │   │
│  │      expiresAt: number;                                    │   │
│  │      hitCount: number;                                     │   │
│  │    }>();                                                   │   │
│  │    private accessOrder: K[] = [];                         │   │
│  │    private config = {                                      │   │
│  │      ttl: 300000,      // 5 minutes                       │   │
│  │      maxSize: 100,                                        │   │
│  │      evictionPolicy: 'lru' // or 'fifo' or 'lfu'         │   │
│  │    };                                                     │   │
│  │                                                             │   │
│  │    set(key: K, value: V): void {                          │   │
│  │      if (this.cache.size >= this.config.maxSize) {        │   │
│  │        this.evict();                                       │   │
│  │      }                                                     │   │
│  │      this.cache.set(key, {                                 │   │
│  │        value,                                              │   │
│  │        expiresAt: Date.now() + this.config.ttl,          │   │
│  │        hitCount: 0                                         │   │
│  │      });                                                   │   │
│  │      this.updateOrder(key);                               │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    get(key: K): V | undefined {                          │   │
│  │      const entry = this.cache.get(key);                  │   │
│  │      if (!entry) return undefined;                       │   │
│  │      if (entry.expiresAt < Date.now()) {                 │   │
│  │        this.cache.delete(key);                           │   │
│  │        return undefined;                                  │   │
│  │      }                                                    │   │
│  │      entry.hitCount++;                                    │   │
│  │      this.updateOrder(key);                              │   │
│  │      return entry.value;                                  │   │
│  │    }                                                       │   │
│  │  }                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              EVICTION POLICIES EXPLAINED                     │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  LRU (Least Recently Used)                          │   │   │
│  │  │  Removes the least recently accessed item          │   │   │
│  │  │  Best for: General purpose                         │   │   │
│  │  │                                                     │   │   │
│  │  │  FIFO (First In, First Out)                        │   │   │
│  │  │  Removes the oldest added item                     │   │   │
│  │  │  Best for: Time-series data                       │   │   │
│  │  │                                                     │   │   │
│  │  │  LFU (Least Frequently Used)                       │   │   │
│  │  │  Removes the least accessed item                   │   │   │
│  │  │  Best for: Highly skewed access patterns          │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Caching significantly improves performance by storing frequently accessed data. The three eviction policies handle different use cases. LRU is the most common—it keeps recently accessed items. FIFO is simpler and works for time-series data. LFU keeps frequently accessed items, which is good when some data is much more popular than others.

---

### Slide S3.6: Authentication Implementation
```
┌─────────────────────────────────────────────────────────────────────┐
│              AUTHENTICATION IMPLEMENTATION                          │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              AUTHENTICATION MANAGER                          │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/utils/auth.ts                                      │   │
│  │                                                             │   │
│  │  import crypto from 'crypto';                              │   │
│  │                                                             │   │
│  │  export class AuthManager {                                │   │
│  │    private apiKeys: Set<string> = new Set();              │   │
│  │    private enabled: boolean;                               │   │
│  │                                                             │   │
│  │    constructor() {                                          │   │
│  │      this.enabled = process.env.MCP_AUTH_ENABLED === 'true'; │   │
│  │      const keys = process.env.MCP_API_KEYS || '';         │   │
│  │      for (const key of keys.split(',')) {                 │   │
│  │        if (key.trim()) this.apiKeys.add(key.trim());     │   │
│  │      }                                                     │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    static generateApiKey(): string {                      │   │
│  │      return `mcp_${crypto.randomBytes(32).toString('hex')}`; │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    validateApiKey(apiKey: string): boolean {             │   │
│  │      if (!this.enabled) return true;                     │   │
│  │      return this.apiKeys.has(apiKey);                    │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    extractApiKey(headers: any): string | null {          │   │
│  │      const authHeader = headers['authorization'] ||       │   │
│  │                         headers['Authorization'];         │   │
│  │      if (authHeader) {                                    │   │
│  │        const [type, key] = authHeader.split(' ');        │   │
│  │        if (type.toLowerCase() === 'bearer') return key;  │   │
│  │      }                                                    │   │
│  │      return headers['x-api-key'] || null;               │   │
│  │    }                                                       │   │
│  │  }                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              AUTHENTICATION FLOW                             │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  1. Client includes API key in request                     │   │
│  │  2. Server extracts and validates key                      │   │
│  │  3. If valid → Process request                            │   │
│  │  4. If invalid → Return 401 Unauthorized                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Authentication is essential for production MCP servers. The auth manager validates API keys from request headers. We use a simple bearer token approach where the key is sent in the Authorization header. API keys are generated using cryptographically secure random bytes.

---

### Slide S3.7: JWT Authentication
```
┌─────────────────────────────────────────────────────────────────────┐
│              JWT AUTHENTICATION                                     │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              JWT MANAGER                                     │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/utils/jwt.ts                                       │   │
│  │                                                             │   │
│  │  import jwt from 'jsonwebtoken';                           │   │
│  │                                                             │   │
│  │  export class JWTManager {                                 │   │
│  │    private secret: string;                                  │   │
│  │    private expiresIn: string;                              │   │
│  │                                                             │   │
│  │    constructor() {                                          │   │
│  │      this.secret = process.env.JWT_SECRET || 'your-secret'; │   │
│  │      this.expiresIn = '24h';                               │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    sign(payload: any): string {                           │   │
│  │      return jwt.sign(payload, this.secret, {              │   │
│  │        expiresIn: this.expiresIn,                          │   │
│  │        issuer: 'mcp-server'                                │   │
│  │      });                                                    │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    verify(token: string): any {                          │   │
│  │      try {                                                 │   │
│  │        return jwt.verify(token, this.secret, {            │   │
│  │          issuer: 'mcp-server'                              │   │
│  │        });                                                 │   │
│  │      } catch {                                             │   │
│  │        return null;                                        │   │
│  │      }                                                     │   │
│  │    }                                                       │   │
│  │  }                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              JWT VS API KEY                                 │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  API Keys              │  JWT                        │   │   │
│  │  ├─────────────────────────────────────────────────────┤   │   │
│  │  │  Simple                │  Contains claims           │   │   │
│  │  │  No expiration          │  Expires after time       │   │   │
│  │  │  No user context       │  Can contain user data    │   │   │
│  │  │  Easy to revoke        │  Hard to revoke           │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
JWT authentication offers more features than simple API keys. JWTs can contain user information (claims), support expiration, and are self-contained. However, they're harder to revoke than API keys. For most MCP servers, API keys are sufficient. JWT is useful when you need user-specific permissions.

---

### Slide S3.8: Tool Execution with Validation
```
┌─────────────────────────────────────────────────────────────────────┐
│              TOOL EXECUTION WITH VALIDATION                         │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              TOOL VALIDATION FLOW                             │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  1. Client sends tool call request                 │   │   │
│  │  │  2. Server validates input against schema           │   │   │
│  │  │  3. If invalid → Return detailed validation error  │   │   │
│  │  │  4. If valid → Execute tool handler                │   │   │
│  │  │  5. Return result to client                        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              VALIDATION EXAMPLE                              │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // Tool with strict validation                            │   │
│  │  server.tool(                                               │   │
│  │    'create_user',                                           │   │
│  │    {                                                        │   │
│  │      name: z.string().min(2).max(100),                     │   │
│  │      email: z.string().email(),                            │   │
│  │      age: z.number().int().min(0).max(150),               │   │
│  │      role: z.enum(['admin', 'editor', 'viewer']).default('viewer') │   │
│  │    },                                                       │   │
│  │    async ({ name, email, age, role }) => {                │   │
│  │      // All inputs are already validated                   │   │
│  │      return { content: [{ type: 'text', text: 'User created' }] }; │   │
│  │    }                                                       │   │
│  │  );                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Zod validation ensures that tools receive correct inputs. The validation happens before the handler executes, so the handler can assume inputs are valid. The validation errors are detailed, making it easy for clients (including AI) to understand what went wrong.

---

### Slide S3.9: Error Handling Strategy
```
┌─────────────────────────────────────────────────────────────────────┐
│              ERROR HANDLING STRATEGY                                │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              ERROR CLASSIFICATION                            │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  ERROR TYPE          │  HANDLING                     │   │   │
│  │  ├─────────────────────────────────────────────────────┤   │   │
│  │  │  Validation Error    │  Return 400 with details     │   │   │
│  │  │  Authentication Error │  Return 401                │   │   │
│  │  │  Authorization Error │  Return 403                │   │   │
│  │  │  Not Found           │  Return 404                │   │   │
│  │  │  Rate Limit Error    │  Return 429 with Retry-After │   │   │
│  │  │  Internal Error      │  Return 500, log error     │   │   │
│  │  │  Transient Error     │  Retry with backoff        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              BEST PRACTICES                                  │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Always return meaningful error messages                │   │
│  │  ✅ Include error codes for programmatic handling          │   │
│  │  ✅ Log errors with appropriate severity                  │   │
│  │  ✅ Never expose sensitive data in error messages         │   │
│  │  ✅ Use isError: true in tool responses                   │   │
│  │  ✅ Implement retry for transient errors                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
A systematic error handling strategy is essential for production systems. Each error type has an appropriate HTTP status code and handling strategy. The key principles are: be specific about what went wrong, don't expose sensitive information, and log everything.

---

### Slide S3.10: Security Guardrails
```
┌─────────────────────────────────────────────────────────────────────┐
│              SECURITY GUARDRAILS                                    │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              SECURITY CHECKLIST                              │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Input Validation (Zod schemas)                         │   │
│  │  ✅ Path Traversal Prevention                               │   │
│  │  ✅ SQL Injection Prevention (parameterized queries)        │   │
│  │  ✅ Rate Limiting                                           │   │
│  │  ✅ Authentication                                          │   │
│  │  ✅ Authorization (RBAC)                                   │   │
│  │  ✅ Logging (audit trail)                                  │   │
│  │  ✅ Error Sanitization (no stack traces to clients)        │   │
│  │  ✅ HTTPS in production                                    │   │
│  │  ✅ Secret Management (environment variables)              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              COMMON VULNERABILITIES                          │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Vulnerability     │  Prevention                    │   │   │
│  │  ├─────────────────────────────────────────────────────┤   │   │
│  │  │  Path Traversal    │  Normalize paths, restrict    │   │   │
│  │  │  SQL Injection     │  Parameterized queries         │   │   │
│  │  │  Command Injection │  Avoid shell commands         │   │   │
│  │  │  DoS Attacks       │  Rate limiting, timeouts      │   │   │
│  │  │  Data Exposure     │  Sanitize error messages      │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Security guardrails are non-negotiable in production systems. This checklist covers the essential security measures for MCP servers. The key is defense in depth—multiple layers of security rather than relying on any single measure.

---

# STAGE 3: BUILDING INTELLIGENT MCP CLIENTS

## Block 4: MCP Client Architecture (20 Slides)

### Slide S4.1: MCP Client Architecture
```
┌─────────────────────────────────────────────────────────────────────┐
│              MCP CLIENT ARCHITECTURE                                │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              CLIENT COMPONENTS                               │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              MCP Client Library                     │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │   │
│  │  │  │ Server   │  │ Tool     │  │ Resource│        │   │   │
│  │  │  │ Manager  │  │ Executor │  │ Reader  │        │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │   │
│  │  │  │ Prompt   │  │ Cache    │  │ Transport│        │   │   │
│  │  │  │ Executor │  │ Manager  │  │ Manager  │        │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              CLIENT RESPONSIBILITIES                         │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  1. Connect to servers                                     │   │
│  │  2. Discover capabilities (tools, resources, prompts)      │   │
│  │  3. Invoke tools with proper parameters                    │   │
│  │  4. Read resources                                          │   │
│  │  5. Execute prompts                                        │   │
│  │  6. Handle errors and timeouts                            │   │
│  │  7. Manage multiple servers                               │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The MCP client is the counterpart to the server. It manages connections, discovers capabilities, and invokes operations. The client library abstracts away the complexity of JSON-RPC, making it easy for AI applications to interact with MCP servers.

---

### Slide S4.2: Server Manager Component
```
┌─────────────────────────────────────────────────────────────────────┐
│              SERVER MANAGER COMPONENT                               │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              SERVER MANAGER                                  │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/server-manager.ts                                  │   │
│  │                                                             │   │
│  │  export class ServerManager {                               │   │
│  │    private config: MCPServerConfig;                        │   │
│  │    private transport: MCPTransport;                        │   │
│  │    private state: ConnectionState = 'disconnected';        │   │
│  │    private reconnectAttempts: number = 0;                  │   │
│  │    private maxReconnectAttempts: number = 5;               │   │
│  │                                                             │   │
│  │    async connect(): Promise<void> {                       │   │
│  │      if (this.state === 'connected') return;             │   │
│  │      this.state = 'connecting';                           │   │
│  │      try {                                                │   │
│  │        await this.transport.connect();                   │   │
│  │        this.state = 'connected';                          │   │
│  │        this.reconnectAttempts = 0;                        │   │
│  │      } catch (error) {                                    │   │
│  │        this.state = 'error';                              │   │
│  │        this.scheduleReconnect();                          │   │
│  │        throw error;                                       │   │
│  │      }                                                    │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    private scheduleReconnect(): void {                    │   │
│  │      const delay = Math.min(1000 * Math.pow(2,           │   │
│  │        this.reconnectAttempts), 30000);                  │   │
│  │      setTimeout(() => this.connect(), delay);            │   │
│  │    }                                                       │   │
│  │  }                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              CONNECTION STATES                               │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  disconnected → connecting → connected → error     │   │   │
│  │  │                                         ↓           │   │   │
│  │  │                                   reconnecting      │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The Server Manager handles the lifecycle of a single server connection. It manages connection state, handles reconnection with exponential backoff, and provides a clean interface for sending and receiving messages. This component ensures reliable communication with the server.

---

### Slide S4.3: Tool Executor Component
```
┌─────────────────────────────────────────────────────────────────────┐
│              TOOL EXECUTOR COMPONENT                                │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              TOOL EXECUTOR                                   │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/tool-executor.ts                                   │   │
│  │                                                             │   │
│  │  export class ToolExecutor {                                │   │
│  │    private cache: ToolCache = new ToolCache();              │   │
│  │                                                             │   │
│  │    async execute(                                           │   │
│  │      serverId: string,                                      │   │
│  │      toolName: string,                                      │   │
│  │      args: Record<string, any>,                            │   │
│  │      options: { cache?: boolean; timeout?: number } = {}  │   │
│  │    ): Promise<ToolResult> {                                │   │
│  │                                                             │   │
│  │      // Check cache                                        │   │
│  │      if (options.cache !== false) {                       │   │
│  │        const cached = this.cache.get(serverId, toolName, args); │   │
│  │        if (cached) return cached;                         │   │
│  │      }                                                     │   │
│  │                                                             │   │
│  │      // Execute with timeout                              │   │
│  │      const timeout = options.timeout || 30000;            │   │
│  │      const result = await this.executeWithTimeout(       │   │
│  │        serverId, toolName, args, timeout                  │   │
│  │      );                                                    │   │
│  │                                                             │   │
│  │      // Cache result                                      │   │
│  │      if (options.cache !== false && result.success) {     │   │
│  │        this.cache.set(serverId, toolName, args, result); │   │
│  │      }                                                     │   │
│  │                                                             │   │
│  │      return result;                                        │   │
│  │    }                                                       │   │
│  │  }                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              EXECUTION FEATURES                              │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Caching                                                │   │
│  │  ✅ Timeouts                                               │   │
│  │  ✅ Retry logic                                            │   │
│  │  ✅ Validation                                            │   │
│  │  ✅ Error recovery                                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The Tool Executor handles all tool invocations. It manages caching, timeouts, and retries. This component is what makes the client intelligent—it can execute tools efficiently and recover from failures. The caching feature is particularly important for performance, as many AI operations involve repeated calls to the same tools.

---

### Slide S4.4: Multi-Server Orchestration
```
┌─────────────────────────────────────────────────────────────────────┐
│              MULTI-SERVER ORCHESTRATION                             │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              ORCHESTRATION PATTERN                           │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────┐                                           │   │
│  │  │  AI Agent   │                                           │   │
│  │  └──────┬──────┘                                           │   │
│  │         │                                                   │   │
│  │         ▼                                                   │   │
│  │  ┌─────────────┐                                           │   │
│  │  │ MCP Client  │                                           │   │
│  │  └──────┬──────┘                                           │   │
│  │         │                                                   │   │
│  │         ▼                                                   │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │   │
│  │  │  Server A   │  │  Server B   │  │  Server C   │        │   │
│  │  │(Knowledge)  │  │(Database)   │  │(GitHub)     │        │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              USE CASE: SEARCH ACROSS SOURCES                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  1. AI Agent requests search across all sources            │   │
│  │  2. Client calls Server A (Knowledge) → results           │   │
│  │  3. Client calls Server B (Database) → results            │   │
│  │  4. Client calls Server C (GitHub) → results             │   │
│  │  5. Client aggregates all results                         │   │
│  │  6. Client returns unified result to AI                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
One of the most powerful features of MCP clients is orchestrating multiple servers. The client can discover capabilities across all connected servers and present them as a unified interface to the AI. This enables the AI to seamlessly access multiple data sources and tools without needing to know which server provides which capability.

---

### Slide S4.5: Client Configuration
```
┌─────────────────────────────────────────────────────────────────────┐
│              CLIENT CONFIGURATION                                   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              CLIENT CONFIG                                   │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/mcp-client.ts                                      │   │
│  │                                                             │   │
│  │  export interface ClientConfig {                           │   │
│  │    // Server configurations                                │   │
│  │    servers?: MCPServerConfig[];                            │   │
│  │                                                             │   │
│  │    // Global timeouts                                      │   │
│  │    defaultTimeout?: number;                                │   │
│  │                                                             │   │
│  │    // Caching settings                                     │   │
│  │    cacheEnabled?: boolean;                                 │   │
│  │    cacheTTL?: number;                                      │   │
│  │                                                             │   │
│  │    // Retry settings                                       │   │
│  │    maxRetries?: number;                                    │   │
│  │    retryDelay?: number;                                    │   │
│  │                                                             │   │
│  │    // Logging                                              │   │
│  │    logLevel?: 'debug' | 'info' | 'warn' | 'error';        │   │
│  │                                                             │   │
│  │    // Event handlers                                      │   │
│  │    eventHandlers?: ClientEventHandler[];                  │   │
│  │  }                                                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              CONFIGURATION EXAMPLE                           │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  const client = new MCPClient({                             │   │
│  │    servers: [                                               │   │
│  │      {                                                      │   │
│  │        id: 'knowledge',                                     │   │
│  │        transport: { type: 'stdio', command: 'node',        │   │
│  │          args: ['knowledge-server.js'] }                   │   │
│  │      },                                                     │   │
│  │      {                                                      │   │
│  │        id: 'database',                                      │   │
│  │        transport: { type: 'http', baseUrl: 'http://...' }, │   │
│  │        auth: { type: 'apiKey', credentials: 'key-123' }   │   │
│  │      }                                                     │   │
│  │    ],                                                       │   │
│  │    defaultTimeout: 30000,                                  │   │
│  │    cacheEnabled: true,                                     │   │
│  │    maxRetries: 3                                           │   │
│  │  });                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The client configuration allows fine-tuning of all behaviors: server connections, timeouts, caching, retries, and logging. This makes the client flexible enough for different deployment scenarios—from development to high-performance production environments.

---

# STAGE 4: ENTERPRISE INTEGRATION

## Block 5: SQLite Database Server (20 Slides)

### Slide S5.1: SQLite Database Server Architecture
```
┌─────────────────────────────────────────────────────────────────────┐
│              SQLITE DATABASE SERVER ARCHITECTURE                    │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              SERVER COMPONENTS                               │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              MCP Interface Layer                    │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │   │
│  │  │  │  Tools   │  │Resources │  │ Prompts  │        │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                              │                               │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              Connection Manager                     │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │   │
│  │  │  │   Pool   │  │  Query   │  │  Backup  │        │   │   │
│  │  │  │ Manager  │  │Executor  │  │ Manager  │        │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                              │                               │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              SQLite Database                        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              KEY FEATURES                                    │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Connection pooling                                     │   │
│  │  ✅ Query timeout protection                               │   │
│  │  ✅ Automatic backups                                       │   │
│  │  ✅ Read-only mode                                         │   │
│  │  ✅ DDL control                                            │   │
│  │  ✅ Query whitelist/blacklist                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The SQLite database server provides enterprise-grade database access through MCP. It includes connection pooling, timeout protection, automatic backups, and security controls. This server demonstrates how MCP can be used to access production databases safely.

---

### Slide S5.2: Connection Manager Implementation
```
┌─────────────────────────────────────────────────────────────────────┐
│              CONNECTION MANAGER IMPLEMENTATION                      │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              CONNECTION MANAGER                              │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/db/connection-manager.ts                           │   │
│  │                                                             │   │
│  │  import sqlite3 from 'sqlite3';                             │   │
│  │                                                             │   │
│  │  export class ConnectionManager {                           │   │
│  │    private pool: ConnectionEntry[] = [];                   │   │
│  │    private config: DBConfig;                                │   │
│  │                                                             │   │
│  │    async executeQuery(sql: string, params: any[] = []): Promise<QueryResult> { │   │
│  │      // Validate query                                     │   │
│  │      this.validateQuery(sql);                              │   │
│  │                                                             │   │
│  │      // Get connection from pool                          │   │
│  │      const conn = await this.getConnection();             │   │
│  │                                                             │   │
│  │      try {                                                 │   │
│  │        // Execute with timeout                            │   │
│  │        const result = await this.executeWithTimeout(     │   │
│  │          conn, sql, params                                │   │
│  │        );                                                  │   │
│  │        return result;                                      │   │
│  │      } finally {                                           │   │
│  │        // Release connection                               │   │
│  │        this.releaseConnection(conn);                      │   │
│  │      }                                                     │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    private validateQuery(sql: string): void {             │   │
│  │      // Prevent DROP, TRUNCATE, etc.                     │   │
│  │      const dangerous = ['drop', 'truncate'];             │   │
│  │      for (const pattern of dangerous) {                  │   │
│  │        if (sql.toLowerCase().includes(pattern)) {        │   │
│  │          throw new Error(`Dangerous query detected: ${pattern}`); │   │
│  │        }                                                   │   │
│  │      }                                                     │   │
│  │    }                                                       │   │
│  │  }                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The Connection Manager is the heart of the database server. It handles connection pooling, query validation, timeout protection, and proper resource cleanup. The validation function prevents dangerous queries (DROP, TRUNCATE) from being executed.

---

### Slide S5.3: Database Tools
```
┌─────────────────────────────────────────────────────────────────────┐
│              DATABASE TOOLS                                         │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              TOOL DEFINITIONS                                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/tools/query-tools.ts                               │   │
│  │                                                             │   │
│  │  export const createQueryTool = () => ({                   │   │
│  │    name: 'execute_query',                                   │   │
│  │    description: 'Execute a SQL query against the database', │   │
│  │    inputSchema: {                                           │   │
│  │      type: 'object',                                        │   │
│  │      properties: {                                          │   │
│  │        sql: { type: 'string', description: 'The SQL query' }, │   │
│  │        params: { type: 'array', description: 'Parameters' }, │   │
│  │        limit: { type: 'integer', description: 'Max rows' } │   │
│  │      },                                                     │   │
│  │      required: ['sql']                                      │   │
│  │    },                                                       │   │
│  │    handler: async ({ sql, params = [], limit }) => {       │   │
│  │      const db = getConnectionManager();                    │   │
│  │      const result = await db.executeQuery(sql, params, limit); │   │
│  │      return {                                               │   │
│  │        content: [{ type: 'text', text: JSON.stringify(result) }] │   │
│  │      };                                                     │   │
│  │    }                                                        │   │
│  │  });                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              AVAILABLE TOOLS                                 │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  🔹 execute_query — Execute SQL queries                    │   │
│  │  🔹 get_schema — Get database schema                      │   │
│  │  🔹 create_table — Create new tables                      │   │
│  │  🔹 describe_table — Get table metadata                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The database tools provide comprehensive database access. The execute_query tool is parameterized to prevent SQL injection. The schema tools allow the AI to understand the database structure. The create_table tool enables schema modifications with appropriate controls.

---

# STAGE 5: BUILDING AUTONOMOUS AI AGENTS

## Block 6: Agent Architecture (25 Slides)

### Slide S6.1: Autonomous Agent Architecture
```
┌─────────────────────────────────────────────────────────────────────┐
│              AUTONOMOUS AGENT ARCHITECTURE                          │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              AGENT COMPONENTS                                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              Agent Core                            │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │   │
│  │  │  │ Planner  │  │Executor  │  │ Reflector│        │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │   │
│  │  │  │ Memory   │  │ Context  │  │  Tools   │        │   │   │
│  │  │  │ Manager  │  │ Manager  │  │ Manager  │        │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                              │                               │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              MCP Client Layer                       │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │   │
│  │  │  │Knowledge │  │Database  │  │  GitHub  │        │   │   │
│  │  │  │ Server   │  │ Servers  │  │ Adapter  │        │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              AGENT CAPABILITIES                              │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Planning — Break down tasks into steps                │   │
│  │  ✅ Reasoning — Use LLM for decision making              │   │
│  │  ✅ Execution — Use tools to perform actions              │   │
│  │  ✅ Reflection — Evaluate outcomes and adjust             │   │
│  │  ✅ Memory — Store and retrieve context                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Autonomous agents represent the next level of AI integration. Unlike simple AI applications that respond to prompts, agents can plan, reason, execute, and reflect. They use MCP to access tools and maintain context through memory systems.

---

### Slide S6.2: The Agent Loop
```
┌─────────────────────────────────────────────────────────────────────┐
│              THE AGENT LOOP                                         │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              AGENT EXECUTION CYCLE                           │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  ┌─────────────────────────────────────────────┐   │   │   │
│  │  │  │              1. PLAN                         │   │   │   │
│  │  │  │   Break goal into steps                      │   │   │   │
│  │  │  └─────────────────────────────────────────────┘   │   │   │
│  │  │                    ↓                               │   │   │
│  │  │  ┌─────────────────────────────────────────────┐   │   │   │
│  │  │  │              2. EXECUTE                      │   │   │   │
│  │  │  │   Perform each step using tools              │   │   │   │
│  │  │  └─────────────────────────────────────────────┘   │   │   │
│  │  │                    ↓                               │   │   │
│  │  │  ┌─────────────────────────────────────────────┐   │   │   │
│  │  │  │              3. OBSERVE                      │   │   │   │
│  │  │  │   Collect and analyze results               │   │   │   │
│  │  │  └─────────────────────────────────────────────┘   │   │   │
│  │  │                    ↓                               │   │   │
│  │  │  ┌─────────────────────────────────────────────┐   │   │   │
│  │  │  │              4. REFLECT                      │   │   │   │
│  │  │  │   Evaluate progress, adjust plan            │   │   │   │
│  │  │  └─────────────────────────────────────────────┘   │   │   │
│  │  │                    ↓                               │   │   │
│  │  │  ┌─────────────────────────────────────────────┐   │   │   │
│  │  │  │              5. REPEAT                       │   │   │   │
│  │  │  │   Continue until goal achieved              │   │   │   │
│  │  │  └─────────────────────────────────────────────┘   │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              ANALOGY: COOKING DINNER                         │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  1. Plan: Decide what to cook and gather recipe            │   │
│  │  2. Execute: Chop vegetables, cook pasta                   │   │
│  │  3. Observe: Check if pasta is al dente                   │   │
│  │  4. Reflect: Add more salt if needed                      │   │
│  │  5. Repeat: Continue until dinner is ready                │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The agent loop is the core of autonomous agents. It's a continuous cycle of planning, executing, observing, and reflecting. This is similar to how humans approach complex tasks—we plan, take action, evaluate results, and adjust our approach.

---

### Slide S6.3: Planner Implementation
```
┌─────────────────────────────────────────────────────────────────────┐
│              PLANNER IMPLEMENTATION                                 │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              PLANNER CLASS                                   │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/planner.ts                                         │   │
│  │                                                             │   │
│  │  export class Planner {                                     │   │
│  │    private memory: SemanticMemory;                         │   │
│  │                                                             │   │
│  │    createPlan(goal: string): ResearchPlan {               │   │
│  │      // Store goal in memory                              │   │
│  │      this.memory.add(`Goal: ${goal}`, 'plan', 8);        │   │
│  │                                                             │   │
│  │      const plan = {                                        │   │
│  │        id: `plan-${Date.now()}`,                           │   │
│  │        goal,                                               │   │
│  │        steps: this.generateSteps(goal),                    │   │
│  │        status: 'planning',                                 │   │
│  │        createdAt: new Date()                              │   │
│  │      };                                                    │   │
│  │                                                             │   │
│  │      return plan;                                          │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    private generateSteps(goal: string): PlanStep[] {     │   │
│  │      const steps: PlanStep[] = [];                        │   │
│  │                                                             │   │
│  │      // Step 1: Understand the request                   │   │
│  │      steps.push({                                           │   │
│  │        id: 'step-1',                                       │   │
│  │        description: 'Understand the research request',     │   │
│  │        action: 'reflect',                                  │   │
│  │        dependencies: []                                    │   │
│  │      });                                                    │   │
│  │                                                             │   │
│  │      // Step 2: Determine data sources                   │   │
│  │      steps.push({                                           │   │
│  │        id: 'step-2',                                       │   │
│  │        description: 'Determine needed data sources',       │   │
│  │        action: 'search_knowledge',                         │   │
│  │        dependencies: ['step-1']                            │   │
│  │      });                                                    │   │
│  │                                                             │   │
│  │      // Step 3: Query data sources                       │   │
│  │      steps.push({                                           │   │
│  │        id: 'step-3',                                       │   │
│  │        description: 'Query data sources',                  │   │
│  │        action: 'execute_query',                            │   │
│  │        dependencies: ['step-2']                            │   │
│  │      });                                                    │   │
│  │                                                             │   │
│  │      return steps;                                         │   │
│  │    }                                                       │   │
│  │  }                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The Planner creates a structured plan from a goal. It breaks down the goal into steps with dependencies. Each step has an action that will be executed. The plan is stored in memory so the agent can track progress and adapt.

---

### Slide S6.4: Memory System
```
┌─────────────────────────────────────────────────────────────────────┐
│              MEMORY SYSTEM                                          │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              MEMORY CLASS                                    │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  // src/memory.ts                                          │   │
│  │                                                             │   │
│  │  export class SemanticMemory {                              │   │
│  │    private shortTerm: MemoryEntry[] = [];                   │   │
│  │    private longTerm: MemoryEntry[] = [];                    │   │
│  │    private maxShortTerm: number = 10;                       │   │
│  │                                                             │   │
│  │    add(content: string, type: MemoryType,                   │   │
│  │        importance: number = 5): void {                     │   │
│  │      const entry = {                                        │   │
│  │        id: `mem-${Date.now()}`,                             │   │
│  │        content,                                             │   │
│  │        type,                                                │   │
│  │        importance,                                          │   │
│  │        timestamp: new Date()                               │   │
│  │      };                                                     │   │
│  │                                                             │   │
│  │      this.shortTerm.unshift(entry);                        │   │
│  │                                                             │   │
│  │      if (this.shortTerm.length > this.maxShortTerm) {     │   │
│  │        const moved = this.shortTerm.pop()!;               │   │
│  │        if (moved.importance >= 4) {                       │   │
│  │          this.longTerm.unshift(moved);                    │   │
│  │        }                                                   │   │
│  │      }                                                     │   │
│  │    }                                                       │   │
│  │                                                             │   │
│  │    getContext(limit: number = 10): string {              │   │
│  │      return this.shortTerm.slice(0, limit).map(e =>      │   │
│  │        `[${e.type}] ${e.content}`                         │   │
│  │      ).join('\n');                                         │   │
│  │    }                                                       │   │
│  │  }                                                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              MEMORY TYPES                                    │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  observation  │  Facts the agent discovered        │   │   │
│  │  │  conclusion   │  Insights drawn from observations  │   │   │
│  │  │  plan         │  Steps to achieve goals            │   │   │
│  │  │  reflection   │  Analysis of progress              │   │   │
│  │  │  result       │  Outcomes of actions              │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The Memory System manages what the agent remembers. It has both short-term and long-term memory. Important information (high importance score) moves from short-term to long-term memory. The context method provides relevant memories for the agent to use in decision making.

---

# STAGE 6: A2A COLLABORATION

## Block 7: A2A Protocol (25 Slides)

### Slide S7.1: A2A Architecture
```
┌─────────────────────────────────────────────────────────────────────┐
│              A2A ARCHITECTURE                                       │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              MULTI-AGENT SYSTEM                              │   │
│  │                                                             │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │   │
│  │  │   Research   │  │    Coding    │  │   Database   │    │   │
│  │  │    Agent     │◄─┼──►  Agent    │◄─┼──►  Agent    │    │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │   │
│  │         ▲                 ▲                 ▲              │   │
│  │         │                 │                 │              │   │
│  │         ▼                 ▼                 ▼              │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              A2A Protocol Layer                    │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │   │
│  │  │  │ Registry │  │  Router  │  │  Message │        │   │   │
│  │  │  │          │  │          │  │  Queue   │        │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │         ▲                 ▲                 ▲              │   │
│  │         │                 │                 │              │   │
│  │         ▼                 ▼                 ▼              │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │                    MCP Layer                       │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │   │
│  │  │  │Knowledge │  │Database  │  │  GitHub  │        │   │   │
│  │  │  │ Server   │  │ Server   │  │ Adapter  │        │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
A2A (Agent-to-Agent) is the protocol that enables agents to communicate and collaborate. Each agent has its own expertise but can communicate with other agents through the A2A layer. The agents still use MCP to access external systems.

---

### Slide S7.2: Agent Roles
```
┌─────────────────────────────────────────────────────────────────────┐
│              AGENT ROLES                                            │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              ROLE DEFINITIONS                                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  COORDINATOR                                        │   │   │
│  │  │  Orchestrates multi-agent workflows                 │   │   │
│  │  │  Breaks down goals into tasks                      │   │   │
│  │  │  Delegates work to specialized agents              │   │   │
│  │  │  Monitors progress                                 │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  RESEARCHER                                         │   │   │
│  │  │  Gathers and analyzes information                   │   │   │
│  │  │  Queries knowledge bases and APIs                  │   │   │
│  │  │  Synthesizes findings                              │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  CODER                                              │   │   │
│  │  │  Writes and reviews code                            │   │   │
│  │  │  Generates tests                                    │   │   │
│  │  │  Refactors and optimizes                           │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  DATABASE                                           │   │   │
│  │  │  Manages database operations                        │   │   │
│  │  │  Executes queries                                   │   │   │
│  │  │  Maintains schema                                   │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Each agent has a specific role in the system. The Coordinator orchestrates, the Researcher gathers information, the Coder writes code, and the Database agent manages data. This specialization makes the system more efficient and capable.

---

### Slide S7.3: A2A Message Flow
```
┌─────────────────────────────────────────────────────────────────────┐
│              A2A MESSAGE FLOW                                       │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              DELEGATION PATTERN                              │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌──────────┐     ┌─────────────┐     ┌──────────┐        │   │
│  │  │  Agent   │     │ Coordinator │     │  Agent   │        │   │
│  │  │   (A)    │     │    Agent    │     │   (C)    │        │   │
│  │  └────┬─────┘     └──────┬──────┘     └────┬─────┘        │   │
│  │       │                  │                  │              │   │
│  │       │ 1. Delegate      │                  │              │   │
│  │       │─────────────────►│                  │              │   │
│  │       │                  │ 2. Find best     │              │   │
│  │       │                  │    agent         │              │   │
│  │       │                  │                  │              │   │
│  │       │                  │ 3. Delegate      │              │   │
│  │       │                  │─────────────────►│              │   │
│  │       │                  │                  │              │   │
│  │       │                  │ 4. Process       │              │   │
│  │       │                  │                  │              │   │
│  │       │                  │ 5. Result        │              │   │
│  │       │                  │◄─────────────────│              │   │
│  │       │                  │                  │              │   │
│  │       │ 6. Result        │                  │              │   │
│  │       │◄─────────────────│                  │              │   │
│  │       │                  │                  │              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              MESSAGE TYPES                                   │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  REQUEST     │  Ask for information or action       │   │   │
│  │  │  RESPONSE    │  Reply to a request                  │   │   │
│  │  │  DELEGATION  │  Assign a task to another agent      │   │   │
│  │  │  NOTIFICATION│  Inform of an event                  │   │   │
│  │  │  BROADCAST   │  Send to all agents                  │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The A2A message flow shows how agents communicate. When Agent A needs something done, it delegates to the Coordinator. The Coordinator finds the best agent for the task (Agent C), delegates the work, and returns the result. This pattern enables efficient multi-agent collaboration.

---

# STAGE 7: MULTI-AGENT ARCHITECTURES

## Block 8: Advanced Patterns (20 Slides)

### Slide S8.1: Hierarchical Architecture
```
┌─────────────────────────────────────────────────────────────────────┐
│              HIERARCHICAL ARCHITECTURE                              │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              PYRAMID STRUCTURE                               │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │               COORDINATOR AGENT                     │   │   │
│  │  │   - Receives project requirements                   │   │   │
│  │  │   - Creates high-level plan                         │   │   │
│  │  │   - Monitors overall progress                       │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                    │                                        │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │               SUPERVISOR AGENT                      │   │   │
│  │  │   - Breaks down into tasks                          │   │   │
│  │  │   - Assigns to workers                              │   │   │
│  │  │   - Reviews and merges work                        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                    │                                        │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │   │
│  │  │ Research │  │  Coding  │  │  Review  │  │  DevOps  │  │   │
│  │  │  Agent   │  │  Agent   │  │  Agent   │  │  Agent   │  │   │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              BENEFITS                                        │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Clear chain of command                                 │   │
│  │  ✅ Scalable architecture                                  │   │
│  │  ✅ Specialization at each level                          │   │
│  │  ✅ Efficient delegation                                   │   │
│  │  ✅ Centralized monitoring                                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Hierarchical architecture mirrors human organizations. The Coordinator sets the vision, the Supervisor manages execution, and Workers do the actual work. This structure scales well because new agents can be added at any level without disrupting the overall system.

---

### Slide S8.2: Shared Memory System
```
┌─────────────────────────────────────────────────────────────────────┐
│              SHARED MEMORY SYSTEM                                   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              SHARED MEMORY                                   │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              SHARED MEMORY HUB                      │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │   │
│  │  │  │ Context  │  │Artifacts │  │ Decisions│        │   │   │
│  │  │  │ Manager  │  │ Manager  │  │ Manager  │        │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                    │                                        │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │    ┌──────────┐  ┌──────────┐  ┌──────────┐       │   │   │
│  │  │    │ Research │  │  Coding  │  │Database  │       │   │   │
│  │  │    │  Agent   │  │  Agent   │  │  Agent   │       │   │   │
│  │  │    └──────────┘  └──────────┘  └──────────┘       │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              USE CASES                                       │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Project context sharing                                 │   │
│  │  ✅ Code artifact storage                                   │   │
│  │  ✅ Decision tracking                                       │   │
│  │  ✅ State management                                        │   │
│  │  ✅ Cross-agent communication                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Shared memory is a centralized system that all agents can read from and write to. It stores project context, artifacts (code, tests, docs), decisions, and state. This enables agents to work on the same project without duplicating effort.

---

# STAGE 8: PRODUCTION ENGINEERING

## Block 9: Production Deployment (25 Slides)

### Slide S9.1: Production Architecture
```
┌─────────────────────────────────────────────────────────────────────┐
│              PRODUCTION ARCHITECTURE                                │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              PRODUCTION STACK                                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              LOAD BALANCER                          │   │   │
│  │  │         (HAProxy / NGINX)                           │   │   │
│  │  │   - SSL Termination                                 │   │   │
│  │  │   - Load Balancing                                  │   │   │
│  │  │   - Rate Limiting                                   │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                    │                                        │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              KUBERNETES CLUSTER                     │   │   │
│  │  │  ┌─────────────────────────────────────────────┐   │   │   │
│  │  │  │              INGRESS CONTROLLER             │   │   │   │
│  │  │  │         (Nginx Ingress)                     │   │   │   │
│  │  │  └─────────────────────────────────────────────┘   │   │   │
│  │  │                    │                                │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │   │
│  │  │  │Knowledge │  │  Agent   │  │  A2A     │        │   │   │
│  │  │  │ Service  │  │ Service  │  │ Service  │        │   │   │
│  │  │  │ (3 pods) │  │ (2 pods) │  │ (3 pods) │        │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                    │                                        │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              OBSERVABILITY STACK                    │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │   │
│  │  │  │Prometheus│  │ Grafana  │  │   ELK    │        │   │   │
│  │  │  │(Metrics) │  │(Dashboards)│ │  (Logs)  │        │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Production architecture requires multiple layers. The load balancer handles traffic distribution and SSL termination. Kubernetes manages container orchestration. The observability stack monitors metrics, logs, and performance.

---

### Slide S9.2: Docker Containerization
```
┌─────────────────────────────────────────────────────────────────────┐
│              DOCKER CONTAINERIZATION                                │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              DOCKERFILE                                     │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  # Stage 1: Builder                                        │   │
│  │  FROM node:20-alpine AS builder                            │   │
│  │  WORKDIR /app                                              │   │
│  │  COPY package*.json ./                                     │   │
│  │  RUN npm ci                                                │   │
│  │  COPY src/ ./src/                                          │   │
│  │  RUN npm run build                                         │   │
│  │                                                             │   │
│  │  # Stage 2: Production                                     │   │
│  │  FROM node:20-alpine                                       │   │
│  │  WORKDIR /app                                              │   │
│  │  COPY --from=builder /app/dist ./dist                     │   │
│  │  COPY --from=builder /app/node_modules ./node_modules     │   │
│  │  USER nodejs                                               │   │
│  │  EXPOSE 3000                                               │   │
│  │  CMD ["node", "dist/index.js"]                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              BEST PRACTICES                                 │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Multi-stage builds (smaller images)                    │   │
│  │  ✅ Use Alpine base images (smaller)                       │   │
│  │  ✅ Run as non-root user                                   │   │
│  │  ✅ Copy only what's needed                                │   │
│  │  ✅ Use .dockerignore                                      │   │
│  │  ✅ Layer caching for faster builds                       │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Docker containerization ensures consistency across environments. The multi-stage build keeps production images small. Running as a non-root user improves security. Layer caching speeds up builds.

---

### Slide S9.3: Kubernetes Deployment
```
┌─────────────────────────────────────────────────────────────────────┐
│              KUBERNETES DEPLOYMENT                                  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              DEPLOYMENT YAML                                 │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  apiVersion: apps/v1                                        │   │
│  │  kind: Deployment                                           │   │
│  │  metadata:                                                  │   │
│  │    name: knowledge-server                                   │   │
│  │    namespace: ai-platform                                   │   │
│  │  spec:                                                      │   │
│  │    replicas: 3                                              │   │
│  │    selector:                                                │   │
│  │      matchLabels:                                           │   │
│  │        app: knowledge-server                                │   │
│  │    template:                                                │   │
│  │      metadata:                                              │   │
│  │        labels:                                              │   │
│  │          app: knowledge-server                              │   │
│  │      spec:                                                  │   │
│  │        containers:                                          │   │
│  │        - name: knowledge-server                             │   │
│  │          image: ${REGISTRY}/knowledge-server:${TAG}       │   │
│  │          ports:                                             │   │
│  │          - containerPort: 3000                              │   │
│  │          env:                                               │   │
│  │          - name: NODE_ENV                                   │   │
│  │            value: "production"                              │   │
│  │          resources:                                         │   │
│  │            requests:                                        │   │
│  │              memory: "256Mi"                                │   │
│  │              cpu: "250m"                                    │   │
│  │            limits:                                          │   │
│  │              memory: "1Gi"                                  │   │
│  │              cpu: "1000m"                                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Kubernetes manages container orchestration in production. The deployment defines replicas (3 instances for high availability), resource limits, and environment variables. Kubernetes handles scaling, rolling updates, and self-healing.

---

### Slide S9.4: HPA & Scaling
```
┌─────────────────────────────────────────────────────────────────────┐
│              HPA & SCALING                                          │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              HORIZONTAL POD AUTOSCALER                      │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  apiVersion: autoscaling/v2                                │   │
│  │  kind: HorizontalPodAutoscaler                             │   │
│  │  metadata:                                                 │   │
│  │    name: knowledge-server-hpa                              │   │
│  │  spec:                                                     │   │
│  │    scaleTargetRef:                                         │   │
│  │      apiVersion: apps/v1                                   │   │
│  │      kind: Deployment                                      │   │
│  │      name: knowledge-server                                │   │
│  │    minReplicas: 2                                          │   │
│  │    maxReplicas: 10                                         │   │
│  │    metrics:                                                │   │
│  │    - type: Resource                                        │   │
│  │      resource:                                             │   │
│  │        name: cpu                                           │   │
│  │        target:                                             │   │
│  │          type: Utilization                                 │   │
│  │          averageUtilization: 70                            │   │
│  │    - type: Resource                                        │   │
│  │      resource:                                             │   │
│  │        name: memory                                        │   │
│  │        target:                                             │   │
│  │          type: Utilization                                 │   │
│  │          averageUtilization: 80                            │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              SCALING BEHAVIOR                                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  CPU > 70%  →  Scale up                             │   │   │
│  │  │  CPU < 50%  →  Scale down                           │   │   │
│  │  │  Memory > 80% → Scale up                           │   │   │
│  │  │  Memory < 60% → Scale down                         │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Horizontal Pod Autoscaling automatically adjusts the number of pods based on resource usage. This ensures your system can handle traffic spikes without wasting resources during quiet periods. The HPA monitors CPU and memory usage and scales accordingly.

---

# STAGE 9: REAL-WORLD PROJECTS

## Block 10: Project Templates (20 Slides)

### Slide S10.1: GitHub Coding Assistant
```
┌─────────────────────────────────────────────────────────────────────┐
│              GITHUB CODING ASSISTANT                                │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              PROJECT OVERVIEW                                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  An AI-powered coding assistant that connects to GitHub    │   │
│  │  repositories, reads code, suggests improvements, and      │   │
│  │  can even write code based on natural language             │   │
│  │  descriptions.                                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              FEATURES                                        │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Read code from GitHub                                   │   │
│  │  ✅ Write code to GitHub                                    │   │
│  │  ✅ Review code quality                                     │   │
│  │  ✅ Generate new code                                       │   │
│  │  ✅ Get repository structure                               │   │
│  │  ✅ Suggest improvements                                    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              USE CASE                                        │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  User: "Review the authentication code in the auth.js file" │   │
│  │  → Assistant reads the file                                │   │
│  │  → Assistant analyzes for security issues                  │   │
│  │  → Assistant provides review and suggestions              │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The GitHub Coding Assistant is a practical application that demonstrates how MCP can connect to real-world development workflows. It can read code, write code, review code, and suggest improvements. This is a tool that could be used in actual software development.

---

### Slide S10.2: Enterprise Documentation Assistant
```
┌─────────────────────────────────────────────────────────────────────┐
│              ENTERPRISE DOCUMENTATION ASSISTANT                     │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              PROJECT OVERVIEW                                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  An AI assistant that helps create, maintain, and search   │   │
│  │  enterprise documentation across multiple systems          │   │
│  │  including Confluence, SharePoint, and Markdown files.     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              ADAPTERS                                        │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  Confluence Adapter │  Read/write Confluence pages  │   │   │
│  │  │  SharePoint Adapter │  Read/write SharePoint docs   │   │   │
│  │  │  Markdown Adapter   │  Read/write Markdown files    │   │   │
│  │  │  Search Engine      │  Search across all sources    │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              USE CASE                                        │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  User: "Find all documentation about authentication"       │   │
│  │  → Assistant searches Confluence                           │   │
│  │  → Assistant searches SharePoint                           │   │
│  │  → Assistant searches Markdown files                      │   │
│  │  → Assistant returns aggregated results                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The Documentation Assistant demonstrates how MCP can unify access to multiple data sources. It provides a single interface for searching across Confluence, SharePoint, and Markdown files. This is common in enterprise environments where documentation is spread across multiple platforms.

---

### Slide S10.3: AI DevOps Engineer
```
┌─────────────────────────────────────────────────────────────────────┐
│              AI DEVOPS ENGINEER                                     │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              PROJECT OVERVIEW                                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  An AI DevOps agent that can manage Docker containers,     │   │
│  │  Kubernetes deployments, and infrastructure-as-code.      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              CAPABILITIES                                    │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Deploy services to Docker/Kubernetes                   │   │
│  │  ✅ Scale services up and down                             │   │
│  │  ✅ View service logs                                      │   │
│  │  ✅ Health checks                                          │   │
│  │  ✅ Rollback deployments                                    │   │
│  │  ✅ Get service status                                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              USE CASE                                        │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  User: "Deploy the authentication service to production"   │   │
│  │  → Agent deploys service with 3 replicas                   │   │
│  │  → Agent performs health check                             │   │
│  │  → Agent confirms deployment successful                    │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The AI DevOps Engineer automates infrastructure management. It can deploy services, scale them, check health, and rollback if needed. This demonstrates how AI can take on complex operational tasks, reducing the burden on human DevOps teams.

---

### Slide S10.4: AI Data Analyst
```
┌─────────────────────────────────────────────────────────────────────┐
│              AI DATA ANALYST                                        │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              PROJECT OVERVIEW                                │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  An AI assistant that can query databases, generate        │   │
│  │  reports, visualize data, and provide insights using       │   │
│  │  natural language.                                          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              CAPABILITIES                                    │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Query PostgreSQL/SQLite databases                       │   │
│  │  ✅ Analyze data for trends and patterns                   │   │
│  │  ✅ Generate reports                                       │   │
│  │  ✅ Visualize data (charts, graphs)                        │   │
│  │  ✅ Provide business insights                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              USE CASE                                        │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  User: "What were the sales trends for Q4 2024?"          │   │
│  │  → Assistant queries the database                          │   │
│  │  → Assistant analyzes the data                            │   │
│  │  → Assistant generates a report with trends               │   │
│  │  → Assistant creates a visualization                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
The AI Data Analyst makes data accessible through natural language. Users can ask questions in plain English, and the AI translates them into SQL queries, analyzes the results, and provides insights. This democratizes data access in organizations.

---

## CONCLUSION SLIDES

### Slide C.1: The Complete Journey
```
┌─────────────────────────────────────────────────────────────────────┐
│              THE COMPLETE JOURNEY                                   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              WHAT YOU'VE LEARNED                            │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ✅ Built MCP servers with tools, resources, and prompts   │   │
│  │  ✅ Created production-grade MCP clients                   │   │
│  │  ✅ Integrated enterprise databases (SQLite, PostgreSQL)   │   │
│  │  ✅ Built autonomous AI agents                            │   │
│  │  ✅ Implemented A2A multi-agent collaboration             │   │
│  │  ✅ Designed advanced multi-agent architectures           │   │
│  │  ✅ Deployed production-ready AI systems                  │   │
│  │  ✅ Built real-world AI applications                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              SKILLS ACQUIRED                                 │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  🚀 Production-grade AI development                       │   │
│  │  🚀 Enterprise system integration                         │   │
│  │  🚀 Autonomous agent engineering                          │   │
│  │  🚀 Multi-agent system design                             │   │
│  │  🚀 Cloud deployment and orchestration                    │   │
│  │  🚀 Security and observability                            │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
You've completed the entire journey from AI integration fundamentals to production multi-agent systems. You now have the skills to build production-grade AI systems that integrate with enterprise systems, operate autonomously, and collaborate across agent teams.

---

### Slide C.2: Next Steps
```
┌─────────────────────────────────────────────────────────────────────┐
│              NEXT STEPS                                             │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              CONTINUE YOUR JOURNEY                           │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  1. EXTEND THE SYSTEM                               │   │   │
│  │  │     Add more specialized agents                    │   │   │
│  │  │     Integrate more data sources                     │   │   │
│  │  │     Build custom tools for your domain             │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  2. ADD MORE LLM PROVIDERS                          │   │   │
│  │  │     Support Claude, Gemini, and others              │   │   │
│  │  │     Compare model performance                      │   │   │
│  │  │     Build fallback strategies                      │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  3. CONTRIBUTE TO OPEN SOURCE                       │   │   │
│  │  │     Share improvements to MCP and A2A              │   │   │
│  │  │     Build new MCP servers                          │   │   │
│  │  │     Help grow the ecosystem                         │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  4. JOIN THE COMMUNITY                              │   │   │
│  │  │     Connect with other AI engineers                 │   │   │
│  │  │     Share your projects                             │   │   │
│  │  │     Stay updated on protocol developments          │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Your journey doesn't end here. The skills you've learned are the foundation for building increasingly sophisticated AI systems. Extend, experiment, and contribute to the growing MCP and A2A ecosystem.

---

### Slide C.3: Thank You
```
┌─────────────────────────────────────────────────────────────────────┐
│              THANK YOU                                              │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                                                             │   │
│  │       MASTERING AI INTEGRATION WITH MCP AND A2A            │   │
│  │                     USING JAVASCRIPT                        │   │
│  │                                                             │   │
│  │                    SERIES COMPLETE                          │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  "The best way to predict the future is to        │   │   │
│  │  │   build it yourself."                             │   │   │
│  │  │                          — Alan Kay                │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  QUESTIONS?                                        │   │   │
│  │  │  Let's keep building the future of AI together!   │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  │                                                             │   │
│  │  🔗 Resources:                                             │   │
│  │  • MCP Specification: modelcontextprotocol.io              │   │
│  │  • A2A Protocol: a2a-protocol.org                         │   │
│  │  • GitHub: github.com/modelcontextprotocol                │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
Thank you for completing this comprehensive journey. You've built the skills to build the future of AI. Keep experimenting, keep building, and keep contributing to the community. The best way to predict the future is to build it yourself.

---

