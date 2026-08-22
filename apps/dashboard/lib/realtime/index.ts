import type { RealtimeEvent, RealtimePayload } from '@/types/realtime';

type EventHandler = (payload: RealtimePayload) => void;

class RealtimeService {
  private handlers: Map<RealtimeEvent, EventHandler[]> = new Map();
  private isConnected = false;

  connect(): void {
    // Mock connection - in production, use Supabase Realtime
    this.isConnected = true;
    console.log('Realtime service connected');
  }

  disconnect(): void {
    this.isConnected = false;
    console.log('Realtime service disconnected');
  }

  subscribe(event: RealtimeEvent, handler: EventHandler): () => void {
    const handlers = this.handlers.get(event) || [];
    handlers.push(handler);
    this.handlers.set(event, handlers);

    return () => {
      const current = this.handlers.get(event) || [];
      this.handlers.set(
        event,
        current.filter((h) => h !== handler)
      );
    };
  }

  emit(event: RealtimeEvent, data: Record<string, unknown>): void {
    const payload: RealtimePayload = {
      event,
      data,
      timestamp: new Date().toISOString(),
    };

    const handlers = this.handlers.get(event) || [];
    handlers.forEach((handler) => handler(payload));
  }

  getConnectionStatus(): boolean {
    return this.isConnected;
  }
}

export const realtimeService = new RealtimeService();
