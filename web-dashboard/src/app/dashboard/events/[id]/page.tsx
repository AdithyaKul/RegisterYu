'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter, useParams } from 'next/navigation';
import { LiquidCard } from '@/components/ui/LiquidCard';
import {
    getEvent,
    getEventRegistrations,
    getEventAssignments,
    updateEvent,
    deleteEvent,
    addEventAssignment,
    removeEventAssignment,
    searchUsers
} from '../actions';
import styles from './manage.module.css';

interface Event {
    id: string;
    title: string;
    description: string;
    date: string;
    location: string;
    category: string;
    price_amount: number;
    capacity: number;
    image_url: string;
    status: 'draft' | 'published' | 'cancelled' | 'completed';
}

interface Registration {
    id: string;
    ticket_code: string;
    status: string;
    check_in_time: string;
    created_at: string;
    profiles: {
        full_name: string;
        email: string;
        phone: string;
    } | null;
}

interface Assignment {
    id: string;
    user_id: string;
    role: string;
    profiles: {
        full_name: string;
        email: string;
        role: string;
    };
}

export default function ManageEventPage() {
    const params = useParams();
    const id = params?.id as string;
    const router = useRouter();

    const [event, setEvent] = useState<Event | null>(null);
    const [stats, setStats] = useState({
        registrations: 0,
        revenue: 0,
        attendees: 0
    });
    const [registrations, setRegistrations] = useState<Registration[]>([]);
    const [assignments, setAssignments] = useState<Assignment[]>([]);
    const [activeTab, setActiveTab] = useState<'overview' | 'attendees' | 'team' | 'settings'>('overview');
    const [showEditModal, setShowEditModal] = useState(false);
    const [showAddMemberModal, setShowAddMemberModal] = useState(false);
    const [loading, setLoading] = useState(true);
    const [errorInfo, setErrorInfo] = useState<string | null>(null);

    useEffect(() => {
        if (id) fetchEventData();
    }, [id]);

    async function fetchEventData() {
        try {
            setErrorInfo(null);

            // 1. Fetch Event
            const eventData = await getEvent(id);
            if (!eventData) throw new Error("Event not found");

            setEvent({
                ...eventData,
                title: eventData.title || eventData.name,
                date: eventData.date || eventData.event_date
            });

            // 2. Fetch Registrations
            const regs = await getEventRegistrations(id);
            if (regs) {
                setRegistrations(regs as any[]);
                const checkedIn = regs.filter((r: any) => r.status === 'checked_in').length;
                const revenue = (eventData.price_amount || 0) * (regs.length);

                setStats({
                    registrations: regs.length,
                    revenue: revenue,
                    attendees: checkedIn
                });
            }

            // 3. Fetch Team Assignments
            const team = await getEventAssignments(id);
            if (team) {
                setAssignments(team as any[]);
            }

        } catch (e: any) {
            console.error("Error fetching event data:", e);
            setErrorInfo(e.message || "Unknown error");
        } finally {
            setLoading(false);
        }
    }

    const handleDelete = async () => {
        if (!confirm("Delete this event? Cannot be undone.")) return;

        try {
            await deleteEvent(id);
            router.push('/dashboard/events');
        } catch (error: any) {
            alert("Error: " + error.message);
        }
    };

    const handleStatusToggle = async () => {
        if (!event) return;
        const newStatus = event.status === 'published' ? 'draft' : 'published';

        try {
            await updateEvent(id, { status: newStatus });
            setEvent({ ...event, status: newStatus });
        } catch (error) {
            alert("Error updating status");
        }
    };

    const handleRemoveMember = async (assignmentId: string) => {
        if (!confirm("Remove this member from event team?")) return;
        try {
            await removeEventAssignment(assignmentId, id);
            fetchEventData();
        } catch (error: any) {
            alert(error.message);
        }
    };

    if (loading) return <div className={styles.container}>Loading...</div>;

    if (errorInfo) return (
        <div className={styles.container} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', paddingTop: 100 }}>
            <h2>Error Loading Event</h2>
            <div style={{ color: '#ef4444', margin: '20px 0', padding: 20, background: 'rgba(255,0,0,0.1)', borderRadius: 8 }}>{errorInfo}</div>
            {errorInfo.includes('uuid') && <p>Invalid Event ID: {id}</p>}
            <Link href="/dashboard/events" className="btn btn-primary">Back to Events</Link>
        </div>
    );

    if (!event) return <div className={styles.container}>Event not found</div>;

    return (
        <div className={styles.container}>
            <div className={styles.bgOrb1} />
            <div className={styles.bgOrb2} />

            {/* Header */}
            <header className={styles.header}>
                <div className={styles.headerLeft}>
                    <Link href="/dashboard/events" className={styles.backBtn}>← Back to Events</Link>
                    <div className={styles.titleRow}>
                        <h1>{event.title}</h1>
                        <span className={styles.statusBadge} style={{
                            background: event.status === 'published' ? '#10b981' : '#f59e0b',
                            color: event.status === 'published' ? 'white' : 'black'
                        }}>
                            {event.status}
                        </span>
                    </div>
                </div>
                <div className={styles.headerActions}>
                    <button className="btn btn-secondary" onClick={() => setShowEditModal(true)}>Edit Event</button>
                </div>
            </header>

            {/* Stats */}
            <div className={styles.statsGrid}>
                <LiquidCard>
                    <div style={{ textAlign: 'center' }}>
                        <div style={{ fontSize: '2rem', fontWeight: 'bold' }}>{stats.registrations} / {event.capacity}</div>
                        <div style={{ color: '#aaa', fontSize: '0.9rem' }}>Registrations</div>
                    </div>
                </LiquidCard>
                <LiquidCard>
                    <div style={{ textAlign: 'center' }}>
                        <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#10b981' }}>₹{stats.revenue.toLocaleString()}</div>
                        <div style={{ color: '#aaa', fontSize: '0.9rem' }}>Revenue</div>
                    </div>
                </LiquidCard>
                <LiquidCard>
                    <div style={{ textAlign: 'center' }}>
                        <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#f59e0b' }}>{stats.attendees}</div>
                        <div style={{ color: '#aaa', fontSize: '0.9rem' }}>Checked-In</div>
                    </div>
                </LiquidCard>
            </div>

            {/* Tabs */}
            <div className={styles.tabs}>
                <button
                    className={`${styles.tab} ${activeTab === 'overview' ? styles.active : ''}`}
                    onClick={() => setActiveTab('overview')}
                >
                    Overview
                </button>
                <button
                    className={`${styles.tab} ${activeTab === 'attendees' ? styles.active : ''}`}
                    onClick={() => setActiveTab('attendees')}
                >
                    Attendees
                </button>
                <button
                    className={`${styles.tab} ${activeTab === 'team' ? styles.active : ''}`}
                    onClick={() => setActiveTab('team')}
                >
                    Team & Access
                </button>
                <button
                    className={`${styles.tab} ${activeTab === 'settings' ? styles.active : ''}`}
                    onClick={() => setActiveTab('settings')}
                >
                    Settings
                </button>
            </div>

            {/* Content Sections */}
            <div className={styles.content}>

                {/* Overview */}
                {activeTab === 'overview' && (
                    <div className={styles.section}>
                        <div className={styles.detailsCard}>
                            <h3>Event Details</h3>
                            <div className={styles.detailRow}>
                                <span className={styles.label}>Date</span>
                                <span className={styles.value}>{new Date(event.date).toLocaleString()}</span>
                            </div>
                            <div className={styles.detailRow}>
                                <span className={styles.label}>Location</span>
                                <span className={styles.value}>{event.location}</span>
                            </div>
                            <div className={styles.detailRow}>
                                <span className={styles.label}>Category</span>
                                <span className={styles.value}>{event.category}</span>
                            </div>
                            <div className={styles.detailRow}>
                                <span className={styles.label}>Price</span>
                                <span className={styles.value}>{event.price_amount ? `₹${event.price_amount}` : 'Free'}</span>
                            </div>
                        </div>
                        {event.image_url && (
                            <div className={styles.detailsCard}>
                                <h3>Cover Image</h3>
                                <img src={event.image_url} alt="Cover" style={{ width: '100%', borderRadius: '8px', maxHeight: '300px', objectFit: 'cover' }} />
                            </div>
                        )}
                    </div>
                )}

                {/* Attendees */}
                {activeTab === 'attendees' && (
                    <div className={styles.section}>
                        <div className={styles.tableContainer}>
                            <div className={styles.tableHeader}>
                                <span>Name</span>
                                <span>Ticket</span>
                                <span>Contact</span>
                                <span>Status</span>
                            </div>
                            {registrations.length === 0 ? (
                                <div style={{ padding: '20px', textAlign: 'center', color: '#aaa' }}>No registrations yet.</div>
                            ) : (
                                registrations.map(reg => (
                                    <div key={reg.id} className={styles.tableRow}>
                                        <div className={styles.attendeeName}>
                                            <div className={styles.avatar}>{reg.profiles?.full_name?.[0]}</div>
                                            {reg.profiles?.full_name || 'Guest'}
                                        </div>
                                        <div style={{ fontFamily: 'monospace' }}>{reg.ticket_code}</div>
                                        <div style={{ fontSize: '0.85rem', color: '#aaa' }}>{reg.profiles?.email}</div>
                                        <div>
                                            <span style={{
                                                padding: '4px 8px', borderRadius: '4px', fontSize: '0.8rem',
                                                background: reg.status === 'checked_in' ? 'rgba(16, 185, 129, 0.2)' : 'rgba(255, 255, 255, 0.1)',
                                                color: reg.status === 'checked_in' ? '#10b981' : '#ccc'
                                            }}>
                                                {reg.status}
                                            </span>
                                        </div>
                                    </div>
                                ))
                            )}
                        </div>
                    </div>
                )}

                {/* Team */}
                {activeTab === 'team' && (
                    <div className={styles.section}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                            <h3>Assigned Team Members</h3>
                            <button className="btn btn-primary" onClick={() => setShowAddMemberModal(true)}>+ Add Member</button>
                        </div>
                        <div className={styles.tableContainer}>
                            <div className={styles.tableHeader} style={{ gridTemplateColumns: '2fr 2fr 1fr 1fr' }}>
                                <span>Name</span>
                                <span>Email</span>
                                <span>Assignment</span>
                                <span>Actions</span>
                            </div>
                            {assignments.length === 0 ? (
                                <div style={{ padding: '20px', textAlign: 'center', color: '#aaa' }}>
                                    No team members assigned. Only Admins can see this event.
                                </div>
                            ) : (
                                assignments.map(a => (
                                    <div key={a.id} className={styles.tableRow} style={{ gridTemplateColumns: '2fr 2fr 1fr 1fr' }}>
                                        <div className={styles.attendeeName}>
                                            <div className={styles.avatar} style={{ background: 'var(--accent-purple)' }}>{a.profiles?.full_name?.[0]}</div>
                                            {a.profiles?.full_name}
                                        </div>
                                        <div style={{ fontSize: '0.9rem', color: '#aaa' }}>{a.profiles?.email}</div>
                                        <div>
                                            <span style={{
                                                padding: '4px 8px', borderRadius: '4px', fontSize: '0.8rem',
                                                background: 'rgba(56, 189, 248, 0.2)', color: '#38bdf8'
                                            }}>
                                                {a.role}
                                            </span>
                                        </div>
                                        <div>
                                            <button className="btn btn-ghost" style={{ color: '#ef4444' }} onClick={() => handleRemoveMember(a.id)}>Remove</button>
                                        </div>
                                    </div>
                                ))
                            )}
                        </div>
                    </div>
                )}

                {/* Settings */}
                {activeTab === 'settings' && (
                    <div className={styles.section}>
                        <div className={styles.detailsCard}>
                            <h3>Event Visibility</h3>
                            <div className={styles.detailRow}>
                                <span className={styles.value} style={{ textTransform: 'uppercase', fontWeight: 'bold', color: event.status === 'published' ? '#10b981' : '#f59e0b' }}>{event.status}</span>
                                <button className="btn btn-secondary" onClick={handleStatusToggle}>
                                    {event.status === 'published' ? 'Unpublish' : 'Publish'}
                                </button>
                            </div>
                        </div>
                        <div className={styles.detailsCard} style={{ borderColor: '#ef4444' }}>
                            <h3 style={{ color: '#ef4444' }}>Danger Zone</h3>
                            <button className="btn" style={{ background: '#ef4444', color: 'white' }} onClick={handleDelete}>Delete Event</button>
                        </div>
                    </div>
                )}
            </div>

            {/* Modals */}
            {showEditModal && (
                <EditEventModal event={event} onClose={() => setShowEditModal(false)} onUpdate={() => { fetchEventData(); setShowEditModal(false); }} />
            )}

            {showAddMemberModal && (
                <AddMemberModal
                    eventId={event.id}
                    onClose={() => setShowAddMemberModal(false)}
                    onAdd={() => { fetchEventData(); setShowAddMemberModal(false); }}
                />
            )}
        </div>
    );
}

function EditEventModal({ event, onClose, onUpdate }: any) {
    const [formData, setFormData] = useState({ ...event, date: event.date ? new Date(event.date).toISOString().slice(0, 16) : '' });
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        try {
            await updateEvent(event.id, formData);
            onUpdate();
        } catch (e: any) { alert(e.message); }
        finally { setLoading(false); }
    };
    return (
        <div className={styles.modalOverlay} onClick={onClose}>
            <div className={styles.modal} onClick={e => e.stopPropagation()}>
                <div className={styles.modalHeader}><h2>Edit Event</h2><button className={styles.closeBtn} onClick={onClose}>✕</button></div>
                <form className={styles.modalBody} onSubmit={handleSubmit}>
                    <label style={{ display: 'block', marginBottom: 8 }}>Title</label>
                    <input className="input" value={formData.title} onChange={e => setFormData({ ...formData, title: e.target.value })} style={{ marginBottom: 16 }} />
                    <label style={{ display: 'block', marginBottom: 8 }}>Date</label>
                    <input type="datetime-local" className="input" value={formData.date} onChange={e => setFormData({ ...formData, date: e.target.value })} style={{ marginBottom: 16 }} />
                    <label style={{ display: 'block', marginBottom: 8 }}>Location</label>
                    <input className="input" value={formData.location} onChange={e => setFormData({ ...formData, location: e.target.value })} style={{ marginBottom: 16 }} />
                    <label style={{ display: 'block', marginBottom: 8 }}>Price</label>
                    <input type="number" className="input" value={formData.price_amount} onChange={e => setFormData({ ...formData, price_amount: e.target.value })} />
                    <div className={styles.modalFooter} style={{ marginTop: 24 }}>
                        <button className="btn btn-primary" disabled={loading}>{loading ? 'Saving...' : 'Save'}</button>
                    </div>
                </form>
            </div>
        </div>
    );
}

function AddMemberModal({ eventId, onClose, onAdd }: any) {
    const [search, setSearch] = useState('');
    const [users, setUsers] = useState<any[]>([]);
    const [role, setRole] = useState('scanner');
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (search.length > 2) doSearch();
    }, [search]);

    async function doSearch() {
        const data = await searchUsers(search);
        setUsers(data);
    }

    async function handleAdd(userId: string) {
        setLoading(true);
        try {
            await addEventAssignment(eventId, userId, role);
            onAdd();
        } catch (e: any) { alert(e.message); }
        finally { setLoading(false); }
    }

    return (
        <div className={styles.modalOverlay} onClick={onClose}>
            <div className={styles.modal} onClick={e => e.stopPropagation()}>
                <div className={styles.modalHeader}><h2>Add Team Member</h2><button className={styles.closeBtn} onClick={onClose}>✕</button></div>
                <div className={styles.modalBody}>
                    <input
                        className="input"
                        placeholder="Search by email..."
                        value={search}
                        onChange={e => setSearch(e.target.value)}
                        autoFocus
                    />
                    <div style={{ marginTop: 16 }}>
                        {users.map(u => (
                            <div key={u.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px', borderBottom: '1px solid #333' }}>
                                <div>
                                    <div style={{ fontWeight: 'bold' }}>{u.full_name || 'No Name'}</div>
                                    <div style={{ fontSize: '0.8rem', color: '#aaa' }}>{u.email}</div>
                                </div>
                                <button className="btn btn-secondary" onClick={() => handleAdd(u.id)} disabled={loading}>Assign</button>
                            </div>
                        ))}
                        {search.length > 2 && users.length === 0 && <div style={{ color: '#aaa', padding: 12 }}>No users found.</div>}
                    </div>
                </div>
            </div>
        </div>
    );
}
