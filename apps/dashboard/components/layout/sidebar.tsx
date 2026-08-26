'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';

const navigation = [
  { name: 'Overview', href: '/dashboard', icon: 'dashboard' },
  { name: 'Live Incidents', href: '/dashboard/incidents', icon: 'warning' },
  { name: 'Map', href: '/dashboard/map', icon: 'map' },
  { name: 'Responders', href: '/dashboard/responders', icon: 'groups' },
  { name: 'Devices', href: '/dashboard/devices', icon: 'sensors' },
  { name: 'Reports', href: '/dashboard/reports', icon: 'assessment' },
  { name: 'Settings', href: '/dashboard/settings', icon: 'settings' },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-64 bg-surface-container h-screen flex flex-col fixed left-0 top-0 py-gutter border-r border-outline-variant z-40">
      <div className="px-6 mb-8">
        <h1 className="font-headline-lg text-headline-lg font-bold text-primary">CampusSafe</h1>
        <p className="font-label-md text-label-md text-on-surface-variant">Emergency Operations</p>
      </div>
      <nav className="flex-1 overflow-y-auto px-4 space-y-1">
        {navigation.map((item) => {
          const isActive = pathname === item.href || 
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
                className="material-symbols-outlined"
                style={active ? { fontVariationSettings: "'FILL' 1" } : undefined}
              >
                {item.icon}
              </span>
              <span className="font-label-md text-label-md">{item.name}</span>
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
