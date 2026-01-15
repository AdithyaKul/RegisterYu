'use client';
import { useState, useEffect } from 'react';
import Link from 'next/link';
import { LiquidCard, LiquidFilterDef, LiquidButton } from '@/components/ui/LiquidCard';
import { getDashboardStats, getUpcomingEvents, getRecentActivity } from './actions';
import styles from './overview.module.css';

interface DashboardStats {
    totalEvents: number;
    totalRegistrations: number;
    revenue: number;
    checkIns: number;
}

interface EventData {
    id: string;
    title: string;
    name?: string; // fallback
    date: string;
    event_date?: string; // fallback
    location: string;
    status: string;
    price_amount?: number;
}

interface RegistrationData {
    id: string;
    created_at: string;
    profiles: {
        full_name: string;
        email: string;
    } | null;
    events: {
        title: string;
        name?: string;
    } | null;
}

export default function OverviewPage() {
    const [stats, setStats] = useState<DashboardStats>({
        totalEvents: 0,
        totalRegistrations: 0,
        revenue: 0,
        checkIns: 0,
    });
    const [upcomingEvents, setUpcomingEvents] = useState<EventData[]>([]);
    const [recentRegistrations, setRecentRegistrations] = useState<RegistrationData[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function fetchDashboardData() {
            try {
                // 1. Fetch Stats
                const statsData = await getDashboardStats();
                setStats(statsData);

                // 2. Fetch Upcoming Events
                const eventsData = await getUpcomingEvents();
                setUpcomingEvents(eventsData);

                // 3. Fetch Recent Activity
                const activityData = await getRecentActivity();
                setRecentRegistrations(activityData);

            } catch (error) {
                console.error("Error fetching dashboard data:", error);
            } finally {
                setLoading(false);
            }
        }

        fetchDashboardData();
    }, []);

    return (
        <div className={styles.container}>
            {/* Liquid Filter Definition */}
            <LiquidFilterDef />

            {/* Stats Grid using LiquidCards */}
            <div className={styles.statsGrid}>
                <LiquidCard>
                    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', textAlign: 'center' }}>
                        <span style={{ fontSize: '2rem', fontWeight: 700, backgroundImage: 'var(--gradient-primary)', WebkitBackgroundClip: 'text', color: 'transparent' }}>
                            {stats.totalEvents}
                        </span>
                        <span style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Total Events</span>
                    </div>
                </LiquidCard>
                <LiquidCard>
                    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', textAlign: 'center' }}>
                        <span style={{ fontSize: '2rem', fontWeight: 700, color: 'white' }}>{stats.totalRegistrations}</span>
                        <span style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Registrations</span>
                    </div>
                </LiquidCard>
                <LiquidCard>
                    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', textAlign: 'center' }}>
                        <span style={{ fontSize: '2rem', fontWeight: 700, color: 'var(--accent-green)' }}>₹{stats.revenue.toLocaleString()}</span>
                        <span style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Revenue</span>
                    </div>
                </LiquidCard>
                <LiquidCard>
                    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', textAlign: 'center' }}>
                        <span style={{ fontSize: '2rem', fontWeight: 700, color: 'var(--accent-orange)' }}>{stats.checkIns}</span>
                        <span style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Check-ins</span>
                    </div>
                </LiquidCard>
            </div>

            <div className={styles.mainGrid}>
                {/* Events Section using CrystalCards */}
                <div style={{ gridColumn: '1 / -1', display: 'flex', flexDirection: 'column', gap: '24px' }}>

                    {/* Events Row */}
                    <div className={styles.eventsSection}>
                        <div className={styles.sectionHeader}>
                            <h2>Upcoming Events</h2>
                            <LiquidButton href="/dashboard/events">View All →</LiquidButton>
                        </div>

                        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                            {upcomingEvents.length === 0 ? (
                                <div style={{ color: 'var(--text-secondary)', width: '100%', textAlign: 'center', padding: '40px' }}>No upcoming events found.</div>
                            ) : (
                                upcomingEvents.map((event) => (
                                    <Link href={`/dashboard/events/${event.id}`} key={event.id} style={{ textDecoration: 'none' }}>
                                        <LiquidCard className={styles.eventRowCard}>
                                            <div style={{ display: 'flex', alignItems: 'center', gap: '24px', width: '100%', padding: '24px' }}>
                                                {/* Date Badge */}
                                                <div style={{
                                                    display: 'flex',
                                                    flexDirection: 'column',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    background: 'rgba(255,255,255,0.1)',
                                                    borderRadius: '12px',
                                                    padding: '12px',
                                                    minWidth: '70px'
                                                }}>
                                                    <span style={{ fontSize: '0.8rem', color: '#ccc', textTransform: 'uppercase' }}>
                                                        {new Date(event.date || event.event_date || Date.now()).toLocaleDateString('en-US', { month: 'short' })}
                                                    </span>
                                                    <span style={{ fontSize: '1.5rem', fontWeight: 'bold', color: 'white' }}>
                                                        {new Date(event.date || event.event_date || Date.now()).getDate()}
                                                    </span>
                                                </div>

                                                {/* Info */}
                                                <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '4px' }}>
                                                    <h3 style={{ margin: 0, fontSize: '1.2rem', color: 'white' }}>{event.title || event.name || 'Untitled'}</h3>
                                                    <span style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                                                        {event.location || 'TBA'} • {event.price_amount ? `₹${event.price_amount}` : 'Free'}
                                                    </span>
                                                </div>

                                                {/* Status/Action */}
                                                <div style={{ display: 'flex', alignItems: 'center' }}>
                                                    <span style={{
                                                        padding: '6px 12px',
                                                        borderRadius: '20px',
                                                        background: 'rgba(16, 185, 129, 0.2)',
                                                        color: '#10b981',
                                                        fontSize: '0.85rem',
                                                        border: '1px solid rgba(16, 185, 129, 0.3)'
                                                    }}>
                                                        {event.status || 'Active'}
                                                    </span>
                                                </div>
                                            </div>
                                        </LiquidCard>
                                    </Link>
                                ))
                            )}
                        </div>
                    </div>

                    {/* Bottom Row: Activity & Actions */}
                    <div className={styles.rightColumn}>
                        {/* Live Activity */}
                        <div className={styles.activityCard}>
                            <div className={styles.sectionHeader}>
                                <h3>Live Activity</h3>
                                <span className={styles.liveTag}>
                                    <span className={styles.liveDot} />
                                    Real-time
                                </span>
                            </div>

                            <div className={styles.activityList}>
                                {recentRegistrations.length === 0 ? (
                                    <div style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>No recent activity.</div>
                                ) : (
                                    recentRegistrations.map((reg) => (
                                        <div key={reg.id} className={styles.activityItem}>
                                            <div className={styles.activityAvatar}>
                                                {reg.profiles?.full_name?.[0]?.toUpperCase() || 'U'}
                                            </div>
                                            <div className={styles.activityContent}>
                                                <span className={styles.activityName}>{reg.profiles?.full_name || 'Anonymous'}</span>
                                                <span className={styles.activityEvent}>
                                                    registered for {reg.events?.title || reg.events?.name || 'Event'}
                                                </span>
                                            </div>
                                            <span className={styles.activityTime}>
                                                {new Date(reg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                            </span>
                                        </div>
                                    ))
                                )}
                            </div>
                        </div>

                        {/* Quick Actions */}
                        <div className={styles.quickActions}>
                            <h3>Quick Actions</h3>
                            <div className={styles.actionGrid}>
                                <Link href="/dashboard/checkin" className={styles.actionCard}>
                                    <span className={styles.actionIcon}>📷</span>
                                    <span className={styles.actionLabel}>Scan QR</span>
                                </Link>
                                <Link href="/dashboard/notifications" className={styles.actionCard}>
                                    <span className={styles.actionIcon}>📢</span>
                                    <span className={styles.actionLabel}>Broadcast</span>
                                </Link>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
