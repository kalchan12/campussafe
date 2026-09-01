'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const supabase = createClient();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      const { error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (signInError) throw signInError;

      router.refresh();
      router.push('/dashboard');
    } catch (err: any) {
      setError(err.message || 'Invalid credentials.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="bg-surface min-h-screen flex flex-col items-center justify-center font-body-md text-body-md antialiased">
      <div className="w-full max-w-md px-margin-mobile md:px-0">
        {/* Brand Header */}
        <div className="text-center mb-8 flex flex-col items-center justify-center space-y-2">
          <span
            className="material-symbols-outlined text-primary text-5xl mb-2"
            style={{ fontVariationSettings: "'FILL' 1" }}
          >
            shield_person
          </span>
          <h1 className="font-headline-lg text-headline-lg font-bold text-primary tracking-tight">
            CampusSafe
          </h1>
          <p className="font-label-md text-label-md text-on-surface-variant uppercase tracking-widest font-semibold">
            Emergency Operations Center
          </p>
        </div>

        {/* Login Card */}
        <div className="bg-surface-container-lowest border border-outline-variant rounded-xl p-8 shadow-[0_4px_12px_rgba(0,0,0,0.05)] relative overflow-hidden">
          {/* Top Accent Bar */}
          <div className="absolute top-0 left-0 w-full h-1 bg-primary opacity-80" />

          {error && (
            <div className="mb-6 p-3 bg-error-container border border-error/20 rounded text-on-error-container font-label-md text-label-md">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Email Input */}
            <div className="space-y-2">
              <label className="font-label-md text-label-md text-on-surface block" htmlFor="email">
                Email Address
              </label>
              <div className="relative">
                <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-lg pointer-events-none">
                  mail
                </span>
                <input
                  id="email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full pl-10 pr-3 py-3 border border-outline-variant rounded bg-surface-container-lowest text-on-surface placeholder:text-outline focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-colors font-technical-sm text-technical-sm"
                  placeholder="officer@campus.edu"
                  autoComplete="email"
                  required
                />
              </div>
            </div>

            {/* Password Input */}
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <label className="font-label-md text-label-md text-on-surface block" htmlFor="password">
                  Password
                </label>
                <button
                  type="button"
                  className="font-label-md text-label-md text-primary hover:text-primary-container hover:underline transition-colors focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 rounded"
                >
                  Forgot Password?
                </button>
              </div>
              <div className="relative">
                <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-lg pointer-events-none">
                  lock
                </span>
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-10 pr-10 py-3 border border-outline-variant rounded bg-surface-container-lowest text-on-surface placeholder:text-outline focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-colors font-technical-sm text-technical-sm tracking-widest"
                  placeholder="••••••••"
                  autoComplete="current-password"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-outline hover:text-on-surface transition-colors focus:outline-none focus:text-primary"
                  aria-label="Toggle password visibility"
                >
                  <span className="material-symbols-outlined text-lg">
                    {showPassword ? 'visibility' : 'visibility_off'}
                  </span>
                </button>
              </div>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full min-h-[44px] bg-primary text-on-primary rounded font-label-md text-label-md flex items-center justify-center space-x-2 hover:bg-primary-container hover:text-on-primary-container transition-colors focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface active:scale-[0.98] mt-8 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span>{isLoading ? 'Signing in...' : 'Sign In'}</span>
              {!isLoading && (
                <span className="material-symbols-outlined text-sm">login</span>
              )}
            </button>
          </form>

          {/* Demo Credentials & Quick Login */}
          <div className="mt-6 p-4 bg-surface-container rounded-lg border border-outline-variant/50 space-y-3">
            <div className="flex items-center justify-between">
              <p className="font-label-md text-label-md text-on-surface font-semibold">Demo Credentials</p>
              <span className="font-technical-sm text-[11px] bg-secondary-container text-primary px-2 py-0.5 rounded font-medium">Quick Fill</span>
            </div>
            <div className="space-y-1.5 text-technical-sm font-technical-sm text-outline">
              <p>Email: <code className="text-on-surface font-medium">operator@campus.edu</code></p>
              <p>Password: <code className="text-on-surface font-medium">password</code></p>
            </div>
            <div className="pt-2 border-t border-outline-variant/40 flex gap-2">
              <button
                type="button"
                onClick={() => {
                  setEmail('operator@campus.edu');
                  setPassword('password');
                  setError('');
                }}
                className="flex-1 py-1.5 px-2.5 text-xs bg-surface-container-lowest hover:bg-surface-variant text-primary border border-outline-variant rounded transition-colors font-medium text-center"
              >
                Fill Operator
              </button>
              <button
                type="button"
                onClick={() => {
                  setEmail('admin@campus.edu');
                  setPassword('password');
                  setError('');
                }}
                className="flex-1 py-1.5 px-2.5 text-xs bg-surface-container-lowest hover:bg-surface-variant text-primary border border-outline-variant rounded transition-colors font-medium text-center"
              >
                Fill Admin
              </button>
            </div>
          </div>
        </div>

        {/* Security Footer */}
        <div className="mt-8 flex flex-col items-center space-y-3">
          <div className="flex items-center space-x-1.5 text-on-surface-variant bg-surface-container py-1.5 px-3 rounded-full border border-outline-variant/50">
            <span className="material-symbols-outlined text-[16px] text-emerald-600">gpp_good</span>
            <span className="font-technical-sm text-technical-sm font-medium tracking-tight">Secure Connection Established</span>
          </div>
          <p className="font-technical-sm text-technical-sm text-outline text-center uppercase tracking-wider max-w-[280px]">
            Authorized Personnel Only. Access attempts are logged.
          </p>
        </div>
      </div>
    </div>
  );
}
