'use client';

import { useState, useEffect } from 'react';
import { getRevenueStats, getRevenueByEvent, getRecentTransactions } from './actions';
import styles from './revenue.module.css';

interface RevenueStats {
    total: number;
    thisMonth: number;
    pending: number;
    refunded: number;
    growth: number;
}

interface EventRevenue {
    event: string;
    revenue: number;
    registrations: number;
    color: string;
}

interface Transaction {
    id: string;
    name: string;
    event: string;
    amount: number;
    status: string;
    date: string;
    method: string;
}

export default function RevenuePage() {
    const [stats, setStats] = useState<RevenueStats>({ total: 0, thisMonth: 0, pending: 0, refunded: 0, growth: 0 });
    const [eventRevenue, setEventRevenue] = useState<EventRevenue[]>([]);
    const [transactions, setTransactions] = useState<Transaction[]>([]);
    const [dateRange, setDateRange] = useState('week');
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function loadData() {
            try {
                const statsData = await getRevenueStats();
                setStats(statsData);

                const eventsData = await getRevenueByEvent();
                setEventRevenue(eventsData);

                const txnsData = await getRecentTransactions();
                setTransactions(txnsData);
            } catch (e) {
                console.error(e);
            } finally {
                setLoading(false);
            }
        }
        loadData();
    }, []);

    const maxRevenue = Math.max(...eventRevenue.map(d => d.revenue), 1); // Avoid div by zero

    return (
        <div className={styles.container}>
            {/* Header */}
            <header className={styles.header}>
                <div>
                    <h1>Revenue Analytics</h1>
                    <p className={styles.subtitle}>Track payments, refunds, and financial insights</p>
                </div>
                <div className={styles.headerActions}>
                    <div className={styles.dateFilter}>
                        {['week', 'month', 'year'].map(range => (
                            <button
                                key={range}
                                className={`${styles.filterBtn} ${dateRange === range ? styles.active : ''}`}
                                onClick={() => setDateRange(range)}
                            >
                                This {range.charAt(0).toUpperCase() + range.slice(1)}
                            </button>
                        ))}
                    </div>
                    <button className="btn btn-secondary">📊 Export Report</button>
                </div>
            </header>

            {/* Stats Cards */}
            <div className={styles.statsGrid}>
                <div className={`${styles.statCard} ${styles.primary}`}>
                    <div className={styles.statHeader}>
                        <span className={styles.statIcon}>💰</span>
                        <span className={styles.statBadge}>{stats.growth >= 0 ? '+' : ''}{stats.growth}%</span>
                    </div>
                    <div className={styles.statValue}>₹{stats.total.toLocaleString()}</div>
                    <div className={styles.statLabel}>Total Revenue</div>
                    <div className={styles.statSubtext}>All time earnings</div>
                </div>

                <div className={styles.statCard}>
                    <div className={styles.statHeader}>
                        <span className={styles.statIcon}>📈</span>
                    </div>
                    <div className={styles.statValue}>₹{stats.thisMonth.toLocaleString()}</div>
                    <div className={styles.statLabel}>This Month</div>
                    <div className={styles.statComparison}>
                        <span className={stats.growth >= 0 ? styles.up : styles.down}>
                            {stats.growth >= 0 ? '↑' : '↓'} {Math.abs(stats.growth)}%
                        </span> vs last month
                    </div>
                </div>

                <div className={styles.statCard}>
                    <div className={styles.statHeader}>
                        <span className={styles.statIcon}>⏳</span>
                    </div>
                    <div className={styles.statValue}>₹{stats.pending.toLocaleString()}</div>
                    <div className={styles.statLabel}>Pending</div>
                    <div className={styles.statSubtext}>Awaiting confirmation</div>
                </div>

                <div className={styles.statCard}>
                    <div className={styles.statHeader}>
                        <span className={styles.statIcon}>↩️</span>
                    </div>
                    <div className={styles.statValue}>₹{stats.refunded.toLocaleString()}</div>
                    <div className={styles.statLabel}>Refunded/Cancelled</div>
                    <div className={styles.statSubtext}>Estimate based on cancellations</div>
                </div>
            </div>

            {/* Charts Row */}
            <div className={styles.chartsRow}>
                {/* Event Revenue Breakdown */}
                <div className={styles.chartCard} style={{ gridColumn: '1 / -1' }}>
                    <div className={styles.chartHeader}>
                        <h3>Revenue by Event</h3>
                    </div>
                    {loading ? <div>Loading...</div> : (
                        <div className={styles.eventList}>
                            {eventRevenue.length === 0 ? <div style={{ padding: 20, color: '#888' }}>No revenue data available</div> :
                                eventRevenue.map((event, index) => (
                                    <div key={event.event} className={styles.eventItem} style={{ animationDelay: `${index * 0.1}s` }}>
                                        <div className={styles.eventInfo}>
                                            <div className={styles.eventDot} style={{ background: event.color }} />
                                            <div>
                                                <span className={styles.eventName}>{event.event}</span>
                                                <span className={styles.eventRegs}>{event.registrations} registrations</span>
                                            </div>
                                        </div>
                                        <div className={styles.eventAmount}>
                                            {event.revenue > 0 ? `₹${event.revenue.toLocaleString()}` : 'Free'}
                                        </div>
                                    </div>
                                ))}
                        </div>
                    )}
                </div>
            </div>

            {/* Transactions Table */}
            <div className={styles.tableCard}>
                <div className={styles.tableHeader}>
                    <h3>Recent Transactions</h3>
                    <div className={styles.tableActions}>
                        <input type="text" className="input" placeholder="Search transactions..." style={{ maxWidth: 250 }} />
                        <button className="btn btn-ghost">View All</button>
                    </div>
                </div>
                <div className={styles.tableContainer}>
                    {loading ? <div style={{ padding: 20 }}>Loading...</div> : (
                        <table className={styles.table}>
                            <thead>
                                <tr>
                                    <th>Transaction ID</th>
                                    <th>Customer</th>
                                    <th>Event</th>
                                    <th>Amount</th>
                                    <th>Method</th>
                                    <th>Status</th>
                                    <th>Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                {transactions.length === 0 ? (
                                    <tr><td colSpan={7} style={{ textAlign: 'center', padding: 20, color: '#888' }}>No transactions found</td></tr>
                                ) : (
                                    transactions.map((txn) => (
                                        <tr key={txn.id}>
                                            <td><code className={styles.txnId}>{txn.id}</code></td>
                                            <td>{txn.name}</td>
                                            <td>{txn.event}</td>
                                            <td className={styles.amount}>₹{txn.amount}</td>
                                            <td>
                                                <span className={styles.method}>{txn.method}</span>
                                            </td>
                                            <td>
                                                <span className={`${styles.status} ${styles[txn.status === 'completed' ? 'completed' : txn.status]}`}>
                                                    {txn.status}
                                                </span>
                                            </td>
                                            <td>{new Date(txn.date).toLocaleDateString()}</td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    )}
                </div>
            </div>
        </div>
    );
}
