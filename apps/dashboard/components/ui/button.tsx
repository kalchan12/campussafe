import { cn } from '@/lib/utils';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
}

export function Button({
  children,
  variant = 'primary',
  size = 'md',
  className,
  ...props
}: ButtonProps) {
  const variants = {
    primary: 'bg-primary text-on-primary hover:bg-primary-container hover:text-on-primary-container',
    secondary: 'bg-surface-container-lowest text-on-surface border border-outline-variant hover:bg-surface-variant',
    ghost: 'text-primary hover:bg-surface-variant border border-transparent hover:border-outline-variant',
    danger: 'bg-error text-on-error hover:bg-on-error-container',
  };

  const sizes = {
    sm: 'px-3 py-1.5 text-technical-sm font-technical-sm',
    md: 'px-4 py-2 text-label-md font-label-md',
    lg: 'px-6 py-3 text-label-md font-label-md min-h-[44px]',
  };

  return (
    <button
      className={cn(
        'inline-flex items-center justify-center rounded font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface disabled:opacity-50 disabled:cursor-not-allowed active:scale-[0.98]',
        variants[variant],
        sizes[size],
        className
      )}
      {...props}
    >
      {children}
    </button>
  );
}
