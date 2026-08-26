import { cn } from '@/lib/utils';

interface StatCardProps {
  title: string;
  value: number | string;
  icon?: string; // Material Symbols icon name
  variant?: 'default' | 'critical';
  trend?: {
    value: number;
    isPositive: boolean;
  };
  className?: string;
}

export function StatCard({ title, value, icon, variant = 'default', trend, className }: StatCardProps) {
  const isCritical = variant === 'critical';

  return (
    <div
      className={cn(
        'bg-surface-container-lowest border border-outline-variant rounded-lg p-6 flex flex-col gap-2 relative overflow-hidden',
        className
      )}
    >
      {isCritical && (
        <div className="absolute inset-0 bg-error/10 pointer-events-none" />
      )}
      <div className="flex justify-between items-center relative z-10">
        <span
          className={cn(
            'font-label-md text-label-md',
            isCritical ? 'text-error font-bold' : 'text-on-surface-variant'
          )}
        >
          {title}
        </span>
        {icon && (
          <span
            className={cn(
              'material-symbols-outlined',
              isCritical ? 'text-error' : 'text-primary'
            )}
          >
            {icon}
          </span>
        )}
      </div>
      <span
        className={cn(
          'font-display-lg text-display-lg relative z-10',
          isCritical ? 'text-error' : 'text-on-surface'
        )}
      >
        {value}
      </span>
      {trend && (
        <div className="mt-2 flex items-center font-technical-sm text-technical-sm relative z-10">
          <span
            className={cn(
              'font-medium',
              trend.isPositive ? 'text-emerald-600' : 'text-error'
            )}
          >
            {trend.isPositive ? '+' : ''}{trend.value}%
          </span>
          <span className="text-on-surface-variant ml-2">from last hour</span>
        </div>
      )}
    </div>
  );
}
