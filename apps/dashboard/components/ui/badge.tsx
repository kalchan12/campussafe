import { cn } from '@/lib/utils';

interface BadgeProps {
  children: React.ReactNode;
  variant?: 'default' | 'success' | 'warning' | 'error' | 'info' | 'critical' | 'high' | 'medium';
  className?: string;
}

export function Badge({ children, variant = 'default', className }: BadgeProps) {
  const variants = {
    default: 'bg-surface-variant text-on-surface-variant border border-outline-variant/50',
    success: 'bg-emerald-50 text-emerald-700 border border-emerald-200',
    warning: 'bg-tertiary-fixed text-on-tertiary-fixed border border-tertiary-fixed-dim/30',
    error: 'bg-error-container text-on-error-container border border-error/20',
    info: 'bg-secondary-container text-on-secondary-container border border-secondary/20',
    critical: 'bg-error-container text-on-error-container border border-error/20',
    high: 'bg-tertiary-fixed text-on-tertiary-fixed border border-on-tertiary-container/20',
    medium: 'bg-surface-container-high text-on-surface-variant border border-outline-variant/50',
  };

  return (
    <span
      className={cn(
        'inline-flex items-center px-2.5 py-0.5 rounded font-label-md text-label-md',
        variants[variant],
        className
      )}
    >
      {children}
    </span>
  );
}
