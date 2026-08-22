import { validateEmail, validatePassword, validateRequired } from '@/lib/validation';

describe('Validation', () => {
  describe('validateEmail', () => {
    it('validates correct email', () => {
      expect(validateEmail('test@example.com')).toBe(true);
    });

    it('rejects invalid email', () => {
      expect(validateEmail('invalid')).toBe(false);
      expect(validateEmail('test@')).toBe(false);
      expect(validateEmail('@example.com')).toBe(false);
    });
  });

  describe('validatePassword', () => {
    it('validates strong password', () => {
      const result = validatePassword('Password123');
      expect(result.isValid).toBe(true);
      expect(result.errors.length).toBe(0);
    });

    it('rejects short password', () => {
      const result = validatePassword('Pass1');
      expect(result.isValid).toBe(false);
      expect(result.errors.some((e) => e.includes('8 characters'))).toBe(true);
    });

    it('rejects password without uppercase', () => {
      const result = validatePassword('password123');
      expect(result.isValid).toBe(false);
      expect(result.errors.some((e) => e.includes('uppercase'))).toBe(true);
    });

    it('rejects password without number', () => {
      const result = validatePassword('Password');
      expect(result.isValid).toBe(false);
      expect(result.errors.some((e) => e.includes('number'))).toBe(true);
    });
  });

  describe('validateRequired', () => {
    it('returns null for non-empty value', () => {
      expect(validateRequired('test', 'Field')).toBeNull();
    });

    it('returns error for empty value', () => {
      expect(validateRequired('', 'Field')).toBe('Field is required');
    });

    it('returns error for whitespace-only value', () => {
      expect(validateRequired('   ', 'Field')).toBe('Field is required');
    });
  });
});
