'use client';

import { Sidebar } from '@/components/layout/sidebar';
import { TopNav } from '@/components/layout/top-nav';
import { Button } from '@/components/ui/button';

export default function SettingsPage() {
  return (
    <div className="flex min-h-screen bg-background">
      <Sidebar />
      <div className="flex-1 flex flex-col ml-64 h-screen">
        <TopNav />
        <main className="flex-1 overflow-y-auto bg-background p-6">
          <div className="max-w-[1280px] mx-auto space-y-6">
            {/* Header */}
            <div>
              <h1 className="font-headline-lg text-headline-lg text-on-surface">Settings</h1>
              <p className="font-body-md text-body-md text-on-surface-variant mt-1">Configure dashboard preferences</p>
            </div>

            <div className="max-w-2xl space-y-6">
              {/* General Settings */}
              <div className="bg-surface-container-lowest border border-outline-variant rounded-lg">
                <div className="px-6 py-4 border-b border-outline-variant">
                  <h2 className="font-headline-lg-mobile text-headline-lg-mobile text-on-surface">General</h2>
                </div>
                <div className="p-6 space-y-4">
                  <div>
                    <label className="block font-label-md text-label-md text-on-surface mb-1">
                      Dashboard Name
                    </label>
                    <input
                      type="text"
                      defaultValue="CampusSafe Operations"
                      className="w-full px-4 py-2 border border-outline-variant rounded bg-surface-container-lowest text-on-surface font-body-md text-body-md focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
                    />
                  </div>
                  <div>
                    <label className="block font-label-md text-label-md text-on-surface mb-1">
                      Refresh Interval (seconds)
                    </label>
                    <input
                      type="number"
                      defaultValue={30}
                      className="w-full px-4 py-2 border border-outline-variant rounded bg-surface-container-lowest text-on-surface font-body-md text-body-md focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
                    />
                  </div>
                </div>
              </div>

              {/* Notification Settings */}
              <div className="bg-surface-container-lowest border border-outline-variant rounded-lg">
                <div className="px-6 py-4 border-b border-outline-variant">
                  <h2 className="font-headline-lg-mobile text-headline-lg-mobile text-on-surface">Notifications</h2>
                </div>
                <div className="p-6 space-y-4">
                  {[
                    { title: 'Sound Alerts', desc: 'Play sound for new incidents' },
                    { title: 'Desktop Notifications', desc: 'Show system notifications' },
                    { title: 'Critical Incident Alerts', desc: 'Alert for priority 1 incidents' },
                  ].map((setting) => (
                    <div key={setting.title} className="flex items-center justify-between">
                      <div>
                        <p className="font-body-md text-body-md text-on-surface font-medium">{setting.title}</p>
                        <p className="font-technical-sm text-technical-sm text-on-surface-variant">{setting.desc}</p>
                      </div>
                      <input
                        type="checkbox"
                        defaultChecked
                        className="w-5 h-5 rounded border-outline-variant text-primary focus:ring-primary"
                      />
                    </div>
                  ))}
                </div>
              </div>

              {/* Map Settings */}
              <div className="bg-surface-container-lowest border border-outline-variant rounded-lg">
                <div className="px-6 py-4 border-b border-outline-variant">
                  <h2 className="font-headline-lg-mobile text-headline-lg-mobile text-on-surface">Map</h2>
                </div>
                <div className="p-6 space-y-4">
                  {[
                    { title: 'Show Responder Locations', desc: 'Display responder positions on map' },
                    { title: 'Show Device Locations', desc: 'Display IoT devices on map' },
                  ].map((setting) => (
                    <div key={setting.title} className="flex items-center justify-between">
                      <div>
                        <p className="font-body-md text-body-md text-on-surface font-medium">{setting.title}</p>
                        <p className="font-technical-sm text-technical-sm text-on-surface-variant">{setting.desc}</p>
                      </div>
                      <input
                        type="checkbox"
                        defaultChecked
                        className="w-5 h-5 rounded border-outline-variant text-primary focus:ring-primary"
                      />
                    </div>
                  ))}
                </div>
              </div>

              <div className="flex justify-end gap-4">
                <Button variant="secondary">Cancel</Button>
                <Button>Save Settings</Button>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}
