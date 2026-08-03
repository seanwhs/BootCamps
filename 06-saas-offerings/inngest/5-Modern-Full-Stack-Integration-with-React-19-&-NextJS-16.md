# Mastering Inngest: Building Reliable Serverless Workflows with Durable Execution

## Design Resilient Event-Driven Systems Without Managing Queues, Workers, or Workflow Infrastructure

---

# Part 5: Modern Full-Stack Integration with React 19 & Next.js 16

## Building Seamless User Experiences with Durable Backend Workflows

---

## Module 5.1: Next.js App Router Integration

### The Target

In this module, you'll learn how to integrate Inngest with Next.js 16's App Router, creating a seamless bridge between your React UI and durable backend workflows.

### The Concept

Full-stack integration is like **building a control panel for your workflows**:

Imagine you're building a cockpit for a spaceship (your application):

1. **Controls** (React components): Levers, buttons, and displays
2. **Communication System** (API routes): Sends commands to the ship
3. **Engine** (Inngest workflows): Executes the commands reliably
4. **Status Display** (Real-time updates): Shows what's happening

The pilot (user) interacts with the controls, which send commands through the communication system to the engine, and the status display shows real-time feedback.

In this module, we'll build this complete cockpit for our WorkflowHub application.

### The Implementation: Project Structure Setup

Let's establish the full-stack architecture:

```
workflowhub/
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   ├── inngest/
│   │   │   │   └── route.ts          # Inngest API endpoint
│   │   │   ├── workflows/
│   │   │   │   ├── trigger/
│   │   │   │   │   └── route.ts      # Trigger workflows from API
│   │   │   │   └── status/
│   │   │   │       └── [runId]/
│   │   │   │           └── route.ts  # Get workflow status
│   │   │   └── events/
│   │   │       └── route.ts           # Send events programmatically
│   │   ├── dashboard/
│   │   │   ├── page.tsx              # Dashboard with Server Components
│   │   │   └── components/
│   │   │       ├── WorkflowList.tsx  # Client component with useActionState
│   │   │       ├── WorkflowStatus.tsx # Real-time status updates
│   │   │       └── TriggerForm.tsx   # Trigger workflows from UI
│   │   ├── workflows/
│   │   │   ├── [id]/
│   │   │   │   └── page.tsx          # Single workflow view
│   │   │   └── new/
│   │   │       └── page.tsx          # Create new workflow
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── inngest/
│   │   ├── client.ts
│   │   ├── functions/
│   │   └── types/
│   └── lib/
│       ├── actions/
│       │   ├── workflow.actions.ts   # Server Actions for workflows
│       │   └── events.actions.ts     # Server Actions for events
│       └── hooks/
│           ├── useWorkflowStatus.ts   # Custom hook for workflow status
│           └── useSSE.ts              # Server-Sent Events hook
├── public/
└── package.json
```

#### Step 1: Server Actions for Workflows

Server Actions allow you to run server-side code directly from React components. Let's create actions for triggering and monitoring workflows:

```typescript
// src/lib/actions/workflow.actions.ts
'use server';

import { inngest } from '@/inngest/client';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

// Schema for triggering a workflow
const TriggerWorkflowSchema = z.object({
  workflowName: z.enum([
    'user/registered',
    'order/created',
    'invoice/generate',
    'campaign/triggered',
    'purchase/requested',
  ]),
  data: z.record(z.any()),
  userId: z.string().uuid().optional(),
});

// Server Action: Trigger a workflow
export async function triggerWorkflow(formData: FormData) {
  try {
    const rawData = {
      workflowName: formData.get('workflowName'),
      data: JSON.parse(formData.get('data') as string || '{}'),
      userId: formData.get('userId') || undefined,
    };

    const validated = TriggerWorkflowSchema.parse(rawData);

    // Send the event to Inngest
    const result = await inngest.send({
      name: validated.workflowName,
      data: validated.data,
      user: validated.userId ? { id: validated.userId } : undefined,
    });

    // Revalidate the dashboard page to show new workflow
    revalidatePath('/dashboard');

    return {
      success: true,
      runId: result.ids?.[0],
      message: 'Workflow triggered successfully',
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}

// Schema for getting workflow status
const WorkflowStatusSchema = z.object({
  runId: z.string().min(1),
});

// Server Action: Get workflow status
export async function getWorkflowStatus(runId: string) {
  try {
    const validated = WorkflowStatusSchema.parse({ runId });

    // In a real app, you'd fetch from Inngest API or database
    // For now, we'll simulate fetching from the Dev Server
    const response = await fetch(
      `http://localhost:3000/api/inngest/runs/${validated.runId}`,
      {
        headers: {
          'Content-Type': 'application/json',
        },
        cache: 'no-store', // Don't cache for real-time updates
      }
    );

    if (!response.ok) {
      throw new Error('Failed to fetch workflow status');
    }

    const data = await response.json();

    return {
      success: true,
      status: data.status,
      steps: data.steps,
      result: data.result,
      error: data.error,
      startedAt: data.startedAt,
      endedAt: data.endedAt,
      duration: data.duration,
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}

// Server Action: Cancel a workflow
export async function cancelWorkflow(runId: string) {
  try {
    // In a real app, you'd call Inngest API to cancel
    // For now, we'll simulate
    await new Promise((resolve) => setTimeout(resolve, 500));

    revalidatePath(`/workflows/${runId}`);

    return {
      success: true,
      message: 'Workflow cancelled successfully',
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}

// Server Action: Get all workflows for a user
export async function getUserWorkflows(userId: string) {
  try {
    // In a real app, you'd fetch from database
    // For now, we'll simulate
    const mockWorkflows = [
      {
        id: 'run_123',
        name: 'User Registration',
        status: 'completed',
        startedAt: new Date(Date.now() - 300000).toISOString(),
      },
      {
        id: 'run_456',
        name: 'Order Processing',
        status: 'running',
        startedAt: new Date(Date.now() - 60000).toISOString(),
      },
      {
        id: 'run_789',
        name: 'Invoice Generation',
        status: 'waiting',
        startedAt: new Date(Date.now() - 120000).toISOString(),
      },
    ];

    return {
      success: true,
      workflows: mockWorkflows,
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}
```

#### Step 2: Custom Hook for Workflow Status

Let's create a React hook for real-time workflow status updates:

```typescript
// src/lib/hooks/useWorkflowStatus.ts
import { useState, useEffect, useCallback } from 'react';
import { getWorkflowStatus } from '@/lib/actions/workflow.actions';

interface WorkflowStatus {
  status: 'pending' | 'running' | 'completed' | 'failed' | 'waiting' | 'cancelled';
  steps?: Array<{
    name: string;
    status: string;
    duration: number;
    result?: any;
  }>;
  result?: any;
  error?: string;
  startedAt?: string;
  endedAt?: string;
  duration?: number;
}

export function useWorkflowStatus(runId: string | null) {
  const [status, setStatus] = useState<WorkflowStatus | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchStatus = useCallback(async () => {
    if (!runId) return;

    setLoading(true);
    setError(null);

    try {
      const result = await getWorkflowStatus(runId);
      
      if (result.success) {
        setStatus({
          status: result.status,
          steps: result.steps,
          result: result.result,
          error: result.error,
          startedAt: result.startedAt,
          endedAt: result.endedAt,
          duration: result.duration,
        });
        
        // If workflow is still running, continue polling
        if (result.status === 'running' || result.status === 'pending') {
          // Poll again after 2 seconds
          setTimeout(fetchStatus, 2000);
        }
      } else {
        setError(result.error || 'Failed to fetch status');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  }, [runId]);

  useEffect(() => {
    fetchStatus();
  }, [fetchStatus]);

  return {
    status,
    loading,
    error,
    refetch: fetchStatus,
    isComplete: status?.status === 'completed' || status?.status === 'failed' || status?.status === 'cancelled',
    isRunning: status?.status === 'running' || status?.status === 'pending',
    isWaiting: status?.status === 'waiting',
  };
}
```

#### Step 3: Server-Sent Events for Real-Time Updates

Server-Sent Events (SSE) provide a lightweight way to push real-time updates from the server to the client:

```typescript
// src/app/api/workflows/status/stream/route.ts
import { NextRequest } from 'next/server';

// This is a Server-Sent Events endpoint for workflow status
export async function GET(request: NextRequest) {
  const runId = request.nextUrl.searchParams.get('runId');
  
  if (!runId) {
    return new Response('Missing runId', { status: 400 });
  }

  // Create a ReadableStream for SSE
  const stream = new ReadableStream({
    async start(controller) {
      // In a real app, you'd connect to a pub/sub system or Redis
      // For now, we'll simulate updates
      
      let isComplete = false;
      let attempts = 0;
      const maxAttempts = 30; // 30 * 2 seconds = 60 seconds max
      
      const sendUpdate = async () => {
        attempts++;
        
        if (attempts > maxAttempts || isComplete) {
          controller.close();
          return;
        }

        // Simulate fetching workflow status
        const status = await getWorkflowStatus(runId);
        
        if (status.success) {
          // Send the update as an SSE event
          const eventData = `data: ${JSON.stringify(status)}\n\n`;
          controller.enqueue(new TextEncoder().encode(eventData));
          
          // Check if workflow is complete
          if (['completed', 'failed', 'cancelled'].includes(status.status)) {
            isComplete = true;
            controller.close();
            return;
          }
        }

        // Wait 2 seconds before next update
        setTimeout(sendUpdate, 2000);
      };

      // Start sending updates
      sendUpdate();
    },
  });

  // Return SSE response
  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  });
}

// Helper function to get workflow status
async function getWorkflowStatus(runId: string) {
  // In a real app, you'd fetch from Inngest API or database
  // Simulate different statuses
  const statuses = ['pending', 'running', 'completed'];
  const randomStatus = statuses[Math.floor(Math.random() * statuses.length)];
  
  return {
    success: true,
    status: randomStatus,
    steps: [
      { name: 'Step 1', status: 'completed', duration: 1000 },
      { name: 'Step 2', status: 'completed', duration: 1500 },
      { name: 'Step 3', status: randomStatus === 'running' ? 'running' : 'completed', duration: 800 },
    ],
    result: randomStatus === 'completed' ? { processed: true } : undefined,
    startedAt: new Date(Date.now() - 5000).toISOString(),
  };
}
```

#### Step 4: Custom Hook for SSE

```typescript
// src/lib/hooks/useSSE.ts
import { useState, useEffect, useCallback, useRef } from 'react';

interface SSEOptions {
  onMessage?: (data: any) => void;
  onError?: (error: Event) => void;
  onOpen?: () => void;
  onClose?: () => void;
}

export function useSSE(url: string, options: SSEOptions = {}) {
  const [isConnected, setIsConnected] = useState(false);
  const [lastMessage, setLastMessage] = useState<any>(null);
  const [error, setError] = useState<Event | null>(null);
  const eventSourceRef = useRef<EventSource | null>(null);

  const connect = useCallback(() => {
    if (eventSourceRef.current) {
      eventSourceRef.current.close();
    }

    try {
      const eventSource = new EventSource(url);
      eventSourceRef.current = eventSource;

      eventSource.onopen = () => {
        setIsConnected(true);
        setError(null);
        options.onOpen?.();
      };

      eventSource.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          setLastMessage(data);
          options.onMessage?.(data);
        } catch (parseError) {
          console.error('Failed to parse SSE message:', parseError);
        }
      };

      eventSource.onerror = (event) => {
        setError(event);
        options.onError?.(event);
        setIsConnected(false);
        
        // Auto-reconnect after delay
        setTimeout(() => {
          connect();
        }, 3000);
      };

    } catch (err) {
      console.error('Failed to connect to SSE:', err);
      setError(err as Event);
    }
  }, [url, options]);

  const disconnect = useCallback(() => {
    if (eventSourceRef.current) {
      eventSourceRef.current.close();
      eventSourceRef.current = null;
      setIsConnected(false);
      options.onClose?.();
    }
  }, [options]);

  useEffect(() => {
    connect();

    return () => {
      disconnect();
    };
  }, [connect, disconnect]);

  return {
    isConnected,
    lastMessage,
    error,
    connect,
    disconnect,
    reconnect: connect,
  };
}
```

---

## Module 5.2: React 19 Action APIs and Optimistic Updates

### The Target

Learn how to use React 19's new Action APIs, including `useActionState` and `useOptimistic`, to build responsive UIs with optimistic updates.

### The Concept

React 19's Action APIs are like **predictive interfaces**:

1. **`useActionState`**: Like a form that knows its state without a server roundtrip
2. **`useOptimistic`**: Like a UI that shows what will happen before it actually happens

This creates a responsive, snappy user experience even when operations take time.

### The Implementation: AI Content Generation Dashboard

Let's build an AI content generation dashboard that uses these React 19 features:

```typescript
// src/app/dashboard/ai-content/page.tsx
'use client';

import { useActionState, useOptimistic, useState } from 'react';
import { generateAIContent } from '@/lib/actions/ai.actions';
import { useWorkflowStatus } from '@/lib/hooks/useWorkflowStatus';
import { WorkflowStatus } from '@/app/dashboard/components/WorkflowStatus';

// Initial state for the form
const initialState = {
  content: '',
  error: null,
  runId: null,
};

export default function AIContentDashboard() {
  // useActionState hook for form state management
  const [state, formAction, isPending] = useActionState(
    generateAIContent,
    initialState
  );

  // Optimistic updates for UI responsiveness
  const [optimisticContent, setOptimisticContent] = useOptimistic(
    state.content,
    (currentState, newContent: string) => newContent
  );

  // Track workflow status if we have a runId
  const { status, loading, isComplete } = useWorkflowStatus(state.runId);

  // Local state for the form
  const [prompt, setPrompt] = useState('');
  const [contentType, setContentType] = useState('blog-post');

  return (
    <div className="max-w-4xl mx-auto p-6">
      <h1 className="text-3xl font-bold mb-8">AI Content Generator</h1>
      
      {/* Form using React 19 Action */}
      <form action={formAction} className="space-y-6">
        <div>
          <label htmlFor="prompt" className="block text-sm font-medium text-gray-700 mb-2">
            Prompt
          </label>
          <textarea
            id="prompt"
            name="prompt"
            value={prompt}
            onChange={(e) => setPrompt(e.target.value)}
            rows={4}
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            placeholder="Describe what you want to generate..."
            required
          />
        </div>

        <div>
          <label htmlFor="contentType" className="block text-sm font-medium text-gray-700 mb-2">
            Content Type
          </label>
          <select
            id="contentType"
            name="contentType"
            value={contentType}
            onChange={(e) => setContentType(e.target.value)}
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="blog-post">Blog Post</option>
            <option value="social-media">Social Media Post</option>
            <option value="email">Email Newsletter</option>
            <option value="product-description">Product Description</option>
          </select>
        </div>

        <button
          type="submit"
          disabled={isPending}
          className="w-full px-6 py-3 bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          {isPending ? (
            <span className="flex items-center justify-center gap-2">
              <span className="animate-spin">⟳</span>
              Generating...
            </span>
          ) : (
            'Generate Content'
          )}
        </button>
      </form>

      {/* Error display */}
      {state.error && (
        <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-md">
          <p className="text-red-600">{state.error}</p>
        </div>
      )}

      {/* Content display with optimistic updates */}
      {(optimisticContent || state.content) && (
        <div className="mt-8 p-6 bg-white border border-gray-200 rounded-lg shadow-sm">
          <h2 className="text-xl font-semibold mb-4">Generated Content</h2>
          
          {/* Optimistic content shows immediately */}
          {optimisticContent && optimisticContent !== state.content && (
            <div className="mb-4 text-sm text-gray-500 italic">
              ✨ Updating content optimistically...
            </div>
          )}
          
          <div className="prose max-w-none">
            {optimisticContent || state.content}
          </div>
        </div>
      )}

      {/* Workflow status display */}
      {state.runId && (
        <div className="mt-8">
          <h3 className="text-lg font-semibold mb-4">Generation Status</h3>
          <WorkflowStatus runId={state.runId} />
        </div>
      )}
    </div>
  );
}
```

#### Server Action for AI Content Generation

```typescript
// src/lib/actions/ai.actions.ts
'use server';

import { inngest } from '@/inngest/client';
import { z } from 'zod';
import { revalidatePath } from 'next/cache';

// Schema for AI content generation
const AIContentSchema = z.object({
  prompt: z.string().min(10, 'Prompt must be at least 10 characters'),
  contentType: z.enum(['blog-post', 'social-media', 'email', 'product-description']),
  userId: z.string().optional(),
});

// This would be your AI content generation workflow
export async function generateAIContent(prevState: any, formData: FormData) {
  try {
    const rawData = {
      prompt: formData.get('prompt') as string,
      contentType: formData.get('contentType') as string,
      userId: formData.get('userId') as string || undefined,
    };

    const validated = AIContentSchema.parse(rawData);

    // Generate a unique ID for this generation
    const generationId = `gen-${Date.now()}-${Math.random().toString(36).substring(7)}`;

    // Send the event to Inngest
    const result = await inngest.send({
      name: 'ai/content-generation-requested',
      data: {
        generationId,
        prompt: validated.prompt,
        contentType: validated.contentType,
        userId: validated.userId || 'anonymous',
      },
      user: validated.userId ? { id: validated.userId } : undefined,
    });

    // For immediate feedback, we'll simulate an optimistic response
    // In a real app, you might generate a quick preview
    
    // Return the runId for tracking
    return {
      content: `✨ Generating ${validated.contentType} content for: "${validated.prompt.substring(0, 60)}..."`,
      error: null,
      runId: result.ids?.[0] || generationId,
    };
  } catch (error) {
    return {
      content: '',
      error: error instanceof Error ? error.message : 'Failed to generate content',
      runId: null,
    };
  }
}

// Actual AI generation workflow (runs in background)
export const aiContentGenerationWorkflow = inngest.createFunction(
  {
    id: 'ai-content-generation-workflow',
    name: 'AI Content Generation',
    description: 'Generate content using AI with durable execution',
    
    // Retry configuration
    retries: 3,
    retryDelay: '5s',
  },
  { event: 'ai/content-generation-requested' },
  async ({ event, step, logger }) => {
    const { generationId, prompt, contentType, userId } = event.data;
    
    logger.info('Starting AI content generation', { generationId, contentType });
    
    // Step 1: Validate prompt and content type
    const validation = await step.run('validate-input', async () => {
      logger.info('Validating input', { generationId });
      await new Promise((resolve) => setTimeout(resolve, 200));
      
      // In a real app, you'd check for profanity, length, etc.
      return {
        valid: true,
        validatedAt: new Date().toISOString(),
      };
    });
    
    // Step 2: Generate content using AI (simulated)
    const content = await step.run('generate-content', async () => {
      logger.info('Generating content with AI', { 
        generationId, 
        contentType,
        promptLength: prompt.length 
      });
      
      // Simulate AI generation time
      await new Promise((resolve) => setTimeout(resolve, 3000));
      
      // Simulate AI response based on content type
      let generatedContent = '';
      
      switch (contentType) {
        case 'blog-post':
          generatedContent = `# ${prompt.substring(0, 40)}...
          
## Introduction
This blog post explores the topic of ${prompt.substring(0, 30)}...

## Key Points
- Point 1: Understanding the fundamentals
- Point 2: Practical applications
- Point 3: Future implications

## Conclusion
In conclusion, ${prompt.substring(0, 20)} is an important topic that deserves attention.`;
          break;
          
        case 'social-media':
          generatedContent = `🚀 Exciting news! ${prompt.substring(0, 50)}...
          
💡 Key insight: ${prompt.substring(0, 30)}...

#innovation #tech #trending`;
          break;
          
        case 'email':
          generatedContent = `Subject: ${prompt.substring(0, 40)}
          
Dear Team,

${prompt.substring(0, 60)}...

Best regards,
Your AI Assistant`;
          break;
          
        case 'product-description':
          generatedContent = `# ${prompt.substring(0, 30)}
          
## Overview
${prompt.substring(0, 50)}...

## Features
- Feature 1: Premium quality
- Feature 2: User-friendly design
- Feature 3: Reliable performance

## Specifications
- Weight: 2.5 kg
- Dimensions: 30 x 20 x 15 cm
- Material: Premium materials`;
          break;
      }
      
      return {
        content: generatedContent,
        contentType,
        generatedAt: new Date().toISOString(),
        wordCount: generatedContent.split(' ').length,
        tokens: Math.floor(generatedContent.length / 4),
      };
    });
    
    // Step 3: Store the generated content
    const storage = await step.run('store-generated-content', async () => {
      logger.info('Storing generated content', { 
        generationId, 
        wordCount: content.wordCount 
      });
      
      await new Promise((resolve) => setTimeout(resolve, 500));
      
      return {
        stored: true,
        storageId: `content-${generationId}`,
        url: `https://storage.workflowhub.com/content/${generationId}.md`,
        storedAt: new Date().toISOString(),
      };
    });
    
    // Step 4: Notify the user
    await step.run('notify-user', async () => {
      logger.info('Notifying user of content generation', { 
        generationId, 
        userId 
      });
      
      await new Promise((resolve) => setTimeout(resolve, 300));
      
      // In a real app, you'd send an email or push notification
      return {
        notified: true,
        notifiedAt: new Date().toISOString(),
      };
    });
    
    // Return the complete result
    return {
      generationId,
      contentType,
      content: content.content,
      wordCount: content.wordCount,
      generatedAt: content.generatedAt,
      storage: storage.url,
      completedAt: new Date().toISOString(),
    };
  }
);
```

---

## Module 5.3: Real-Time Workflow Monitoring UI

### The Target

Build a comprehensive UI for monitoring and managing workflows in real-time.

### The Concept

Real-time monitoring is like **air traffic control** for your workflows:

1. **Radar** (SSE): Shows all workflows in real-time
2. **Status Board** (UI): Displays status of each workflow
3. **Controls** (Actions): Pause, cancel, or retry workflows
4. **Alerts**: Notifies when workflows need attention

### The Implementation: Workflow Monitoring Dashboard

```typescript
// src/app/dashboard/components/WorkflowStatus.tsx
'use client';

import { useWorkflowStatus } from '@/lib/hooks/useWorkflowStatus';
import { useState } from 'react';

interface WorkflowStatusProps {
  runId: string;
  showDetails?: boolean;
  onCancel?: () => void;
}

export function WorkflowStatus({ runId, showDetails = false, onCancel }: WorkflowStatusProps) {
  const { status, loading, error, refetch, isComplete, isRunning, isWaiting } = useWorkflowStatus(runId);
  const [isCancelling, setIsCancelling] = useState(false);

  const handleCancel = async () => {
    if (!window.confirm('Are you sure you want to cancel this workflow?')) {
      return;
    }

    setIsCancelling(true);
    try {
      // In a real app, you'd call a Server Action
      await new Promise((resolve) => setTimeout(resolve, 500));
      onCancel?.();
      refetch();
    } finally {
      setIsCancelling(false);
    }
  };

  if (loading && !status) {
    return (
      <div className="flex items-center gap-3 p-4 bg-gray-50 rounded-lg">
        <div className="animate-spin">⟳</div>
        <span>Loading workflow status...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
        <p className="text-red-600">Error: {error}</p>
        <button
          onClick={refetch}
          className="mt-2 px-3 py-1 bg-red-100 text-red-700 rounded hover:bg-red-200 transition-colors"
        >
          Retry
        </button>
      </div>
    );
  }

  if (!status) {
    return (
      <div className="p-4 bg-gray-50 border border-gray-200 rounded-lg">
        <p className="text-gray-600">No status available</p>
      </div>
    );
  }

  // Status color mapping
  const statusColors = {
    pending: 'bg-yellow-100 text-yellow-800',
    running: 'bg-blue-100 text-blue-800',
    completed: 'bg-green-100 text-green-800',
    failed: 'bg-red-100 text-red-800',
    waiting: 'bg-purple-100 text-purple-800',
    cancelled: 'bg-gray-100 text-gray-800',
  };

  const statusIcons = {
    pending: '⏳',
    running: '🔄',
    completed: '✅',
    failed: '❌',
    waiting: '⏰',
    cancelled: '🛑',
  };

  return (
    <div className="border border-gray-200 rounded-lg overflow-hidden">
      <div className="p-4 bg-white">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <span className="text-2xl">{statusIcons[status.status] || '⚪'}</span>
            <div>
              <span className={`px-2 py-1 text-sm font-medium rounded-full ${statusColors[status.status] || 'bg-gray-100 text-gray-800'}`}>
                {status.status.toUpperCase()}
              </span>
              {status.startedAt && (
                <span className="text-sm text-gray-500 ml-3">
                  Started: {new Date(status.startedAt).toLocaleString()}
                </span>
              )}
            </div>
          </div>
          
          <div className="flex items-center gap-2">
            <button
              onClick={refetch}
              className="px-3 py-1 text-sm bg-gray-100 hover:bg-gray-200 rounded-md transition-colors"
              disabled={loading}
            >
              ↻ Refresh
            </button>
            
            {isRunning && !isComplete && (
              <button
                onClick={handleCancel}
                disabled={isCancelling}
                className="px-3 py-1 text-sm bg-red-100 hover:bg-red-200 text-red-700 rounded-md transition-colors disabled:opacity-50"
              >
                {isCancelling ? 'Cancelling...' : 'Cancel'}
              </button>
            )}
          </div>
        </div>

        {status.duration && (
          <div className="mt-2 text-sm text-gray-500">
            Duration: {(status.duration / 1000).toFixed(1)}s
          </div>
        )}

        {status.error && (
          <div className="mt-3 p-3 bg-red-50 border border-red-200 rounded-md">
            <p className="text-sm text-red-700 font-medium">Error:</p>
            <p className="text-sm text-red-600">{status.error}</p>
          </div>
        )}
      </div>

      {/* Step details */}
      {showDetails && status.steps && status.steps.length > 0 && (
        <div className="border-t border-gray-200">
          <div className="p-4 bg-gray-50">
            <h4 className="text-sm font-medium text-gray-700 mb-3">Step Details</h4>
            <div className="space-y-2">
              {status.steps.map((step, index) => (
                <div key={index} className="flex items-center justify-between text-sm">
                  <div className="flex items-center gap-2">
                    <span className={step.status === 'completed' ? 'text-green-600' : 'text-blue-600'}>
                      {step.status === 'completed' ? '✅' : '🔄'}
                    </span>
                    <span className="font-medium">{step.name}</span>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className={`px-2 py-0.5 text-xs rounded-full ${
                      step.status === 'completed' ? 'bg-green-100 text-green-800' :
                      step.status === 'running' ? 'bg-blue-100 text-blue-800' :
                      'bg-gray-100 text-gray-800'
                    }`}>
                      {step.status}
                    </span>
                    {step.duration && (
                      <span className="text-gray-500">
                        {(step.duration / 1000).toFixed(1)}s
                      </span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Result */}
      {isComplete && status.result && (
        <div className="border-t border-gray-200">
          <div className="p-4 bg-gray-50">
            <h4 className="text-sm font-medium text-gray-700 mb-2">Result</h4>
            <pre className="text-xs bg-white p-3 rounded border border-gray-200 overflow-auto max-h-40">
              {JSON.stringify(status.result, null, 2)}
            </pre>
          </div>
        </div>
      )}
    </div>
  );
}
```

#### Live Workflow Dashboard

```typescript
// src/app/dashboard/page.tsx
'use client';

import { useState, useEffect } from 'react';
import { useSSE } from '@/lib/hooks/useSSE';
import { WorkflowStatus } from './components/WorkflowStatus';
import { TriggerForm } from './components/TriggerForm';

interface WorkflowSummary {
  id: string;
  name: string;
  status: string;
  startedAt: string;
}

export default function DashboardPage() {
  const [workflows, setWorkflows] = useState<WorkflowSummary[]>([]);
  const [selectedWorkflow, setSelectedWorkflow] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // SSE for real-time updates
  const { lastMessage, isConnected } = useSSE('/api/workflows/status/stream', {
    onMessage: (data) => {
      // Update the workflow list when new data arrives
      if (data.workflows) {
        setWorkflows(data.workflows);
      }
    },
  });

  // Fetch initial workflows
  useEffect(() => {
    async function fetchWorkflows() {
      try {
        // In a real app, you'd fetch from your API
        const mockWorkflows: WorkflowSummary[] = [
          {
            id: 'run_123',
            name: 'User Registration',
            status: 'completed',
            startedAt: new Date(Date.now() - 300000).toISOString(),
          },
          {
            id: 'run_456',
            name: 'Order Processing',
            status: 'running',
            startedAt: new Date(Date.now() - 60000).toISOString(),
          },
          {
            id: 'run_789',
            name: 'AI Content Generation',
            status: 'pending',
            startedAt: new Date(Date.now() - 120000).toISOString(),
          },
        ];
        setWorkflows(mockWorkflows);
      } catch (error) {
        console.error('Failed to fetch workflows:', error);
      } finally {
        setIsLoading(false);
      }
    }

    fetchWorkflows();
  }, []);

  return (
    <div className="max-w-7xl mx-auto p-6">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold">Workflow Dashboard</h1>
          <p className="text-gray-600 mt-1">
            {isConnected ? '🟢 Live' : '🔴 Disconnected'}
          </p>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-sm text-gray-500">
            {workflows.filter(w => w.status === 'running').length} running
          </span>
          <TriggerForm />
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <div className="bg-white p-4 rounded-lg shadow-sm border border-gray-200">
          <div className="text-sm text-gray-500">Total</div>
          <div className="text-2xl font-bold">{workflows.length}</div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border border-gray-200">
          <div className="text-sm text-gray-500">Running</div>
          <div className="text-2xl font-bold text-blue-600">
            {workflows.filter(w => w.status === 'running').length}
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border border-gray-200">
          <div className="text-sm text-gray-500">Completed</div>
          <div className="text-2xl font-bold text-green-600">
            {workflows.filter(w => w.status === 'completed').length}
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border border-gray-200">
          <div className="text-sm text-gray-500">Failed</div>
          <div className="text-2xl font-bold text-red-600">
            {workflows.filter(w => w.status === 'failed').length}
          </div>
        </div>
      </div>

      {/* Workflow List */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <div className="px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold">Recent Workflows</h2>
        </div>
        <div className="divide-y divide-gray-200">
          {isLoading ? (
            <div className="p-8 text-center text-gray-500">Loading workflows...</div>
          ) : workflows.length === 0 ? (
            <div className="p-8 text-center text-gray-500">No workflows found</div>
          ) : (
            workflows.map((workflow) => (
              <div key={workflow.id} className="p-4 hover:bg-gray-50 transition-colors cursor-pointer">
                <div className="flex items-center justify-between">
                  <div onClick={() => setSelectedWorkflow(workflow.id)}>
                    <h3 className="font-medium">{workflow.name}</h3>
                    <div className="flex items-center gap-3 mt-1">
                      <span className={`px-2 py-0.5 text-xs rounded-full ${
                        workflow.status === 'completed' ? 'bg-green-100 text-green-800' :
                        workflow.status === 'running' ? 'bg-blue-100 text-blue-800' :
                        workflow.status === 'failed' ? 'bg-red-100 text-red-800' :
                        workflow.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {workflow.status}
                      </span>
                      <span className="text-xs text-gray-500">
                        {new Date(workflow.startedAt).toLocaleString()}
                      </span>
                    </div>
                  </div>
                  <button
                    onClick={() => setSelectedWorkflow(
                      selectedWorkflow === workflow.id ? null : workflow.id
                    )}
                    className="text-sm text-blue-600 hover:text-blue-800"
                  >
                    {selectedWorkflow === workflow.id ? 'Hide Details' : 'View Details'}
                  </button>
                </div>

                {/* Expanded workflow details */}
                {selectedWorkflow === workflow.id && (
                  <div className="mt-4">
                    <WorkflowStatus 
                      runId={workflow.id} 
                      showDetails={true}
                      onCancel={() => {
                        // Refresh the list
                        setWorkflows(prev => 
                          prev.map(w => 
                            w.id === workflow.id 
                              ? { ...w, status: 'cancelled' }
                              : w
                          )
                        );
                      }}
                    />
                  </div>
                )}
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
```

#### Trigger Form Component

```typescript
// src/app/dashboard/components/TriggerForm.tsx
'use client';

import { useState } from 'react';
import { triggerWorkflow } from '@/lib/actions/workflow.actions';

interface TriggerFormProps {
  onSuccess?: (runId: string) => void;
}

export function TriggerForm({ onSuccess }: TriggerFormProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [workflowType, setWorkflowType] = useState('user/registered');
  const [eventData, setEventData] = useState('{\n  "userId": "user_123",\n  "email": "test@example.com"\n}');
  const [error, setError] = useState<string | null>(null);

  const workflowTemplates: Record<string, any> = {
    'user/registered': {
      data: {
        userId: 'user_123',
        email: 'test@example.com',
        name: 'Test User',
        plan: 'pro',
      },
    },
    'order/created': {
      data: {
        orderId: 'order_123',
        userId: 'user_123',
        total: 149.99,
        items: [
          { productId: 'prod_1', quantity: 2, price: 49.99 },
          { productId: 'prod_2', quantity: 1, price: 50.01 },
        ],
        paymentMethod: 'credit-card',
      },
    },
    'invoice/generate': {
      data: {
        orderId: 'order_123',
        userId: 'user_123',
        items: [
          { id: 'item_1', name: 'Widget', quantity: 2, unitPrice: 29.99 },
          { id: 'item_2', name: 'Gadget', quantity: 1, unitPrice: 49.99 },
        ],
        billingAddress: {
          name: 'John Doe',
          street: '123 Main St',
          city: 'Anytown',
          state: 'CA',
          postalCode: '12345',
          country: 'USA',
        },
      },
    },
    'campaign/triggered': {
      data: {
        campaignId: 'campaign_123',
        name: 'Weekly Newsletter',
        subject: 'Your Weekly Update',
        htmlContent: '<h1>Hello!</h1><p>Here is your weekly update...</p>',
        fromEmail: 'newsletter@workflowhub.com',
        recipients: [
          { id: 'user_1', email: 'user1@example.com', name: 'User One' },
          { id: 'user_2', email: 'user2@example.com', name: 'User Two' },
        ],
      },
    },
    'purchase/requested': {
      data: {
        purchaseId: 'purchase_123',
        userId: 'user_123',
        department: 'Engineering',
        amount: 7500,
        description: 'New developer workstations',
        vendor: 'TechWorks Inc',
        items: [
          { name: 'MacBook Pro', quantity: 5, unitPrice: 2499 },
          { name: 'External Monitor', quantity: 5, unitPrice: 499 },
        ],
        urgency: 'high',
        requesterEmail: 'requester@workflowhub.com',
        approverEmail: 'approver@workflowhub.com',
      },
    },
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);

    try {
      const formData = new FormData();
      formData.append('workflowName', workflowType);
      formData.append('data', eventData);

      const result = await triggerWorkflow(formData);

      if (result.success) {
        setIsOpen(false);
        onSuccess?.(result.runId);
        // Reset form
        setEventData(JSON.stringify(workflowTemplates[workflowType]?.data || {}, null, 2));
      } else {
        setError(result.error || 'Failed to trigger workflow');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setIsLoading(false);
    }
  };

  const handleWorkflowChange = (type: string) => {
    setWorkflowType(type);
    setEventData(JSON.stringify(workflowTemplates[type]?.data || {}, null, 2));
  };

  return (
    <>
      <button
        onClick={() => setIsOpen(true)}
        className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
      >
        + Trigger Workflow
      </button>

      {isOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-bold">Trigger Workflow</h2>
              <button
                onClick={() => setIsOpen(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Workflow Type
                </label>
                <select
                  value={workflowType}
                  onChange={(e) => handleWorkflowChange(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="user/registered">User Registration</option>
                  <option value="order/created">Order Created</option>
                  <option value="invoice/generate">Invoice Generation</option>
                  <option value="campaign/triggered">Email Campaign</option>
                  <option value="purchase/requested">Purchase Request</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Event Data (JSON)
                </label>
                <textarea
                  value={eventData}
                  onChange={(e) => setEventData(e.target.value)}
                  rows={8}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md font-mono text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  spellCheck={false}
                  required
                />
              </div>

              {error && (
                <div className="p-3 bg-red-50 border border-red-200 rounded-md">
                  <p className="text-sm text-red-600">{error}</p>
                </div>
              )}

              <div className="flex items-center gap-3">
                <button
                  type="submit"
                  disabled={isLoading}
                  className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 transition-colors"
                >
                  {isLoading ? 'Triggering...' : 'Trigger Workflow'}
                </button>
                <button
                  type="button"
                  onClick={() => setIsOpen(false)}
                  className="px-4 py-2 text-gray-600 hover:text-gray-800 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}
```

---

## Verification: Testing Full-Stack Integration

### Step 1: Start Development Server

```bash
# Start the Next.js development server
pnpm dev

# You should see:
# ✓ Ready in 2.3s
# - Local:        http://localhost:3000
# - Inngest Dev:  http://localhost:3000/api/inngest
```

### Step 2: Test AI Content Generation

1. Navigate to `http://localhost:3000/dashboard/ai-content`
2. Enter a prompt like "Write a blog post about serverless computing"
3. Select "Blog Post" as content type
4. Click "Generate Content"
5. You should see:
   - Immediate optimistic update
   - Loading state
   - Workflow status updates
   - Final generated content

### Step 3: Test Workflow Monitoring

1. Navigate to `http://localhost:3000/dashboard`
2. You should see:
   - List of recent workflows
   - Real-time status updates
   - Ability to view workflow details
   - Stats counters
   - Live connection status

### Step 4: Test Trigger Form

1. Click "Trigger Workflow" button
2. Select workflow type
3. Modify data if needed
4. Click "Trigger Workflow"
5. You should see:
   - Success message
   - Workflow appears in the list
   - Real-time status updates

### Step 5: Test Server Actions

```bash
# Using curl to test the API directly
curl -X POST http://localhost:3000/api/workflows/trigger \
  -H "Content-Type: application/json" \
  -d '{
    "workflowName": "user/registered",
    "data": {
      "userId": "user_123",
      "email": "test@example.com",
      "name": "Test User",
      "plan": "pro"
    }
  }'

# Expected response:
# {"success":true,"runId":"run_xxxxxxxxxxxx","message":"Workflow triggered successfully"}
```

---

## Deep Dive: React 19 Features for Workflow UIs

### useActionState Pattern

```typescript
// Complete useActionState example with workflow integration
'use client';

import { useActionState } from 'react';
import { processOrder } from '@/lib/actions/order.actions';

const initialState = {
  success: false,
  orderId: null,
  error: null,
  status: 'idle',
};

export function OrderForm() {
  const [state, formAction, isPending] = useActionState(
    async (prevState: any, formData: FormData) => {
      const result = await processOrder(formData);
      // The action can return any shape of data
      return {
        ...result,
        status: result.success ? 'completed' : 'failed',
      };
    },
    initialState
  );

  return (
    <form action={formAction}>
      <input name="orderData" />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Processing...' : 'Place Order'}
      </button>
      {state.status === 'completed' && (
        <div>Order {state.orderId} placed successfully!</div>
      )}
      {state.error && <div className="error">{state.error}</div>}
    </form>
  );
}
```

### useOptimistic for Workflow Progress

```typescript
'use client';

import { useOptimistic, useState } from 'react';

export function WorkflowProgress({ workflowId }: { workflowId: string }) {
  const [progress, setProgress] = useState({ current: 0, total: 10 });
  
  // Optimistic updates show immediate progress
  const [optimisticProgress, addOptimisticProgress] = useOptimistic(
    progress,
    (state, newProgress: number) => ({
      ...state,
      current: Math.min(state.current + newProgress, state.total),
    })
  );

  const simulateProgress = () => {
    // Optimistically update UI immediately
    addOptimisticProgress(1);
    
    // Then update the real state
    setProgress(prev => ({
      ...prev,
      current: Math.min(prev.current + 1, prev.total),
    }));
  };

  return (
    <div>
      <div className="w-full bg-gray-200 rounded-full h-2">
        <div
          className="bg-blue-600 h-2 rounded-full transition-all duration-300"
          style={{
            width: `${(optimisticProgress.current / optimisticProgress.total) * 100}%`,
          }}
        />
      </div>
      <div className="flex justify-between mt-1 text-sm text-gray-500">
        <span>
          {optimisticProgress.current} / {optimisticProgress.total}
        </span>
        <span>{Math.round((optimisticProgress.current / optimisticProgress.total) * 100)}%</span>
      </div>
      <button
        onClick={simulateProgress}
        className="mt-2 px-3 py-1 text-sm bg-blue-100 text-blue-700 rounded"
      >
        Simulate Progress
      </button>
    </div>
  );
}
```

---

## Troubleshooting Common Integration Issues

### Issue: Server Actions Not Working

**Problem:** Server Actions fail with "Action not found" errors.

**Solution:**
```typescript
// Ensure your server actions are properly configured
// next.config.js
module.exports = {
  experimental: {
    serverActions: true,
    serverActionsBodySizeLimit: '2mb',
  },
};

// Ensure actions are in the correct location
// src/lib/actions/*.actions.ts
// Files must end with .actions.ts or .actions.js
```

### Issue: SSE Not Connecting

**Problem:** Server-Sent Events fail to connect.

**Solution:**
```typescript
// Ensure SSE endpoint returns correct headers
export async function GET(request: NextRequest) {
  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache, no-transform',
      'Connection': 'keep-alive',
      'X-Accel-Buffering': 'no', // Disable nginx buffering
    },
  });
}

// Client-side: Check for connection errors
const eventSource = new EventSource(url);
eventSource.onerror = (error) => {
  console.error('SSE Error:', error);
  // Attempt to reconnect after delay
  setTimeout(() => {
    eventSource.close();
    // Create new connection
  }, 3000);
};
```

### Issue: Optimistic Updates Out of Sync

**Problem:** Optimistic UI shows different state than server.

**Solution:**
```typescript
// Use proper state management for optimistic updates
import { useOptimistic, useTransition } from 'react';

function WorkflowAction() {
  const [isPending, startTransition] = useTransition();
  const [optimisticData, setOptimisticData] = useOptimistic(
    currentData,
    (state, newData) => ({ ...state, ...newData })
  );

  const handleAction = async () => {
    // Optimistic update
    setOptimisticData({ status: 'processing' });
    
    // Actual server action
    startTransition(async () => {
      const result = await serverAction();
      // Result will reconcile with optimistic state
    });
  };
}
```

---

## What You've Accomplished

In Part 5, you've mastered full-stack integration:

1. ✅ Next.js App Router integration with Inngest
2. ✅ Server Actions for triggering workflows
3. ✅ React 19 Action APIs and `useActionState`
4. ✅ Optimistic updates with `useOptimistic`
5. ✅ Server-Sent Events for real-time updates
6. ✅ Custom hooks for workflow status
7. ✅ AI content generation dashboard
8. ✅ Workflow monitoring UI
9. ✅ Trigger form for manual workflow execution
10. ✅ Complete full-stack application architecture

You've learned:
- How to connect React UI to durable workflows
- How to build responsive UIs with optimistic updates
- How to stream real-time workflow status
- How to use React 19's new Action APIs
- Best practices for full-stack workflow integration

---

## Deep Dive Reference: Full-Stack Integration Cheatsheet

### Server Action Patterns

```typescript
// Pattern 1: Basic action
'use server';
export async function myAction(data: any) {
  // Server-side logic
  return result;
}

// Pattern 2: Action with validation
import { z } from 'zod';
const schema = z.object({ name: z.string() });
export async function validatedAction(data: unknown) {
  const valid = schema.parse(data);
  // Process valid data
}

// Pattern 3: Action with revalidation
'use server';
import { revalidatePath } from 'next/cache';
export async function actionThatUpdatesData() {
  // Update data
  revalidatePath('/dashboard');
}

// Pattern 4: Action with redirect
'use server';
import { redirect } from 'next/navigation';
export async function actionWithRedirect() {
  // Process
  redirect('/success');
}
```

### React 19 Hooks for Workflows

```typescript
// useActionState with workflows
const [state, formAction, isPending] = useActionState(
  async (prevState: any, formData: FormData) => {
    const result = await triggerWorkflow(formData);
    return { ...prevState, ...result };
  },
  initialState
);

// useOptimistic with workflow progress
const [optimisticProgress, setOptimisticProgress] = useOptimistic(
  currentProgress,
  (state, increment: number) => ({
    ...state,
    current: Math.min(state.current + increment, state.total),
  })
);

// Custom hook for workflows
function useWorkflow(runId: string) {
  const [status, setStatus] = useState(null);
  // ... implementation
  return { status, refetch, isRunning };
}
```

---

## Next Steps

In **Part 6**, we'll take everything to production:
- Production deployment strategies
- Environment configuration and secrets
- Security best practices
- Testing durable workflows
- Monitoring and observability
- Performance optimization
- Cost optimization
- Production deployment pipeline
- Workflow health dashboard
- End-to-end testing suite

---

## References

- [Next.js Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions)
- [React 19 useActionState](https://react.dev/reference/react/useActionState)
- [React 19 useOptimistic](https://react.dev/reference/react/useOptimistic)
- [Server-Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events)
- [Inngest Next.js Integration](https://www.inngest.com/docs/guides/nextjs)
