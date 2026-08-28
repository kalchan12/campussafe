import { supabase } from '../backend/supabase';
import type { RealtimeEvent, RealtimePayload } from '@/types/realtime';

type EventHandler = (payload: RealtimePayload) => void;

class RealtimeService {
  private handlers: Map<RealtimeEvent, EventHandler[]> = new Map();
  private isConnected = false;
  private channel: ReturnType<typeof supabase.channel> | null = null;

  connect(): void {
    if (this.isConnected) return;
    this.isConnected = true;

    try {
      this.channel = supabase
        .channel('dashboard-realtime')
        .on(
          'postgres_changes',
          { event: 'INSERT', schema: 'public', table: 'incidents' },
          (payload) => {
            this.emit('INCIDENT_CREATED', payload.new as Record<string, unknown>);
          }
        )
        .on(
          'postgres_changes',
          { event: 'UPDATE', schema: 'public', table: 'incidents' },
          (payload) => {
            const newRecord = payload.new as Record<string, unknown>;
            const oldRecord = payload.old as Record<string, unknown>;
            if (newRecord.status !== oldRecord.status) {
              this.emit('INCIDENT_STATUS_CHANGED', newRecord);
            }
            if (newRecord.assigned_responder_id && !oldRecord.assigned_responder_id) {
              this.emit('INCIDENT_ASSIGNED', newRecord);
            }
          }
        )
        .on(
          'postgres_changes',
          { event: 'INSERT', schema: 'public', table: 'device_events' },
          (payload) => {
            this.emit('DEVICE_EVENT_RECEIVED', payload.new as Record<string, unknown>);
          }
        )
        .subscribe((status) => {
          if (status === 'SUBSCRIBED') {
            this.isConnected = true;
          }
        });
    } catch {
      // Fallback in environments without live Supabase
      this.isConnected = true;
    }
  }

  disconnect(): void {
    this.isConnected = false;
    if (this.channel) {
      supabase.removeChannel(this.channel);
      this.channel = null;
    }
  }

  subscribe(event: RealtimeEvent, handler: EventHandler): () => void {
    const handlers = this.handlers.get(event) || [];
    handlers.push(handler);
    this.handlers.set(event, handlers);

    // Auto-connect on first subscription
    if (!this.isConnected) {
      this.connect();
    }

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
