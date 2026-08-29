'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import { getCurrentUser } from '@/lib/auth';
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

export function Sidebar() {
  const pathname = usePathname();
  const [currentUser, setCurrentUser] = useState<User | null>(null);

  useEffect(() => {
    getCurrentUser().then(setCurrentUser);
  }, []);

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
        className={cn(
          'flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-200 border-l-4',
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
        <span className="font-label-md text-label-md">{item.name}</span>
      </Link>
    );
  };

  return (
    <aside className="w-64 bg-surface-container h-screen flex flex-col fixed left-0 top-0 py-gutter border-r border-outline-variant z-40">
      <div className="px-6 mb-6">
        <h1 className="font-headline-lg text-headline-lg font-bold text-primary">CampusSafe</h1>
        <p className="font-label-md text-xs text-on-surface-variant uppercase tracking-wider font-semibold">
          {isAdmin ? 'System Administration' : 'Emergency Operations'}
        </p>
      </div>

      <nav className="flex-1 overflow-y-auto px-4 space-y-4">
        {/* Operations Section */}
        <div>
          <p className="px-4 mb-2 text-[11px] font-label-md uppercase tracking-wider text-outline font-bold">
            Operations
          </p>
          <div className="space-y-1">
            {operationalNav.map(renderLink)}
          </div>
        </div>

        {/* Administration Section */}
        <div>
          <p className="px-4 mb-2 text-[11px] font-label-md uppercase tracking-wider text-outline font-bold">
            Administration
          </p>
          <div className="space-y-1">
            {adminNav.map(renderLink)}
          </div>
        </div>
      </nav>

      {/* Role Indicator Footer */}
      {currentUser && (
        <div className="p-4 mx-4 mt-auto border-t border-outline-variant/50 flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-xs">
            {currentUser.full_name?.charAt(0) || 'U'}
          </div>
          <div className="flex-1 min-w-0">
            <p className="font-label-md text-xs font-semibold text-on-surface truncate">
              {currentUser.full_name}
            </p>
            <span className="inline-block px-1.5 py-0.2 text-[10px] uppercase font-technical-sm font-semibold rounded bg-surface-variant text-on-surface-variant">
              {currentUser.role}
            </span>
          </div>
        </div>
      )}
    </aside>
  );
}

