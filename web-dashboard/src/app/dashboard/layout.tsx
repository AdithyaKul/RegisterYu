'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { usePathname } from 'next/navigation';
import styles from './dashboard.module.css';

const navItems = [
    { icon: '📊', label: 'Overview', path: '/dashboard' },
    { icon: '📅', label: 'Events', path: '/dashboard/events' },
    { icon: '👥', label: 'Attendees', path: '/dashboard/attendees' },
    { icon: '🛡️', label: 'Team', path: '/dashboard/team' },
    { icon: '📷', label: 'Check-in', path: '/dashboard/checkin' },
    { icon: '💰', label: 'Revenue', path: '/dashboard/revenue' },
    { icon: '📧', label: 'Notifications', path: '/dashboard/notifications' },
];

const bottomNavItems = [
    { icon: '⚙️', label: 'Settings', path: '/dashboard/settings' },
    { icon: '❓', label: 'Help', path: '/dashboard/help' },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
    const [sidebarOpen, setSidebarOpen] = useState(true);
    const [currentTime, setCurrentTime] = useState(new Date());
    const pathname = usePathname();

    useEffect(() => {
        const timer = setInterval(() => setCurrentTime(new Date()), 1000);
        return () => clearInterval(timer);
    }, []);

    // Close sidebar on mobile by default
    useEffect(() => {
        const handleResize = () => {
            if (window.innerWidth < 768) {
                setSidebarOpen(false);
            } else {
                setSidebarOpen(true);
            }
        };
        handleResize();
        window.addEventListener('resize', handleResize);
        return () => window.removeEventListener('resize', handleResize);
    }, []);

    const getPageTitle = () => {
        const path = pathname.split('/').pop();
        if (path === 'dashboard') return 'Overview';
        return path ? path.charAt(0).toUpperCase() + path.slice(1) : 'Overview';
    };

    return (
        <div className={styles.layout}>
            {/* Sidebar Overlay for Mobile */}
            {sidebarOpen && (
                <div
                    className={styles.sidebarOverlay}
                    onClick={() => setSidebarOpen(false)}
                />
            )}

            {/* Sidebar */}
            <aside className={`${styles.sidebar} ${sidebarOpen ? styles.open : ''}`}>
                <div className={styles.sidebarHeader}>
                    <Link href="/" className={styles.logo}>
                        <div className={styles.logoIcon}>
                            {/* <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M10 4H14V14H10V4Z" fill="white" />
                                <path fillRule="evenodd" clipRule="evenodd" d="M19 3H5C3.89543 3 3 3.89543 3 5V19C3 20.1046 3.89543 21 5 21H19C20.1046 21 21 20.1046 21 19V5C21 3.89543 20.1046 3 19 3ZM5 5H19V19H5V5Z" fill="white" fillOpacity="0.8" />
                            </svg> */}
                            <Image src="/logo.jpg" alt="Logo" width={24} height={24} style={{ borderRadius: '4px' }} />
                        </div>
                        <span className={styles.logoText}>RegisterYu</span>
                    </Link>
                </div>

                <nav className={styles.nav}>
                    {navItems.map((item) => (
                        <Link
                            key={item.path}
                            href={item.path}
                            className={`${styles.navItem} ${pathname === item.path ? styles.active : ''}`}
                            onClick={() => window.innerWidth < 768 && setSidebarOpen(false)}
                        >
                            <span className={styles.navIcon}>{item.icon}</span>
                            <span className={styles.navLabel}>{item.label}</span>
                        </Link>
                    ))}

                    <div className={styles.navDivider} />

                    {bottomNavItems.map((item) => (
                        <Link
                            key={item.path}
                            href={item.path}
                            className={`${styles.navItem} ${pathname === item.path ? styles.active : ''}`}
                            onClick={() => window.innerWidth < 768 && setSidebarOpen(false)}
                        >
                            <span className={styles.navIcon}>{item.icon}</span>
                            <span className={styles.navLabel}>{item.label}</span>
                        </Link>
                    ))}
                </nav>

                <div className={styles.sidebarFooter}>
                    <div className={styles.userCard}>
                        <div className={styles.userAvatar}>SC</div>
                        <div className={styles.userInfo}>
                            <span className={styles.userName}>Sambhram College</span>
                            <span className={styles.userRole}>Admin</span>
                        </div>
                    </div>
                </div>
            </aside>

            {/* Main Content */}
            <main className={`${styles.main} ${!sidebarOpen ? styles.sidebarClosed : ''}`}>
                {/* Top Bar */}
                <header className={styles.topBar}>
                    <div className={styles.topBarLeft}>
                        <button className={styles.menuBtn} onClick={() => setSidebarOpen(!sidebarOpen)}>
                            ☰
                        </button>
                        <div className={styles.breadcrumb}>
                            <span>Dashboard</span>
                            <span>/</span>
                            <span className={styles.breadcrumbActive}>{getPageTitle()}</span>
                        </div>
                    </div>

                    <div className={styles.topBarRight}>
                        <div className={styles.liveIndicator}>
                            <span className={styles.liveDot} />
                            Live
                        </div>
                        <div className={styles.clock}>
                            {currentTime.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' })}
                        </div>
                        <button className={styles.iconBtn}>🔔</button>
                        <Link href="/dashboard/events" className="btn btn-primary">
                            + New Event
                        </Link>
                    </div>
                </header>

                {/* Page Content */}
                <div className={styles.content}>
                    {children}
                </div>
            </main>
        </div>
    );
}
