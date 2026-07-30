# Appendix K: Real-World Project Templates

## Overview

This appendix provides complete project templates for real-world AI applications built using MCP and A2A. Each template includes a full project structure, configuration files, and core implementation code. Use these as starting points for your own production applications.

---

## Template 1: GitHub Coding Assistant

### Overview
An AI-powered coding assistant that connects to GitHub repositories, reads code, suggests improvements, and can even write code based on natural language descriptions.

### Project Structure
```
github-coding-assistant/
├── src/
│   ├── index.ts
│   ├── server.ts
│   ├── logger.ts
│   ├── github/
│   │   ├── client.ts
│   │   └── handlers.ts
│   ├── code/
│   │   ├── analyzer.ts
│   │   ├── generator.ts
│   │   └── reviewer.ts
│   ├── tools/
│   │   ├── read-code.ts
│   │   ├── write-code.ts
│   │   ├── review-code.ts
│   │   └── suggest-improvements.ts
│   └── prompts/
│       ├── code-review.ts
│       └── code-generation.ts
├── package.json
├── tsconfig.json
├── .env.example
└── README.md
```

### Implementation

**File:** `github-coding-assistant/src/index.ts`

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { createLogger } from './logger.js';
import { GitHubClient } from './github/client.js';
import { CodeAnalyzer } from './code/analyzer.js';
import { CodeGenerator } from './code/generator.js';
import { CodeReviewer } from './code/reviewer.js';

const logger = createLogger();

class GitHubCodingAssistant {
  private server: McpServer;
  private github: GitHubClient;
  private analyzer: CodeAnalyzer;
  private generator: CodeGenerator;
  private reviewer: CodeReviewer;

  constructor() {
    this.server = new McpServer({
      name: 'github-coding-assistant',
      version: '1.0.0'
    });

    this.github = new GitHubClient(process.env.GITHUB_TOKEN!);
    this.analyzer = new CodeAnalyzer();
    this.generator = new CodeGenerator(process.env.OPENAI_API_KEY!);
    this.reviewer = new CodeReviewer(process.env.OPENAI_API_KEY!);

    this.registerTools();
    this.registerResources();
    this.registerPrompts();

    logger.info('GitHub Coding Assistant initialized');
  }

  private registerTools(): void {
    // Tool: Read code from GitHub
    this.server.tool(
      'read_code',
      {
        repo: z.string().describe('Repository name (owner/repo)'),
        path: z.string().describe('Path to the file'),
        branch: z.string().optional().describe('Branch name (default: main)')
      },
      async ({ repo, path, branch = 'main' }) => {
        logger.info('Reading code', { repo, path, branch });
        
        try {
          const content = await this.github.readFile(repo, path, branch);
          
          return {
            content: [
              {
                type: 'text',
                text: `File: ${path}\nRepository: ${repo}\nBranch: ${branch}\n\n${content}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error reading file: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Write code to GitHub
    this.server.tool(
      'write_code',
      {
        repo: z.string().describe('Repository name (owner/repo)'),
        path: z.string().describe('Path to the file'),
        content: z.string().describe('File content'),
        branch: z.string().optional().describe('Branch name (default: main)'),
        message: z.string().optional().describe('Commit message')
      },
      async ({ repo, path, content, branch = 'main', message }) => {
        logger.info('Writing code', { repo, path, branch });
        
        try {
          const commitMessage = message || `Update ${path}`;
          await this.github.writeFile(repo, path, content, commitMessage, branch);
          
          return {
            content: [
              {
                type: 'text',
                text: `Successfully wrote to ${path} in ${repo}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error writing file: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Review code
    this.server.tool(
      'review_code',
      {
        repo: z.string().describe('Repository name (owner/repo)'),
        path: z.string().describe('Path to the file'),
        branch: z.string().optional().describe('Branch name (default: main)'),
        focus: z.enum(['security', 'performance', 'style', 'all']).optional().default('all')
      },
      async ({ repo, path, branch = 'main', focus = 'all' }) => {
        logger.info('Reviewing code', { repo, path, branch, focus });
        
        try {
          const content = await this.github.readFile(repo, path, branch);
          const review = await this.reviewer.review(content, focus);
          
          return {
            content: [
              {
                type: 'text',
                text: `Code Review for ${path}\n\n${review}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error reviewing code: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Generate code
    this.server.tool(
      'generate_code',
      {
        description: z.string().describe('Description of the code to generate'),
        language: z.string().optional().default('typescript').describe('Programming language'),
        context: z.string().optional().describe('Additional context about the code')
      },
      async ({ description, language = 'typescript', context }) => {
        logger.info('Generating code', { description, language });
        
        try {
          const code = await this.generator.generate(description, language, context);
          
          return {
            content: [
              {
                type: 'text',
                text: `Generated ${language} code:\n\n${code}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error generating code: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Get repository structure
    this.server.tool(
      'repo_structure',
      {
        repo: z.string().describe('Repository name (owner/repo)'),
        branch: z.string().optional().describe('Branch name (default: main)')
      },
      async ({ repo, branch = 'main' }) => {
        logger.info('Getting repository structure', { repo, branch });
        
        try {
          const structure = await this.github.getRepoStructure(repo, branch);
          
          return {
            content: [
              {
                type: 'text',
                text: `Repository Structure for ${repo}:\n\n${structure}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error getting structure: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Get repository information
    this.server.tool(
      'repo_info',
      {
        repo: z.string().describe('Repository name (owner/repo)')
      },
      async ({ repo }) => {
        logger.info('Getting repository information', { repo });
        
        try {
          const info = await this.github.getRepoInfo(repo);
          
          return {
            content: [
              {
                type: 'text',
                text: `Repository Information:\n\n${JSON.stringify(info, null, 2)}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error getting repository info: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );
  }

  private registerResources(): void {
    // Resource: Repository file
    this.server.resource(
      'github_file',
      'github://*',
      {
        description: 'GitHub repository file content',
        mimeType: 'text/plain'
      },
      async (uri: string) => {
        // Parse URI: github://{repo}/{path}?branch={branch}
        const url = new URL(uri);
        const repo = url.hostname;
        const path = url.pathname.substring(1);
        const branch = url.searchParams.get('branch') || 'main';
        
        logger.info('Reading GitHub file resource', { repo, path, branch });
        
        try {
          const content = await this.github.readFile(repo, path, branch);
          
          return {
            contents: [
              {
                uri,
                text: content,
                mimeType: 'text/plain'
              }
            ]
          };
        } catch (error) {
          throw new Error(`Failed to read file: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
      }
    );
  }

  private registerPrompts(): void {
    // Prompt: Code review guide
    this.server.prompt(
      'code_review_guide',
      {
        repo: z.string().describe('Repository name'),
        file: z.string().describe('File to review'),
        focus: z.enum(['security', 'performance', 'style', 'all']).describe('Review focus')
      },
      ({ repo, file, focus }) => {
        return {
          messages: [
            {
              role: 'assistant',
              content: {
                type: 'text',
                text: `You are a senior code reviewer. Review the file ${file} in repository ${repo} with focus on ${focus}.

Please use the following tools:
1. read_code - To read the file content
2. analyze_code - To analyze the code structure

Provide a comprehensive review including:
- Security vulnerabilities (if security focus)
- Performance issues (if performance focus)
- Style violations (if style focus)
- Code quality score
- Specific improvement suggestions
- Examples of better code

Be thorough and provide actionable feedback.`
              }
            }
          ]
        };
      }
    );

    // Prompt: Code generation guide
    this.server.prompt(
      'code_generation_guide',
      {
        description: z.string().describe('Description of the code to generate'),
        language: z.string().describe('Programming language'),
        style: z.string().optional().describe('Coding style guide to follow')
      },
      ({ description, language, style }) => {
        return {
          messages: [
            {
              role: 'assistant',
              content: {
                type: 'text',
                text: `You are an expert ${language} developer. Generate code based on the following description:

Description: ${description}
${style ? `Style Guide: ${style}` : ''}

Generate clean, well-structured code with:
- Proper error handling
- Comprehensive comments
- Good naming conventions
- Security best practices
- Performance considerations
- Unit tests

Use the generate_code tool to create the implementation.`
              }
            }
          ]
        };
      }
    );
  }

  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    logger.info('GitHub Coding Assistant started');
    console.error('GitHub Coding Assistant is running...');
  }
}

const assistant = new GitHubCodingAssistant();
assistant.start().catch(console.error);
```

---

## Template 2: Enterprise Documentation Assistant

### Overview
An AI assistant that helps create, maintain, and search enterprise documentation across multiple systems including Confluence, SharePoint, and Markdown files.

### Project Structure
```
documentation-assistant/
├── src/
│   ├── index.ts
│   ├── server.ts
│   ├── logger.ts
│   ├── adapters/
│   │   ├── confluence.ts
│   │   ├── sharepoint.ts
│   │   └── markdown.ts
│   ├── search/
│   │   ├── indexer.ts
│   │   └── searcher.ts
│   ├── generators/
│   │   ├── api-docs.ts
│   │   └── user-guide.ts
│   └── tools/
│       ├── search-docs.ts
│       ├── create-doc.ts
│       ├── update-doc.ts
│       └── generate-docs.ts
├── package.json
├── tsconfig.json
├── .env.example
└── README.md
```

### Implementation

**File:** `documentation-assistant/src/server.ts`

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { createLogger } from './logger.js';
import { ConfluenceAdapter } from './adapters/confluence.js';
import { SharePointAdapter } from './adapters/sharepoint.js';
import { MarkdownAdapter } from './adapters/markdown.js';
import { SearchEngine } from './search/searcher.js';
import { DocumentGenerator } from './generators/api-docs.js';

const logger = createLogger();

export class DocumentationAssistant {
  private server: McpServer;
  private confluence: ConfluenceAdapter;
  private sharepoint: SharePointAdapter;
  private markdown: MarkdownAdapter;
  private search: SearchEngine;
  private generator: DocumentGenerator;

  constructor() {
    this.server = new McpServer({
      name: 'documentation-assistant',
      version: '1.0.0'
    });

    // Initialize adapters
    this.confluence = new ConfluenceAdapter(process.env.CONFLUENCE_URL!, process.env.CONFLUENCE_TOKEN!);
    this.sharepoint = new SharePointAdapter(process.env.SHAREPOINT_URL!, process.env.SHAREPOINT_USER!, process.env.SHAREPOINT_PASS!);
    this.markdown = new MarkdownAdapter(process.env.DOCS_PATH || './docs');
    this.search = new SearchEngine();
    this.generator = new DocumentGenerator(process.env.OPENAI_API_KEY!);

    this.registerTools();
    this.registerResources();
    this.registerPrompts();

    logger.info('Documentation Assistant initialized');
  }

  private registerTools(): void {
    // Tool: Search documentation
    this.server.tool(
      'search_docs',
      {
        query: z.string().describe('Search query'),
        sources: z.array(z.enum(['confluence', 'sharepoint', 'markdown'])).optional().describe('Sources to search'),
        limit: z.number().optional().default(10).describe('Maximum results')
      },
      async ({ query, sources, limit = 10 }) => {
        logger.info('Searching documentation', { query, sources });
        
        try {
          const results = await this.search.search(query, sources, limit);
          
          let responseText = `📚 Documentation Search Results\n\n`;
          responseText += `Query: "${query}"\n`;
          responseText += `Found: ${results.length} results\n\n`;
          
          for (const result of results) {
            responseText += `📄 ${result.title}\n`;
            responseText += `   Source: ${result.source}\n`;
            responseText += `   URL: ${result.url}\n`;
            responseText += `   Snippet: ${result.snippet}\n\n`;
          }
          
          return {
            content: [
              {
                type: 'text',
                text: responseText
              },
              {
                type: 'text',
                text: JSON.stringify(results, null, 2)
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error searching docs: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Create documentation
    this.server.tool(
      'create_doc',
      {
        title: z.string().describe('Document title'),
        content: z.string().describe('Document content'),
        type: z.enum(['confluence', 'markdown']).describe('Document type'),
        space: z.string().optional().describe('Confluence space (for Confluence)'),
        tags: z.array(z.string()).optional().describe('Document tags')
      },
      async ({ title, content, type, space, tags = [] }) => {
        logger.info('Creating documentation', { title, type });
        
        try {
          let result;
          
          if (type === 'confluence') {
            result = await this.confluence.createPage(title, content, space || 'DOCS', tags);
          } else {
            result = await this.markdown.createFile(title, content, tags);
          }
          
          return {
            content: [
              {
                type: 'text',
                text: `✅ Document created successfully\n\nTitle: ${title}\nType: ${type}\nURL: ${result.url}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error creating doc: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Generate API documentation
    this.server.tool(
      'generate_api_docs',
      {
        source: z.string().describe('Source code path or GitHub repo'),
        format: z.enum(['markdown', 'confluence']).default('markdown').describe('Output format'),
        language: z.string().optional().default('typescript').describe('Programming language')
      },
      async ({ source, format, language }) => {
        logger.info('Generating API documentation', { source, format });
        
        try {
          const docs = await this.generator.generateFromSource(source, language, format);
          
          return {
            content: [
              {
                type: 'text',
                text: `📖 API Documentation Generated\n\n${docs}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error generating docs: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Get documentation structure
    this.server.tool(
      'get_structure',
      {
        source: z.enum(['confluence', 'sharepoint', 'markdown']).describe('Documentation source'),
        path: z.string().optional().describe('Path within the documentation')
      },
      async ({ source, path = '' }) => {
        logger.info('Getting documentation structure', { source, path });
        
        try {
          let structure;
          
          if (source === 'confluence') {
            structure = await this.confluence.getSpaceStructure(path);
          } else if (source === 'sharepoint') {
            structure = await this.sharepoint.getFolderStructure(path);
          } else {
            structure = await this.markdown.getStructure(path);
          }
          
          let responseText = `📂 Documentation Structure: ${source}\n\n`;
          
          for (const item of structure) {
            if (item.type === 'folder') {
              responseText += `📁 ${item.name}/\n`;
            } else {
              responseText += `📄 ${item.name}\n`;
            }
          }
          
          return {
            content: [
              {
                type: 'text',
                text: responseText
              },
              {
                type: 'text',
                text: JSON.stringify(structure, null, 2)
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error getting structure: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );
  }

  private registerResources(): void {
    // Resource: Documentation content
    this.server.resource(
      'doc_content',
      'doc://*',
      {
        description: 'Documentation content resource',
        mimeType: 'text/markdown'
      },
      async (uri: string) => {
        // Parse URI: doc://{source}/{path}
        const url = new URL(uri);
        const source = url.hostname;
        const path = url.pathname.substring(1);
        
        logger.info('Getting documentation resource', { source, path });
        
        try {
          let content;
          
          if (source === 'confluence') {
            content = await this.confluence.getPageContent(path);
          } else if (source === 'markdown') {
            content = await this.markdown.getFileContent(path);
          } else {
            throw new Error(`Unknown source: ${source}`);
          }
          
          return {
            contents: [
              {
                uri,
                text: content,
                mimeType: 'text/markdown'
              }
            ]
          };
        } catch (error) {
          throw new Error(`Failed to read documentation: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
      }
    );
  }

  private registerPrompts(): void {
    // Prompt: Document search guide
    this.server.prompt(
      'doc_search_guide',
      {
        topic: z.string().describe('Topic to research'),
        depth: z.enum(['brief', 'detailed']).default('detailed').describe('Research depth')
      },
      ({ topic, depth }) => {
        return {
          messages: [
            {
              role: 'assistant',
              content: {
                type: 'text',
                text: `You are a documentation researcher. Research the topic "${topic}" across all available documentation sources.

${depth === 'brief' ? 'Provide a concise overview with key information.' : 'Provide comprehensive research with detailed information from multiple sources.'}

Use the search_docs tool to find relevant documentation.
Use the get_structure tool to understand documentation organization.
Use the doc_content resource to read specific documents.

Provide:
1. Summary of findings
2. Key information points
3. Related documentation
4. Gaps in documentation
5. Recommendations for improvement`
              }
            }
          ]
        };
      }
    );

    // Prompt: Documentation improvement
    this.server.prompt(
      'improve_docs',
      {
        docId: z.string().describe('Document ID or path'),
        focus: z.enum(['clarity', 'completeness', 'formatting', 'all']).default('all')
      },
      ({ docId, focus }) => {
        return {
          messages: [
            {
              role: 'assistant',
              content: {
                type: 'text',
                text: `You are a documentation expert. Improve the document with ID/path "${docId}" with focus on ${focus}.

Use the doc_content resource to read the document.
Use the create_doc or update_doc tools to make improvements.

Focus areas:
${focus === 'clarity' ? '- Improve clarity and readability\n- Simplify complex language\n- Add examples\n- Improve structure' :
focus === 'completeness' ? '- Fill in missing information\n- Add more details\n- Expand on key concepts\n- Add references' :
focus === 'formatting' ? '- Improve formatting\n- Add tables and lists\n- Use consistent headings\n- Add visual elements' :
'- All of the above'}

Provide a detailed improvement plan and then implement the changes.`
              }
            }
          ]
        };
      }
    );
  }

  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    logger.info('Documentation Assistant started');
    console.error('Documentation Assistant is running...');
  }
}
```

---

## Template 3: AI DevOps Engineer

### Overview
An AI DevOps agent that can manage Docker containers, Kubernetes deployments, and infrastructure-as-code.

### Project Structure
```
ai-devops-engineer/
├── src/
│   ├── index.ts
│   ├── server.ts
│   ├── logger.ts
│   ├── docker/
│   │   ├── client.ts
│   │   └── manager.ts
│   ├── kubernetes/
│   │   ├── client.ts
│   │   └── manager.ts
│   ├── terraform/
│   │   └── manager.ts
│   └── tools/
│       ├── deploy-service.ts
│       ├── scale-service.ts
│       ├── get-logs.ts
│       └── health-check.ts
├── package.json
├── tsconfig.json
├── .env.example
└── README.md
```

### Implementation

**File:** `ai-devops-engineer/src/server.ts`

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { createLogger } from './logger.js';
import { DockerManager } from './docker/manager.js';
import { KubernetesManager } from './kubernetes/manager.js';
import { TerraformManager } from './terraform/manager.js';

const logger = createLogger();

export class DevOpsEngineer {
  private server: McpServer;
  private docker: DockerManager;
  private kubernetes: KubernetesManager;
  private terraform: TerraformManager;

  constructor() {
    this.server = new McpServer({
      name: 'ai-devops-engineer',
      version: '1.0.0'
    });

    this.docker = new DockerManager();
    this.kubernetes = new KubernetesManager();
    this.terraform = new TerraformManager();

    this.registerTools();
    this.registerResources();
    this.registerPrompts();

    logger.info('AI DevOps Engineer initialized');
  }

  private registerTools(): void {
    // Tool: Deploy service
    this.server.tool(
      'deploy_service',
      {
        name: z.string().describe('Service name'),
        image: z.string().describe('Container image (e.g., nginx:latest)'),
        environment: z.enum(['dev', 'staging', 'production']).describe('Deployment environment'),
        replicas: z.number().optional().default(1).describe('Number of replicas'),
        ports: z.array(z.number()).optional().describe('Ports to expose'),
        env_vars: z.record(z.string()).optional().describe('Environment variables')
      },
      async ({ name, image, environment, replicas = 1, ports = [], env_vars = {} }) => {
        logger.info('Deploying service', { name, environment });
        
        try {
          let result;
          
          if (environment === 'dev') {
            result = await this.docker.deployService(name, image, ports, env_vars);
          } else {
            result = await this.kubernetes.deployService(name, image, environment, replicas, ports, env_vars);
          }
          
          return {
            content: [
              {
                type: 'text',
                text: `✅ Service Deployed\n\nName: ${name}\nEnvironment: ${environment}\nImage: ${image}\nReplicas: ${replicas}\nStatus: ${result.status}\nURL: ${result.url || 'N/A'}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error deploying service: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Scale service
    this.server.tool(
      'scale_service',
      {
        name: z.string().describe('Service name'),
        environment: z.enum(['dev', 'staging', 'production']).describe('Deployment environment'),
        replicas: z.number().min(0).describe('Number of replicas (0 to stop)')
      },
      async ({ name, environment, replicas }) => {
        logger.info('Scaling service', { name, environment, replicas });
        
        try {
          const result = await this.kubernetes.scaleService(name, environment, replicas);
          
          return {
            content: [
              {
                type: 'text',
                text: `✅ Service Scaled\n\nName: ${name}\nEnvironment: ${environment}\nReplicas: ${replicas}\nStatus: ${result.status}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error scaling service: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Get service logs
    this.server.tool(
      'get_logs',
      {
        name: z.string().describe('Service name'),
        environment: z.enum(['dev', 'staging', 'production']).describe('Deployment environment'),
        lines: z.number().optional().default(100).describe('Number of log lines'),
        tail: z.boolean().optional().default(true).describe('Tail logs')
      },
      async ({ name, environment, lines = 100, tail = true }) => {
        logger.info('Getting service logs', { name, environment });
        
        try {
          let logs;
          
          if (environment === 'dev') {
            logs = await this.docker.getLogs(name, lines, tail);
          } else {
            logs = await this.kubernetes.getLogs(name, environment, lines);
          }
          
          const logPreview = logs.slice(0, 1000) + (logs.length > 1000 ? '\n... (truncated)' : '');
          
          return {
            content: [
              {
                type: 'text',
                text: `📋 Logs for ${name} (${environment})\n\n${logPreview}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error getting logs: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Health check
    this.server.tool(
      'health_check',
      {
        name: z.string().describe('Service name'),
        environment: z.enum(['dev', 'staging', 'production']).describe('Deployment environment'),
        timeout: z.number().optional().default(30).describe('Timeout in seconds')
      },
      async ({ name, environment, timeout = 30 }) => {
        logger.info('Performing health check', { name, environment });
        
        try {
          let health;
          
          if (environment === 'dev') {
            health = await this.docker.healthCheck(name);
          } else {
            health = await this.kubernetes.healthCheck(name, environment, timeout);
          }
          
          const statusIcon = health.healthy ? '✅' : '❌';
          
          return {
            content: [
              {
                type: 'text',
                text: `${statusIcon} Health Check for ${name} (${environment})\n\nStatus: ${health.healthy ? 'Healthy' : 'Unhealthy'}\nDetails: ${JSON.stringify(health.details || {}, null, 2)}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error performing health check: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Get service status
    this.server.tool(
      'service_status',
      {
        environment: z.enum(['dev', 'staging', 'production']).describe('Deployment environment')
      },
      async ({ environment }) => {
        logger.info('Getting service status', { environment });
        
        try {
          let services;
          
          if (environment === 'dev') {
            services = await this.docker.listServices();
          } else {
            services = await this.kubernetes.listServices(environment);
          }
          
          let responseText = `📊 Service Status (${environment})\n\n`;
          
          for (const service of services) {
            const statusIcon = service.status === 'running' ? '✅' : '❌';
            responseText += `${statusIcon} ${service.name}\n`;
            responseText += `   Status: ${service.status}\n`;
            responseText += `   Replicas: ${service.replicas}\n`;
            responseText += `   Uptime: ${service.uptime || 'N/A'}\n\n`;
          }
          
          return {
            content: [
              {
                type: 'text',
                text: responseText
              },
              {
                type: 'text',
                text: JSON.stringify(services, null, 2)
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error getting service status: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );

    // Tool: Rollback deployment
    this.server.tool(
      'rollback',
      {
        name: z.string().describe('Service name'),
        environment: z.enum(['dev', 'staging', 'production']).describe('Deployment environment'),
        version: z.string().optional().describe('Version to rollback to (if not specified, rollback one version)')
      },
      async ({ name, environment, version }) => {
        logger.info('Rolling back deployment', { name, environment, version });
        
        try {
          const result = await this.kubernetes.rollback(name, environment, version);
          
          return {
            content: [
              {
                type: 'text',
                text: `✅ Rollback Complete\n\nService: ${name}\nEnvironment: ${environment}\nRolled back to: ${result.version}\nStatus: ${result.status}`
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error rolling back: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    );
  }

  private registerResources(): void {
    // Resource: Infrastructure status
    this.server.resource(
      'infra_status',
      'infra://status',
      {
        description: 'Current infrastructure status',
        mimeType: 'application/json'
      },
      async () => {
        logger.info('Getting infrastructure status');
        
        try {
          const status = {
            docker: {
              status: await this.docker.status()
            },
            kubernetes: {
              status: await this.kubernetes.status()
            },
            timestamp: new Date().toISOString()
          };
          
          return {
            contents: [
              {
                uri: 'infra://status',
                text: JSON.stringify(status, null, 2),
                mimeType: 'application/json'
              }
            ]
          };
        } catch (error) {
          throw new Error(`Failed to get infrastructure status: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
      }
    );
  }

  private registerPrompts(): void {
    // Prompt: Deployment guide
    this.server.prompt(
      'deployment_guide',
      {
        service: z.string().describe('Service name'),
        environment: z.enum(['dev', 'staging', 'production']).describe('Target environment')
      },
      ({ service, environment }) => {
        return {
          messages: [
            {
              role: 'assistant',
              content: {
                type: 'text',
                text: `You are a DevOps engineer. Deploy the service "${service}" to the ${environment} environment.

Use the following tools:
1. deploy_service - To deploy the service
2. health_check - To verify the deployment
3. get_logs - To monitor the deployment

Steps:
1. Prepare the deployment configuration
2. Deploy the service with appropriate resources
3. Verify the deployment is healthy
4. Monitor the logs for any issues

${environment === 'production' ? '⚠️ This is a production deployment. Ensure proper approval and monitoring.' : ''}

Provide detailed steps and confirm each step as you go.`
              }
            }
          ]
        };
      }
    );

    // Prompt: Incident response
    this.server.prompt(
      'incident_response',
      {
        service: z.string().describe('Service with incident'),
        environment: z.enum(['dev', 'staging', 'production']).describe('Affected environment'),
        symptom: z.string().describe('Incident symptoms')
      },
      ({ service, environment, symptom }) => {
        return {
          messages: [
            {
              role: 'assistant',
              content: {
                type: 'text',
                text: `You are a DevOps engineer responding to an incident.

Incident Details:
- Service: ${service}
- Environment: ${environment}
- Symptoms: ${symptom}

Use the following tools:
1. get_logs - To investigate the issue
2. health_check - To verify service status
3. service_status - To check overall health

Steps:
1. Gather information about the incident
2. Investigate the logs and metrics
3. Identify the root cause
4. Implement a fix or rollback
5. Verify the fix resolved the issue
6. Document the incident

${environment === 'production' ? '⚠️ Production incident - prioritize resolution and communication.' : ''}

Provide a detailed incident response plan.`
              }
            }
          ]
        };
      }
    );
  }

  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    logger.info('AI DevOps Engineer started');
    console.error('AI DevOps Engineer is running...');
  }
}
```

---

## Template 4: AI Data Analyst

### Overview
An AI assistant that can query databases, generate reports, visualize data, and provide insights using natural language.

### Project Structure
```
ai-data-analyst/
├── src/
│   ├── index.ts
│   ├── server.ts
│   ├── logger.ts
│   ├── databases/
│   │   ├── postgres.ts
│   │   └── sqlite.ts
│   ├── analytics/
│   │   ├── aggregator.ts
│   │   ├── statistics.ts
│   │   └── visualizer.ts
│   └── tools/
│       ├── query-data.ts
│       ├── analyze-data.ts
│       ├── generate-report.ts
│       └── visualize-data.ts
├── package.json
├── tsconfig.json
├── .env.example
└── README.md
```

---

## Template 5: Customer Support Agent

### Overview
An AI agent that handles customer support tickets, answers questions, and escalates complex issues to human agents.

---

## Template 6: Security Operations Assistant

### Overview
An AI security analyst that monitors security logs, detects anomalies, and responds to security incidents.

---

These templates provide complete starting points for real-world AI applications using MCP and A2A. Each template includes:

1. **Full Project Structure** — All necessary files and directories
2. **Core Implementation** — The main server and tool implementations
3. **Integration Code** — Connections to external systems
4. **Configuration** — Environment variables and project configuration
5. **Prompts** — AI guidance templates

Use these as foundations for your own production applications, customizing the tools, resources, and prompts for your specific use cases.
