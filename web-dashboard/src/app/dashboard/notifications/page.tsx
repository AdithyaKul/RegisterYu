'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import styles from './notifications.module.css';

interface Event {
    id: string;
    name: string;
    // other fields
}

export default function NotificationsPage() {
    const [activeTab, setActiveTab] = useState<'compose' | 'templates' | 'history'>('compose');
    const [events, setEvents] = useState<Event[]>([]);
    const [selectedEvent, setSelectedEvent] = useState('');
    const [attendeeCount, setAttendeeCount] = useState(0);
    const [notificationType, setNotificationType] = useState<'email' | 'whatsapp' | 'push'>('email');
    const [subject, setSubject] = useState('');
    const [message, setMessage] = useState('');
    const [sending, setSending] = useState(false);

    useEffect(() => {
        // Fetch events for dropdown
        async function loadEvents() {
            const { data } = await supabase.from('events').select('id, name');
            if (data) setEvents(data);
        }
        loadEvents();
    }, []);

    useEffect(() => {
        // Fetch attendee count when event changes
        async function loadCount() {
            if (!selectedEvent) {
                // All events
                const { count } = await supabase.from('registrations').select('*', { count: 'exact', head: true });
                setAttendeeCount(count || 0);
            } else {
                const { count } = await supabase
                    .from('registrations')
                    .select('*', { count: 'exact', head: true })
                    .eq('event_id', selectedEvent);
                setAttendeeCount(count || 0);
            }
        }
        loadCount();
    }, [selectedEvent]);

    const handleSend = async () => {
        if (!message) return alert("Please enter a message");
        setSending(true);

        // Simulation of sending
        // In a real app, call an Edge Function here

        await new Promise(resolve => setTimeout(resolve, 2000));

        alert(`Successfully queued ${notificationType} to ${attendeeCount} recipients!`);
        setSending(false);
        setMessage('');
        setSubject('');
    };

    return (
        <div className={styles.container}>
            {/* Header */}
            <header className={styles.header}>
                <div>
                    <h1>Notifications</h1>
                    <p className={styles.subtitle}>Send emails, WhatsApp messages, and push notifications</p>
                </div>
            </header>

            {/* Tabs */}
            <div className={styles.tabs}>
                {[
                    { id: 'compose', label: '✍️ Compose', icon: '' },
                    { id: 'templates', label: '📄 Templates', icon: '' },
                    { id: 'history', label: '📜 History', icon: '' },
                ].map(tab => (
                    <button
                        key={tab.id}
                        className={`${styles.tab} ${activeTab === tab.id ? styles.active : ''}`}
                        onClick={() => setActiveTab(tab.id as typeof activeTab)}
                    >
                        {tab.label}
                    </button>
                ))}
            </div>

            {/* Content */}
            <div className={styles.content}>
                {activeTab === 'compose' && (
                    <div className={styles.composeSection}>
                        <div className={styles.composeForm}>
                            {/* Notification Type */}
                            <div className={styles.formGroup}>
                                <label>Notification Type</label>
                                <div className={styles.typeSelector}>
                                    {[
                                        { id: 'email', icon: '📧', label: 'Email' },
                                        { id: 'whatsapp', icon: '📱', label: 'WhatsApp' },
                                        { id: 'push', icon: '🔔', label: 'Push' },
                                    ].map(type => (
                                        <button
                                            key={type.id}
                                            className={`${styles.typeBtn} ${notificationType === type.id ? styles.active : ''}`}
                                            onClick={() => setNotificationType(type.id as typeof notificationType)}
                                        >
                                            <span>{type.icon}</span>
                                            <span>{type.label}</span>
                                        </button>
                                    ))}
                                </div>
                            </div>

                            {/* Select Event */}
                            <div className={styles.formGroup}>
                                <label>Target Event</label>
                                <select
                                    className="input"
                                    value={selectedEvent}
                                    onChange={(e) => setSelectedEvent(e.target.value)}
                                >
                                    <option value="">All attendees ({attendeeCount} people)</option>
                                    {events.map(event => (
                                        <option key={event.id} value={event.id}>
                                            {event.name}
                                        </option>
                                    ))}
                                </select>
                            </div>

                            {/* Subject (Email only) */}
                            {notificationType === 'email' && (
                                <div className={styles.formGroup}>
                                    <label>Subject</label>
                                    <input
                                        type="text"
                                        className="input"
                                        placeholder="Enter email subject..."
                                        value={subject}
                                        onChange={(e) => setSubject(e.target.value)}
                                    />
                                </div>
                            )}

                            {/* Message */}
                            <div className={styles.formGroup}>
                                <label>Message</label>
                                <textarea
                                    className={`input ${styles.textarea}`}
                                    placeholder="Type your message here... Use {name}, {event_name}, {ticket_id} for personalization"
                                    rows={8}
                                    value={message}
                                    onChange={(e) => setMessage(e.target.value)}
                                />
                                <div className={styles.messageHint}>
                                    Available variables: <code>{'{name}'}</code>, <code>{'{event_name}'}</code>, <code>{'{ticket_id}'}</code>
                                </div>
                            </div>

                            {/* Actions */}
                            <div className={styles.formActions}>
                                <button className="btn btn-secondary">📄 Save as Template</button>
                                <button className="btn btn-ghost">👁️ Preview</button>
                                <button className="btn btn-primary" onClick={handleSend} disabled={sending}>
                                    {sending ? 'Sending...' : `🚀 Send to ${attendeeCount} people`}
                                </button>
                            </div>
                        </div>

                        {/* Quick Stats */}
                        <div className={styles.composeStats}>
                            <div className={styles.statsCard}>
                                <h4>📊 Delivery Stats</h4>
                                <div className={styles.statsGrid}>
                                    <div className={styles.statItem}>
                                        <span className={styles.statValue}>1,247</span>
                                        <span className={styles.statLabel}>Emails Sent</span>
                                    </div>
                                    <div className={styles.statItem}>
                                        <span className={styles.statValue}>98.2%</span>
                                        <span className={styles.statLabel}>Delivery Rate</span>
                                    </div>
                                </div>
                            </div>

                            <div className={styles.tipsCard}>
                                <h4>💡 Tips</h4>
                                <ul>
                                    <li>Send reminders 24 hours before events</li>
                                    <li>Keep WhatsApp messages under 160 characters</li>
                                    <li>Include clear call-to-action buttons</li>
                                    <li>Personalize with attendee names</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                )}

                {/* Other tabs placeholder */}
                {activeTab !== 'compose' && (
                    <div style={{ padding: '40px', textAlign: 'center', color: '#888' }}>
                        Feature coming soon
                    </div>
                )}
            </div>
        </div>
    );
}
