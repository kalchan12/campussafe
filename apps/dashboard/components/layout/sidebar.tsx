'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import { createClient } from '@/lib/supabase/client';
import type { User } from '@/types/user';

interface NavItem {
  name: string;
  href: string;
  icon: string;
  adminOnly?: boolean;
}

const operationalNav: NavItem[] = [
  { name: 'Overview', href: '/dashboard', icon: 'dashboard' },
  { name: 'Live Incidents', href: '/dashboard/incidents', icon: 'warning' },
  { name: 'Map', href: '/dashboard/map', icon: 'map' },
  { name: 'Responders', href: '/dashboard/responders', icon: 'groups' },
  { name: 'Devices', href: '/dashboard/devices', icon: 'sensors' },
  { name: 'Reports', href: '/dashboard/reports', icon: 'assessment' },
];

const adminNav: NavItem[] = [
  { name: 'User Management', href: '/dashboard/users', icon: 'manage_accounts' },
  { name: 'Settings', href: '/dashboard/settings', icon: 'settings' },
];

export function Sidebar({ isCollapsed = false, onToggle }: { isCollapsed?: boolean; onToggle?: () => void }) {
  const pathname = usePathname();
  const [currentUser, setCurrentUser] = useState<User | null>(null);
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
          setCurrentUser({
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

  const isAdmin = currentUser?.role === 'administrator';

  const renderLink = (item: NavItem) => {
    const isActive =
      pathname === item.href ||
      (item.href !== '/dashboard' && pathname.startsWith(item.href + '/'));
    const isExactDashboard = item.href === '/dashboard' && pathname === '/dashboard';
    const active = isActive || isExactDashboard;

    return (
      <Link
        key={item.name}
        href={item.href}
        title={isCollapsed ? item.name : undefined}
        className={cn(
          'flex items-center rounded-lg transition-all duration-200 border-l-4',
          isCollapsed ? 'justify-center px-0 py-3 mx-2' : 'gap-3 px-4 py-3 mx-0',
          active
            ? 'bg-secondary-container border-primary text-primary font-bold opacity-90'
            : 'border-transparent text-on-surface-variant hover:bg-surface-variant'
        )}
      >
        <span
          className="material-symbols-outlined text-xl"
          style={active ? { fontVariationSettings: "'FILL' 1" } : undefined}
        >
          {item.icon}
        </span>
        {!isCollapsed && <span className="font-label-md text-label-md">{item.name}</span>}
      </Link>
    );
  };

  return (
    <aside className={cn(
      "bg-surface-container h-screen flex flex-col fixed left-0 top-0 py-gutter border-r border-outline-variant z-40 transition-all duration-300",
      isCollapsed ? "w-[72px]" : "w-64"
    )}>
      <div className={cn("mb-6 flex flex-col", isCollapsed ? "px-2 items-center" : "px-6")}>
        <div className={cn("flex items-center w-full mb-1", isCollapsed ? "justify-center mt-2" : "justify-between")}>
          <h1 className={cn("font-headline-lg font-bold text-primary", isCollapsed ? "text-xl" : "text-headline-lg")}>
            {isCollapsed ? 'CS' : 'CampusSafe'}
          </h1>
          {!isCollapsed && onToggle && (
            <button 
              onClick={onToggle}
              className="p-1 -mr-2 rounded hover:bg-surface-variant text-on-surface-variant transition-colors"
              title="Collapse sidebar"
            >
              <span className="material-symbols-outlined">menu_open</span>
            </button>
          )}
        </div>
        
        {isCollapsed && onToggle && (
           <button 
             onClick={onToggle}
             className="p-1.5 mt-3 rounded-lg hover:bg-surface-variant text-on-surface-variant transition-colors"
             title="Expand sidebar"
           >
             <span className="material-symbols-outlined">menu</span>
           </button>
        )}

        {!isCollapsed && (
          <p className="font-label-md text-xs text-on-surface-variant uppercase tracking-wider font-semibold">
            {isAdmin ? 'System Administration' : 'Emergency Operations'}
          </p>
        )}
      </div>

      <nav className={cn("flex-1 overflow-y-auto space-y-4", isCollapsed ? "px-1" : "px-4")}>
        {/* Operations Section */}
        <div>
          {!isCollapsed && (
            <p className="px-4 mb-2 text-[11px] font-label-md uppercase tracking-wider text-outline font-bold">
              Operations
            </p>
          )}
          <div className="space-y-1">
            {operationalNav.map(renderLink)}
          </div>
        </div>

        {/* Administration Section */}
        {isAdmin && (
          <div>
            {!isCollapsed && (
              <p className="px-4 mb-2 text-[11px] font-label-md uppercase tracking-wider text-outline font-bold">
                Administration
              </p>
            )}
            <div className="space-y-1">
              {adminNav.map(renderLink)}
            </div>
          </div>
        )}
      </nav>

      {/* Role Indicator Footer */}
      {currentUser && (
        <div className={cn("mt-auto border-t border-outline-variant/50 flex items-center", isCollapsed ? "p-2 mx-2 justify-center" : "p-4 mx-4 gap-3")}>
          <div className="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-xs shrink-0">
            {currentUser.full_name?.charAt(0) || 'U'}
          </div>
          {!isCollapsed && (
            <div className="flex-1 min-w-0">
              <p className="font-label-md text-xs font-semibold text-on-surface truncate">
                {currentUser.full_name}
              </p>
              <span className="inline-block px-1.5 py-0.2 text-[10px] uppercase font-technical-sm font-semibold rounded bg-surface-variant text-on-surface-variant">
                {currentUser.role}
              </span>
            </div>
          )}
        </div>
      )}
    </aside>
  );
}

