import type { Incident } from '@/types/incident';
import type { Responder } from '@/types/responder';
import type { Device } from '@/types/device';

describe('Types', () => {
  describe('Incident', () => {
    it('has required fields', () => {
      const incident: Incident = {
        id: '1',
        type: 'medical',
        status: 'created',
        priority: 1,
        reporter_id: 'user-1',
        latitude: 6.8897,
        longitude: 79.8823,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };
      expect(incident.id).toBe('1');
      expect(incident.type).toBe('medical');
      expect(incident.status).toBe('created');
    });
  });

  describe('Responder', () => {
    it('has required fields', () => {
      const responder: Responder = {
        id: '1',
        user_id: 'user-1',
        name: 'Test Responder',
        email: 'test@campus.edu',
        role: 'medical',
        status: 'available',
        last_active: new Date().toISOString(),
        created_at: new Date().toISOString(),
      };
      expect(responder.name).toBe('Test Responder');
      expect(responder.status).toBe('available');
    });
  });

  describe('Device', () => {
    it('has required fields', () => {
      const device: Device = {
        id: '1',
        device_id: 'SOS-001',
        type: 'sos_station',
        name: 'Test Device',
        status: 'online',
        created_at: new Date().toISOString(),
      };
      expect(device.device_id).toBe('SOS-001');
      expect(device.type).toBe('sos_station');
    });
  });
});
