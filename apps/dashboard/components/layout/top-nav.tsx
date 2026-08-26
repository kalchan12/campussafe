'use client';

interface TopNavProps {
  title?: string;
  showSearch?: boolean;
  searchPlaceholder?: string;
  onSearch?: (query: string) => void;
  actions?: React.ReactNode;
}

export function TopNav({ title = 'CampusSafe EOC', showSearch = false, searchPlaceholder = 'Search...', onSearch, actions }: TopNavProps) {
  return (
    <header className="bg-surface sticky top-0 z-50 border-b border-outline-variant flex justify-between items-center px-margin-desktop py-4 h-20 shadow-[0_4px_12px_rgba(0,0,0,0.05)]">
      <div className="flex items-center">
        <h2 className="font-headline-lg text-headline-lg font-bold text-primary">{title}</h2>
      </div>
      <div className="flex items-center gap-4">
        {showSearch && (
          <div className="relative">
            <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-lg pointer-events-none">search</span>
            <input
              type="text"
              placeholder={searchPlaceholder}
              onChange={(e) => onSearch?.(e.target.value)}
              className="pl-10 pr-4 py-2 border border-outline-variant rounded bg-surface-container-lowest text-on-surface placeholder:text-outline focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-colors font-label-md text-label-md w-64"
            />
          </div>
        )}
        {actions}
        <button className="relative p-2 text-on-surface-variant hover:text-primary transition-colors hover:scale-95 duration-150 rounded-full hover:bg-surface-variant">
          <span className="material-symbols-outlined">notifications</span>
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-error rounded-full" />
        </button>
        <button className="p-2 text-on-surface-variant hover:text-primary transition-colors hover:scale-95 duration-150 rounded-full hover:bg-surface-variant">
          <span className="material-symbols-outlined">account_circle</span>
        </button>
      </div>
    </header>
  );
}
