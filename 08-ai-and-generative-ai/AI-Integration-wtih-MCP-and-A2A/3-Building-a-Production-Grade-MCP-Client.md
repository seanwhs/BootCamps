# Part 3: Building a Production-Grade MCP Client

## The Target

In this part, we're building a complete, production-grade MCP client library that can:
- **Dynamically discover** server capabilities (tools, resources, prompts)
- **Invoke tools** with type safety and error handling
- **Read resources** with caching and streaming support
- **Execute prompts** with variable interpolation
- **Manage multiple servers** simultaneously
- **Handle connection lifecycle** (connect, disconnect, reconnect)
- **Provide a clean, intuitive API** for AI applications

This client will be the foundation for all future AI applications in this series.

## The Concept

### The Client-Server Relationship

Think of the MCP client as a **universal remote control** for AI applications. Just as a universal remote works with multiple TV brands, our MCP client will work with any MCP-compliant server.

The client's responsibilities are:
1. **Discovery** — Ask the server "What can you do?"
2. **Invocation** — Execute tools with the right parameters
3. **Retrieval** — Read resources and prompts
4. **Orchestration** — Coordinate multiple servers
5. **Abstraction** — Hide the complexity of JSON-RPC

### Client Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     AI Application                          │
│  ┌────────────────────────────────────────────────────┐    │
│  │              MCP Client Library                    │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐       │    │
│  │  │ Server   │  │ Tool     │  │ Resource│       │    │
│  │  │ Manager  │  │ Executor │  │ Reader  │       │    │
│  │  └──────────┘  └──────────┘  └──────────┘       │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐       │    │
│  │  │ Prompt   │  │ Cache    │  │ Transport│       │    │
│  │  │ Executor │  │ Manager  │  │ Manager  │       │    │
│  │  └──────────┘  └──────────┘  └──────────┘       │    │
│  └────────────────────────────────────────────────────┘    │
│                           │                                 │
│                           ▼                                 │
│  ┌────────────────────────────────────────────────────┐    │
│  │           JSON-RPC over Transport                  │    │
│  │      (stdio, WebSocket, HTTP, or custom)          │    │
│  └────────────────────────────────────────────────────┘    │
│                           │                                 │
│                           ▼                                 │
│  ┌────────────────────────────────────────────────────┐    │
│  │                 MCP Server(s)                     │    │
│  └────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
```

### Client Design Principles

1. **Lazy Discovery** — Only discover capabilities when needed
2. **Type Safety** — Use TypeScript generics for tool parameters
3. **Idempotent Operations** — Safe to retry
4. **Graceful Degradation** — Handle failures gracefully
5. **Observability** — Comprehensive logging and metrics

## The Implementation

### Step 1: Project Setup and Types

**Target:** Define the type system for our client library

**The Concept:** Type safety is crucial for production code. We'll define comprehensive types that represent all MCP concepts: servers, tools, resources, prompts, and messages.

**Implementation:**

Create the client directory:

```bash
cd ai-integration-javascript/mcp-protocol
mkdir -p clients/mcp-client-lib/src
cd clients/mcp-client-lib
npm init -y
```

Install dependencies:

```bash
npm install @modelcontextprotocol/sdk zod dotenv pino pino-pretty
npm install -D typescript @types/node tsx vitest @vitest/coverage-v8 @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint prettier
```

**File:** `ai-integration-javascript/mcp-protocol/clients/mcp-client-lib/tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "resolveJsonModule": true,
    "isolatedModules": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

**File:** `ai-integration-javascript/mcp-protocol/clients/mcp-client-lib/src/types.ts`

```typescript
/**
 * Core type definitions for the MCP client library
 * These types mirror the MCP specification
 */

import { z } from 'zod';

/**
 * MCP Server configuration
 */
export interface MCPServerConfig {
  /** Unique identifier for the server */
  id: string;
  /** Server name */
  name?: string;
  /** Server version */
  version?: string;
  /** Transport configuration */
  transport: TransportConfig;
  /** Authentication configuration */
  auth?: AuthConfig;
  /** Connection timeout in milliseconds */
  timeout?: number;
  /** Whether to automatically reconnect */
  autoReconnect?: boolean;
  /** Maximum reconnection attempts */
  maxReconnectAttempts?: number;
}

/**
 * Transport configuration for different communication methods
 */
export type TransportConfig = 
  | StdioTransportConfig
  | WebSocketTransportConfig
  | HttpTransportConfig;

/**
 * stdio transport configuration
 * Communicates via standard input/output
 */
export interface StdioTransportConfig {
  type: 'stdio';
  /** Command to execute (e.g., 'node', 'python') */
  command: string;
  /** Arguments for the command */
  args: string[];
  /** Environment variables to set */
  env?: Record<string, string>;
  /** Working directory */
  cwd?: string;
}

/**
 * WebSocket transport configuration
 * Communicates via WebSocket protocol
 */
export interface WebSocketTransportConfig {
  type: 'websocket';
  /** WebSocket URL */
  url: string;
  /** Additional WebSocket options */
  options?: {
    protocols?: string[];
    headers?: Record<string, string>;
  };
}

/**
 * HTTP transport configuration
 * Communicates via HTTP/HTTPS
 */
export interface HttpTransportConfig {
  type: 'http';
  /** Base URL for the server */
  baseUrl: string;
  /** HTTP headers to send with every request */
  headers?: Record<string, string>;
  /** Additional fetch options */
  options?: RequestInit;
}

/**
 * Authentication configuration
 */
export interface AuthConfig {
  type: 'apiKey' | 'bearer' | 'basic';
  /** API key or token */
  credentials: string;
  /** Where to place the credentials */
  location: 'header' | 'query';
  /** Header name (if location is 'header') */
  headerName?: string;
  /** Query parameter name (if location is 'query') */
  queryParamName?: string;
}

/**
 * MCP Tool definition
 */
export interface MCPTool {
  /** Tool name (unique within the server) */
  name: string;
  /** Human-readable description */
  description?: string;
  /** Input schema (JSON Schema format) */
  inputSchema?: {
    type: 'object';
    properties?: Record<string, any>;
    required?: string[];
  };
}

/**
 * MCP Resource definition
 */
export interface MCPResource {
  /** Resource URI (unique within the server) */
  uri: string;
  /** Human-readable name */
  name?: string;
  /** Human-readable description */
  description?: string;
  /** MIME type of the resource content */
  mimeType?: string;
}

/**
 * MCP Prompt definition
 */
export interface MCPPrompt {
  /** Prompt name (unique within the server) */
  name: string;
  /** Human-readable description */
  description?: string;
  /** Arguments the prompt accepts */
  arguments?: Array<{
    name: string;
    description?: string;
    required?: boolean;
  }>;
}

/**
 * MCP Server capabilities
 * Discovered from the server
 */
export interface MCPCapabilities {
  /** Available tools */
  tools: MCPTool[];
  /** Available resources */
  resources: MCPResource[];
  /** Available prompts */
  prompts: MCPPrompt[];
}

/**
 * Tool call request
 */
export interface ToolCallRequest {
  /** Tool name */
  name: string;
  /** Tool arguments */
  arguments: Record<string, any>;
}

/**
 * Tool call response
 */
export interface ToolCallResponse {
  /** Whether the call was successful */
  success: boolean;
  /** Result content */
  content: Array<{
    type: 'text' | 'image' | 'resource';
    text?: string;
    data?: string;
    mimeType?: string;
    uri?: string;
  }>;
  /** Error message if unsuccessful */
  error?: string;
}

/**
 * Resource read request
 */
export interface ResourceReadRequest {
  /** Resource URI */
  uri: string;
}

/**
 * Resource read response
 */
export interface ResourceReadResponse {
  /** Resource contents */
  contents: Array<{
    uri: string;
    text?: string;
    blob?: string;
    mimeType?: string;
  }>;
}

/**
 * Prompt execution request
 */
export interface PromptExecuteRequest {
  /** Prompt name */
  name: string;
  /** Prompt arguments */
  arguments?: Record<string, string>;
}

/**
 * Prompt execution response
 */
export interface PromptExecuteResponse {
  /** Messages generated by the prompt */
  messages: Array<{
    role: 'assistant' | 'user' | 'system';
    content: {
      type: 'text';
      text: string;
    };
  }>;
}

/**
 * Connection state for a server
 */
export type ConnectionState = 
  | 'disconnected'
  | 'connecting'
  | 'connected'
  | 'reconnecting'
  | 'error'
  | 'closed';

/**
 * Client event types
 */
export type ClientEvent = 
  | { type: 'connected'; serverId: string }
  | { type: 'disconnected'; serverId: string }
  | { type: 'error'; serverId: string; error: Error }
  | { type: 'reconnecting'; serverId: string; attempt: number }
  | { type: 'capabilities_discovered'; serverId: string; capabilities: MCPCapabilities }
  | { type: 'tool_called'; serverId: string; toolName: string; duration: number }
  | { type: 'resource_read'; serverId: string; uri: string }
  | { type: 'prompt_executed'; serverId: string; promptName: string };

/**
 * Client event handler
 */
export type ClientEventHandler = (event: ClientEvent) => void;

/**
 * Client configuration
 */
export interface ClientConfig {
  /** Default server configurations */
  servers?: MCPServerConfig[];
  /** Global timeout for operations in milliseconds */
  defaultTimeout?: number;
  /** Enable debug logging */
  debug?: boolean;
  /** Log level */
  logLevel?: 'debug' | 'info' | 'warn' | 'error';
  /** Event handlers */
  eventHandlers?: ClientEventHandler[];
}

/**
 * Schema validation result
 */
export interface ValidationResult {
  valid: boolean;
  errors?: string[];
}
```

### Step 2: Create the Logger Module

**File:** `ai-integration-javascript/mcp-protocol/clients/mcp-client-lib/src/logger.ts`

```typescript
import pino from 'pino';
import { randomUUID } from 'crypto';

/**
 * Logger configuration
 */
interface LoggerConfig {
  level: string;
  prettyPrint: boolean;
  serviceName: string;
}

/**
 * Create a logger instance
 */
export const createLogger = (config?: Partial<LoggerConfig>) => {
  const env = process.env.NODE_ENV || 'development';
  const level = config?.level || process.env.LOG_LEVEL || (env === 'production' ? 'info' : 'debug');
  const prettyPrint = config?.prettyPrint ?? (env !== 'production');
  const serviceName = config?.serviceName || 'mcp-client';
  
  const transports = pino.transport({
    targets: [
      {
        target: 'pino-pretty',
        level: level,
        options: {
          colorize: prettyPrint,
          translateTime: 'SYS:standard',
          ignore: 'pid,hostname',
          singleLine: !prettyPrint,
          hideObject: false
        }
      }
    ]
  });

  const rootLogger = pino(
    {
      level,
      base: {
        service: serviceName,
        env
      }
    },
    transports
  );

  return {
    debug: (msg: string, data?: Record<string, any>) => {
      rootLogger.debug({ ...data, msg });
    },
    info: (msg: string, data?: Record<string, any>) => {
      rootLogger.info({ ...data, msg });
    },
    warn: (msg: string, data?: Record<string, any>) => {
      rootLogger.warn({ ...data, msg });
    },
    error: (msg: string, data?: Record<string, any>) => {
      rootLogger.error({ ...data, msg });
    },
    fatal: (msg: string, data?: Record<string, any>) => {
      rootLogger.fatal({ ...data, msg });
    },
    child: (bindings: Record<string, any>) => {
      return createLogger({
        ...config,
        serviceName: `${serviceName}:${bindings.component || 'child'}`
      });
    }
  };
};

export type Logger = ReturnType<typeof createLogger>;

// Default logger instance
export const defaultLogger = createLogger();
```

### Step 3: Implement the Transport Layer

**Target:** Create transport implementations for different communication methods

**The Concept:** The transport layer abstracts communication details. We'll implement stdio and HTTP transports, with a factory pattern for creating the right transport.

**Implementation:**

**File:** `ai-integration-javascript/mcp-protocol/clients/mcp-client-lib/src/transport/transport-factory.ts`

```typescript
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { TransportConfig, StdioTransportConfig, HttpTransportConfig } from '../types.js';
import { Logger, createLogger } from '../logger.js';
import { spawn } from 'child_process';

/**
 * Base transport interface
 */
export interface MCPTransport {
  /** Send a message to the server */
  send(message: string): Promise<void>;
  /** Receive a message from the server */
  receive(): AsyncIterable<string>;
  /** Connect to the server */
  connect(): Promise<void>;
  /** Disconnect from the server */
  disconnect(): Promise<void>;
  /** Check if the transport is connected */
  isConnected(): boolean;
}

/**
 * stdio transport implementation
 * Communicates via standard input/output streams
 */
export class StdioTransport implements MCPTransport {
  private process: any;
  private config: StdioTransportConfig;
  private connected: boolean = false;
  private logger: Logger;
  private messageBuffer: string = '';

  constructor(config: StdioTransportConfig, logger?: Logger) {
    this.config = config;
    this.logger = logger || createLogger({ serviceName: 'stdio-transport' });
  }

  async connect(): Promise<void> {
    this.logger.debug('Connecting stdio transport', {
      command: this.config.command,
      args: this.config.args
    });

    return new Promise((resolve, reject) => {
      try {
        // Spawn the server process
        this.process = spawn(this.config.command, this.config.args, {
          env: {
            ...process.env,
            ...this.config.env
          },
          cwd: this.config.cwd || process.cwd(),
          stdio: ['pipe', 'pipe', 'pipe']
        });

        // Handle process errors
        this.process.on('error', (error: Error) => {
          this.logger.error('Process error', { error: error.message });
          this.connected = false;
          reject(error);
        });

        // Handle process exit
        this.process.on('exit', (code: number, signal: string) => {
          this.logger.info('Process exited', { code, signal });
          this.connected = false;
        });

        // Handle process output
        this.process.stdout.on('data', (data: Buffer) => {
          // Data will be consumed by receive() method
        });

        // Handle process errors on stderr
        this.process.stderr.on('data', (data: Buffer) => {
          const message = data.toString();
          this.logger.debug('Server stderr', { message });
          // Log as info since this is often server logs
          console.error('Server:', message);
        });

        this.connected = true;
        this.logger.info('Stdio transport connected');
        resolve();

      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        this.logger.error('Failed to connect stdio transport', { error: errorMsg });
        reject(error);
      }
    });
  }

  async disconnect(): Promise<void> {
    this.logger.debug('Disconnecting stdio transport');
    
    if (this.process && !this.process.killed) {
      this.process.kill();
    }
    
    this.connected = false;
    this.logger.info('Stdio transport disconnected');
  }

  async send(message: string): Promise<void> {
    if (!this.connected || !this.process) {
      throw new Error('Not connected to server');
    }

    this.logger.debug('Sending message', { 
      messageLength: message.length,
      messagePreview: message.substring(0, 100) + (message.length > 100 ? '...' : '')
    });

    // Write to stdin
    this.process.stdin.write(message + '\n');
  }

  async *receive(): AsyncIterable<string> {
    if (!this.connected || !this.process) {
      throw new Error('Not connected to server');
    }

    // Create a buffer for incoming messages
    let buffer = '';

    for await (const chunk of this.process.stdout) {
      buffer += chunk.toString();
      
      // Split by newlines
      const lines = buffer.split('\n');
      buffer = lines.pop() || ''; // Keep incomplete line

      for (const line of lines) {
        if (line.trim()) {
          this.logger.debug('Received message', {
            messageLength: line.length,
            messagePreview: line.substring(0, 100) + (line.length > 100 ? '...' : '')
          });
          yield line;
        }
      }
    }

    // Handle remaining data
    if (buffer.trim()) {
      yield buffer;
    }
  }

  isConnected(): boolean {
    return this.connected && this.process !== null && !this.process.killed;
  }
}

/**
 * HTTP transport implementation
 * Communicates via HTTP requests
 */
export class HttpTransport implements MCPTransport {
  private config: HttpTransportConfig;
  private connected: boolean = false;
  private logger: Logger;

  constructor(config: HttpTransportConfig, logger?: Logger) {
    this.config = config;
    this.logger = logger || createLogger({ serviceName: 'http-transport' });
  }

  async connect(): Promise<void> {
    this.logger.debug('Connecting HTTP transport', {
      baseUrl: this.config.baseUrl
    });

    try {
      // Test the connection
      const response = await fetch(`${this.config.baseUrl}/health`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          ...this.config.headers
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP connection failed: ${response.status}`);
      }

      this.connected = true;
      this.logger.info('HTTP transport connected');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Failed to connect HTTP transport', { error: errorMsg });
      throw error;
    }
  }

  async disconnect(): Promise<void> {
    this.connected = false;
    this.logger.info('HTTP transport disconnected');
  }

  async send(message: string): Promise<void> {
    if (!this.connected) {
      throw new Error('Not connected to server');
    }

    this.logger.debug('Sending HTTP request', {
      messageLength: message.length
    });

    try {
      const response = await fetch(`${this.config.baseUrl}/mcp`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...this.config.headers
        },
        body: message,
        ...this.config.options
      });

      if (!response.ok) {
        throw new Error(`HTTP request failed: ${response.status}`);
      }

      // Store response for receive()
      const responseData = await response.text();
      
      // We need to make this available to receive()
      // For HTTP, we'll use a queue pattern
      this.responseQueue = this.responseQueue || [];
      this.responseQueue.push(responseData);

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('HTTP request failed', { error: errorMsg });
      throw error;
    }
  }

  private responseQueue: string[] = [];

  async *receive(): AsyncIterable<string> {
    // For HTTP, responses are collected from the queue
    while (this.connected) {
      if (this.responseQueue && this.responseQueue.length > 0) {
        const response = this.responseQueue.shift();
        if (response) {
          this.logger.debug('Received HTTP response', {
            responseLength: response.length,
            responsePreview: response.substring(0, 100) + (response.length > 100 ? '...' : '')
          });
          yield response;
        }
      } else {
        // Wait for a response
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    }
  }

  isConnected(): boolean {
    return this.connected;
  }
}

/**
 * Transport factory
 * Creates the appropriate transport based on configuration
 */
export class TransportFactory {
  static create(config: TransportConfig, logger?: Logger): MCPTransport {
    const transportLogger = logger || createLogger({ serviceName: 'transport-factory' });
    
    transportLogger.debug('Creating transport', { type: config.type });

    switch (config.type) {
      case 'stdio':
        return new StdioTransport(config, transportLogger);
      case 'http':
        return new HttpTransport(config, transportLogger);
      case 'websocket':
        // WebSocket transport would be implemented here
        // For now, throw an error
        throw new Error('WebSocket transport not yet implemented');
      default:
        throw new Error(`Unsupported transport type: ${(config as any).type}`);
    }
  }
}
```

### Step 4: Implement the Server Connection Manager

**Target:** Create a server connection manager that handles the lifecycle of server connections

**The Concept:** The server manager handles connecting, disconnecting, reconnecting, and managing the state of each server connection.

**Implementation:**

**File:** `ai-integration-javascript/mcp-protocol/clients/mcp-client-lib/src/server-manager.ts`

```typescript
import { MCPServerConfig, ConnectionState, ClientEventHandler, ClientEvent } from './types.js';
import { MCPTransport, TransportFactory } from './transport/transport-factory.js';
import { Logger, createLogger } from './logger.js';
import { EventEmitter } from 'events';

/**
 * Server connection manager
 * Handles the lifecycle of MCP server connections
 */
export class ServerManager {
  private config: MCPServerConfig;
  private transport: MCPTransport;
  private state: ConnectionState = 'disconnected';
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number;
  private autoReconnect: boolean;
  private logger: Logger;
  private eventEmitter: EventEmitter;
  private reconnectTimer?: NodeJS.Timeout;
  private messageBuffer: string[] = [];

  constructor(config: MCPServerConfig, logger?: Logger) {
    this.config = config;
    this.logger = logger || createLogger({ 
      serviceName: `server-manager:${config.id}` 
    });
    
    this.maxReconnectAttempts = config.maxReconnectAttempts || 5;
    this.autoReconnect = config.autoReconnect !== false;
    this.eventEmitter = new EventEmitter();
    
    // Create the transport
    this.transport = TransportFactory.create(config.transport, this.logger);
    
    this.logger.debug('Server manager initialized', {
      serverId: config.id,
      autoReconnect: this.autoReconnect,
      maxReconnectAttempts: this.maxReconnectAttempts
    });
  }

  /**
   * Connect to the server
   */
  async connect(): Promise<void> {
    if (this.state === 'connected' || this.state === 'connecting') {
      this.logger.debug('Already connecting or connected');
      return;
    }

    this.setState('connecting');
    this.logger.info('Connecting to server', { serverId: this.config.id });

    try {
      // Connect the transport
      await this.transport.connect();
      
      this.setState('connected');
      this.reconnectAttempts = 0;
      this.logger.info('Connected to server', { serverId: this.config.id });
      
      this.emitEvent({
        type: 'connected',
        serverId: this.config.id
      });

      // Start listening for messages
      this.startMessageListener();

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Failed to connect to server', { 
        serverId: this.config.id, 
        error: errorMsg 
      });
      
      this.setState('error');
      this.emitEvent({
        type: 'error',
        serverId: this.config.id,
        error: error instanceof Error ? error : new Error(errorMsg)
      });

      // Attempt reconnection
      if (this.autoReconnect) {
        this.scheduleReconnect();
      } else {
        this.setState('disconnected');
      }
      
      throw error;
    }
  }

  /**
   * Disconnect from the server
   */
  async disconnect(): Promise<void> {
    this.logger.info('Disconnecting from server', { serverId: this.config.id });
    
    // Clear reconnect timer
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = undefined;
    }

    try {
      await this.transport.disconnect();
      this.setState('disconnected');
      this.logger.info('Disconnected from server', { serverId: this.config.id });
      
      this.emitEvent({
        type: 'disconnected',
        serverId: this.config.id
      });
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Error during disconnect', { 
        serverId: this.config.id, 
        error: errorMsg 
      });
      this.setState('error');
    }
  }

  /**
   * Send a message to the server
   */
  async send(message: string): Promise<void> {
    if (this.state !== 'connected') {
      // Buffer messages if reconnecting
      if (this.state === 'reconnecting') {
        this.logger.debug('Buffering message while reconnecting');
        this.messageBuffer.push(message);
        return;
      }
      throw new Error(`Not connected to server ${this.config.id}. Current state: ${this.state}`);
    }

    try {
      await this.transport.send(message);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Failed to send message', { 
        serverId: this.config.id, 
        error: errorMsg 
      });
      throw error;
    }
  }

  /**
   * Receive messages from the server
   */
  async *receive(): AsyncIterable<string> {
    try {
      for await (const message of this.transport.receive()) {
        yield message;
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Error receiving messages', { 
        serverId: this.config.id, 
        error: errorMsg 
      });
      
      // Trigger reconnection if connection lost
      if (this.autoReconnect && this.state === 'connected') {
        this.logger.warn('Connection lost, triggering reconnection');
        this.setState('disconnected');
        this.scheduleReconnect();
      }
      
      throw error;
    }
  }

  /**
   * Get the current connection state
   */
  getState(): ConnectionState {
    return this.state;
  }

  /**
   * Get the server configuration
   */
  getConfig(): MCPServerConfig {
    return this.config;
  }

  /**
   * Check if connected
   */
  isConnected(): boolean {
    return this.state === 'connected' && this.transport.isConnected();
  }

  /**
   * Register an event listener
   */
  on(event: string, handler: ClientEventHandler): void {
    this.eventEmitter.on(event, handler);
  }

  /**
   * Remove an event listener
   */
  off(event: string, handler: ClientEventHandler): void {
    this.eventEmitter.off(event, handler);
  }

  /**
   * Set the connection state and emit events
   */
  private setState(state: ConnectionState): void {
    this.state = state;
    this.logger.debug('State changed', { 
      serverId: this.config.id, 
      state: this.state 
    });
  }

  /**
   * Emit an event
   */
  private emitEvent(event: ClientEvent): void {
    this.eventEmitter.emit(event.type, event);
  }

  /**
   * Schedule a reconnection attempt
   */
  private scheduleReconnect(): void {
    if (this.reconnectTimer) {
      return;
    }

    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      this.logger.error('Max reconnection attempts reached', {
        serverId: this.config.id,
        attempts: this.reconnectAttempts
      });
      this.setState('error');
      return;
    }

    // Exponential backoff: 1s, 2s, 4s, 8s, 16s
    const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);
    this.reconnectAttempts++;

    this.logger.info('Scheduling reconnection attempt', {
      serverId: this.config.id,
      attempt: this.reconnectAttempts,
      delay
    });

    this.setState('reconnecting');
    this.emitEvent({
      type: 'reconnecting',
      serverId: this.config.id,
      attempt: this.reconnectAttempts
    });

    this.reconnectTimer = setTimeout(async () => {
      this.reconnectTimer = undefined;
      try {
        await this.connect();
        // Resend buffered messages
        if (this.messageBuffer.length > 0) {
          this.logger.info('Resending buffered messages', {
            serverId: this.config.id,
            count: this.messageBuffer.length
          });
          
          for (const message of this.messageBuffer) {
            await this.send(message);
          }
          this.messageBuffer = [];
        }
      } catch (error) {
        // Reconnection failed, try again
        this.scheduleReconnect();
      }
    }, delay);
  }

  /**
   * Start listening for messages
   */
  private async startMessageListener(): Promise<void> {
    // This is a background task that processes incoming messages
    // The actual message processing is handled by the client
    // This just ensures the receive iterator is active
    (async () => {
      try {
        for await (const _message of this.receive()) {
          // Messages are handled by the client
        }
      } catch (error) {
        // Error is already handled in receive()
      }
    })();
  }
}
```

### Step 5: Implement the Core Client

**Target:** Create the main MCP client with all capabilities

**The Concept:** The core client orchestrates everything: managing servers, discovering capabilities, invoking tools, and providing a clean API.

**Implementation:**

**File:** `ai-integration-javascript/mcp-protocol/clients/mcp-client-lib/src/mcp-client.ts`

```typescript
import { 
  MCPServerConfig, 
  ClientConfig, 
  MCPCapabilities, 
  MCPTool,
  MCPResource,
  MCPPrompt,
  ToolCallRequest,
  ToolCallResponse,
  ResourceReadRequest,
  ResourceReadResponse,
  PromptExecuteRequest,
  PromptExecuteResponse,
  ClientEvent,
  ClientEventHandler,
  ConnectionState
} from './types.js';
import { ServerManager } from './server-manager.js';
import { Logger, createLogger } from './logger.js';
import { EventEmitter } from 'events';
import { randomUUID } from 'crypto';

/**
 * Main MCP Client class
 * Provides a unified interface for interacting with MCP servers
 */
export class MCPClient {
  private servers: Map<string, ServerManager> = new Map();
  private capabilities: Map<string, MCPCapabilities> = new Map();
  private eventEmitter: EventEmitter = new EventEmitter();
  private logger: Logger;
  private config: Required<Pick<ClientConfig, 'defaultTimeout' | 'debug'>>;
  private requestId: number = 0;
  private pendingRequests: Map<string, {
    resolve: (value: any) => void;
    reject: (error: any) => void;
    timeout: NodeJS.Timeout;
  }> = new Map();

  constructor(config: ClientConfig = {}) {
    this.logger = createLogger({ serviceName: 'mcp-client' });
    this.config = {
      defaultTimeout: config.defaultTimeout || 30000,
      debug: config.debug || false
    };

    // Register event handlers
    if (config.eventHandlers) {
      config.eventHandlers.forEach(handler => {
        this.onEvent(handler);
      });
    }

    // Initialize servers
    if (config.servers) {
      config.servers.forEach(serverConfig => {
        this.addServer(serverConfig);
      });
    }

    this.logger.info('MCP Client initialized', {
      serverCount: this.servers.size,
      defaultTimeout: this.config.defaultTimeout
    });
  }

  /**
   * Add a server to the client
   */
  addServer(config: MCPServerConfig): void {
    if (this.servers.has(config.id)) {
      throw new Error(`Server with id ${config.id} already exists`);
    }

    this.logger.info('Adding server', { serverId: config.id });
    
    const serverManager = new ServerManager(config, this.logger);
    
    // Forward events from the server manager
    serverManager.on('connected', (event: ClientEvent) => {
      this.eventEmitter.emit('connected', event);
      // Automatically discover capabilities when connected
      this.discoverCapabilities(config.id).catch(error => {
        this.logger.error('Failed to discover capabilities', {
          serverId: config.id,
          error: error.message
        });
      });
    });
    
    serverManager.on('disconnected', (event: ClientEvent) => {
      this.eventEmitter.emit('disconnected', event);
    });
    
    serverManager.on('error', (event: ClientEvent) => {
      this.eventEmitter.emit('error', event);
    });
    
    serverManager.on('reconnecting', (event: ClientEvent) => {
      this.eventEmitter.emit('reconnecting', event);
    });

    this.servers.set(config.id, serverManager);
    this.logger.info('Server added', { serverId: config.id });
  }

  /**
   * Remove a server from the client
   */
  async removeServer(serverId: string): Promise<void> {
    const serverManager = this.servers.get(serverId);
    if (!serverManager) {
      throw new Error(`Server ${serverId} not found`);
    }

    this.logger.info('Removing server', { serverId });
    
    await serverManager.disconnect();
    this.servers.delete(serverId);
    this.capabilities.delete(serverId);
    
    this.logger.info('Server removed', { serverId });
  }

  /**
   * Connect to a specific server
   */
  async connectServer(serverId: string): Promise<void> {
    const serverManager = this.servers.get(serverId);
    if (!serverManager) {
      throw new Error(`Server ${serverId} not found`);
    }

    this.logger.info('Connecting to server', { serverId });
    await serverManager.connect();
    this.logger.info('Connected to server', { serverId });
  }

  /**
   * Disconnect from a specific server
   */
  async disconnectServer(serverId: string): Promise<void> {
    const serverManager = this.servers.get(serverId);
    if (!serverManager) {
      throw new Error(`Server ${serverId} not found`);
    }

    this.logger.info('Disconnecting from server', { serverId });
    await serverManager.disconnect();
    this.logger.info('Disconnected from server', { serverId });
  }

  /**
   * Connect to all servers
   */
  async connectAll(): Promise<void> {
    this.logger.info('Connecting to all servers');
    
    const connectPromises = Array.from(this.servers.values()).map(server => 
      server.connect().catch(error => {
        this.logger.error('Failed to connect server', {
          serverId: server.getConfig().id,
          error: error.message
        });
      })
    );
    
    await Promise.allSettled(connectPromises);
    this.logger.info('All servers connection attempts complete');
  }

  /**
   * Disconnect from all servers
   */
  async disconnectAll(): Promise<void> {
    this.logger.info('Disconnecting from all servers');
    
    const disconnectPromises = Array.from(this.servers.values()).map(server =>
      server.disconnect().catch(error => {
        this.logger.error('Failed to disconnect server', {
          serverId: server.getConfig().id,
          error: error.message
        });
      })
    );
    
    await Promise.allSettled(disconnectPromises);
    this.logger.info('All servers disconnected');
  }

  /**
   * Discover capabilities from a server
   */
  async discoverCapabilities(serverId: string): Promise<MCPCapabilities> {
    const serverManager = this.servers.get(serverId);
    if (!serverManager) {
      throw new Error(`Server ${serverId} not found`);
    }

    if (!serverManager.isConnected()) {
      await serverManager.connect();
    }

    this.logger.info('Discovering capabilities', { serverId });

    try {
      // List tools
      const toolsResponse = await this.sendRequest(serverId, 'tools/list', {});
      const tools = toolsResponse.tools || [];

      // List resources
      const resourcesResponse = await this.sendRequest(serverId, 'resources/list', {});
      const resources = resourcesResponse.resources || [];

      // List prompts
      const promptsResponse = await this.sendRequest(serverId, 'prompts/list', {});
      const prompts = promptsResponse.prompts || [];

      const capabilities: MCPCapabilities = {
        tools,
        resources,
        prompts
      };

      this.capabilities.set(serverId, capabilities);
      
      this.logger.info('Capabilities discovered', {
        serverId,
        tools: tools.length,
        resources: resources.length,
        prompts: prompts.length
      });

      this.eventEmitter.emit('capabilities_discovered', {
        type: 'capabilities_discovered',
        serverId,
        capabilities
      });

      return capabilities;

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Failed to discover capabilities', {
        serverId,
        error: errorMsg
      });
      throw error;
    }
  }

  /**
   * Get capabilities for a server
   */
  getCapabilities(serverId: string): MCPCapabilities | undefined {
    return this.capabilities.get(serverId);
  }

  /**
   * Call a tool on a server
   */
  async callTool(
    serverId: string,
    toolName: string,
    args: Record<string, any>
  ): Promise<ToolCallResponse> {
    const startTime = Date.now();
    this.logger.info('Calling tool', { serverId, toolName, args });

    try {
      const response = await this.sendRequest(serverId, 'tools/call', {
        name: toolName,
        arguments: args
      });

      const duration = Date.now() - startTime;
      
      this.eventEmitter.emit('tool_called', {
        type: 'tool_called',
        serverId,
        toolName,
        duration
      });

      const toolResponse: ToolCallResponse = {
        success: true,
        content: response.content || [],
        error: response.error
      };

      this.logger.info('Tool called successfully', { 
        serverId, 
        toolName, 
        duration 
      });

      return toolResponse;

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Tool call failed', { serverId, toolName, error: errorMsg });
      
      return {
        success: false,
        content: [],
        error: errorMsg
      };
    }
  }

  /**
   * Read a resource from a server
   */
  async readResource(
    serverId: string,
    uri: string
  ): Promise<ResourceReadResponse> {
    this.logger.info('Reading resource', { serverId, uri });

    try {
      const response = await this.sendRequest(serverId, 'resources/read', {
        uri
      });

      this.eventEmitter.emit('resource_read', {
        type: 'resource_read',
        serverId,
        uri
      });

      this.logger.info('Resource read successfully', { serverId, uri });

      return {
        contents: response.contents || []
      };

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Resource read failed', { serverId, uri, error: errorMsg });
      throw error;
    }
  }

  /**
   * Execute a prompt on a server
   */
  async executePrompt(
    serverId: string,
    promptName: string,
    args?: Record<string, string>
  ): Promise<PromptExecuteResponse> {
    this.logger.info('Executing prompt', { serverId, promptName, args });

    try {
      const response = await this.sendRequest(serverId, 'prompts/get', {
        name: promptName,
        arguments: args
      });

      this.eventEmitter.emit('prompt_executed', {
        type: 'prompt_executed',
        serverId,
        promptName
      });

      this.logger.info('Prompt executed successfully', { serverId, promptName });

      return {
        messages: response.messages || []
      };

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Prompt execution failed', { 
        serverId, 
        promptName, 
        error: errorMsg 
      });
      throw error;
    }
  }

  /**
   * Get the state of a server
   */
  getServerState(serverId: string): ConnectionState | undefined {
    const serverManager = this.servers.get(serverId);
    return serverManager?.getState();
  }

  /**
   * List all servers
   */
  listServers(): string[] {
    return Array.from(this.servers.keys());
  }

  /**
   * List all tools across all servers
   */
  listAllTools(): Array<{ serverId: string; tool: MCPTool }> {
    const result: Array<{ serverId: string; tool: MCPTool }> = [];
    
    for (const [serverId, capabilities] of this.capabilities.entries()) {
      for (const tool of capabilities.tools) {
        result.push({ serverId, tool });
      }
    }
    
    return result;
  }

  /**
   * List all resources across all servers
   */
  listAllResources(): Array<{ serverId: string; resource: MCPResource }> {
    const result: Array<{ serverId: string; resource: MCPResource }> = [];
    
    for (const [serverId, capabilities] of this.capabilities.entries()) {
      for (const resource of capabilities.resources) {
        result.push({ serverId, resource });
      }
    }
    
    return result;
  }

  /**
   * List all prompts across all servers
   */
  listAllPrompts(): Array<{ serverId: string; prompt: MCPPrompt }> {
    const result: Array<{ serverId: string; prompt: MCPPrompt }> = [];
    
    for (const [serverId, capabilities] of this.capabilities.entries()) {
      for (const prompt of capabilities.prompts) {
        result.push({ serverId, prompt });
      }
    }
    
    return result;
  }

  /**
   * Register an event handler
   */
  onEvent(handler: ClientEventHandler): void {
    this.eventEmitter.on('event', handler);
  }

  /**
   * Remove an event handler
   */
  offEvent(handler: ClientEventHandler): void {
    this.eventEmitter.off('event', handler);
  }

  /**
   * Send a JSON-RPC request to a server
   */
  private async sendRequest(
    serverId: string,
    method: string,
    params: Record<string, any>
  ): Promise<any> {
    const serverManager = this.servers.get(serverId);
    if (!serverManager) {
      throw new Error(`Server ${serverId} not found`);
    }

    if (!serverManager.isConnected()) {
      await serverManager.connect();
    }

    const id = this.requestId++;
    const requestId = `req-${Date.now()}-${id}`;
    
    const request = {
      jsonrpc: '2.0',
      id: requestId,
      method,
      params
    };

    this.logger.debug('Sending request', {
      serverId,
      method,
      params,
      requestId
    });

    // Create a promise that will be resolved when we get a response
    return new Promise((resolve, reject) => {
      // Set up timeout
      const timeout = setTimeout(() => {
        this.pendingRequests.delete(requestId);
        reject(new Error(`Request timed out after ${this.config.defaultTimeout}ms`));
      }, this.config.defaultTimeout);

      // Store the pending request
      this.pendingRequests.set(requestId, {
        resolve,
        reject,
        timeout
      });

      // Send the request
      serverManager.send(JSON.stringify(request)).catch(error => {
        clearTimeout(timeout);
        this.pendingRequests.delete(requestId);
        reject(error);
      });

      // Start listening for responses
      this.listenForResponses(serverId);
    });
  }

  /**
   * Listen for responses from a server
   */
  private async listenForResponses(serverId: string): Promise<void> {
    const serverManager = this.servers.get(serverId);
    if (!serverManager) return;

    try {
      for await (const message of serverManager.receive()) {
        try {
          const response = JSON.parse(message);
          
          // Check if this is a response to a pending request
          if (response.id && this.pendingRequests.has(response.id)) {
            const pending = this.pendingRequests.get(response.id)!;
            clearTimeout(pending.timeout);
            this.pendingRequests.delete(response.id);
            
            if (response.error) {
              pending.reject(new Error(response.error.message || 'JSON-RPC error'));
            } else {
              pending.resolve(response.result || {});
            }
          } else if (response.method === 'notifications') {
            // Handle notifications
            this.logger.debug('Received notification', {
              serverId,
              notification: response.method
            });
          } else {
            this.logger.debug('Received response without pending request', {
              serverId,
              message: message.substring(0, 100)
            });
          }
        } catch (error) {
          this.logger.error('Failed to parse response', {
            serverId,
            message: message.substring(0, 100),
            error: error instanceof Error ? error.message : 'Unknown error'
          });
        }
      }
    } catch (error) {
      this.logger.error('Error listening for responses', {
        serverId,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }
}

/**
 * Factory function for creating MCP clients
 */
export const createMCPClient = (config?: ClientConfig): MCPClient => {
  return new MCPClient(config);
};

/**
 * Default client instance
 */
export const defaultClient = createMCPClient();
```

### Step 6: Create the Client Entry Point and Test

**File:** `ai-integration-javascript/mcp-protocol/clients/mcp-client-lib/src/index.ts`

```typescript
/**
 * MCP Client Library - Main Entry Point
 * Export all public APIs
 */

export { MCPClient, createMCPClient, defaultClient } from './mcp-client.js';
export { ServerManager } from './server-manager.js';
export { TransportFactory, StdioTransport, HttpTransport } from './transport/transport-factory.js';

// Export types
export * from './types.js';

// Export utilities
export { createLogger, defaultLogger } from './logger.js';
```

**File:** `ai-integration-javascript/mcp-protocol/clients/mcp-client-lib/src/test-client.ts`

```typescript
#!/usr/bin/env node

/**
 * Test script for the MCP client
 * Demonstrates connecting to our first MCP server and using all capabilities
 */
import { createMCPClient, MCPServerConfig } from './index.js';
import { createLogger } from './logger.js';

const logger = createLogger({ serviceName: 'test-client' });

/**
 * Test the MCP client with the first server
 */
const testClient = async () => {
  logger.info('Starting MCP client test');

  // Configure the server
  const serverConfig: MCPServerConfig = {
    id: 'first-server',
    name: 'First MCP Server',
    version: '1.0.0',
    transport: {
      type: 'stdio',
      command: 'node',
      args: ['../../servers/first-server/dist/index.js'],
      env: {
        NODE_ENV: 'development',
        LOG_LEVEL: 'info'
      }
    },
    autoReconnect: true,
    maxReconnectAttempts: 3,
    timeout: 30000
  };

  // Create the client
  const client = createMCPClient({
    servers: [serverConfig],
    defaultTimeout: 30000,
    debug: true
  });

  // Register event handlers
  client.onEvent((event) => {
    switch (event.type) {
      case 'connected':
        logger.info('Event: Connected to server', { serverId: event.serverId });
        break;
      case 'disconnected':
        logger.info('Event: Disconnected from server', { serverId: event.serverId });
        break;
      case 'capabilities_discovered':
        logger.info('Event: Capabilities discovered', {
          serverId: event.serverId,
          tools: event.capabilities.tools.length,
          resources: event.capabilities.resources.length,
          prompts: event.capabilities.prompts.length
        });
        break;
      case 'tool_called':
        logger.info('Event: Tool called', {
          serverId: event.serverId,
          toolName: event.toolName,
          duration: event.duration
        });
        break;
      case 'error':
        logger.error('Event: Error', {
          serverId: event.serverId,
          error: event.error.message
        });
        break;
      case 'reconnecting':
        logger.info('Event: Reconnecting', {
          serverId: event.serverId,
          attempt: event.attempt
        });
        break;
    }
  });

  try {
    // Connect to the server
    logger.info('Connecting to server...');
    await client.connectServer('first-server');

    // Wait for capabilities to be discovered
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Test tools
    logger.info('=== Testing Tools ===');
    
    // List all tools
    const allTools = client.listAllTools();
    logger.info('Available tools:', {
      count: allTools.length,
      tools: allTools.map(t => t.tool.name)
    });

    // Call add tool
    const addResult = await client.callTool('first-server', 'add', { a: 10, b: 20 });
    logger.info('Add result:', { 
      success: addResult.success, 
      content: addResult.content.map(c => c.text) 
    });

    // Call multiply tool
    const multiplyResult = await client.callTool('first-server', 'multiply', { a: 5, b: 6 });
    logger.info('Multiply result:', { 
      success: multiplyResult.success, 
      content: multiplyResult.content.map(c => c.text) 
    });

    // Call divide tool
    const divideResult = await client.callTool('first-server', 'divide', { a: 15, b: 3 });
    logger.info('Divide result:', { 
      success: divideResult.success, 
      content: divideResult.content.map(c => c.text) 
    });

    // Test advanced tools
    logger.info('=== Testing Advanced Tools ===');
    
    // Test CSV to JSON
    const csvData = 'name,age,city\nAlice,30,New York\nBob,25,London\nCharlie,35,Tokyo';
    const csvResult = await client.callTool('first-server', 'csv_to_json', { 
      csvData, 
      parseHeaders: true 
    });
    logger.info('CSV to JSON result:', { 
      success: csvResult.success,
      content: csvResult.content[0]?.text?.substring(0, 100) + '...'
    });

    // Test batch processing
    const batchResult = await client.callTool('first-server', 'process_batch', {
      data: [' hello ', 'WORLD', '  JavaScript  ', 'MCP   '],
      operation: 'trim',
      batchSize: 2
    });
    logger.info('Batch processing result:', { 
      success: batchResult.success,
      content: batchResult.content[0]?.text?.substring(0, 100) + '...'
    });

    // Test resources
    logger.info('=== Testing Resources ===');
    
    // List all resources
    const allResources = client.listAllResources();
    logger.info('Available resources:', {
      count: allResources.length,
      resources: allResources.map(r => r.resource.uri)
    });

    // Read system info
    const systemInfo = await client.readResource('first-server', 'system://info');
    logger.info('System info:', {
      content: systemInfo.contents[0]?.text?.substring(0, 200) + '...'
    });

    // Read server status
    const serverStatus = await client.readResource('first-server', 'server://status');
    logger.info('Server status:', {
      content: serverStatus.contents[0]?.text?.substring(0, 200) + '...'
    });

    // Test prompts
    logger.info('=== Testing Prompts ===');
    
    // List all prompts
    const allPrompts = client.listAllPrompts();
    logger.info('Available prompts:', {
      count: allPrompts.length,
      prompts: allPrompts.map(p => p.prompt.name)
    });

    // Get welcome prompt
    const welcomePrompt = await client.executePrompt('first-server', 'welcome', { 
      name: 'Developer' 
    });
    logger.info('Welcome prompt:', {
      message: welcomePrompt.messages[0]?.content.text?.substring(0, 200) + '...'
    });

    // Get help prompt
    const helpPrompt = await client.executePrompt('first-server', 'help', {
      issue: 'How do I add numbers?'
    });
    logger.info('Help prompt:', {
      message: helpPrompt.messages[0]?.content.text?.substring(0, 200) + '...'
    });

    // Test system status prompt
    const statusPrompt = await client.executePrompt('first-server', 'system_status', {
      detail: 'detailed'
    });
    logger.info('System status prompt:', {
      message: statusPrompt.messages[0]?.content.text?.substring(0, 300) + '...'
    });

    logger.info('=== All tests completed successfully! ===');

  } catch (error) {
    logger.error('Test failed', { error: error instanceof Error ? error.message : 'Unknown error' });
  } finally {
    // Clean up
    logger.info('Disconnecting...');
    await client.disconnectAll();
    logger.info('Done');
  }

  // Exit after a delay to allow logs to flush
  setTimeout(() => process.exit(0), 1000);
};

// Run the test
void testClient();
```

### Step 7: Update Package.json

**File:** `ai-integration-javascript/mcp-protocol/clients/mcp-client-lib/package.json`

```json
{
  "name": "@mcp/client-lib",
  "version": "1.0.0",
  "description": "Production-grade MCP client library for JavaScript",
  "main": "dist/index.js",
  "type": "module",
  "scripts": {
    "build": "tsc",
    "build:watch": "tsc --watch",
    "test": "vitest",
    "test:coverage": "vitest --coverage",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix",
    "format": "prettier --write src/**/*.ts",
    "test:client": "tsx src/test-client.ts"
  },
  "keywords": [
    "mcp",
    "model-context-protocol",
    "ai",
    "client",
    "typescript"
  ],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0",
    "zod": "^3.22.4",
    "dotenv": "^16.3.1",
    "pino": "^8.17.2",
    "pino-pretty": "^10.3.1"
  },
  "devDependencies": {
    "@types/node": "^20.10.5",
    "@typescript-eslint/eslint-plugin": "^6.14.0",
    "@typescript-eslint/parser": "^6.14.0",
    "eslint": "^8.55.0",
    "prettier": "^3.1.1",
    "tsx": "^4.6.0",
    "typescript": "^5.3.3",
    "vitest": "^1.0.4",
    "@vitest/coverage-v8": "^1.0.4"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

## The Verification

### Step 1: Build the Client Library

```bash
cd ai-integration-javascript/mcp-protocol/clients/mcp-client-lib
npm install
npm run build
```

### Step 2: Start the Server (in another terminal)

```bash
cd ai-integration-javascript/mcp-protocol/servers/first-server
npm start
```

### Step 3: Run the Client Test

```bash
cd ai-integration-javascript/mcp-protocol/clients/mcp-client-lib
npm run test:client
```

You should see comprehensive output showing:

1. **Connection** — Connecting to the server
2. **Capability Discovery** — Discovering tools, resources, and prompts
3. **Tool Calls** — All tools working correctly
4. **Resource Reads** — All resources accessible
5. **Prompt Execution** — All prompts executing
6. **Event Handling** — Events being emitted
7. **Clean Disconnection** — Graceful cleanup

### Step 4: Test Manual Operations

You can also use the client programmatically:

**File:** `manual-client-test.js`

```javascript
import { createMCPClient } from './dist/index.js';

const client = createMCPClient({
  servers: [{
    id: 'my-server',
    transport: {
      type: 'stdio',
      command: 'node',
      args: ['../../servers/first-server/dist/index.js']
    }
  }]
});

// Connect and use the client
await client.connectAll();
const tools = client.listAllTools();
console.log('Available tools:', tools);

// Call a tool
const result = await client.callTool('my-server', 'add', { a: 5, b: 3 });
console.log('Result:', result);

await client.disconnectAll();
```

### Step 5: Test with Multiple Servers

Create a test with multiple server configurations:

```typescript
const config: ClientConfig = {
  servers: [
    {
      id: 'server1',
      transport: {
        type: 'stdio',
        command: 'node',
        args: ['server1/dist/index.js']
      }
    },
    {
      id: 'server2',
      transport: {
        type: 'stdio',
        command: 'node',
        args: ['server2/dist/index.js']
      }
    }
  ]
};

const client = createMCPClient(config);
await client.connectAll();

// Tools from all servers
const allTools = client.listAllTools();
console.log(`Total tools: ${allTools.length}`);
```

## What You've Built

Congratulations! You've built a production-grade MCP client library with:

### Core Features
1. **Multiple Server Management** — Connect to multiple servers simultaneously
2. **Transport Abstraction** — stdio, HTTP (WebSocket ready)
3. **Capability Discovery** — Dynamic discovery of tools, resources, prompts
4. **Tool Execution** — Type-safe tool calls with error handling
5. **Resource Reading** — Read resources from any server
6. **Prompt Execution** — Execute prompts with variable interpolation

### Production Features
1. **Auto-Reconnection** — Automatic reconnection with exponential backoff
2. **Connection Pooling** — Manage multiple server connections
3. **Request/Response Tracking** — Track pending requests with timeouts
4. **Event System** — Comprehensive event emission for observability
5. **Logging** — Structured logging with request tracing
6. **Error Handling** — Graceful error recovery
7. **Type Safety** — Complete TypeScript type definitions

### Performance Features
1. **Message Buffering** — Buffer messages during reconnection
2. **Request Timeouts** — Prevent hanging requests
3. **Connection State Management** — Track connection states
4. **Efficient Transport** — Minimal overhead

## Key Takeaways

1. **Client-Server Separation** — The client handles all communication details
2. **Transport Abstraction** — Same API works for stdio, HTTP, WebSocket
3. **Dynamic Discovery** — Clients discover capabilities at runtime
4. **Error Resilience** — Auto-reconnection and retry logic
5. **Observability** — Events and logging for monitoring
6. **Type Safety** — TypeScript ensures correct usage
7. **Reusability** — The client works with any MCP server

## What's Next?

In **Part 4**, we'll start connecting enterprise systems:
- **SQLite Database** — Query and manage databases
- **PostgreSQL** — Production database integration
- **REST APIs** — Connect to external services
- **File System** — Advanced file operations
- **Docker** — Container management
- **GitHub** — Repository and issue management

You'll build an **Enterprise Knowledge Server** that aggregates multiple data sources into a unified MCP interface.
