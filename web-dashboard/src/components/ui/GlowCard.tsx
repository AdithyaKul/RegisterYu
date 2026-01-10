import React from 'react';
import styles from './cards.module.css';

interface GlowCardProps {
    children: React.ReactNode;
    className?: string; // Kept for API compatibility, but might be empty
    onClick?: () => void;
}

export const GlowCard: React.FC<GlowCardProps> = ({ children, className = '', onClick }) => {
    return (
        <div
            onClick={onClick}
            className={`${styles.glowCard} ${className}`}
        >
            {/* Search/Inner Content Container */}
            <div className={styles.glowCardContent}>
                {children}
            </div>

            {/* Glow Effect */}
            <div className={styles.glowEffect}></div>
        </div>
    );
};

