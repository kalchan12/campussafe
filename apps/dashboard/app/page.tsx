import Link from 'next/link';

export default function Home() {
  return (
    <main className="min-h-screen bg-surface flex flex-col items-center justify-center p-6">
      <div className="text-center space-y-6">
        <span
          className="material-symbols-outlined text-primary text-7xl"
          style={{ fontVariationSettings: "'FILL' 1" }}
        >
          shield_person
        </span>
        <h1 className="font-display-lg text-display-lg text-primary tracking-tight">CampusSafe</h1>
        <p className="font-body-md text-body-md text-on-surface-variant max-w-md">
          Emergency Operations Dashboard — Centralized monitoring and response coordination for campus safety.
        </p>
        <Link
          href="/login"
          className="inline-flex items-center gap-2 px-8 py-3 bg-primary text-on-primary rounded font-label-md text-label-md hover:bg-primary-container hover:text-on-primary-container transition-colors focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
        >
          <span>Access Dashboard</span>
          <span className="material-symbols-outlined text-sm">arrow_forward</span>
        </Link>
      </div>
    </main>
  );
}
