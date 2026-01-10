import React from 'react';
import styles from './cards.module.css';

interface CrystalCardProps {
    title?: string;
    subtitle?: string;
    footerText?: string;
    tags?: string[];
    onClick?: () => void;
    className?: string; // Kept via API but less used
}

export const CrystalCard: React.FC<CrystalCardProps> = ({
    title = "Card",
    subtitle = "text",
    footerText = "2025",
    tags = ["UIverse", "card"],
    onClick,
    className = ""
}) => {
    return (
        <div className={`${styles.crystalCard} ${className}`}>
            {/* Background Layers */}
            <div className={styles.crystalBgLayer}>
                <div className={styles.crystalBgShape}></div>
            </div>

            {/* Spinning Gradient Center */}
            <div className={styles.crystalSpinnerContainer}>
                <div className={styles.crystalSpinner}></div>
            </div>

            {/* Content Overlay */}
            <div className={styles.crystalContentOverlay}>
                {/* Left Content Area */}
                <div className={styles.crystalLeftCol}>
                    <span className={styles.crystalTitle}>{title}</span>
                    <span className={styles.crystalSubtitle}>{subtitle}</span>
                    <div className={styles.crystalFooter}>
                        <span className="text-xs text-gray-400">{footerText}</span>
                    </div>
                </div>

                {/* Right Action/Tags Area */}
                <div className={styles.crystalRightCol}>
                    {tags.map((tag, i) => (
                        <span key={i}>{tag}</span>
                    ))}

                    {/* Action Button */}
                    <div
                        onClick={onClick}
                        className={styles.crystalActionButton}
                    >
                        <span className={styles.crystalActionIcon}>
                            <svg
                                xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 12 12"
                                width="100%" height="100%"
                                fill="currentColor"
                            >
                                <g fill="none">
                                    <path
                                        d="M4.646 2.146a.5.5 0 0 0 0 .708L7.793 6L4.646 9.146a.5.5 0 1 0 .708.708l3.5-3.5a.5.5 0 0 0 0-.708l-3.5-3.5a.5.5 0 0 0-.708 0z"
                                        fill="currentColor"
                                    ></path>
                                </g>
                            </svg>
                        </span>
                    </div>
                </div>
            </div>
        </div>
    );
};
