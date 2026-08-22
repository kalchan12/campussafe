export type RealtimeEvent =
  | 'INCIDENT_CREATED'
  | 'INCIDENT_ASSIGNED'
  | 'INCIDENT_ACCEPTED'
  | 'INCIDENT_STATUS_CHANGED'
  | 'RESPONDER_STATUS_CHANGED'
  | 'DEVICE_STATUS_CHANGED'
  | 'DEVICE_EVENT_RECEIVED';

export interface RealtimePayload {
  event: RealtimeEvent;
  data: Record<string, unknown>;
  timestamp: string;
}
