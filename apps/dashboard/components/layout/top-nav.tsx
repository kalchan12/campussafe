'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import type { User } from '@/types/user';

interface TopNavProps {
  title?: string;
  showSearch?: boolean;
  searchPlaceholder?: string;
  onSearch?: (query: string) => void;
  actions?: React.ReactNode;
}

export function TopNav({ title = '', showSearch = false, searchPlaceholder = 'Search...', onSearch, actions }: TopNavProps) {
  const router = useRouter();
  const [user, setUser] = useState<User | null>(null);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);
  const supabase = createClient();

  useEffect(() => {
    supabase.auth.getUser().then(async ({ data: { user } }) => {
      if (user) {
        const { data: profile } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();
        if (profile) {
          setUser({
             id: user.id,
             email: user.email || '',
             full_name: profile.full_name,
             role: profile.role,
             campus_block: profile.campus_block,
             created_at: profile.created_at,
             updated_at: profile.updated_at,
          });
        }
      }
    });
  }, [supabase]);

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
    await supabase.auth.signOut();
    router.push('/login');
    router.refresh();
  };

  return (
    <header className="bg-surface sticky top-0 z-50 border-b border-outline-variant flex justify-between items-center px-4 py-4 h-20 shadow-[0_4px_12px_rgba(0,0,0,0.05)] relative">
      <div className="flex items-center z-10">
        {title && <h2 className="font-headline-lg text-headline-lg font-bold text-primary truncate">{title}</h2>}
      </div>
      
      {showSearch && (
        <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
          <div className="relative w-full max-w-xl pointer-events-auto">
            <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-lg pointer-events-none">search</span>
            <input
              type="text"
              placeholder={searchPlaceholder}
              onChange={(e) => onSearch?.(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-outline-variant rounded-full bg-surface-container-lowest text-on-surface placeholder:text-outline focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-colors font-label-md text-label-md shadow-sm"
            />
          </div>
        </div>
      )}

      <div className="flex items-center gap-4 z-10">
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

