'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import styles from './team.module.css';

interface Profile {
    id: string;
    full_name: string;
    email: string;
    role: string;
    created_at: string;
}

import { getTeamMembers, updateTeamMemberRole } from './actions';

export default function TeamPage() {
    const [users, setUsers] = useState<Profile[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedUser, setSelectedUser] = useState<Profile | null>(null);
    const [showEditModal, setShowEditModal] = useState(false);
    const [currentUserRole, setCurrentUserRole] = useState('');

    useEffect(() => {
        loadData();
    }, []);

    async function loadData() {
        setLoading(true);
        try {
            // Check current user role for UI context (still client-side)
            const { data: { user } } = await supabase.auth.getUser();
            if (user) {
                const { data: profile } = await supabase.from('profiles').select('role').eq('id', user.id).single();
                setCurrentUserRole(profile?.role || 'student');
            }

            // Fetch all users using Server Action (bypasses RLS)
            const data = await getTeamMembers();
            setUsers(data as Profile[]);
        } catch (error) {
            console.error('Failed to load team:', error);
        } finally {
            setLoading(false);
        }
    }

    const handleEditRole = (user: Profile) => {
        setSelectedUser(user);
        setShowEditModal(true);
    };

    const getRoleColor = (role: string) => {
        switch (role) {
            case 'admin': return '#ef4444'; // Red
            case 'organizer': return '#f59e0b'; // Orange
            case 'volunteer': return '#10b981'; // Green
            case 'scanner': return '#3b82f6'; // Blue
            default: return '#9ca3af'; // Gray
        }
    };

    return (
        <div className={styles.container}>
            <div className={styles.bgOrb1} />
            <div className={styles.bgOrb2} />

            <header className={styles.header}>
                <div className={styles.titleRow}>
                    <h1>Global Team Management</h1>
                    <p className={styles.subtitle}>Manage system-wide roles and access permissions.</p>
                </div>
                <button className="btn btn-primary" onClick={loadData}>
                    Refresh List
                </button>
            </header>

            {loading ? (
                <div>Loading users...</div>
            ) : users.length === 0 ? (
                <div style={{ padding: 40, background: 'rgba(255,255,255,0.05)', borderRadius: 16 }}>
                    <h3>No users found.</h3>
                    <p>This is likely because you do not have <strong>Admin</strong> permissions enabled in the database.</p>
                    <p>Current Role detected: <strong>{currentUserRole}</strong></p>
                    <br />
                    <p>To fix this:</p>
                    <ol style={{ paddingLeft: 20, lineHeight: 1.6 }}>
                        <li>Go to Supabase Dashboard &gt; Table Editor &gt; <code>profiles</code> table.</li>
                        <li>Find your user row.</li>
                        <li>Change the <code>role</code> column valye to <code>admin</code>.</li>
                        <li>Refresh this page.</li>
                    </ol>
                </div>
            ) : (
                <div className={styles.tableContainer}>
                    <div className={styles.tableHeader}>
                        <span>User</span>
                        <span>Email</span>
                        <span>Global Role</span>
                        <span>Actions</span>
                    </div>
                    {users.map(user => (
                        <div key={user.id} className={styles.tableRow}>
                            <div className={styles.userCell}>
                                <div className={styles.avatar}>{user.full_name?.[0]?.toUpperCase()}</div>
                                <span style={{ fontWeight: 500 }}>{user.full_name || 'Unnamed'}</span>
                            </div>
                            <div style={{ color: '#aaa' }}>{user.email}</div>
                            <div>
                                <span
                                    className={styles.roleBadge}
                                    style={{ background: `${getRoleColor(user.role)}33`, color: getRoleColor(user.role) }}
                                >
                                    {user.role}
                                </span>
                            </div>
                            <div>
                                <button className="btn btn-ghost" onClick={() => handleEditRole(user)}>Edit Role</button>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {showEditModal && selectedUser && (
                <EditRoleModal
                    user={selectedUser}
                    onClose={() => setShowEditModal(false)}
                    onUpdate={loadData}
                />
            )}
        </div>
    );
}

function EditRoleModal({ user, onClose, onUpdate }: any) {
    const [role, setRole] = useState(user.role);
    const [loading, setLoading] = useState(false);

    const handleSave = async () => {
        setLoading(true);
        try {
            await updateTeamMemberRole(user.id, role);
            onUpdate();
            onClose();
        } catch (error: any) {
            alert(error.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className={styles.modalOverlay} onClick={onClose}>
            <div className={styles.modal} onClick={e => e.stopPropagation()}>
                <div className={styles.modalHeader}>
                    <h2>Edit Role: {user.full_name}</h2>
                    <button className={styles.closeBtn} onClick={onClose}>✕</button>
                </div>
                <div style={{ marginBottom: 24 }}>
                    <label style={{ display: 'block', marginBottom: 8 }}>Global System Role</label>
                    <select
                        className="input"
                        value={role}
                        onChange={e => setRole(e.target.value)}
                    >
                        <option value="student">Student / Guest (Default)</option>
                        <option value="volunteer">Volunteer (Can be assigned events)</option>
                        <option value="organizer">Organizer (Can manage many things)</option>
                        <option value="admin">Admin (Full Access)</option>
                    </select>
                    <p style={{ marginTop: 12, fontSize: '0.9rem', color: '#aaa' }}>
                        <strong>Note:</strong>
                        <br />- <strong>Volunteers</strong> only see events assigned to them in the app.
                        <br />- <strong>Admins</strong> see everything.
                    </p>
                </div>
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 12 }}>
                    <button className="btn btn-ghost" onClick={onClose}>Cancel</button>
                    <button className="btn btn-primary" onClick={handleSave} disabled={loading}>
                        {loading ? 'Saving...' : 'Save Role'}
                    </button>
                </div>
            </div>
        </div>
    );
}
