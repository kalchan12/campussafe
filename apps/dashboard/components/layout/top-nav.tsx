'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { getCurrentUser, signOut } from '@/lib/auth';
import type { User } from '@/types/user';

interface TopNavProps {
  title?: string;
  showSearch?: boolean;
  searchPlaceholder?: string;
  onSearch?: (query: string) => void;
  actions?: React.ReactNode;
}

export function TopNav({ title = 'CampusSafe EOC', showSearch = false, searchPlaceholder = 'Search...', onSearch, actions }: TopNavProps) {
  const router = useRouter();
  const [user, setUser] = useState<User | null>(null);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    getCurrentUser().then(setUser);
  }, []);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setIsMenuOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleSignOut = async () => {
    await signOut();
    router.push('/login');
    router.refresh();
  };

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
        <button
          type="button"
          aria-label="Notifications"
          className="relative p-2 text-on-surface-variant hover:text-primary transition-colors hover:scale-95 duration-150 rounded-full hover:bg-surface-variant"
        >
          <span className="material-symbols-outlined">notifications</span>
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-error rounded-full" />
        </button>

        {/* User Account Menu */}
        <div className="relative" ref={menuRef}>
          <button
            type="button"
            onClick={() => setIsMenuOpen((prev) => !prev)}
            className="flex items-center gap-2 p-1.5 pr-3 text-on-surface-variant hover:text-primary transition-colors rounded-full hover:bg-surface-variant border border-outline-variant/40"
          >
            <span className="material-symbols-outlined text-2xl text-primary">account_circle</span>
            <div className="hidden md:flex flex-col text-left">
              <span className="font-label-md text-xs font-semibold text-on-surface leading-tight">
                {user?.full_name ?? 'Operator'}
              </span>
              <span className="font-technical-sm text-[10px] text-outline uppercase tracking-wider leading-none">
                {user?.role ?? 'operator'}
              </span>
            </div>
            <span className="material-symbols-outlined text-sm text-outline">
              {isMenuOpen ? 'expand_less' : 'expand_more'}
            </span>
          </button>

          {isMenuOpen && (
            <div className="absolute right-0 mt-2 w-56 bg-surface-container-lowest border border-outline-variant rounded-xl shadow-lg py-2 z-50">
              <div className="px-4 py-2 border-b border-outline-variant/50 mb-1">
                <p className="font-label-md text-sm font-semibold text-on-surface truncate">
                  {user?.full_name ?? 'Operator'}
                </p>
                <p className="font-technical-sm text-xs text-outline truncate">
                  {user?.email ?? 'operator@campus.edu'}
                </p>
              </div>

              <button
                type="button"
                onClick={handleSignOut}
                className="w-full flex items-center gap-2 px-4 py-2.5 text-sm text-error hover:bg-error-container/30 transition-colors font-label-md text-left"
              >
                <span className="material-symbols-outlined text-base">logout</span>
                <span>Sign Out</span>
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}

