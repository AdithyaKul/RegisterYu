<div align="center">

# ⚡ **R E G I S T E R - Y U** ⚡

**The Ultimate Campus Event Orchestration Layer**

[![Build Status](https://img.shields.io/badge/Build-PASSING-brightgreen?style=for-the-badge&logo=github)](https://github.com/AdithyaKul/RegisterYu)
[![Version](https://img.shields.io/badge/Version-BETA_1.2-blueviolet?style=for-the-badge)](https://github.com/AdithyaKul/RegisterYu/releases)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Next JS](https://img.shields.io/badge/Next-black?style=for-the-badge&logo=next.js&logoColor=white)](https://nextjs.org)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)](https://tailwindcss.com)
[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)

<img src="./web-dashboard/public/logo.jpg" alt="RegisterYu Logo" height="200" style="border-radius: 20px; margin: 20px 0;">

**[ 📲 DOWNLOAD APP (BETA) ](https://registeryu-dashboard.vercel.app/app-registeryu.apk)** • **[ 🌐 OPEN DASHBOARD ](https://registeryu-dashboard.vercel.app)**

</div>

---

## 🔮 **THE VISION**

**RegisterYu** dismantles the archaic, paper-based chaos of college fests. We replaced it with a **liquid-smooth, digital nervous system** that connects students, organizers, and events in real-time. 

Built with **Liquid Glass Aesthetics**, the interface feels like it's floating. It's not just an app; it's a statement.

---

## 🏗️ **SYSTEM ARCHITECTURE**

We don't do spaghetti code. We build skyscrapers.

```mermaid
graph TD
    User([📱 Student]) -->|Interacts| MobileApp[Flutter Mobile App]
    Admin([🤵 Admin]) -->|Manages| WebDash[Next.js Dashboard]
    Gate([🚧 Gate Registrar]) -->|On-site Entry| Scanner[Admin Scanner App]
    Vol([🙋 Volunteer]) -->|Event Check-in| Scanner

    subgraph "Core Infrastructure"
        MobileApp -->|Auth & Data| Supabase[(Supabase Backend)]
        WebDash -->|Auth & Data| Supabase
        Scanner -->|Verify & Register| Supabase
    end

    subgraph "External Services"
        MobileApp -->|Google Sign-In| OAuth[Google OAuth]
        MobileApp -->|Direct Payment| UPI[UPI Deep Link]
    end
```

---

## 💎 **THE QUADRANT**

### 1️⃣ **The Mobile Experience** (Flutter)
> *For the students. Fast, fluid, fabulous.*
*   **120Hz Rendering**: Optimized scroll physics.
*   **UPI Deep-Links**: Direct payments via GPay/PhonePe/Paytm. NO Gateways.
*   **Smart Wallet**: NFC-ready digital tickets.
*   **Google One-Tap**: Instant login.

### 2️⃣ **The Command Center** (Next.js 15)
> *For the Admins. Total Control.*
*   **Live Analytics**: Real-time registration tracking.
*   **Master Control**: Create events, manage users, override payments.

### 3️⃣ **The Gate Keepers** (Scanner Mode: Registrar)
> *For the Frontline. Entry & On-spot.*
*   **Gate Registration**: Register students on the spot at the college entrance.
*   **Initial Verification**: Validate ID cards and payments before entry.

### 4️⃣ **The Event Volunteers** (Scanner Mode: Event)
> *For the Hosts. Event Specific.*
*   **Event Check-in**: Scan tickets for specific sub-events (e.g., Hackathon, Concert).
*   **Crowd Control**: Verify eligibility for individual activities.

---

## 📂 **PROJECT STRUCTURE**

```text
📦 RegisterYu
 ┣ 📂 mobile_app         # The Flutter Application (User Facing)
 ┃ ┣ 📂 lib              # Core Logic & UI Components
 ┃ ┗ 📜 pubspec.yaml     # Dependencies
 ┣ 📂 web-dashboard      # The Next.js Admin Panel
 ┃ ┣ 📂 src              # React Components & Pages
 ┃ ┗ 📂 public           # Assets & APK Hosting
 ┣ 📂 admin_app          # The Ticket Scanner Tool
 ┣ 📂 backend            # Supabase Configs & SQL
 ┗ 📜 README.md          # You are here
```

---

## 🚀 **DEPLOYMENT PROTOCOL**

### **Prerequisites**
*   **Flutter SDK**: > 3.27.0
*   **Node.js**: > 20.0.0
*   **Git**: Latest

### **Initiate Sequence**

**1. Clone the Monorepo**
```bash
git clone https://github.com/AdithyaKul/RegisterYu.git
```

**2. Ignite Mobile App**
```bash
cd mobile_app
flutter pub get
flutter run --release
```

**3. Launch Web Dashboard**
```bash
cd web-dashboard
npm install
npm run dev
```


---

## 🔮 **FUTURE ROADMAP**

*   **📜 Automated Certificate Generator**:
    *   Instantly generate participation and merit certificates for specific events.
    *   Direct download option from the App Ticket Wallet.
    *   Verify certificate authenticity via QR code.

---

## 📜 **DOCUMENTATION**

*   **[Setup Google Auth](./GOOGLE_AUTH_SETUP.md)**: The key to social login.
*   **[Known Issues](./KNOWN_ISSUES.md)**: We know, we're working on it.
*   **[The Master Plan](./IMPLEMENTATION_PLAN.md)**: Future roadmap.
*   **[Changelog](./CHANGELOG.md)**: Version history.

---

<div align="center">

### **Crafted with ❤️ and ☕ at Sambhram Institute of Technology**

*"Building the future of campus events."*

</div>
