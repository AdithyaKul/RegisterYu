'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { getAttendees, updateAttendeeStatus } from './actions';
import styles from './attendees.module.css';

interface Attendee {
    id: string; // Changed from number to string for UUID
    name: string;
    email: string;
    phone: string;
    collegeId: string;
    department: string;
    event: string;
    ticketId: string;
    status: string;
    registeredAt: string;
    checkedInAt?: string | null;
    avatar: string;
}

export default function AttendeesPage() {
    const [attendees, setAttendees] = useState<Attendee[]>([]);
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState('all');
    const [selectedAttendees, setSelectedAttendees] = useState<string[]>([]);
    const [showDetailModal, setShowDetailModal] = useState<Attendee | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchData();
    }, []);

    async function fetchData() {
        try {
            const data = await getAttendees();
            setAttendees(data);
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    }

    const filteredAttendees = attendees.filter(attendee => {
        if (statusFilter !== 'all' && attendee.status !== statusFilter) return false;
        if (searchQuery) {
            const query = searchQuery.toLowerCase();
            return (
                (attendee.name?.toLowerCase() || '').includes(query) ||
                (attendee.email?.toLowerCase() || '').includes(query) ||
                (attendee.collegeId?.toLowerCase() || '').includes(query) ||
                (attendee.ticketId?.toLowerCase() || '').includes(query)
            );
        }
        return true;
    });

    const toggleSelect = (id: string) => {
        setSelectedAttendees(prev =>
            prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]
        );
    };

    const selectAll = () => {
        if (selectedAttendees.length === filteredAttendees.length) {
            setSelectedAttendees([]);
        } else {
            setSelectedAttendees(filteredAttendees.map(a => a.id));
        }
    };

    const handleCheckIn = async (id: string) => {
        try {
            await updateAttendeeStatus(id, 'checked_in');
            fetchData();
            if (showDetailModal && showDetailModal.id === id) {
                setShowDetailModal({ ...showDetailModal, status: 'checked_in', checkedInAt: new Date().toISOString() });
            }
        } catch (e: any) { alert(e.message); }
    };

    return (
        <div className={styles.container}>
            <div className={styles.bgOrb1} />
            <div className={styles.bgOrb2} />

            {/* Header */}
            <header className={styles.header}>
                <div className={styles.headerLeft}>
                    <Link href="/dashboard" className={styles.backBtn}>← Back</Link>
                    <h1>Attendees</h1>
                    <span className={styles.count}>{attendees.length} total</span>
                </div>
                <div className={styles.headerActions}>
                    <button className="btn btn-secondary">📧 Email Selected</button>
                    <button className="btn btn-secondary">📊 Export CSV</button>
                </div>
            </header>

            {/* Filters */}
            <div className={styles.filters}>
                <div className={styles.search}>
                    <span>🔍</span>
                    <input
                        type="text"
                        placeholder="Search by name, email, ID..."
                        className="input"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                    />
                </div>

                <div className={styles.filterTabs}>
                    {['all', 'confirmed', 'checked_in', 'pending', 'cancelled'].map(status => (
                        <button
                            key={status}
                            className={`${styles.filterTab} ${statusFilter === status ? styles.active : ''}`}
                            onClick={() => setStatusFilter(status)}
                        >
                            {status === 'all' ? 'All' : status.replace('_', ' ')}
                        </button>
                    ))}
                </div>
            </div>

            {/* Table */}
            <div className={styles.tableContainer}>
                {loading ? <div style={{ padding: 20 }}>Loading...</div> : (
                    <table className={styles.table}>
                        <thead>
                            <tr>
                                <th>
                                    <input
                                        type="checkbox"
                                        className="checkbox"
                                        checked={selectedAttendees.length === filteredAttendees.length && filteredAttendees.length > 0}
                                        onChange={selectAll}
                                    />
                                </th>
                                <th>Attendee</th>
                                <th>Event</th>
                                <th>Ticket ID</th>
                                <th>Department</th>
                                <th>Status</th>
                                <th>Registered</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filteredAttendees.length === 0 ? (
                                <tr><td colSpan={8} style={{ textAlign: 'center', padding: 20, color: '#aaa' }}>No attendees found.</td></tr>
                            ) : (
                                filteredAttendees.map((attendee) => (
                                    <tr key={attendee.id} className={selectedAttendees.includes(attendee.id) ? styles.selected : ''}>
                                        <td>
                                            <input
                                                type="checkbox"
                                                className="checkbox"
                                                checked={selectedAttendees.includes(attendee.id)}
                                                onChange={() => toggleSelect(attendee.id)}
                                            />
                                        </td>
                                        <td>
                                            <div className={styles.attendeeCell}>
                                                <div className={styles.avatar}>{attendee.avatar}</div>
                                                <div>
                                                    <span className={styles.name}>{attendee.name}</span>
                                                    <span className={styles.email}>{attendee.email}</span>
                                                </div>
                                            </div>
                                        </td>
                                        <td>{attendee.event}</td>
                                        <td><code className={styles.ticketId}>{attendee.ticketId}</code></td>
                                        <td>{attendee.department}</td>
                                        <td>
                                            <span className={`badge badge-${getStatusColor(attendee.status)}`}>
                                                {attendee.status.replace('_', ' ')}
                                            </span>
                                        </td>
                                        <td>{new Date(attendee.registeredAt).toLocaleDateString()}</td>
                                        <td>
                                            <div className={styles.actions}>
                                                <button
                                                    className="btn btn-ghost"
                                                    onClick={() => setShowDetailModal(attendee)}
                                                >
                                                    View
                                                </button>
                                                {attendee.status !== 'checked_in' && (
                                                    <button className="btn btn-ghost" onClick={() => handleCheckIn(attendee.id)}>✅</button>
                                                )}
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                )}
            </div>

            {/* Stats */}
            <div className={styles.stats}>
                <div className={styles.statItem}>
                    <span className={styles.statValue}>{attendees.filter(a => a.status === 'checked_in').length}</span>
                    <span className={styles.statLabel}>Checked In</span>
                </div>
                <div className={styles.statItem}>
                    <span className={styles.statValue}>{attendees.filter(a => a.status === 'confirmed').length}</span>
                    <span className={styles.statLabel}>Confirmed</span>
                </div>
            </div>

            {/* Detail Modal */}
            {showDetailModal && (
                <AttendeeDetailModal
                    attendee={showDetailModal}
                    onClose={() => setShowDetailModal(null)}
                    onCheckIn={() => handleCheckIn(showDetailModal.id)}
                />
            )}
        </div>
    );
}

function getStatusColor(status: string) {
    switch (status) {
        case 'checked_in': return 'success';
        case 'confirmed': return 'info';
        case 'pending': return 'warning';
        case 'cancelled': return 'danger';
        default: return 'info';
    }
}

function AttendeeDetailModal({ attendee, onClose, onCheckIn }: { attendee: Attendee; onClose: () => void; onCheckIn: () => void }) {
    return (
        <div className={styles.modalOverlay} onClick={onClose}>
            <div className={styles.modal} onClick={(e) => e.stopPropagation()}>
                <div className={styles.modalHeader}>
                    <h2>Attendee Details</h2>
                    <button className={styles.closeBtn} onClick={onClose}>✕</button>
                </div>

                <div className={styles.modalBody}>
                    <div className={styles.profileSection}>
                        <div className={styles.largeAvatar}>{attendee.avatar}</div>
                        <div>
                            <h3>{attendee.name}</h3>
                            <p>{attendee.email}</p>
                        </div>
                    </div>

                    <div className={styles.detailGrid}>
                        <div className={styles.detailItem}>
                            <span className={styles.detailLabel}>Phone</span>
                            <span className={styles.detailValue}>{attendee.phone || 'N/A'}</span>
                        </div>
                        <div className={styles.detailItem}>
                            <span className={styles.detailLabel}>College ID</span>
                            <span className={styles.detailValue}>{attendee.collegeId}</span>
                        </div>
                        <div className={styles.detailItem}>
                            <span className={styles.detailLabel}>Department</span>
                            <span className={styles.detailValue}>{attendee.department}</span>
                        </div>
                        <div className={styles.detailItem}>
                            <span className={styles.detailLabel}>Event</span>
                            <span className={styles.detailValue}>{attendee.event}</span>
                        </div>
                        <div className={styles.detailItem}>
                            <span className={styles.detailLabel}>Ticket ID</span>
                            <span className={styles.detailValue}><code>{attendee.ticketId}</code></span>
                        </div>
                        <div className={styles.detailItem}>
                            <span className={styles.detailLabel}>Status</span>
                            <span className={`badge badge-${getStatusColor(attendee.status)}`}>
                                {attendee.status.replace('_', ' ')}
                            </span>
                        </div>
                        <div className={styles.detailItem}>
                            <span className={styles.detailLabel}>Registered</span>
                            <span className={styles.detailValue}>
                                {new Date(attendee.registeredAt).toLocaleString()}
                            </span>
                        </div>
                        {attendee.checkedInAt && (
                            <div className={styles.detailItem}>
                                <span className={styles.detailLabel}>Checked In</span>
                                <span className={styles.detailValue}>
                                    {new Date(attendee.checkedInAt).toLocaleString()}
                                </span>
                            </div>
                        )}
                    </div>
                </div>

                <div className={styles.modalFooter}>
                    <button className="btn btn-ghost" onClick={onClose}>Close</button>
                    <button className="btn btn-secondary">📧 Send Email</button>
                    {attendee.status !== 'checked_in' && (
                        <button className="btn btn-primary" onClick={onCheckIn}>✅ Check In</button>
                    )}
                </div>
            </div>
        </div>
    );
}
