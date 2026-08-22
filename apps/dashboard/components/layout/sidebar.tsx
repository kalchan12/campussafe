'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: '📊' },
  { name: 'Incidents', href: '/dashboard/incidents', icon: '🚨' },
  { name: 'Responders', href: '/dashboard/responders', icon: '👥' },
  { name: 'Devices', href: '/dashboard/devices', icon: '📡' },
  { name: 'Reports', href: '/dashboard/reports', icon: '📋' },
  { name: 'Settings', href: '/dashboard/settings', icon: '⚙️' },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-64 bg-gray-900 text-white min-h-screen">
      <div className="p-6">
        <h1 className="text-xl font-bold">CampusSafe</h1>
        <p className="text-sm text-gray-400">Operations Dashboard</p>
      </div>
      <nav className="px-4">
        {navigation.map((item) => {
          const isActive = pathname === item.href || pathname.startsWith(item.href + '/');
          return (
            <Link
              key={item.name}
              href={item.href}
              className={cn(
                'flex items-center gap-3 px-4 py-3 rounded-lg mb-1 text-sm font-medium transition-colors',
                isActive
                  ? 'bg-blue-600 text-white'
                  : 'text-gray-300 hover:bg-gray-800'
              )}
            >
              <span>{item.icon}</span>
              <span>{item.name}</span>
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
