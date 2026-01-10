import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import styles from './liquid.module.css';

interface LiquidCardProps {
    children: React.ReactNode;
    className?: string;
    onClick?: () => void;
}

export const LiquidCard: React.FC<LiquidCardProps> = ({ children, className = '', onClick }) => {
    const [filterUrl, setFilterUrl] = useState('');

    useEffect(() => {
        // Load the displacement map
        const feImage = document.getElementById('liquid-map-image');
        if (feImage) {
            if (feImage.getAttribute('href')) return;
            // Use local public asset
            feImage.setAttribute("href", "/liquid-map.png");
        }
    }, []);

    return (
        <div
            onClick={onClick}
            className={`${styles.liquidGlass} ${className}`}
        // Removed heavy SVG filter causing lag
        // style={{ backdropFilter: 'url(#glass)' }} 
        >
            <div className={styles.liquidGlassContent}>
                {children}
            </div>
        </div>
    );
};

interface LiquidButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    children: React.ReactNode;
    href?: string;
}

export const LiquidButton: React.FC<LiquidButtonProps> = ({ children, className = '', href, ...props }) => {
    if (href) {
        return (
            <Link href={href} className={`${styles.liquidButton} ${className}`}>
                {children}
            </Link>
        );
    }
    return (
        <button
            className={`${styles.liquidButton} ${className}`}
            {...props}
        >
            {children}
        </button>
    );
}

// Global Filter Component (Should be placed once in Layout or Page)
export const LiquidFilterDef = () => (
    <svg style={{ position: 'absolute', width: 0, height: 0, pointerEvents: 'none' }}>
        <filter
            id="glass"
            x="-50%"
            y="-50%"
            width="200%"
            height="200%"
            primitiveUnits="objectBoundingBox"
        >
            <feImage
                id="liquid-map-image"
                x="-50%"
                y="-50%"
                width="200%"
                height="200%"
                result="map"
                preserveAspectRatio="none"
                href="/liquid-map.png"
            />
            <feGaussianBlur in="SourceGraphic" stdDeviation="0.02" result="blur" />
            <feDisplacementMap
                id="disp"
                in="blur"
                in2="map"
                scale="0.05"
                xChannelSelector="R"
                yChannelSelector="G"
            ></feDisplacementMap>
        </filter>
    </svg>
);
