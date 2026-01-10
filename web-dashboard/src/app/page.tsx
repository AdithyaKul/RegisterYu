'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import styles from './page.module.css';

export default function LandingPage() {
  const [activeSlide, setActiveSlide] = useState(0);

  // High quality representational images
  const heroes = [
    'https://images.unsplash.com/photo-1562774053-701939374585?q=80&w=1920', // Campus
    'https://images.unsplash.com/photo-1523580494863-6f3031224c94?q=80&w=1920', // Students
    'https://images.unsplash.com/photo-1517048676732-d65bc937f952?q=80&w=1920'  // Conference
  ];

  useEffect(() => {
    const timer = setInterval(() => {
      setActiveSlide(prev => (prev + 1) % heroes.length);
    }, 5000);
    return () => clearInterval(timer);
  }, []);

  return (
    <div className={styles.container}>
      {/* Navigation */}
      <nav className={styles.nav}>
        <div className={styles.logo}>
          {/* <div style={{ width: 32, height: 32, background: 'linear-gradient(135deg, #7c3aed, #f59e0b)', borderRadius: 8 }}></div> */}
          <Image src="/logo.jpg" alt="Logo" width={32} height={32} style={{ borderRadius: 8 }} />
          <span className={styles.logoText}>RegisterYu</span>
        </div>
        <div style={{ display: 'flex', gap: 16 }}>
          <Link href="/login" className="btn btn-ghost" style={{ color: 'white' }}>
            Event Admin Login
          </Link>
          <Link href="/login" className="btn btn-primary">
            Student Login
          </Link>
        </div>
      </nav>

      {/* Hero Slider */}
      <main className={styles.hero}>
        {heroes.map((img, idx) => (
          <div
            key={idx}
            className={styles.heroBg}
            style={{
              opacity: activeSlide === idx ? 1 : 0,
              transition: 'opacity 1s ease-in-out'
            }}
          >
            <img src={img} className={styles.heroImage} alt="Sambhram Campus" />
          </div>
        ))}
        <div className={styles.heroOverlay} />

        <div className={styles.heroContent}>
          <div className={styles.badge}>Sambhram Institute of Technology</div>
          <h1 className={styles.title}>
            The Future of <br />
            <span style={{ color: '#f59e0b' }}>Campus Events</span>
          </h1>
          <p className={styles.subtitle}>
            Experience a seamless, digital-first event culture.
            Register for workshops, cultural fests, and hackathons with a single tap.
            <br />Welcome to the new standard.
          </p>
          <div className={styles.ctaGroup}>
            <Link href="/login" className="btn btn-primary" style={{ padding: '16px 32px', fontSize: '1.1rem' }}>
              Explore Events
            </Link>
            <Link href="/login" className="btn btn-secondary" style={{ padding: '16px 32px', fontSize: '1.1rem' }}>
              Organizer Dashboard
            </Link>
          </div>
        </div>
      </main>

      {/* Features */}
      <section className={styles.section}>
        <h2 className={styles.sectionTitle}>Why RegisterYu?</h2>
        <div className={styles.grid}>
          <FeatureCard
            icon="⚡"
            title="Instant Access"
            desc="No more long lines. Get your QR ticket instantly on your phone and breeze through check-ins."
          />
          <FeatureCard
            icon="🎓"
            title="Student Centric"
            desc="Built for Sambhram students. Earn activity points, track participation, and build your portfolio."
          />
          <FeatureCard
            icon="🛡️"
            title="Secure Platform"
            desc="Your data is safe. Verified profiles ensure a secure and exclusive community environment."
          />
        </div>
      </section>

      {/* Footer */}
      <footer className={styles.footer}>
        <p style={{ marginBottom: 8, fontSize: '1.1rem' }}>
          Made with <span style={{ color: '#ff375f' }}>❤️</span> at Sambhram Institute of Technology
        </p>
        <p style={{ fontSize: '0.9rem', opacity: 0.6 }}>
          &copy; {new Date().getFullYear()} RegisterYu. All rights reserved.
        </p>
      </footer>
    </div>
  );
}

function FeatureCard({ icon, title, desc }: any) {
  return (
    <div className={styles.card}>
      <div className={styles.cardIcon}>{icon}</div>
      <h3>{title}</h3>
      <p>{desc}</p>
    </div>
  );
}
