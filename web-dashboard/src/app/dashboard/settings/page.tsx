'use client';

import { useState } from 'react';
import styles from './settings.module.css';

export default function SettingsPage() {
    const [activeSection, setActiveSection] = useState('general');

    // Form states
    const [orgName, setOrgName] = useState('Sambhram College');
    const [orgEmail, setOrgEmail] = useState('events@sambhram.edu');
    const [timezone, setTimezone] = useState('Asia/Kolkata');
    const [currency, setCurrency] = useState('INR');

    // Toggle states
    const [emailNotifications, setEmailNotifications] = useState(true);
    const [pushNotifications, setPushNotifications] = useState(true);
    const [autoCheckIn, setAutoCheckIn] = useState(false);
    const [requireApproval, setRequireApproval] = useState(false);
    const [darkMode, setDarkMode] = useState(true);

    const sections = [
        { id: 'general', label: 'General', icon: '⚙️' },
        { id: 'notifications', label: 'Notifications', icon: '🔔' },
        { id: 'payments', label: 'Payments', icon: '💳' },
        { id: 'security', label: 'Security', icon: '🔒' },
        { id: 'appearance', label: 'Appearance', icon: '🎨' },
        { id: 'integrations', label: 'Integrations', icon: '🔗' },
    ];

    return (
        <div className={styles.container}>
            {/* Header */}
            <header className={styles.header}>
                <h1>Settings</h1>
                <p className={styles.subtitle}>Manage your organization and preferences</p>
            </header>

            <div className={styles.layout}>
                {/* Sidebar */}
                <nav className={styles.sidebar}>
                    {sections.map(section => (
                        <button
                            key={section.id}
                            className={`${styles.sidebarItem} ${activeSection === section.id ? styles.active : ''}`}
                            onClick={() => setActiveSection(section.id)}
                        >
                            <span className={styles.sidebarIcon}>{section.icon}</span>
                            {section.label}
                        </button>
                    ))}
                </nav>

                {/* Content */}
                <div className={styles.content}>
                    {activeSection === 'general' && (
                        <div className={styles.section}>
                            <div className={styles.sectionHeader}>
                                <h2>General Settings</h2>
                                <p>Basic organization information and preferences</p>
                            </div>

                            <div className={styles.formCard}>
                                <h3>Organization Details</h3>
                                <div className={styles.formGrid}>
                                    <div className={styles.formGroup}>
                                        <label>Organization Name</label>
                                        <input
                                            type="text"
                                            className="input"
                                            value={orgName}
                                            onChange={(e) => setOrgName(e.target.value)}
                                        />
                                    </div>
                                    <div className={styles.formGroup}>
                                        <label>Contact Email</label>
                                        <input
                                            type="email"
                                            className="input"
                                            value={orgEmail}
                                            onChange={(e) => setOrgEmail(e.target.value)}
                                        />
                                    </div>
                                    <div className={styles.formGroup}>
                                        <label>Timezone</label>
                                        <select
                                            className="input"
                                            value={timezone}
                                            onChange={(e) => setTimezone(e.target.value)}
                                        >
                                            <option value="Asia/Kolkata">Asia/Kolkata (IST)</option>
                                            <option value="UTC">UTC</option>
                                            <option value="America/New_York">America/New_York (EST)</option>
                                        </select>
                                    </div>
                                    <div className={styles.formGroup}>
                                        <label>Currency</label>
                                        <select
                                            className="input"
                                            value={currency}
                                            onChange={(e) => setCurrency(e.target.value)}
                                        >
                                            <option value="INR">INR (₹)</option>
                                            <option value="USD">USD ($)</option>
                                            <option value="EUR">EUR (€)</option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div className={styles.formCard}>
                                <h3>Event Defaults</h3>
                                <div className={styles.toggleList}>
                                    <ToggleItem
                                        label="Require Registration Approval"
                                        description="Manually approve each registration before confirmation"
                                        checked={requireApproval}
                                        onChange={setRequireApproval}
                                    />
                                    <ToggleItem
                                        label="Auto Check-in"
                                        description="Automatically check in attendees when QR is scanned"
                                        checked={autoCheckIn}
                                        onChange={setAutoCheckIn}
                                    />
                                </div>
                            </div>
                        </div>
                    )}

                    {activeSection === 'notifications' && (
                        <div className={styles.section}>
                            <div className={styles.sectionHeader}>
                                <h2>Notification Preferences</h2>
                                <p>Control how and when you receive notifications</p>
                            </div>

                            <div className={styles.formCard}>
                                <h3>Channels</h3>
                                <div className={styles.toggleList}>
                                    <ToggleItem
                                        label="Email Notifications"
                                        description="Receive updates about registrations and events via email"
                                        checked={emailNotifications}
                                        onChange={setEmailNotifications}
                                    />
                                    <ToggleItem
                                        label="Push Notifications"
                                        description="Get instant alerts on your browser"
                                        checked={pushNotifications}
                                        onChange={setPushNotifications}
                                    />
                                </div>
                            </div>

                            <div className={styles.formCard}>
                                <h3>Email Triggers</h3>
                                <div className={styles.checkboxList}>
                                    {[
                                        'New registration',
                                        'Payment received',
                                        'Event check-in',
                                        'Refund requested',
                                        'Daily summary',
                                        'Weekly report',
                                    ].map(item => (
                                        <label key={item} className={styles.checkboxItem}>
                                            <input type="checkbox" className="checkbox" defaultChecked />
                                            <span>{item}</span>
                                        </label>
                                    ))}
                                </div>
                            </div>
                        </div>
                    )}

                    {activeSection === 'payments' && (
                        <div className={styles.section}>
                            <div className={styles.sectionHeader}>
                                <h2>Payment Settings</h2>
                                <p>Configure payment gateways and preferences</p>
                            </div>

                            <div className={styles.formCard}>
                                <h3>Payment Gateway</h3>
                                <div className={styles.gatewayOptions}>
                                    <div className={`${styles.gatewayCard} ${styles.active}`}>
                                        <div className={styles.gatewayIcon}>💳</div>
                                        <div className={styles.gatewayInfo}>
                                            <h4>Razorpay</h4>
                                            <span className={styles.gatewayStatus}>Connected</span>
                                        </div>
                                        <button className="btn btn-ghost">Configure</button>
                                    </div>
                                    <div className={styles.gatewayCard}>
                                        <div className={styles.gatewayIcon}>📱</div>
                                        <div className={styles.gatewayInfo}>
                                            <h4>PhonePe</h4>
                                            <span className={styles.gatewayStatus}>Not Connected</span>
                                        </div>
                                        <button className="btn btn-secondary">Connect</button>
                                    </div>
                                </div>
                            </div>

                            <div className={styles.formCard}>
                                <h3>UPI Settings</h3>
                                <div className={styles.formGroup}>
                                    <label>UPI ID</label>
                                    <input
                                        type="text"
                                        className="input"
                                        placeholder="yourbusiness@upi"
                                        defaultValue="sambhram@okicici"
                                    />
                                </div>
                            </div>
                        </div>
                    )}

                    {activeSection === 'security' && (
                        <div className={styles.section}>
                            <div className={styles.sectionHeader}>
                                <h2>Security Settings</h2>
                                <p>Protect your account and data</p>
                            </div>

                            <div className={styles.formCard}>
                                <h3>Change Password</h3>
                                <div className={styles.formStack}>
                                    <div className={styles.formGroup}>
                                        <label>Current Password</label>
                                        <input type="password" className="input" />
                                    </div>
                                    <div className={styles.formGroup}>
                                        <label>New Password</label>
                                        <input type="password" className="input" />
                                    </div>
                                    <div className={styles.formGroup}>
                                        <label>Confirm Password</label>
                                        <input type="password" className="input" />
                                    </div>
                                </div>
                                <button className="btn btn-primary" style={{ marginTop: 16 }}>
                                    Update Password
                                </button>
                            </div>

                            <div className={styles.formCard}>
                                <h3>Two-Factor Authentication</h3>
                                <p className={styles.cardDesc}>
                                    Add an extra layer of security to your account
                                </p>
                                <button className="btn btn-secondary">Enable 2FA</button>
                            </div>

                            <div className={styles.formCard}>
                                <h3>Active Sessions</h3>
                                <div className={styles.sessionsList}>
                                    <div className={styles.sessionItem}>
                                        <div className={styles.sessionIcon}>💻</div>
                                        <div className={styles.sessionInfo}>
                                            <span className={styles.sessionDevice}>Windows • Chrome</span>
                                            <span className={styles.sessionMeta}>Current session</span>
                                        </div>
                                        <span className={styles.sessionActive}>Active</span>
                                    </div>
                                    <div className={styles.sessionItem}>
                                        <div className={styles.sessionIcon}>📱</div>
                                        <div className={styles.sessionInfo}>
                                            <span className={styles.sessionDevice}>Android • RegisterYu App</span>
                                            <span className={styles.sessionMeta}>Last active 2 hours ago</span>
                                        </div>
                                        <button className="btn btn-ghost">Revoke</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    )}

                    {activeSection === 'appearance' && (
                        <div className={styles.section}>
                            <div className={styles.sectionHeader}>
                                <h2>Appearance</h2>
                                <p>Customize how the dashboard looks</p>
                            </div>

                            <div className={styles.formCard}>
                                <h3>Theme</h3>
                                <div className={styles.toggleList}>
                                    <ToggleItem
                                        label="Dark Mode"
                                        description="Use dark theme across the dashboard"
                                        checked={darkMode}
                                        onChange={setDarkMode}
                                    />
                                </div>
                            </div>

                            <div className={styles.formCard}>
                                <h3>Accent Color</h3>
                                <div className={styles.colorPicker}>
                                    {['#2997FF', '#BF5AF2', '#30D158', '#FF9F0A', '#FF375F', '#64D2FF'].map(color => (
                                        <button
                                            key={color}
                                            className={`${styles.colorOption} ${color === '#2997FF' ? styles.active : ''}`}
                                            style={{ background: color }}
                                        />
                                    ))}
                                </div>
                            </div>
                        </div>
                    )}

                    {activeSection === 'integrations' && (
                        <div className={styles.section}>
                            <div className={styles.sectionHeader}>
                                <h2>Integrations</h2>
                                <p>Connect with third-party services</p>
                            </div>

                            <div className={styles.integrationsList}>
                                {[
                                    { name: 'Google Calendar', icon: '📅', status: 'connected', desc: 'Sync events automatically' },
                                    { name: 'Slack', icon: '💬', status: 'disconnected', desc: 'Get notifications in Slack' },
                                    { name: 'Google Sheets', icon: '📊', status: 'connected', desc: 'Export attendee data' },
                                    { name: 'Zapier', icon: '⚡', status: 'disconnected', desc: 'Automate workflows' },
                                ].map(integration => (
                                    <div key={integration.name} className={styles.integrationCard}>
                                        <div className={styles.integrationIcon}>{integration.icon}</div>
                                        <div className={styles.integrationInfo}>
                                            <h4>{integration.name}</h4>
                                            <p>{integration.desc}</p>
                                        </div>
                                        <button className={`btn ${integration.status === 'connected' ? 'btn-ghost' : 'btn-secondary'}`}>
                                            {integration.status === 'connected' ? 'Configure' : 'Connect'}
                                        </button>
                                    </div>
                                ))}
                            </div>
                        </div>
                    )}

                    {/* Save Button (always visible) */}
                    <div className={styles.saveBar}>
                        <button className="btn btn-ghost">Cancel</button>
                        <button className="btn btn-primary">Save Changes</button>
                    </div>
                </div>
            </div>
        </div>
    );
}

function ToggleItem({ label, description, checked, onChange }: {
    label: string;
    description: string;
    checked: boolean;
    onChange: (value: boolean) => void;
}) {
    return (
        <div className={styles.toggleItem}>
            <div className={styles.toggleInfo}>
                <span className={styles.toggleLabel}>{label}</span>
                <span className={styles.toggleDesc}>{description}</span>
            </div>
            <button
                className={`${styles.toggle} ${checked ? styles.on : ''}`}
                onClick={() => onChange(!checked)}
            >
                <span className={styles.toggleKnob} />
            </button>
        </div>
    );
}
