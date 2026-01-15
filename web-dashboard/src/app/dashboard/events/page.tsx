'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { supabase } from '@/lib/supabase';
import { getEvents, createEvent } from './actions';
import styles from './events.module.css';

// Schema based on backend/schema.sql
// We use 'title' and 'date' as primaries.
interface Event {
    id: string;
    title: string;
    description: string;
    date: string;
    location: string;
    category: string;
    price_amount: number;
    price_currency?: string;
    capacity: number;
    image_url: string;
    status: string;
    registrations_count?: number;
}

export default function EventsPage() {
    const [events, setEvents] = useState<Event[]>([]);
    const [filter, setFilter] = useState('all');
    const [searchQuery, setSearchQuery] = useState('');
    const [showCreateModal, setShowCreateModal] = useState(false);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchEvents();
    }, []);

    async function fetchEvents() {
        try {
            const data = await getEvents();
            setEvents(data);
        } catch (e) {
            console.error("Error fetching events:", e);
        } finally {
            setLoading(false);
        }
    }

    const filteredEvents = events.filter(event => {
        const matchesSearch = !searchQuery || event.title.toLowerCase().includes(searchQuery.toLowerCase());

        if (filter === 'all') return matchesSearch;

        // "upcoming" is a date filter, not a status
        if (filter === 'upcoming') {
            return matchesSearch && new Date(event.date) > new Date();
        }

        // Otherwise filter by explicit status (e.g. 'draft', 'published')
        return matchesSearch && event.status === filter;
    });

    return (
        <div className={styles.container}>
            <div className={styles.bgOrb1} />
            <div className={styles.bgOrb2} />

            <header className={styles.header}>
                <div className={styles.headerLeft}>
                    <Link href="/dashboard" className={styles.backBtn}>← Back</Link>
                    <h1>Events</h1>
                    <span className={styles.eventCount}>{events.length} total</span>
                </div>
                <button className="btn btn-primary" onClick={() => setShowCreateModal(true)}>
                    + Create Event
                </button>
            </header>

            <div className={styles.filters}>
                <div className={styles.search}>
                    <span className={styles.searchIcon}>🔍</span>
                    <input
                        type="text"
                        placeholder="Search events..."
                        className="input"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                    />
                </div>

                <div className={styles.filterTabs}>
                    <button
                        className={`${styles.filterTab} ${filter === 'all' ? styles.active : ''}`}
                        onClick={() => setFilter('all')}
                    >
                        All
                    </button>
                    <button
                        className={`${styles.filterTab} ${filter === 'upcoming' ? styles.active : ''}`}
                        onClick={() => setFilter('upcoming')}
                    >
                        Upcoming
                    </button>
                    <button
                        className={`${styles.filterTab} ${filter === 'published' ? styles.active : ''}`}
                        onClick={() => setFilter('published')}
                    >
                        Published
                    </button>
                    <button
                        className={`${styles.filterTab} ${filter === 'draft' ? styles.active : ''}`}
                        onClick={() => setFilter('draft')}
                    >
                        Drafts
                    </button>
                </div>
            </div>

            <div className={styles.eventsGrid}>
                {loading ? (
                    <div style={{ color: 'white', padding: '20px' }}>Loading...</div>
                ) : (
                    filteredEvents.length === 0 ? (
                        <div style={{ color: '#ccc', padding: '20px' }}>No events found.</div>
                    ) : (
                        filteredEvents.map((event) => (
                            <EventCard key={event.id} event={event} />
                        ))
                    )
                )}
            </div>

            {showCreateModal && (
                <CreateEventModal onClose={() => setShowCreateModal(false)} />
            )}
        </div>
    );
}

function EventCard({ event }: { event: Event }) {
    const registrations = event.registrations_count || 0;
    const capacity = event.capacity || 100;
    const progress = Math.min((registrations / capacity) * 100, 100);

    return (
        <div className={styles.eventCard}>
            <div
                className={styles.eventCover}
                style={{ backgroundImage: `url(${event.image_url || 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&q=80'})` }}
            >
                <div className={styles.eventOverlay}>
                    <span className={`${styles.statusBadge}`} style={{
                        background: event.status === 'published' ? '#10b981' : '#f59e0b',
                        color: event.status === 'published' ? 'white' : 'black'
                    }}>
                        {event.status || 'Active'}
                    </span>
                </div>
            </div>

            <div className={styles.eventBody}>
                <div className={styles.eventMeta}>
                    <span className={styles.category}>{event.category || 'General'}</span>
                    <span className={styles.price}>
                        {(!event.price_amount || event.price_amount === 0) ? 'Free' : `₹${event.price_amount}`}
                    </span>
                </div>

                <h3 className={styles.eventTitle}>{event.title}</h3>
                <p className={styles.eventDesc}>{event.description?.substring(0, 100) || 'No description provided.'}{event.description?.length > 100 ? '...' : ''}</p>

                <div className={styles.eventDetails}>
                    <div className={styles.detailRow}>
                        <span>📅</span>
                        <span>{new Date(event.date).toLocaleDateString('en-IN', {
                            weekday: 'short',
                            month: 'short',
                            day: 'numeric',
                        })} • {new Date(event.date).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' })}</span>
                    </div>
                    <div className={styles.detailRow}>
                        <span>📍</span>
                        <span>{event.location || 'TBA'}</span>
                    </div>
                </div>

                <div className={styles.statsRow}>
                    <div className={styles.registrationStats}>
                        <div className={styles.progressBar}>
                            <div
                                className={styles.progressFill}
                                style={{ width: `${progress}%` }}
                            />
                        </div>
                        <span>{registrations} / {capacity}</span>
                    </div>
                </div>

                <div className={styles.actions}>
                    <Link href={`/dashboard/events/${event.id}`} className="btn btn-primary" style={{ flex: 1, textAlign: 'center' }}>Manage Event</Link>
                </div>
            </div>
        </div>
    );
}

function CreateEventModal({ onClose }: { onClose: () => void }) {
    const [loading, setLoading] = useState(false);
    const [uploading, setUploading] = useState(false);

    const [formData, setFormData] = useState({
        title: '',
        description: '',
        date: '',
        location: '',
        category: 'General',
        price_amount: 0,
        capacity: 100,
        image_url: ''
    });

    const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        if (!e.target.files || e.target.files.length === 0) return;
        const file = e.target.files[0];
        setUploading(true);

        try {
            const fileExt = file.name.split('.').pop();
            const fileName = `${Math.random().toString(36).substring(2)}.${fileExt}`;
            const filePath = `${fileName}`;

            // Ensure bucket exists or handle error
            const { error: uploadError } = await supabase.storage
                .from('event-images')
                .upload(filePath, file);

            if (uploadError) {
                console.error(uploadError);
                alert(`Error uploading image: ${uploadError.message}. Make sure 'event-images' bucket is public.`);
                return;
            }

            const { data: { publicUrl } } = supabase.storage
                .from('event-images')
                .getPublicUrl(filePath);

            setFormData(prev => ({ ...prev, image_url: publicUrl }));

        } catch (error: any) {
            alert('Upload failed: ' + error.message);
        } finally {
            setUploading(false);
        }
    };

    const handleSubmit = async (status: 'draft' | 'published') => {
        if (!formData.title || !formData.date) {
            alert("Title and Date are required.");
            return;
        }

        setLoading(true);
        try {
            const payload = {
                ...formData,
                date: new Date(formData.date).toISOString(),
                status: status
            };

            const { data } = await createEvent(payload);


            alert(`Event ${status === 'published' ? 'published' : 'saved as draft'} successfully!`);
            window.location.reload();
        } catch (e: any) {
            console.error(e);
            alert("Error creating event: " + e.message);
        } finally {
            setLoading(false);
            onClose();
        }
    }

    return (
        <div className={styles.modalOverlay} onClick={onClose}>
            <div className={styles.modal} onClick={(e) => e.stopPropagation()} style={{ maxWidth: '600px' }}>
                <div className={styles.modalHeader}>
                    <h2>Create New Event</h2>
                    <button className={styles.closeBtn} onClick={onClose}>✕</button>
                </div>

                <div className={styles.modalBody}>
                    <div className={styles.formGroup}>
                        <label>Event Title *</label>
                        <input
                            type="text"
                            className="input"
                            placeholder="Enter event title"
                            value={formData.title}
                            onChange={e => setFormData({ ...formData, title: e.target.value })}
                        />
                    </div>

                    <div className={styles.formGroup}>
                        <label>Description</label>
                        <textarea
                            className="input"
                            placeholder="Describe your event..."
                            rows={3}
                            value={formData.description}
                            onChange={e => setFormData({ ...formData, description: e.target.value })}
                        />
                    </div>

                    <div className={styles.formRow}>
                        <div className={styles.formGroup}>
                            <label>Date & Time *</label>
                            <input
                                type="datetime-local"
                                className="input"
                                value={formData.date}
                                onChange={e => setFormData({ ...formData, date: e.target.value })}
                            />
                        </div>
                        <div className={styles.formGroup}>
                            <label>Category</label>
                            <select
                                className="input"
                                value={formData.category}
                                onChange={e => setFormData({ ...formData, category: e.target.value })}
                            >
                                <option>General</option>
                                <option>Hackathon</option>
                                <option>Workshop</option>
                                <option>Seminar</option>
                                <option>Cultural</option>
                            </select>
                        </div>
                    </div>

                    <div className={styles.formRow}>
                        <div className={styles.formGroup}>
                            <label>Location / Venue</label>
                            <input
                                type="text"
                                className="input"
                                placeholder="E.g. Auditorium"
                                value={formData.location}
                                onChange={e => setFormData({ ...formData, location: e.target.value })}
                            />
                        </div>
                        <div className={styles.formGroup}>
                            <label>Capacity</label>
                            <input
                                type="number"
                                className="input"
                                placeholder="Max attendees"
                                value={formData.capacity}
                                onChange={e => setFormData({ ...formData, capacity: parseInt(e.target.value) })}
                            />
                        </div>
                    </div>

                    <div className={styles.formRow}>
                        <div className={styles.formGroup}>
                            <label>Ticket Price (₹)</label>
                            <input
                                type="number"
                                className="input"
                                placeholder="0 for Free"
                                value={formData.price_amount}
                                onChange={e => setFormData({ ...formData, price_amount: parseInt(e.target.value) })}
                            />
                        </div>
                        <div className={styles.formGroup}>
                            <label>Cover Image</label>
                            <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                                <input
                                    type="file"
                                    accept="image/*"
                                    onChange={handleImageUpload}
                                    style={{ fontSize: '12px' }}
                                />
                                {uploading && <span style={{ fontSize: '12px', color: '#aaa' }}>Uploading...</span>}
                            </div>
                        </div>
                    </div>

                    {formData.image_url && (
                        <div style={{ marginTop: '10px', borderRadius: '8px', overflow: 'hidden', height: '100px', width: '100%', backgroundImage: `url(${formData.image_url})`, backgroundSize: 'cover', backgroundPosition: 'center' }} />
                    )}
                </div>

                <div className={styles.modalFooter}>
                    <button type="button" className="btn btn-ghost" onClick={onClose}>Cancel</button>
                    <button type="button" className="btn btn-secondary" onClick={() => handleSubmit('draft')} disabled={loading || uploading}>
                        Save Draft
                    </button>
                    <button type="button" className="btn btn-primary" onClick={() => handleSubmit('published')} disabled={loading || uploading}>
                        {loading ? 'Publishing...' : 'Create & Publish'}
                    </button>
                </div>
            </div>
        </div>
    );
}
