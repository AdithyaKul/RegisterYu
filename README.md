# 🎓 RegisterYu: The Ultimate Campus Event Platform

Welcome to **RegisterYu** (formerly Sambhram Registrations), a premium, high-performance ecosystem designed to streamline college event management. Built with a focus on **Liquid Glass Aesthetics** and **Native-speed performance**.

## 🚀 The Ecosystem

RegisterYu isn't just an app; it's a complete event infrastructure:

1.  **Mobile App (Flutter)**: The user-facing platform for finding events, registering, and managing tickets.
    *   **120fps Scrolling**: Butter-smooth event browsing.
    *   **Google One-Tap Auth**: Instant secure login.
    *   **Smart Wallet**: Digital tickets with QR codes and NFC support.
    *   **Guest Mode**: Explore events without immediate login.
2.  **Web Dashboard (Next.js)**: The central hub for organizers to manage events, track revenue (Razorpay), and view analytics.
3.  **Admin Scanner App (Flutter)**: A specialized high-speed scanning tool for event check-ins at entry gates.

---

## ✨ Key Features

*   **Liquid UI**: A premium, modern design language with glassmorphism, smooth gradients, and micro-animations.
*   **Secure Payments**: Integrated with Razorpay for reliable registrations.
*   **Dual Auth**: Support for traditional Email/Password and Google Social Login.
*   **Offline Support**: Optimized caching for viewed event list.
*   **NFC Integration**: Fast check-ins using physical NFC-enabled college ID cards.

---

## 🛠️ Tech Stack

*   **Frontend (Mobile)**: Flutter, Provider
*   **Frontend (Web)**: Next.js 15, Tailwind CSS, Shadcn UI
*   **Backend**: Supabase (PostgreSQL, Realtime, Auth, Storage)
*   **Payments**: Razorpay SDK
*   **Infrastructure**: Vercel (Web), GitHub Actions

---

## 📥 Getting Started

### For Users
You can download the latest beta of the Android App directly from our landing page or via the link below:
👉 **[Download RegisterYu APK](https://registeryu-dashboard.vercel.app/app-registeryu.apk)** (Replace with actual domain when live)

### For Developers
1.  **Clone the Repo**: `git clone https://github.com/AdithyaKul/RegisterYu.git`
2.  **Setup Backend**: Follow the instructions in `backend/README.md` to set up your Supabase project.
3.  **Mobile App**:
    ```bash
    cd mobile_app
    flutter pub get
    flutter run
    ```
4.  **Web Dashboard**:
    ```bash
    cd web-dashboard
    npm install
    npm run dev
    ```

---

## 📖 Essential Documentation
*   [Google Auth Setup Guide](./GOOGLE_AUTH_SETUP.md) - How to configure social login.
*   [Known Issues](./KNOWN_ISSUES.md) - Current status and common fixes.
*   [Implementation Plan](./IMPLEMENTATION_PLAN.md) - The architectural road-map.
*   [Changelog](./CHANGELOG.md) - Evolution of the platform.

---

## 🤝 Contributing
RegisterYu is born at **Sambhram Institute of Technology**. We welcome contributions from students and developers to make campus life more digital and seamless.

Made with ❤️ at SaIT.
