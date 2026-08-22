export interface MapMarker {
  id: string;
  latitude: number;
  longitude: number;
  type: 'incident' | 'responder' | 'device' | 'campus_block';
  label: string;
  status?: string;
  color?: string;
}

export interface CampusBlock {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  radius?: number;
}
