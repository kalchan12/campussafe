'use client';

interface TopNavProps {
  title: string;
  actions?: React.ReactNode;
}

export function TopNav({ title, actions }: TopNavProps) {
  return (
    <header className="bg-white border-b border-gray-200 px-6 py-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">{title}</h1>
        </div>
        <div className="flex items-center gap-4">
          {actions}
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
              <span className="text-sm font-medium text-blue-600">OP</span>
            </div>
            <span className="text-sm font-medium text-gray-700">Operator</span>
          </div>
        </div>
      </div>
    </header>
  );
}
