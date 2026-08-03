# Primer 4: Full-Stack Integration with Next.js & React

**Estimated Time**: 15 Minutes
**Prerequisites**: Completion of Primer 3, or basic understanding of Inngest concepts. React and Next.js knowledge assumed.

---

## 1. The Full-Stack Picture

In the previous primers, we focused on building durable workflows on the backend. Now, we'll bridge the gap between your UI and these powerful workflows, creating a seamless full-stack experience.

**What You'll Learn:**
- Setting up the Inngest API route in Next.js App Router
- Triggering workflows from React components
- Real-time status updates with Server-Sent Events (SSE)
- React 19 Action APIs for form handling
- Optimistic updates for responsive UIs

---

## 2. The Architecture

Here's how everything fits together:

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Layer                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  React 19 Components                               │  │
│  │  • useActionState for forms                       │  │
│  │  • useOptimistic for responsive UI                │  │
│  │  • useSSE for real-time updates                   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Layer                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Next.js API Routes                                │  │
│  │  • /api/inngest - Inngest endpoint                 │  │
│  │  • Server Actions (trigger workflows)              │  │
│  │  • SSE endpoint (stream status)                   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Workflow Orchestration Layer                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Inngest Durable Workflows                         │  │
│  │  • Event processing                                │  │
│  │  • State management                                │  │
│  │  • Retry & recovery                                │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Setting Up the Inngest API Route

First, ensure your Inngest endpoint is properly configured in Next.js App Router:

```typescript
// src/app/api/inngest/route.ts
import { serve } from "inngest/next";
import { inngest } from "@/inngest/client";
import { userRegistrationWorkflow } from "@/inngest/functions/user-registration";
import { orderProcessingWorkflow } from "@/inngest/functions/order-processing";

// Configure the serve handler
export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [
    userRegistrationWorkflow,
    orderProcessingWorkflow,
    // Add all your workflows here
  ],
});

// Disable Next.js body parser (Inngest handles parsing)
export const config = {
  api: {
    bodyParser: false,
  },
};
```

---

## 4. Triggering Workflows from the UI

### A. Basic Trigger with Server Action

Create a Server Action that your React component can call:

```typescript
// src/lib/actions/workflow.actions.ts
'use server';

import { inngest } from "@/inngest/client";
import { z } from "zod";
import { revalidatePath } from "next/cache";

// Define the schema for the trigger data
const TriggerOrderSchema = z.object({
  customerId: z.string().uuid(),
  items: z.array(z.object({
    productId: z.string(),
    quantity: z.number().int().positive(),
  })),
  total: z.number().positive(),
});

// Server Action to trigger the order workflow
export async function createOrder(formData: FormData) {
  try {
    const rawData = {
      customerId: formData.get('customerId'),
      items: JSON.parse(formData.get('items') as string || '[]'),
      total: parseFloat(formData.get('total') as string || '0'),
    };

    const validated = TriggerOrderSchema.parse(rawData);

    // Send the event to Inngest
    const result = await inngest.send({
      name: "order/placed",
      data: {
        orderId: `ord-${Date.now()}`,
        ...validated,
      },
      user: { id: validated.customerId },
    });

    // Revalidate the dashboard to show the new order
    revalidatePath('/dashboard');

    return {
      success: true,
      runId: result.ids?.[0],
      message: "Order created successfully",
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : "Unknown error",
    };
  }
}
```

### B. React Component with useActionState

Use React 19's `useActionState` to handle the form state:

```typescript
// src/app/dashboard/page.tsx
'use client';

import { useActionState, useState } from 'react';
import { createOrder } from '@/lib/actions/workflow.actions';

// Initial state for the form
const initialState = {
  success: false,
  error: null as string | null,
  message: null as string | null,
};

export default function OrderForm() {
  const [state, formAction, isPending] = useActionState(
    createOrder,
    initialState
  );

  const [items, setItems] = useState([
    { productId: '', quantity: 1 }
  ]);

  const addItem = () => {
    setItems([...items, { productId: '', quantity: 1 }]);
  };

  const updateItem = (index: number, field: string, value: string | number) => {
    const updated = [...items];
    updated[index] = { ...updated[index], [field]: value };
    setItems(updated);
  };

  return (
    <div className="max-w-2xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">Create Order</h1>

      <form action={formAction} className="space-y-4">
        {/* Customer ID */}
        <div>
          <label className="block text-sm font-medium text-gray-700">
            Customer ID
          </label>
          <input
            type="text"
            name="customerId"
            defaultValue="user-123"
            className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
            required
          />
        </div>

        {/* Items */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Items
          </label>
          {items.map((item, index) => (
            <div key={index} className="flex gap-2 mb-2">
              <input
                type="text"
                placeholder="Product ID"
                value={item.productId}
                onChange={(e) => updateItem(index, 'productId', e.target.value)}
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md"
              />
              <input
                type="number"
                placeholder="Quantity"
                value={item.quantity}
                onChange={(e) => updateItem(index, 'quantity', parseInt(e.target.value) || 1)}
                className="w-24 px-3 py-2 border border-gray-300 rounded-md"
                min="1"
              />
            </div>
          ))}
          <button
            type="button"
            onClick={addItem}
            className="text-sm text-blue-600 hover:text-blue-800"
          >
            + Add Item
          </button>
        </div>

        {/* Hidden fields for form submission */}
        <input
          type="hidden"
          name="items"
          value={JSON.stringify(items)}
        />
        <input
          type="hidden"
          name="total"
          value={items.reduce((sum, item) => sum + (item.quantity * 10), 0)}
        />

        {/* Submit button */}
        <button
          type="submit"
          disabled={isPending}
          className="w-full px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
        >
          {isPending ? 'Creating Order...' : 'Create Order'}
        </button>
      </form>

      {/* Status messages */}
      {state.success && (
        <div className="mt-4 p-4 bg-green-50 border border-green-200 rounded-md">
          <p className="text-green-700">{state.message}</p>
          {state.runId && (
            <p className="text-sm text-gray-600 mt-1">
              Run ID: {state.runId}
            </p>
          )}
        </div>
      )}

      {state.error && (
        <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-md">
          <p className="text-red-600">{state.error}</p>
        </div>
      )}
    </div>
  );
}
```

---

## 5. Real-Time Status Updates with Server-Sent Events (SSE)

### A. SSE Endpoint

Create an endpoint that streams workflow status updates:

```typescript
// src/app/api/workflows/status/stream/route.ts
import { NextRequest } from 'next/server';

export async function GET(request: NextRequest) {
  const runId = request.nextUrl.searchParams.get('runId');

  if (!runId) {
    return new Response('Missing runId', { status: 400 });
  }

  // Create a ReadableStream for SSE
  const stream = new ReadableStream({
    async start(controller) {
      // Function to fetch and send status updates
      const sendUpdate = async () => {
        try {
          // In a real app, fetch from your database or Inngest API
          const status = await getWorkflowStatus(runId);

          // Send as SSE event
          const eventData = `data: ${JSON.stringify(status)}\n\n`;
          controller.enqueue(new TextEncoder().encode(eventData));

          // If workflow is complete, close the stream
          if (['completed', 'failed', 'cancelled'].includes(status.status)) {
            controller.close();
            return;
          }

          // Continue polling every 2 seconds
          setTimeout(sendUpdate, 2000);
        } catch (error) {
          controller.error(error);
        }
      };

      // Start sending updates
      sendUpdate();
    },
  });

  // Return SSE response with appropriate headers
  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache, no-transform',
      'Connection': 'keep-alive',
      'X-Accel-Buffering': 'no', // Disable nginx buffering
    },
  });
}

// Helper to get workflow status
async function getWorkflowStatus(runId: string) {
  // In a real app, you'd fetch from Inngest API or your database
  // For now, simulate different statuses
  const statuses = ['pending', 'running', 'completed'];
  const steps = [
    { name: 'Validate Order', status: 'completed', duration: 500 },
    { name: 'Process Payment', status: 'running', duration: 1200 },
    { name: 'Update Inventory', status: 'pending', duration: 0 },
    { name: 'Send Confirmation', status: 'pending', duration: 0 },
  ];

  return {
    runId,
    status: statuses[Math.floor(Math.random() * statuses.length)],
    steps,
    startedAt: new Date(Date.now() - 5000).toISOString(),
    duration: 5000,
  };
}
```

### B. Custom Hook for SSE

Create a reusable hook for consuming SSE streams:

```typescript
// src/lib/hooks/useSSE.ts
import { useState, useEffect, useCallback, useRef } from 'react';

interface SSEOptions {
  onMessage?: (data: any) => void;
  onError?: (error: Event) => void;
  onOpen?: () => void;
  onClose?: () => void;
  autoReconnect?: boolean;
  reconnectDelay?: number;
}

export function useSSE(url: string, options: SSEOptions = {}) {
  const {
    onMessage,
    onError,
    onOpen,
    onClose,
    autoReconnect = true,
    reconnectDelay = 3000,
  } = options;

  const [isConnected, setIsConnected] = useState(false);
  const [lastMessage, setLastMessage] = useState<any>(null);
  const [error, setError] = useState<Event | null>(null);
  const eventSourceRef = useRef<EventSource | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  const connect = useCallback(() => {
    // Clean up existing connection
    if (eventSourceRef.current) {
      eventSourceRef.current.close();
    }

    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }

    try {
      const eventSource = new EventSource(url);
      eventSourceRef.current = eventSource;

      eventSource.onopen = () => {
        setIsConnected(true);
        setError(null);
        onOpen?.();
      };

      eventSource.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          setLastMessage(data);
          onMessage?.(data);
        } catch (parseError) {
          console.error('Failed to parse SSE message:', parseError);
        }
      };

      eventSource.onerror = (event) => {
        setError(event);
        onError?.(event);
        setIsConnected(false);

        // Auto-reconnect if enabled
        if (autoReconnect) {
          if (reconnectTimeoutRef.current) {
            clearTimeout(reconnectTimeoutRef.current);
          }
          reconnectTimeoutRef.current = setTimeout(() => {
            connect();
          }, reconnectDelay);
        }
      };

    } catch (err) {
      setError(err as Event);
      setIsConnected(false);
    }
  }, [url, onMessage, onError, onOpen, onClose, autoReconnect, reconnectDelay]);

  const disconnect = useCallback(() => {
    if (eventSourceRef.current) {
      eventSourceRef.current.close();
      eventSourceRef.current = null;
    }
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }
    setIsConnected(false);
    onClose?.();
  }, [onClose]);

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

### C. Workflow Status Component

Combine everything into a real-time status component:

```typescript
// src/app/dashboard/components/WorkflowStatus.tsx
'use client';

import { useSSE } from '@/lib/hooks/useSSE';
import { useState } from 'react';

interface WorkflowStatusProps {
  runId: string;
}

export function WorkflowStatus({ runId }: WorkflowStatusProps) {
  const [status, setStatus] = useState<{
    status: string;
    steps: any[];
    startedAt: string;
    duration: number;
  } | null>(null);

  // Use SSE for real-time updates
  const { isConnected, lastMessage, error } = useSSE(
    `/api/workflows/status/stream?runId=${runId}`,
    {
      onMessage: (data) => {
        setStatus(data);
      },
      onError: () => {
        console.error('SSE connection error');
      },
    }
  );

  // Status color mapping
  const statusColors = {
    pending: 'bg-yellow-100 text-yellow-800',
    running: 'bg-blue-100 text-blue-800',
    completed: 'bg-green-100 text-green-800',
    failed: 'bg-red-100 text-red-800',
    cancelled: 'bg-gray-100 text-gray-800',
  };

  const statusIcons = {
    pending: '⏳',
    running: '🔄',
    completed: '✅',
    failed: '❌',
    cancelled: '🛑',
  };

  if (!status) {
    return (
      <div className="p-4 bg-gray-50 rounded-lg">
        <p className="text-gray-500">Waiting for status...</p>
      </div>
    );
  }

  return (
    <div className="border border-gray-200 rounded-lg overflow-hidden">
      <div className="p-4 bg-white">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <span className="text-2xl">
              {statusIcons[status.status] || '⚪'}
            </span>
            <span className={`px-2 py-1 text-sm font-medium rounded-full ${statusColors[status.status] || 'bg-gray-100 text-gray-800'}`}>
              {status.status.toUpperCase()}
            </span>
            {isConnected ? (
              <span className="text-sm text-green-600">● Live</span>
            ) : (
              <span className="text-sm text-red-600">● Disconnected</span>
            )}
          </div>
          <span className="text-sm text-gray-500">
            {status.startedAt && new Date(status.startedAt).toLocaleTimeString()}
          </span>
        </div>

        {/* Progress bar */}
        <div className="mt-4">
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className="bg-blue-600 h-2 rounded-full transition-all duration-500"
              style={{
                width: `${getProgress(status)}%`,
              }}
            />
          </div>
        </div>

        {/* Steps */}
        {status.steps && status.steps.length > 0 && (
          <div className="mt-4 space-y-2">
            {status.steps.map((step, index) => (
              <div key={index} className="flex items-center justify-between text-sm">
                <div className="flex items-center gap-2">
                  <span className={
                    step.status === 'completed' ? 'text-green-600' :
                    step.status === 'running' ? 'text-blue-600' :
                    'text-gray-400'
                  }>
                    {step.status === 'completed' ? '✅' :
                     step.status === 'running' ? '🔄' :
                     '⏳'}
                  </span>
                  <span className={step.status === 'pending' ? 'text-gray-400' : ''}>
                    {step.name}
                  </span>
                </div>
                <span className="text-gray-500">
                  {step.duration ? `${(step.duration / 1000).toFixed(1)}s` : 'Waiting...'}
                </span>
              </div>
            ))}
          </div>
        )}

        {status.duration && (
          <div className="mt-4 text-sm text-gray-500">
            Total duration: {(status.duration / 1000).toFixed(1)}s
          </div>
        )}
      </div>
    </div>
  );
}

function getProgress(status: any): number {
  if (status.status === 'completed') return 100;
  if (status.status === 'failed') return 0;
  if (!status.steps || status.steps.length === 0) return 0;

  const completed = status.steps.filter((s: any) => s.status === 'completed').length;
  return (completed / status.steps.length) * 100;
}
```

---

## 6. Optimistic Updates with useOptimistic

React 19's `useOptimistic` hook provides immediate UI feedback while workflows process in the background:

```typescript
// src/app/dashboard/ai-content/page.tsx
'use client';

import { useOptimistic, useState, useRef } from 'react';
import { generateAIContent } from '@/lib/actions/ai.actions';

export default function AIContentGenerator() {
  const [content, setContent] = useState('');
  const [isGenerating, setIsGenerating] = useState(false);
  const [runId, setRunId] = useState<string | null>(null);

  // Optimistic content - shows immediately
  const [optimisticContent, addOptimisticContent] = useOptimistic(
    content,
    (state, newContent: string) => newContent
  );

  const formRef = useRef<HTMLFormElement>(null);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsGenerating(true);

    const formData = new FormData(e.currentTarget);
    const prompt = formData.get('prompt') as string;
    const contentType = formData.get('contentType') as string;

    // Optimistic update - show generating state immediately
    addOptimisticContent(`✨ Generating ${contentType} content for: "${prompt.substring(0, 50)}..."`);

    try {
      // Trigger the workflow
      const result = await generateAIContent(formData);
      
      if (result.success) {
        setRunId(result.runId);
        setContent(result.content);
      } else {
        setContent(`❌ Error: ${result.error}`);
      }
    } catch (error) {
      setContent(`❌ Error: ${error.message}`);
    } finally {
      setIsGenerating(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">AI Content Generator</h1>

      <form ref={formRef} onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">
            Prompt
          </label>
          <textarea
            name="prompt"
            rows={4}
            className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
            placeholder="Describe the content you want to generate..."
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">
            Content Type
          </label>
          <select
            name="contentType"
            className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
          >
            <option value="blog-post">Blog Post</option>
            <option value="social-media">Social Media Post</option>
            <option value="email">Email Newsletter</option>
            <option value="product-description">Product Description</option>
          </select>
        </div>

        <button
          type="submit"
          disabled={isGenerating}
          className="w-full px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
        >
          {isGenerating ? 'Generating...' : 'Generate Content'}
        </button>
      </form>

      {/* Optimistic content shows immediately */}
      {optimisticContent && (
        <div className="mt-6 p-4 bg-gray-50 border border-gray-200 rounded-lg">
          <h3 className="font-medium mb-2">Generated Content (Optimistic)</h3>
          <div className="prose max-w-none whitespace-pre-wrap">
            {optimisticContent}
          </div>
          {isGenerating && (
            <div className="mt-2 text-sm text-gray-500 animate-pulse">
              ✨ Updating content optimistically...
            </div>
          )}
        </div>
      )}

      {/* Show run ID for tracking */}
      {runId && (
        <div className="mt-4 text-sm text-gray-500">
          Run ID: {runId}
          <button
            onClick={() => window.location.href = `/dashboard/status/${runId}`}
            className="ml-2 text-blue-600 hover:text-blue-800"
          >
            View Status
          </button>
        </div>
      )}
    </div>
  );
}
```

---

## 7. Summary: Full-Stack Integration

| Component | Purpose | Key Feature |
|-----------|---------|-------------|
| **Inngest API Route** | Receive events and register functions | `serve()` from `inngest/next` |
| **Server Actions** | Trigger workflows from UI | `'use server'` + `inngest.send()` |
| **useActionState** | Form state management | React 19 hook with pending state |
| **Server-Sent Events** | Real-time status updates | SSE stream with `ReadableStream` |
| **useSSE** | Custom hook for SSE | Auto-reconnect, message handling |
| **useOptimistic** | Immediate UI feedback | Optimistic updates with fallback |

---

## Next Steps

You now know how to integrate Inngest with Next.js and React for a complete full-stack experience. The next primer will cover production deployment, monitoring, and observability.
