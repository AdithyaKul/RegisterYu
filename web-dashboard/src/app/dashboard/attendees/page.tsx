'use client';

import { useState } from 'react';
import Link from 'next/link';
import styles from './attendees.module.css';

const mockAttendees = [
    { id: 1, name: 'Adithya Kumar', email: 'adithya@sambhram.edu', phone: '+91 98765 43210', collegeId: 'SCE2024001', department: 'Computer Science', event: 'HackHorizon 2024', ticketId: 'TKT-2024-HH-001', status: 'checked_in', registeredAt: '2024-10-01T14:30:00', checkedInAt: '2024-10-14T09:15:00', avatar: 'AK' },
    { id: 2, name: 'Priya Sharma', email: 'priya.s@sambhram.edu', phone: '+91 87654 32109', collegeId: 'SCE2024042', department: 'Electronics', event: 'AI & The Future', ticketId: 'TKT-2024-AI-042', status: 'confirmed', registeredAt: '2024-10-05T11:15:00', checkedInAt: null, avatar: 'PS' },
    { id: 3, name: 'Rahul Verma', email: 'rahul.v@sambhram.edu', phone: '+91 76543 21098', collegeId: 'SCE2024023', department: 'Mechanical', event: 'HackHorizon 2024', ticketId: 'TKT-2024-HH-023', status: 'confirmed', registeredAt: '2024-10-08T16:45:00', checkedInAt: null, avatar: 'RV' },
    { id: 4, name: 'Sneha Reddy', email: 'sneha.r@sambhram.edu', phone: '+91 65432 10987', collegeId: 'SCE2024067', department: 'Computer Science', event: 'Cloud Native Summit', ticketId: 'TKT-2024-CN-067', status: 'confirmed', registeredAt: '2024-10-10T10:00:00', checkedInAt: null, avatar: 'SR' },
    { id: 5, name: 'Karthik M', email: 'karthik.m@sambhram.edu', phone: '+91 54321 09876', collegeId: 'SCE2024089', department: 'Information Science', event: 'Design Thinking Lab', ticketId: 'TKT-2024-DT-089', status: 'pending', registeredAt: '2024-10-12T09:30:00', checkedInAt: null, avatar: 'KM' },
    { id: 6, name: 'Anjali Nair', email: 'anjali.n@sambhram.edu', phone: '+91 43210 98765', collegeId: 'SCE2024112', department: 'Computer Science', event: 'AI & The Future', ticketId: 'TKT-2024-AI-112', status: 'cancelled', registeredAt: '2024-10-03T13:20:00', checkedInAt: null, avatar: 'AN' },
];

export default function AttendeesPage() {
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState('all');
    const [selectedAttendees, setSelectedAttendees] = useState<number[]>([]);
    const [showDetailModal, setShowDetailModal] = useState<typeof mockAttendees[0] | null>(null);

    const filteredAttendees = mockAttendees.filter(attendee => {
        if (statusFilter !== 'all' && attendee.status !== statusFilter) return false;
        if (searchQuery) {
            const query = searchQuery.toLowerCase();
            return (
                attendee.name.toLowerCase().includes(query) ||
                attendee.email.toLowerCase().includes(query) ||
                attendee.collegeId.toLowerCase().includes(query) ||
                attendee.ticketId.toLowerCase().includes(query)
            );
        }
        return true;
    });

    const toggleSelect = (id: number) => {
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

    return (
        <div className={styles.container}>
            <div className={styles.bgOrb1} />
            <div className={styles.bgOrb2} />

            {/* Header */}
            <header className={styles.header}>
                <div className={styles.headerLeft}>
                    <Link href="/dashboard" className={styles.backBtn}>← Back</Link>
                    <h1>Attendees</h1>
                    <span className={styles.count}>{mockAttendees.length} total</span>
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
                        {filteredAttendees.map((attendee) => (
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
                                        <button className="btn btn-ghost">✉️</button>
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>

            {/* Stats */}
            <div className={styles.stats}>
                <div className={styles.statItem}>
                    <span className={styles.statValue}>{mockAttendees.filter(a => a.status === 'checked_in').length}</span>
                    <span className={styles.statLabel}>Checked In</span>
                </div>
                <div className={styles.statItem}>
                    <span className={styles.statValue}>{mockAttendees.filter(a => a.status === 'confirmed').length}</span>
                    <span className={styles.statLabel}>Confirmed</span>
                </div>
                <div className={styles.statItem}>
                    <span className={styles.statValue}>{mockAttendees.filter(a => a.status === 'pending').length}</span>
                    <span className={styles.statLabel}>Pending</span>
                </div>
                <div className={styles.statItem}>
                    <span className={styles.statValue}>{mockAttendees.filter(a => a.status === 'cancelled').length}</span>
                    <span className={styles.statLabel}>Cancelled</span>
                </div>
            </div>

            {/* Detail Modal */}
            {showDetailModal && (
                <AttendeeDetailModal
                    attendee={showDetailModal}
                    onClose={() => setShowDetailModal(null)}
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

function AttendeeDetailModal({ attendee, onClose }: { attendee: typeof mockAttendees[0]; onClose: () => void }) {
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
                            <span className={styles.detailValue}>{attendee.phone}</span>
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
                    <button className="btn btn-primary">✅ Check In</button>
                </div>
            </div>
        </div>
    );
}
