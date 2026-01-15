'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { getCheckinStats, performCheckIn } from './actions';
import styles from './checkin.module.css';

interface CheckinRecord {
    id: string; // UUID
    name: string;
    event: string;
    ticketId: string; // Display code
    time: string;
    success: boolean;
}

export default function CheckinPage() {
    const [scanMode, setScanMode] = useState<'qr' | 'manual'>('manual');
    const [manualInput, setManualInput] = useState('');
    const [lastScan, setLastScan] = useState<CheckinRecord | null>(null);
    const [recentCheckins, setRecentCheckins] = useState<CheckinRecord[]>([]);
    const [stats, setStats] = useState({
        totalCheckins: 0,
        lastHour: 0,
        pending: 0,
    });
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        fetchStatsLine();
        const interval = setInterval(fetchStatsLine, 30000); // Live refresh every 30s
        return () => clearInterval(interval);
    }, []);

    async function fetchStatsLine() {
        try {
            const data = await getCheckinStats();
            setStats({
                totalCheckins: data.totalCheckins,
                pending: data.pending,
                lastHour: data.lastHour
            });
            setRecentCheckins(data.recent);
        } catch (e) {
            console.error(e);
        }
    }

    const handleManualCheckIn = async () => {
        if (!manualInput.trim()) return;
        setLoading(true);

        const inputId = manualInput.trim();

        try {
            const result = await performCheckIn(inputId);

            if (result.success) {
                setLastScan(result.record);
                // Optimistically update recent checkins
                setRecentCheckins(prev => [result.record, ...prev]);
                // Optimistically update stats
                setStats(prev => ({
                    ...prev,
                    totalCheckins: prev.totalCheckins + 1,
                    pending: prev.pending - 1,
                    lastHour: prev.lastHour + 1
                }));
                setManualInput('');
            } else {
                setLastScan(result.record || {
                    id: 'error',
                    name: 'Duplicate Scan',
                    event: 'N/A',
                    ticketId: inputId,
                    time: new Date().toLocaleTimeString(),
                    success: false
                });
                alert(result.message);
            }

        } catch (e: any) {
            console.error(e);
            setLastScan({
                id: 'error',
                name: 'Error / Invalid Ticket',
                event: 'N/A',
                ticketId: inputId,
                time: new Date().toLocaleTimeString(),
                success: false
            });
        } finally {
            setLoading(false);
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
                    <h1>Check-in Scanner</h1>
                </div>
                <div className={styles.liveIndicator}>
                    <span className={styles.liveDot} />
                    Live Mode
                </div>
            </header>

            <div className={styles.content}>
                {/* Scanner Section */}
                <div className={styles.scannerSection}>
                    {/* Mode Toggle */}
                    <div className={styles.modeToggle}>
                        <button
                            className={`${styles.modeBtn} ${scanMode === 'qr' ? styles.active : ''}`}
                            onClick={() => setScanMode('qr')}
                        >
                            📷 QR Scanner
                        </button>
                        <button
                            className={`${styles.modeBtn} ${scanMode === 'manual' ? styles.active : ''}`}
                            onClick={() => setScanMode('manual')}
                        >
                            ⌨️ Manual Entry
                        </button>
                    </div>

                    {/* Scanner/Manual Input */}
                    <div className={styles.scannerBox}>
                        {scanMode === 'qr' ? (
                            <div className={styles.qrScanner}>
                                <div className={styles.scannerFrame}>
                                    <div className={styles.scannerCorner} style={{ top: 0, left: 0 }} />
                                    <div className={styles.scannerCorner} style={{ top: 0, right: 0 }} />
                                    <div className={styles.scannerCorner} style={{ bottom: 0, left: 0 }} />
                                    <div className={styles.scannerCorner} style={{ bottom: 0, right: 0 }} />
                                    <div className={styles.scanLine} />
                                </div>
                                <p>Position QR code within the frame</p>
                                <button className="btn btn-secondary" onClick={() => alert("Please use the Mobile App for camera scanning.")}>
                                    📱 Open Camera
                                </button>
                            </div>
                        ) : (
                            <div className={styles.manualEntry}>
                                <div className={styles.inputGroup}>
                                    <input
                                        type="text"
                                        className="input"
                                        placeholder="Enter Ticket Code (e.g. A1B2C3D4)"
                                        value={manualInput}
                                        onChange={(e) => setManualInput(e.target.value)}
                                        onKeyDown={(e) => e.key === 'Enter' && handleManualCheckIn()}
                                    />
                                    <button className="btn btn-primary" onClick={handleManualCheckIn} disabled={loading}>
                                        {loading ? '...' : 'Check In'}
                                    </button>
                                </div>
                            </div>
                        )}
                    </div>

                    {/* Last Scan Result */}
                    {lastScan && (
                        <div className={`${styles.scanResult} ${lastScan.success ? styles.success : styles.error}`}>
                            <div className={styles.resultIcon}>
                                {lastScan.success ? '✅' : '❌'}
                            </div>
                            <div className={styles.resultContent}>
                                <h3>{lastScan.success ? 'Check-in Successful!' : 'Check-in Failed'}</h3>
                                <p><strong>{lastScan.name}</strong></p>
                                <p>{lastScan.event} • {lastScan.ticketId}</p>
                            </div>
                            <span className={styles.resultTime}>{lastScan.time}</span>
                        </div>
                    )}

                    {/* Stats */}
                    <div className={styles.statsRow}>
                        <div className={styles.statCard}>
                            <span className={styles.statValue}>{stats.totalCheckins}</span>
                            <span className={styles.statLabel}>Total Check-ins</span>
                        </div>
                        <div className={styles.statCard}>
                            <span className={styles.statValue}>{stats.lastHour}</span>
                            <span className={styles.statLabel}>Last Hour</span>
                        </div>
                        <div className={styles.statCard}>
                            <span className={styles.statValue}>{stats.pending}</span>
                            <span className={styles.statLabel}>Pending</span>
                        </div>
                    </div>
                </div>

                {/* Recent Check-ins */}
                <div className={styles.recentSection}>
                    <h2>Recent Check-ins</h2>
                    <div className={styles.recentList}>
                        {recentCheckins.length === 0 ? (
                            <div style={{ color: '#888', padding: '20px' }}>No recent check-ins</div>
                        ) : (
                            recentCheckins.map((checkin, index) => (
                                <div
                                    key={checkin.id}
                                    className={styles.recentItem}
                                    style={{ animationDelay: `${index * 0.1}s` }}
                                >
                                    <div className={styles.recentAvatar}>
                                        {checkin.name.split(' ').map(n => n[0]).join('')}
                                    </div>
                                    <div className={styles.recentInfo}>
                                        <span className={styles.recentName}>{checkin.name}</span>
                                        <span className={styles.recentEvent}>{checkin.event}</span>
                                    </div>
                                    <div className={styles.recentMeta}>
                                        <code>{checkin.ticketId}</code>
                                        <span>{checkin.time}</span>
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
