'use client';

import { useState } from 'react';
import styles from './revenue.module.css';

const mockRevenueData = {
    total: 145320,
    thisMonth: 45320,
    lastMonth: 38750,
    growth: 16.9,
    pending: 8500,
    refunded: 2150,
};

const mockTransactions = [
    { id: 'TXN001', name: 'Adithya Kumar', event: 'AI & The Future', amount: 150, status: 'completed', date: '2024-10-12', method: 'UPI' },
    { id: 'TXN002', name: 'Priya Sharma', event: 'Cloud Native Summit', amount: 300, status: 'completed', date: '2024-10-12', method: 'UPI' },
    { id: 'TXN003', name: 'Rahul Verma', event: 'AI & The Future', amount: 150, status: 'pending', date: '2024-10-11', method: 'Card' },
    { id: 'TXN004', name: 'Sneha Reddy', event: 'Design Thinking Lab', amount: 200, status: 'completed', date: '2024-10-11', method: 'UPI' },
    { id: 'TXN005', name: 'Karthik M', event: 'Cloud Native Summit', amount: 300, status: 'refunded', date: '2024-10-10', method: 'UPI' },
    { id: 'TXN006', name: 'Anjali Nair', event: 'AI & The Future', amount: 150, status: 'completed', date: '2024-10-10', method: 'Card' },
];

const mockWeeklyData = [
    { day: 'Mon', amount: 12500 },
    { day: 'Tue', amount: 18200 },
    { day: 'Wed', amount: 8900 },
    { day: 'Thu', amount: 22100 },
    { day: 'Fri', amount: 15600 },
    { day: 'Sat', amount: 19800 },
    { day: 'Sun', amount: 11200 },
];

const mockEventRevenue = [
    { event: 'Cloud Native Summit', revenue: 18600, registrations: 62, color: '#2997FF' },
    { event: 'AI & The Future', revenue: 12750, registrations: 85, color: '#BF5AF2' },
    { event: 'Design Thinking Lab', revenue: 9000, registrations: 45, color: '#30D158' },
    { event: 'HackHorizon 2024', revenue: 0, registrations: 127, color: '#FF9F0A' },
];

export default function RevenuePage() {
    const [dateRange, setDateRange] = useState('week');
    const maxWeekly = Math.max(...mockWeeklyData.map(d => d.amount));

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
                        <span className={styles.statBadge}>+{mockRevenueData.growth}%</span>
                    </div>
                    <div className={styles.statValue}>₹{mockRevenueData.total.toLocaleString()}</div>
                    <div className={styles.statLabel}>Total Revenue</div>
                    <div className={styles.statSubtext}>All time earnings</div>
                </div>

                <div className={styles.statCard}>
                    <div className={styles.statHeader}>
                        <span className={styles.statIcon}>📈</span>
                    </div>
                    <div className={styles.statValue}>₹{mockRevenueData.thisMonth.toLocaleString()}</div>
                    <div className={styles.statLabel}>This Month</div>
                    <div className={styles.statComparison}>
                        <span className={styles.up}>↑ 16.9%</span> vs last month
                    </div>
                </div>

                <div className={styles.statCard}>
                    <div className={styles.statHeader}>
                        <span className={styles.statIcon}>⏳</span>
                    </div>
                    <div className={styles.statValue}>₹{mockRevenueData.pending.toLocaleString()}</div>
                    <div className={styles.statLabel}>Pending</div>
                    <div className={styles.statSubtext}>Awaiting confirmation</div>
                </div>

                <div className={styles.statCard}>
                    <div className={styles.statHeader}>
                        <span className={styles.statIcon}>↩️</span>
                    </div>
                    <div className={styles.statValue}>₹{mockRevenueData.refunded.toLocaleString()}</div>
                    <div className={styles.statLabel}>Refunded</div>
                    <div className={styles.statSubtext}>This month</div>
                </div>
            </div>

            {/* Charts Row */}
            <div className={styles.chartsRow}>
                {/* Weekly Chart */}
                <div className={styles.chartCard}>
                    <div className={styles.chartHeader}>
                        <h3>Weekly Revenue</h3>
                        <span className={styles.chartTotal}>₹{mockWeeklyData.reduce((a, b) => a + b.amount, 0).toLocaleString()}</span>
                    </div>
                    <div className={styles.barChart}>
                        {mockWeeklyData.map((data, index) => (
                            <div key={data.day} className={styles.barColumn}>
                                <div className={styles.barWrapper}>
                                    <div
                                        className={styles.bar}
                                        style={{
                                            height: `${(data.amount / maxWeekly) * 100}%`,
                                            animationDelay: `${index * 0.1}s`
                                        }}
                                    >
                                        <span className={styles.barTooltip}>₹{data.amount.toLocaleString()}</span>
                                    </div>
                                </div>
                                <span className={styles.barLabel}>{data.day}</span>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Event Revenue Breakdown */}
                <div className={styles.chartCard}>
                    <div className={styles.chartHeader}>
                        <h3>Revenue by Event</h3>
                    </div>
                    <div className={styles.eventList}>
                        {mockEventRevenue.map((event, index) => (
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
                            {mockTransactions.map((txn) => (
                                <tr key={txn.id}>
                                    <td><code className={styles.txnId}>{txn.id}</code></td>
                                    <td>{txn.name}</td>
                                    <td>{txn.event}</td>
                                    <td className={styles.amount}>₹{txn.amount}</td>
                                    <td>
                                        <span className={styles.method}>{txn.method}</span>
                                    </td>
                                    <td>
                                        <span className={`${styles.status} ${styles[txn.status]}`}>
                                            {txn.status}
                                        </span>
                                    </td>
                                    <td>{new Date(txn.date).toLocaleDateString()}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}
