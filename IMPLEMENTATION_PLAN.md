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
    *   UPI Payment Integration (Razorpay/PhonePe) for paid events.
*   **Ticket Wallet**: 
    *   QR Code generation for entry.
    *   Offline access to tickets.
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
*   **Check-in System**:
    *   Web-based QR Scanner to verify tickets at the door.

### 6. Ticket System & Communications
*   **Email Infrastructure**: 
    *   **Provider**: **Resend**.
    *   **Templating**: **React Email** (Allows us to share UI components between Web and Email).
    *   **Design**: Dark mode, ticket-style emails with embedded QR codes.
*   **Digital Wallets**:
    *   **Android**: **Google Wallet API** (Native "Add to Google Wallet" button).
    *   **iOS**: **Apple Wallet (.pkpass)** files.
    *   *Experience*: Students receive an email -> Click "Add to Wallet" -> Ticket lives in their phone's native wallet for offline access.

## 4. Proposed Tech Stack
To ensure speed, performance, and a premium feel:

### Variant A: The "Flutter" Path (Recommended based on your history)
*   **Mobile App**: **Flutter**. Best for beautiful, native-performance UI and complex animations.
*   **Web Dashboard**: **Next.js (React)**. Best for SEO and complex admin interfaces.
*   **Backend**: **Supabase** (PostgreSQL). Handles Auth, Database, and Realtime subscriptions for both App and Web.

### Variant B: The "Unified" Path
*   **Mobile App**: **React Native (Expo)**. Allows sharing code with the web.
*   **Web Dashboard**: **Next.js**.
*   **Backend**: **Supabase**.

## 5. Next Steps
1.  **Confirm Tech Stack**: Shall we go with **Flutter + Next.js + Supabase**?
2.  **Design System Setup**: Define the color palette and typography.
3.  **Database Modeling**: Design the Schema (Users, Events, Tickets, Registrations).
