import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'RegisterYu Dashboard | Event Management',
  description: 'Premium event management dashboard for Sambhram College',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
