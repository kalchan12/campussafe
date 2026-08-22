import { formatDate, formatTime, timeAgo, cn } from '@/lib/utils';

describe('Utils', () => {
  describe('formatDate', () => {
    it('formats date correctly', () => {
      const date = '2026-01-15T10:30:00Z';
      const result = formatDate(date);
      expect(result).toContain('2026');
      expect(result).toContain('Jan');
    });
  });

  describe('formatTime', () => {
    it('formats time correctly', () => {
      const date = '2026-01-15T10:30:00Z';
      const result = formatTime(date);
      expect(result).toMatch(/\d{2}:\d{2}/);
    });
  });

  describe('timeAgo', () => {
    it('returns "Just now" for recent times', () => {
      const now = new Date().toISOString();
      const result = timeAgo(now);
      expect(result).toBe('Just now');
    });

    it('returns minutes ago', () => {
      const fiveMinsAgo = new Date(Date.now() - 5 * 60000).toISOString();
      const result = timeAgo(fiveMinsAgo);
      expect(result).toContain('m ago');
    });
  });

  describe('cn', () => {
    it('merges class names', () => {
      const result = cn('text-red-500', 'text-blue-500');
      expect(result).toBe('text-blue-500');
    });

    it('handles conditional classes', () => {
      const result = cn('base', false && 'hidden', 'extra');
      expect(result).toContain('base');
      expect(result).toContain('extra');
      expect(result).not.toContain('hidden');
    });
  });
});
