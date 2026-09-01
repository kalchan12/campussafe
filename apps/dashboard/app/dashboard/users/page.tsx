'use client';

import { useState, useEffect, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { DashboardLayout } from '@/components/layout/dashboard-layout';
import { fetchUsers, updateUserRole, toggleUserActive, fetchUserStats } from '@/lib/data-service';
import type { User, UserRole, UserFilter } from '@/types/user';
import { USER_ROLE_LABELS, USER_ROLE_COLORS } from '@/types/user';

export default function UserManagementPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [stats, setStats] = useState<{
    total: number;
    students: number;
    responders: number;
    operators: number;
    administrators: number;
    staff: number;
    active: number;
    inactive: number;
  } | null>(null);
  const [search, setSearch] = useState('');
  const [selectedRole, setSelectedRole] = useState<string>('');
  const [selectedStatus, setSelectedStatus] = useState<string>('');
  const [selectedBlock, setSelectedBlock] = useState<string>('');
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [isUpdating, setIsUpdating] = useState(false);
  const [successMessage, setSuccessMessage] = useState('');

  const router = useRouter();
  const supabase = createClient();
  
  useEffect(() => {
    supabase.auth.getUser().then(async ({ data: { user } }) => {
      if (user) {
        const { data: profile } = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
        if (profile?.role !== 'administrator') {
          router.replace('/dashboard');
        }
      } else {
        router.replace('/login');
      }
    });
  }, [router, supabase]);

  const loadData = async () => {
    const filter: UserFilter = {
      search: search || undefined,
      role: selectedRole ? [selectedRole as UserRole] : undefined,
      is_active: selectedStatus === 'active' ? true : selectedStatus === 'inactive' ? false : undefined,
      campus_block: selectedBlock || undefined,
    };
    const [userData, statsData] = await Promise.all([
      fetchUsers(filter),
      fetchUserStats(),
    ]);
    setUsers(userData);
    setStats(statsData);
  };

  useEffect(() => {
    loadData();
  }, [search, selectedRole, selectedStatus, selectedBlock]);

  const handleRoleChange = async (userId: string, newRole: UserRole) => {
    setIsUpdating(true);
    try {
      await updateUserRole(userId, newRole);
      setSuccessMessage('User role updated successfully');
      setTimeout(() => setSuccessMessage(''), 3000);
      await loadData();
    } catch (err) {
      console.error(err);
    } finally {
      setIsUpdating(false);
      setEditingUser(null);
    }
  };

  const handleToggleStatus = async (userId: string, currentStatus: boolean = true) => {
    setIsUpdating(true);
    try {
      await toggleUserActive(userId, !currentStatus);
      setSuccessMessage(`User ${!currentStatus ? 'activated' : 'deactivated'} successfully`);
      setTimeout(() => setSuccessMessage(''), 3000);
      await loadData();
    } catch (err) {
      console.error(err);
    } finally {
      setIsUpdating(false);
    }
  };

  const campusBlocks = useMemo(() => {
    return Array.from(new Set(users.map((u) => u.campus_block).filter(Boolean)));
  }, [users]);

  return (
    <DashboardLayout title="User & Access Administration"
          showSearch
          searchPlaceholder="Search by name, email, phone or block..."
          onSearch={setSearch}>
      <div className="max-w-[1280px] mx-auto space-y-6">
            {/* Header & Role summary banner */}
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
              <div>
                <div className="flex items-center gap-2">
                  <span className="material-symbols-outlined text-primary text-2xl">admin_panel_settings</span>
                  <h1 className="font-headline-lg text-headline-lg font-bold text-on-surface">User Management</h1>
                </div>
                <p className="font-body-md text-body-md text-on-surface-variant mt-1">
                  Manage accounts, permissions, and roles across mobile apps, responders, and EOC operators.
                </p>
              </div>

              {successMessage && (
                <div className="flex items-center gap-2 px-4 py-2 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-lg font-label-md text-label-md animate-fade-in">
                  <span className="material-symbols-outlined text-sm">check_circle</span>
                  <span>{successMessage}</span>
                </div>
              )}
            </div>

            {/* Quick KPI stats grid */}
            {stats && (
              <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
                <div className="bg-surface-container-lowest border border-outline-variant/60 rounded-xl p-4 shadow-sm">
                  <div className="flex items-center justify-between text-on-surface-variant mb-1">
                    <span className="font-label-md text-xs font-semibold uppercase tracking-wider">Total Users</span>
                    <span className="material-symbols-outlined text-base text-primary">groups</span>
                  </div>
                  <p className="font-headline-lg text-2xl font-bold text-on-surface">{stats.total}</p>
                  <p className="font-technical-sm text-xs text-outline mt-1">{stats.active} Active accounts</p>
                </div>

                <div className="bg-surface-container-lowest border border-outline-variant/60 rounded-xl p-4 shadow-sm">
                  <div className="flex items-center justify-between text-on-surface-variant mb-1">
                    <span className="font-label-md text-xs font-semibold uppercase tracking-wider">Students</span>
                    <span className="material-symbols-outlined text-base text-blue-600">school</span>
                  </div>
                  <p className="font-headline-lg text-2xl font-bold text-on-surface">{stats.students}</p>
                  <p className="font-technical-sm text-xs text-blue-600 mt-1">Mobile app users</p>
                </div>

                <div className="bg-surface-container-lowest border border-outline-variant/60 rounded-xl p-4 shadow-sm">
                  <div className="flex items-center justify-between text-on-surface-variant mb-1">
                    <span className="font-label-md text-xs font-semibold uppercase tracking-wider">Responders</span>
                    <span className="material-symbols-outlined text-base text-red-600">medical_services</span>
                  </div>
                  <p className="font-headline-lg text-2xl font-bold text-on-surface">{stats.responders}</p>
                  <p className="font-technical-sm text-xs text-red-600 mt-1">Medical & Security</p>
                </div>

                <div className="bg-surface-container-lowest border border-outline-variant/60 rounded-xl p-4 shadow-sm">
                  <div className="flex items-center justify-between text-on-surface-variant mb-1">
                    <span className="font-label-md text-xs font-semibold uppercase tracking-wider">Operators</span>
                    <span className="material-symbols-outlined text-base text-indigo-600">desktop_windows</span>
                  </div>
                  <p className="font-headline-lg text-2xl font-bold text-on-surface">{stats.operators}</p>
                  <p className="font-technical-sm text-xs text-indigo-600 mt-1">EOC dashboard</p>
                </div>

                <div className="bg-surface-container-lowest border border-outline-variant/60 rounded-xl p-4 shadow-sm">
                  <div className="flex items-center justify-between text-on-surface-variant mb-1">
                    <span className="font-label-md text-xs font-semibold uppercase tracking-wider">Staff</span>
                    <span className="material-symbols-outlined text-base text-teal-600">badge</span>
                  </div>
                  <p className="font-headline-lg text-2xl font-bold text-on-surface">{stats.staff}</p>
                  <p className="font-technical-sm text-xs text-teal-600 mt-1">Faculty & Officers</p>
                </div>

                <div className="bg-surface-container-lowest border border-outline-variant/60 rounded-xl p-4 shadow-sm">
                  <div className="flex items-center justify-between text-on-surface-variant mb-1">
                    <span className="font-label-md text-xs font-semibold uppercase tracking-wider">Admins</span>
                    <span className="material-symbols-outlined text-base text-purple-600">shield_person</span>
                  </div>
                  <p className="font-headline-lg text-2xl font-bold text-on-surface">{stats.administrators}</p>
                  <p className="font-technical-sm text-xs text-purple-600 mt-1">System control</p>
                </div>
              </div>
            )}

            {/* Filter toolbar */}
            <div className="bg-surface-container-lowest border border-outline-variant rounded-xl p-4 flex flex-wrap items-center justify-between gap-4">
              <div className="flex flex-wrap items-center gap-3">
                <div className="flex items-center gap-1.5 text-on-surface-variant font-label-md text-sm font-semibold">
                  <span className="material-symbols-outlined text-lg">filter_list</span>
                  <span>Filter by:</span>
                </div>

                {/* Role filter */}
                <select
                  value={selectedRole}
                  onChange={(e) => setSelectedRole(e.target.value)}
                  className="px-3 py-2 border border-outline-variant rounded-lg bg-surface-container-lowest text-on-surface font-label-md text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
                >
                  <option value="">All Roles</option>
                  <option value="student">Student (Mobile User)</option>
                  <option value="medical_responder">Medical Responder</option>
                  <option value="security_responder">Security Responder</option>
                  <option value="operator">EOC Operator</option>
                  <option value="staff">Staff</option>
                  <option value="administrator">Administrator</option>
                </select>

                {/* Status filter */}
                <select
                  value={selectedStatus}
                  onChange={(e) => setSelectedStatus(e.target.value)}
                  className="px-3 py-2 border border-outline-variant rounded-lg bg-surface-container-lowest text-on-surface font-label-md text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
                >
                  <option value="">All Statuses</option>
                  <option value="active">Active</option>
                  <option value="inactive">Inactive / Suspended</option>
                </select>

                {/* Block filter */}
                <select
                  value={selectedBlock}
                  onChange={(e) => setSelectedBlock(e.target.value)}
                  className="px-3 py-2 border border-outline-variant rounded-lg bg-surface-container-lowest text-on-surface font-label-md text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
                >
                  <option value="">All Locations</option>
                  {campusBlocks.map((blk) => (
                    <option key={blk} value={blk}>
                      {blk}
                    </option>
                  ))}
                </select>

                {(selectedRole || selectedStatus || selectedBlock || search) && (
                  <button
                    type="button"
                    onClick={() => {
                      setSelectedRole('');
                      setSelectedStatus('');
                      setSelectedBlock('');
                      setSearch('');
                    }}
                    className="text-xs text-primary font-medium hover:underline flex items-center gap-1"
                  >
                    <span className="material-symbols-outlined text-sm">restart_alt</span>
                    Reset Filters
                  </button>
                )}
              </div>

              <div className="font-technical-sm text-xs text-outline">
                Showing {users.length} registered accounts
              </div>
            </div>

            {/* Users Directory Table */}
            <div className="bg-surface-container-lowest border border-outline-variant rounded-xl overflow-hidden shadow-sm">
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="border-b border-outline-variant bg-surface-container/60">
                      <th className="py-3.5 px-4 font-label-md text-xs uppercase tracking-wider text-on-surface-variant font-semibold">User</th>
                      <th className="py-3.5 px-4 font-label-md text-xs uppercase tracking-wider text-on-surface-variant font-semibold">Role</th>
                      <th className="py-3.5 px-4 font-label-md text-xs uppercase tracking-wider text-on-surface-variant font-semibold">Campus Block</th>
                      <th className="py-3.5 px-4 font-label-md text-xs uppercase tracking-wider text-on-surface-variant font-semibold">Emergency Info / Notes</th>
                      <th className="py-3.5 px-4 font-label-md text-xs uppercase tracking-wider text-on-surface-variant font-semibold">Status</th>
                      <th className="py-3.5 px-4 font-label-md text-xs uppercase tracking-wider text-on-surface-variant font-semibold text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-outline-variant/60 font-body-md text-sm text-on-surface">
                    {users.length === 0 ? (
                      <tr>
                        <td colSpan={6} className="py-12 text-center text-outline">
                          <span className="material-symbols-outlined text-4xl block mb-2 text-outline/60">person_off</span>
                          No users found matching your filters.
                        </td>
                      </tr>
                    ) : (
                      users.map((u) => {
                        const isActive = u.is_active ?? true;
                        const roleColor = USER_ROLE_COLORS[u.role] || 'bg-gray-100 text-gray-800';
                        const roleLabel = USER_ROLE_LABELS[u.role] || u.role;

                        return (
                          <tr key={u.id} className="hover:bg-surface-variant/30 transition-colors">
                            {/* User Name & Email */}
                            <td className="py-4 px-4">
                              <div className="flex items-center gap-3">
                                <div className="w-9 h-9 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-sm">
                                  {u.full_name.charAt(0)}
                                </div>
                                <div>
                                  <p className="font-semibold text-on-surface">{u.full_name}</p>
                                  <p className="font-technical-sm text-xs text-outline">{u.email}</p>
                                  {u.phone && (
                                    <p className="font-technical-sm text-xs text-outline/80">{u.phone}</p>
                                  )}
                                </div>
                              </div>
                            </td>

                            {/* Role Badge / Role selector */}
                            <td className="py-4 px-4">
                              {editingUser?.id === u.id ? (
                                <select
                                  defaultValue={u.role}
                                  onChange={(e) => handleRoleChange(u.id, e.target.value as UserRole)}
                                  disabled={isUpdating}
                                  className="px-2 py-1 border border-primary rounded text-xs bg-surface-container-lowest font-medium text-on-surface focus:outline-none"
                                >
                                  <option value="student">Student</option>
                                  <option value="staff">Staff</option>
                                  <option value="medical_responder">Medical Responder</option>
                                  <option value="security_responder">Security Responder</option>
                                  <option value="operator">EOC Operator</option>
                                  <option value="administrator">Administrator</option>
                                </select>
                              ) : (
                                <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold border ${roleColor}`}>
                                  {roleLabel}
                                </span>
                              )}
                            </td>

                            {/* Campus Location */}
                            <td className="py-4 px-4 font-technical-sm text-xs text-on-surface-variant">
                              {u.campus_block ? (
                                <span className="inline-flex items-center gap-1">
                                  <span className="material-symbols-outlined text-sm text-outline">location_on</span>
                                  {u.campus_block}
                                </span>
                              ) : (
                                <span className="text-outline italic">—</span>
                              )}
                            </td>

                            {/* Emergency Notes */}
                            <td className="py-4 px-4 max-w-xs text-xs text-on-surface-variant truncate" title={u.emergency_info}>
                              {u.emergency_info || <span className="text-outline italic">None provided</span>}
                            </td>

                            {/* Status */}
                            <td className="py-4 px-4">
                              <span
                                className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[11px] font-semibold ${
                                  isActive
                                    ? 'bg-emerald-100 text-emerald-800'
                                    : 'bg-red-100 text-red-800'
                                }`}
                              >
                                <span className={`w-1.5 h-1.5 rounded-full ${isActive ? 'bg-emerald-500' : 'bg-red-500'}`} />
                                {isActive ? 'Active' : 'Suspended'}
                              </span>
                            </td>

                            {/* Actions */}
                            <td className="py-4 px-4 text-right">
                              <div className="inline-flex items-center gap-1">
                                <button
                                  type="button"
                                  onClick={() => setEditingUser(editingUser?.id === u.id ? null : u)}
                                  title="Change Role"
                                  className="p-1.5 text-on-surface-variant hover:text-primary hover:bg-surface-variant rounded transition-colors"
                                >
                                  <span className="material-symbols-outlined text-base">manage_accounts</span>
                                </button>

                                <button
                                  type="button"
                                  onClick={() => handleToggleStatus(u.id, isActive)}
                                  disabled={isUpdating}
                                  title={isActive ? 'Deactivate User' : 'Activate User'}
                                  className={`p-1.5 rounded transition-colors ${
                                    isActive
                                      ? 'text-on-surface-variant hover:text-error hover:bg-error-container/30'
                                      : 'text-on-surface-variant hover:text-emerald-600 hover:bg-emerald-50'
                                  }`}
                                >
                                  <span className="material-symbols-outlined text-base">
                                    {isActive ? 'block' : 'check_circle'}
                                  </span>
                                </button>
                              </div>
                            </td>
                          </tr>
                        );
                      })
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
    </DashboardLayout>
  );
}
