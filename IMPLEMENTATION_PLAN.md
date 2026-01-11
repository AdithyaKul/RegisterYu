# Sambhram Registrations App - Implementation Plan

## 1. Project Overview
A premium event registration system for Sambhram College, inspired by [Luma](https://lu.ma). The system bridges the gap between event organizers and students through a seamless Android App for students and a powerful Web Dashboard for organizers.

## 2. Design Philosophy ("Liquid Glass")
*   **Aesthetics**: Ultra-premium Apple-style design. Heavy use of depth, blur, and layering.
*   **Theme**: 
    *   *System-Wide*: Deep, rich dark backgrounds (True Black to Charcoal).
    *   *Materials*: **Liquid Glass** surfaces—high blur (backdrop-filter: blur(20px)), varying opacity (10-30%), and thin, subtle white borders (0.5px).
*   **Visual Language**:
    *   **The "Glass" Feel**: Elements should feel like physical glass planes floating over the background.
    *   **Typography**: SF Pro Display (or similar sans-serif) with tight tracking for that iOS native feel.
    *   **Interactions**: Smooth 120Hz-feel animations. Navigation transitions that slide and blur.

## 3. Core Features

### 📱 Android Application (Student Facing)
*   **Authentication**: Google Sign-In (College Domain Lock optional), OTP Login.
*   **Discover Feed**: 
    *   "For You" section based on interests.
    *   "Trending" events in college.
    *   Calendar view of upcoming events.
*   **Event Details**: 
    *   Immersive cover art.
    *   Rich text description.
    *   Speaker/Guest profiles.
    *   "Who's Going" (Social proof).
*   **Registration**:
    *   One-tap register (if free).
    *   **UPI Intent Payment**: Deep-link directly to GPay/PhonePe/Paytm. No payment gateway fees.
*   **Ticket Wallet**: 
    *   QR Code generation for entry.
    *   Offline access to tickets.
    *   NFC Support for fast entry.
*   **Notifications**: Push notifications for event reminders and updates.

### 💻 Web Dashboard (Admin/Organizer Facing)
*   **Command Center**:
    *   Live stats (Views, Registrations, Revenue).
    *   Real-time check-in counter.
*   **Event Builder**:
    *   WYSIWYG Editor for event pages.
    *   Ticket tier management (Early Bird, Regular, VIP).
    *   Custom form builder (ask flexible questions to attendees).
*   **Attendee Management**:
    *   Table view of all registrants.
    *   Export to CSV.
    *   Bulk Email/WhatsApp notifications.
*   **Role-Based Access Control (RBAC)**:
    *   **Admin**: Full system access.
    *   **Organizer**: Can manage their own events.

### 🔫 Admin & Gate Scanner App (Staff Facing)
*   **Mode A: Gate Registrar (Gate Entry)**:
    *   Located at the main college entrance.
    *   **Features**: On-spot Registration, Payment Verification, ID Card Scanning.
    *   **Goal**: Ensure every student entering has a valid pass/registration.
*   **Mode B: Event Volunteer (Event Check-in)**:
    *   Located at specific event venues (e.g., Auditorium, Lab).
    *   **Features**: Scan QR codes for specific event entry.
    *   **Goal**: Verify student is registered for *this specific event*.

### 6. Ticket System & Communications
*   **Email Infrastructure**: 
    *   **Provider**: **Resend**.
    *   **Templating**: **React Email** (Allows us to share UI components between Web and Email).
    *   **Design**: Dark mode, ticket-style emails with embedded QR codes.
*   **Digital Wallets**:
    *   **Android**: **Google Wallet API** (Native "Add to Google Wallet" button).
    *   **iOS**: **Apple Wallet (.pkpass)** files.

## 4. Confirmed Tech Stack
*   **Mobile App**: **Flutter** (3.27+).
*   **Web Dashboard**: **Next.js 15 (React)**.
*   **Backend**: **Supabase** (PostgreSQL, Auth, Edge Functions).
*   **Infrastructure**: Vercel (Web), GitHub Actions (CI/CD).

## 5. Next Steps
1.  **Refine RBAC**: Implement the "Gate Registrar" vs "Volunteer" logic in Supabase.
2.  **Scanner App Modes**: Update the Flutter Admin app to have a mode switch.
3.  **UPI Integration**: Implement `url_launcher` based UPI intent firing in the mobile app.
