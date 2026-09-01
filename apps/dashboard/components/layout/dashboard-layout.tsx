'use client';

import { useState } from 'react';
import { Sidebar } from './sidebar';
import { TopNav } from './top-nav';
import { cn } from '@/lib/utils';

interface DashboardLayoutProps {
  children: React.ReactNode;
  title?: string;
  showSearch?: boolean;
  searchPlaceholder?: string;
  onSearch?: (query: string) => void;
  actions?: React.ReactNode;
  mainClassName?: string;
}

export function DashboardLayout({
  children,
  title,
  showSearch,
  searchPlaceholder,
  onSearch,
  actions,
  mainClassName = "flex-1 overflow-y-auto bg-background p-6"
}: DashboardLayoutProps) {
  const [isCollapsed, setIsCollapsed] = useState(false);

  return (
    <div className="flex h-screen bg-background overflow-hidden">
      <Sidebar isCollapsed={isCollapsed} onToggle={() => setIsCollapsed(!isCollapsed)} />
      <div className={cn(
        "flex-1 flex flex-col transition-all duration-300 h-screen overflow-hidden",
        isCollapsed ? "ml-[72px]" : "ml-64"
      )}>
        <TopNav 
          title={title}
          showSearch={showSearch}
          searchPlaceholder={searchPlaceholder}
          onSearch={onSearch}
          actions={actions}
        />
        <main className={mainClassName}>
          {children}
        </main>
      </div>
    </div>
  );
}
