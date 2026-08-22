import { getIncidents, getResponders, getDevices } from '@/lib/mock';

describe('Mock Data Services', () => {
  describe('getIncidents', () => {
    it('returns all incidents when no filter', async () => {
      const incidents = await getIncidents();
      expect(incidents.length).toBeGreaterThan(0);
    });

    it('filters by status', async () => {
      const incidents = await getIncidents({ status: ['responding'] });
      incidents.forEach((i) => {
        expect(i.status).toBe('responding');
      });
    });

    it('filters by type', async () => {
      const incidents = await getIncidents({ type: ['medical'] });
      incidents.forEach((i) => {
        expect(i.type).toBe('medical');
      });
    });

    it('filters by search', async () => {
      const incidents = await getIncidents({ search: 'chest pain' });
      expect(incidents.length).toBeGreaterThan(0);
      incidents.forEach((i) => {
        expect(
          i.description?.toLowerCase().includes('chest pain') ||
            i.location_description?.toLowerCase().includes('chest pain')
        ).toBe(true);
      });
    });
  });

  describe('getResponders', () => {
    it('returns all responders when no filter', async () => {
      const responders = await getResponders();
      expect(responders.length).toBeGreaterThan(0);
    });

    it('filters by status', async () => {
      const responders = await getResponders({ status: ['available'] });
      responders.forEach((r) => {
        expect(r.status).toBe('available');
      });
    });

    it('filters by role', async () => {
      const responders = await getResponders({ role: ['medical'] });
      responders.forEach((r) => {
        expect(r.role).toBe('medical');
      });
    });
  });

  describe('getDevices', () => {
    it('returns all devices when no filter', async () => {
      const devices = await getDevices();
      expect(devices.length).toBeGreaterThan(0);
    });

    it('filters by status', async () => {
      const devices = await getDevices({ status: ['online'] });
      devices.forEach((d) => {
        expect(d.status).toBe('online');
      });
    });
  });
});
