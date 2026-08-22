'use client';

import { Sidebar } from '@/components/layout/sidebar';
import { Button } from '@/components/ui/button';

export default function SettingsPage() {
  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 overflow-auto">
        <header className="bg-white border-b border-gray-200 px-6 py-4">
          <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
          <p className="text-sm text-gray-500 mt-1">Configure dashboard preferences</p>
        </header>

        <div className="p-6">
          <div className="max-w-2xl space-y-6">
            {/* General Settings */}
            <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-lg font-semibold text-gray-900">General</h2>
              </div>
              <div className="p-6 space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Dashboard Name
                  </label>
                  <input
                    type="text"
                    defaultValue="CampusSafe Operations"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Refresh Interval (seconds)
                  </label>
                  <input
                    type="number"
                    defaultValue={30}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                  />
                </div>
              </div>
            </div>

            {/* Notification Settings */}
            <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-lg font-semibold text-gray-900">Notifications</h2>
              </div>
              <div className="p-6 space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-900">Sound Alerts</p>
                    <p className="text-sm text-gray-500">Play sound for new incidents</p>
                  </div>
                  <input
                    type="checkbox"
                    defaultChecked
                    className="w-5 h-5 rounded border-gray-300"
                  />
                </div>
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-900">Desktop Notifications</p>
                    <p className="text-sm text-gray-500">Show system notifications</p>
                  </div>
                  <input
                    type="checkbox"
                    defaultChecked
                    className="w-5 h-5 rounded border-gray-300"
                  />
                </div>
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-900">Critical Incident Alerts</p>
                    <p className="text-sm text-gray-500">Alert for priority 1 incidents</p>
                  </div>
                  <input
                    type="checkbox"
                    defaultChecked
                    className="w-5 h-5 rounded border-gray-300"
                  />
                </div>
              </div>
            </div>

            {/* Map Settings */}
            <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-lg font-semibold text-gray-900">Map</h2>
              </div>
              <div className="p-6 space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-900">Show Responder Locations</p>
                    <p className="text-sm text-gray-500">Display responder positions on map</p>
                  </div>
                  <input
                    type="checkbox"
                    defaultChecked
                    className="w-5 h-5 rounded border-gray-300"
                  />
                </div>
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-900">Show Device Locations</p>
                    <p className="text-sm text-gray-500">Display IoT devices on map</p>
                  </div>
                  <input
                    type="checkbox"
                    defaultChecked
                    className="w-5 h-5 rounded border-gray-300"
                  />
                </div>
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
  );
}
