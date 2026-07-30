# Primer 12: Understanding Real-Time Systems & WebSockets

## A Deep Dive into Building Real-Time Applications

Welcome to the twelfth primer! This is a comprehensive deep dive into building real-time systems with WebSockets and other real-time technologies. Think of this like setting up a live communication system in your restaurant chain - the kitchen needs to know immediately when an order is placed, the waitstaff needs instant updates on order status, and managers need real-time insights into operations.

### 1. The Big Picture

#### Real-Time Communication Patterns

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    REAL-TIME COMMUNICATION PATTERNS                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     WEBSOCKETS                                      │   │
│  │  • Full-duplex communication                                       │   │
│  │  • Persistent connection                                           │   │
│  │  • Low latency                                                     │   │
│  │  • Bi-directional                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     SERVER-SENT EVENTS (SSE)                        │   │
│  │  • One-way communication (server to client)                        │   │
│  │  • Automatic reconnection                                          │   │
│  │  • HTTP-based                                                      │   │
│  │  • Simple to implement                                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     LONG POLLING                                   │   │
│  │  • HTTP request stays open                                         │   │
│  │  • Server responds when data is available                          │   │
│  │  • Client immediately reconnects                                   │   │
│  │  • Fallback for older browsers                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. WebSocket Server Implementation

#### WebSocket Server Setup

```typescript
import { WebSocketServer, WebSocket } from 'ws';
import { createServer } from 'http';
import { randomUUID } from 'crypto';

interface WebSocketClient extends WebSocket {
    id: string;
    userId?: string;
    rooms: Set<string>;
    isAlive: boolean;
    metadata: Record<string, any>;
}

class WebSocketManager {
    private wss: WebSocketServer;
    private clients: Map<string, WebSocketClient> = new Map();
    private rooms: Map<string, Set<string>> = new Map();
    private logger: Logger;

    constructor(server: http.Server) {
        this.logger = createLogger({ service: 'websocket' });
        
        this.wss = new WebSocketServer({ 
            server,
            path: '/ws',
            // Config options
            perMessageDeflate: true,
            maxPayload: 1024 * 1024, // 1MB
        });

        this.setupServer();
        this.startHeartbeat();
    }

    private setupServer(): void {
        this.wss.on('connection', (ws: WebSocketClient, req: http.IncomingMessage) => {
            // Assign client ID
            ws.id = randomUUID();
            ws.isAlive = true;
            ws.rooms = new Set();
            ws.metadata = {};

            // Store client
            this.clients.set(ws.id, ws);

            // Extract user ID from request (query params or headers)
            const url = new URL(req.url || '', `http://${req.headers.host}`);
            const userId = url.searchParams.get('userId');
            if (userId) {
                ws.userId = userId;
            }

            this.logger.info('WebSocket client connected', {
                clientId: ws.id,
                userId: ws.userId,
                clients: this.clients.size,
            });

            // Set up message handler
            ws.on('message', (data: Buffer) => {
                this.handleMessage(ws, data);
            });

            // Set up close handler
            ws.on('close', () => {
                this.handleDisconnect(ws);
            });

            // Set up error handler
            ws.on('error', (error) => {
                this.logger.error('WebSocket error', { 
                    clientId: ws.id, 
                    error 
                });
            });

            // Send initial connection success
            this.sendToClient(ws, {
                type: 'connected',
                data: {
                    clientId: ws.id,
                    timestamp: new Date().toISOString(),
                },
            });
        });

        this.wss.on('error', (error) => {
            this.logger.error('WebSocket server error', { error });
        });
    }

    private handleMessage(ws: WebSocketClient, data: Buffer): void {
        try {
            const message = JSON.parse(data.toString());
            
            this.logger.debug('Message received', {
                clientId: ws.id,
                type: message.type,
            });

            switch (message.type) {
                case 'ping':
                    this.sendToClient(ws, { type: 'pong' });
                    break;

                case 'subscribe':
                    this.handleSubscribe(ws, message.room);
                    break;

                case 'unsubscribe':
                    this.handleUnsubscribe(ws, message.room);
                    break;

                case 'message':
                    this.handleChatMessage(ws, message);
                    break;

                case 'typing':
                    this.handleTyping(ws, message);
                    break;

                default:
                    this.logger.warn('Unknown message type', { 
                        clientId: ws.id, 
                        type: message.type 
                    });
            }
        } catch (error) {
            this.logger.error('Message parsing error', { 
                clientId: ws.id, 
                error 
            });
            this.sendToClient(ws, {
                type: 'error',
                data: { message: 'Invalid message format' },
            });
        }
    }

    // Subscription management
    private handleSubscribe(ws: WebSocketClient, room: string): void {
        if (!room) return;

        // Add client to room
        ws.rooms.add(room);
        
        if (!this.rooms.has(room)) {
            this.rooms.set(room, new Set());
        }
        this.rooms.get(room)!.add(ws.id);

        this.logger.debug('Client subscribed', {
            clientId: ws.id,
            room,
        });

        // Send confirmation
        this.sendToClient(ws, {
            type: 'subscribed',
            data: { room },
        });

        // Send room history (if available)
        this.sendRoomHistory(ws, room);
    }

    private handleUnsubscribe(ws: WebSocketClient, room: string): void {
        if (!room) return;

        ws.rooms.delete(room);
        
        const roomClients = this.rooms.get(room);
        if (roomClients) {
            roomClients.delete(ws.id);
            if (roomClients.size === 0) {
                this.rooms.delete(room);
            }
        }

        this.logger.debug('Client unsubscribed', {
            clientId: ws.id,
            room,
        });

        this.sendToClient(ws, {
            type: 'unsubscribed',
            data: { room },
        });
    }

    // Message handling
    private handleChatMessage(ws: WebSocketClient, message: any): void {
        const { room, content } = message.data || {};

        if (!room || !content) {
            this.sendToClient(ws, {
                type: 'error',
                data: { message: 'Invalid message format' },
            });
            return;
        }

        // Broadcast to room
        this.broadcastToRoom(room, {
            type: 'message',
            data: {
                id: randomUUID(),
                userId: ws.userId,
                clientId: ws.id,
                content,
                timestamp: new Date().toISOString(),
            },
        });
    }

    private handleTyping(ws: WebSocketClient, message: any): void {
        const { room, isTyping } = message.data || {};

        if (!room) return;

        this.broadcastToRoom(room, {
            type: 'typing',
            data: {
                userId: ws.userId,
                clientId: ws.id,
                isTyping,
            },
        });
    }

    // Broadcast methods
    broadcastToRoom(room: string, message: any): void {
        const roomClients = this.rooms.get(room);
        if (!roomClients) return;

        const payload = JSON.stringify(message);

        for (const clientId of roomClients) {
            const client = this.clients.get(clientId);
            if (client && client.readyState === WebSocket.OPEN) {
                client.send(payload);
            }
        }
    }

    broadcastToAll(message: any): void {
        const payload = JSON.stringify(message);

        for (const client of this.clients.values()) {
            if (client.readyState === WebSocket.OPEN) {
                client.send(payload);
            }
        }
    }

    sendToClient(ws: WebSocketClient, message: any): void {
        if (ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify(message));
        }
    }

    // Room history
    private sendRoomHistory(ws: WebSocketClient, room: string): void {
        // In a real implementation, you'd fetch from a database
        // This is a placeholder
        this.sendToClient(ws, {
            type: 'history',
            data: {
                room,
                messages: [],
            },
        });
    }

    // Heartbeat to keep connections alive
    private startHeartbeat(): void {
        setInterval(() => {
            for (const client of this.clients.values()) {
                if (client.isAlive === false) {
                    this.handleDisconnect(client);
                    continue;
                }

                client.isAlive = false;
                client.ping();
            }
        }, 30000);
    }

    // Handle disconnection
    private handleDisconnect(ws: WebSocketClient): void {
        // Remove from all rooms
        for (const room of ws.rooms) {
            const roomClients = this.rooms.get(room);
            if (roomClients) {
                roomClients.delete(ws.id);
                if (roomClients.size === 0) {
                    this.rooms.delete(room);
                }
            }
        }

        // Remove from clients
        this.clients.delete(ws.id);

        this.logger.info('WebSocket client disconnected', {
            clientId: ws.id,
            userId: ws.userId,
            clients: this.clients.size,
        });

        // Notify others
        this.broadcastToAll({
            type: 'user_disconnected',
            data: {
                userId: ws.userId,
                clientId: ws.id,
                timestamp: new Date().toISOString(),
            },
        });
    }

    // Stats
    getStats(): Record<string, any> {
        return {
            totalClients: this.clients.size,
            totalRooms: this.rooms.size,
            clients: Array.from(this.clients.keys()),
            rooms: Array.from(this.rooms.keys()).map(room => ({
                room,
                clients: this.rooms.get(room)?.size || 0,
            })),
        };
    }

    // Clean up
    close(): void {
        this.wss.close();
        this.clients.clear();
        this.rooms.clear();
        this.logger.info('WebSocket server closed');
    }
}
```

### 3. Client Implementation

```typescript
class WebSocketClient {
    private ws: WebSocket | null = null;
    private reconnectAttempts: number = 0;
    private maxReconnectAttempts: number = 10;
    private reconnectDelay: number = 1000;
    private subscriptions: Set<string> = new Set();
    private messageHandlers: Map<string, ((data: any) => void)[]> = new Map();
    private logger: Logger;

    constructor(
        private url: string,
        private options?: {
            userId?: string;
            autoReconnect?: boolean;
            onConnect?: () => void;
            onDisconnect?: () => void;
        }
    ) {
        this.logger = createLogger({ service: 'websocket-client' });
        this.connect();
    }

    private connect(): void {
        try {
            const wsUrl = new URL(this.url);
            if (this.options?.userId) {
                wsUrl.searchParams.set('userId', this.options.userId);
            }

            this.ws = new WebSocket(wsUrl.toString());

            this.ws.onopen = () => {
                this.logger.info('WebSocket connected');
                this.reconnectAttempts = 0;
                
                // Resubscribe to rooms
                for (const room of this.subscriptions) {
                    this.send('subscribe', { room });
                }

                if (this.options?.onConnect) {
                    this.options.onConnect();
                }
            };

            this.ws.onmessage = (event) => {
                try {
                    const message = JSON.parse(event.data);
                    this.handleMessage(message);
                } catch (error) {
                    this.logger.error('Message parsing error', { error });
                }
            };

            this.ws.onclose = () => {
                this.logger.warn('WebSocket disconnected');
                
                if (this.options?.onDisconnect) {
                    this.options.onDisconnect();
                }

                if (this.options?.autoReconnect !== false) {
                    this.scheduleReconnect();
                }
            };

            this.ws.onerror = (error) => {
                this.logger.error('WebSocket error', { error });
            };

        } catch (error) {
            this.logger.error('WebSocket connection error', { error });
            this.scheduleReconnect();
        }
    }

    private scheduleReconnect(): void {
        if (this.reconnectAttempts >= this.maxReconnectAttempts) {
            this.logger.error('Max reconnect attempts reached');
            return;
        }

        const delay = Math.min(
            this.reconnectDelay * Math.pow(2, this.reconnectAttempts),
            30000
        );

        this.reconnectAttempts++;
        this.logger.info(`Reconnecting in ${delay}ms`, { 
            attempt: this.reconnectAttempts 
        });

        setTimeout(() => {
            this.connect();
        }, delay);
    }

    private handleMessage(message: any): void {
        const { type, data } = message;

        // Call handlers for this message type
        const handlers = this.messageHandlers.get(type) || [];
        for (const handler of handlers) {
            try {
                handler(data);
            } catch (error) {
                this.logger.error('Message handler error', { type, error });
            }
        }

        // Handle specific message types
        switch (type) {
            case 'connected':
                this.logger.info('Connected to server', data);
                break;

            case 'subscribed':
                this.subscriptions.add(data.room);
                this.logger.debug('Subscribed to room', { room: data.room });
                break;

            case 'unsubscribed':
                this.subscriptions.delete(data.room);
                this.logger.debug('Unsubscribed from room', { room: data.room });
                break;

            case 'message':
                this.logger.debug('Message received', data);
                break;

            case 'typing':
                this.logger.debug('Typing event', data);
                break;

            case 'pong':
                // Keep connection alive
                break;

            case 'error':
                this.logger.error('Server error', data);
                break;

            default:
                this.logger.debug('Unknown message type', { type });
        }
    }

    // Public API
    send(type: string, data: any): void {
        if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
            this.logger.warn('Cannot send message, WebSocket not open');
            return;
        }

        this.ws.send(JSON.stringify({ type, data }));
    }

    subscribe(room: string): void {
        this.send('subscribe', { room });
    }

    unsubscribe(room: string): void {
        this.send('unsubscribe', { room });
    }

    sendMessage(room: string, content: string): void {
        this.send('message', { room, content });
    }

    sendTyping(room: string, isTyping: boolean): void {
        this.send('typing', { room, isTyping });
    }

    // Event handlers
    on(type: string, handler: (data: any) => void): void {
        if (!this.messageHandlers.has(type)) {
            this.messageHandlers.set(type, []);
        }
        this.messageHandlers.get(type)!.push(handler);
    }

    off(type: string, handler: (data: any) => void): void {
        const handlers = this.messageHandlers.get(type);
        if (handlers) {
            const index = handlers.indexOf(handler);
            if (index !== -1) {
                handlers.splice(index, 1);
            }
        }
    }

    // Utility methods
    isConnected(): boolean {
        return this.ws?.readyState === WebSocket.OPEN;
    }

    disconnect(): void {
        if (this.ws) {
            this.ws.close();
        }
    }

    reconnect(): void {
        this.disconnect();
        this.reconnectAttempts = 0;
        this.connect();
    }
}
```

### 4. Real-Time Use Cases

#### Live Notifications

```typescript
class NotificationService {
    private wsManager: WebSocketManager;
    private logger: Logger;

    constructor(wsManager: WebSocketManager) {
        this.wsManager = wsManager;
        this.logger = createLogger({ service: 'notifications' });
    }

    async sendNotification(
        userId: string,
        notification: Notification
    ): Promise<void> {
        // Store notification in database
        await this.storeNotification(userId, notification);

        // Send real-time notification
        this.wsManager.broadcastToRoom(`user:${userId}`, {
            type: 'notification',
            data: notification,
        });

        this.logger.info('Notification sent', { userId, notification });
    }

    async sendBulkNotification(
        userIds: string[],
        notification: Notification
    ): Promise<void> {
        // Store for all users
        await Promise.all(
            userIds.map(userId => this.storeNotification(userId, notification))
        );

        // Send real-time to all connected users
        for (const userId of userIds) {
            this.wsManager.broadcastToRoom(`user:${userId}`, {
                type: 'notification',
                data: notification,
            });
        }

        this.logger.info('Bulk notification sent', {
            users: userIds.length,
            notification,
        });
    }

    private async storeNotification(
        userId: string,
        notification: Notification
    ): Promise<void> {
        // Store in database
        // await db.notifications.create({ userId, ...notification });
    }
}

interface Notification {
    id: string;
    type: 'info' | 'success' | 'warning' | 'error';
    title: string;
    message: string;
    timestamp: Date;
    read: boolean;
    metadata?: Record<string, any>;
}
```

#### Live Collaboration

```typescript
class CollaborationService {
    private wsManager: WebSocketManager;
    private documents: Map<string, DocumentState> = new Map();
    private logger: Logger;

    constructor(wsManager: WebSocketManager) {
        this.wsManager = wsManager;
        this.logger = createLogger({ service: 'collaboration' });
        this.setupEventHandlers();
    }

    private setupEventHandlers(): void {
        // Handle document updates
        this.wsManager.on('message', (ws, message) => {
            if (message.type === 'document_update') {
                this.handleDocumentUpdate(ws, message.data);
            }
        });
    }

    private handleDocumentUpdate(ws: WebSocketClient, data: any): void {
        const { documentId, content, userId } = data;

        // Update document state
        const state = this.getDocumentState(documentId);
        state.content = content;
        state.lastUpdated = new Date();
        state.version++;

        // Broadcast to all collaborators
        this.broadcastDocumentUpdate(documentId, {
            type: 'document_updated',
            data: {
                documentId,
                content,
                userId,
                version: state.version,
                timestamp: new Date().toISOString(),
            },
        });
    }

    private getDocumentState(documentId: string): DocumentState {
        if (!this.documents.has(documentId)) {
            this.documents.set(documentId, {
                content: '',
                version: 0,
                lastUpdated: new Date(),
                collaborators: new Set(),
            });
        }
        return this.documents.get(documentId)!;
    }

    private broadcastDocumentUpdate(documentId: string, message: any): void {
        this.wsManager.broadcastToRoom(`document:${documentId}`, message);
    }

    getDocument(documentId: string): DocumentState | undefined {
        return this.documents.get(documentId);
    }
}

interface DocumentState {
    content: string;
    version: number;
    lastUpdated: Date;
    collaborators: Set<string>;
}
```

#### Real-Time Metrics

```typescript
class RealTimeMetricsService {
    private wsManager: WebSocketManager;
    private metrics: MetricsData;
    private logger: Logger;

    constructor(wsManager: WebSocketManager) {
        this.wsManager = wsManager;
        this.logger = createLogger({ service: 'metrics' });
        
        this.metrics = {
            activeUsers: 0,
            totalRequests: 0,
            requestsPerSecond: 0,
            errorsPerSecond: 0,
            averageLatency: 0,
            systemLoad: 0,
            memoryUsage: 0,
            timestamp: new Date(),
        };

        this.startMetricsCollection();
    }

    private startMetricsCollection(): void {
        setInterval(() => {
            this.updateMetrics();
            this.broadcastMetrics();
        }, 5000);
    }

    private updateMetrics(): void {
        // Collect metrics from various sources
        this.metrics = {
            activeUsers: this.getActiveUsers(),
            totalRequests: this.getTotalRequests(),
            requestsPerSecond: this.getRequestsPerSecond(),
            errorsPerSecond: this.getErrorsPerSecond(),
            averageLatency: this.getAverageLatency(),
            systemLoad: this.getSystemLoad(),
            memoryUsage: this.getMemoryUsage(),
            timestamp: new Date(),
        };
    }

    private broadcastMetrics(): void {
        this.wsManager.broadcastToRoom('metrics', {
            type: 'metrics_update',
            data: this.metrics,
        });
    }

    private getActiveUsers(): number {
        // Get active users from auth service or database
        return 0;
    }

    private getTotalRequests(): number {
        // Get total requests from metrics service
        return 0;
    }

    private getRequestsPerSecond(): number {
        // Calculate requests per second
        return 0;
    }

    private getErrorsPerSecond(): number {
        // Calculate errors per second
        return 0;
    }

    private getAverageLatency(): number {
        // Calculate average latency
        return 0;
    }

    private getSystemLoad(): number {
        // Get system load from OS
        return 0;
    }

    private getMemoryUsage(): number {
        // Get memory usage from process
        return process.memoryUsage().heapUsed / 1024 / 1024;
    }
}

interface MetricsData {
    activeUsers: number;
    totalRequests: number;
    requestsPerSecond: number;
    errorsPerSecond: number;
    averageLatency: number;
    systemLoad: number;
    memoryUsage: number;
    timestamp: Date;
}
```

### 5. Key Takeaways

1. **WebSockets are for Real-Time:**
   - Low latency communication
   - Persistent connections
   - Full-duplex messaging
   - Ideal for chat, gaming, live updates

2. **Connection Management:**
   - Implement heartbeat/ping-pong
   - Handle reconnection gracefully
   - Manage connection limits
   - Clean up dead connections

3. **Message Protocol:**
   - Use structured message types
   - Include metadata (timestamp, id)
   - Validate messages
   - Handle errors gracefully

4. **Scalability Considerations:**
   - Use Redis for pub/sub across servers
   - Implement horizontal scaling
   - Handle connection distribution
   - Use sticky sessions when needed

5. **Security:**
   - Authenticate WebSocket connections
   - Validate messages
   - Implement rate limiting
   - Use SSL/TLS

6. **Fallback Strategies:**
   - Server-Sent Events (SSE)
   - Long polling
   - Graceful degradation
   - Cross-browser compatibility

---

This primer provides a comprehensive understanding of real-time systems and WebSockets. These technologies are essential for building interactive, responsive applications that require instant communication between server and clients.
