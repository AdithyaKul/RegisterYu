# 🔐 Google Sign-In Setup Guide

To enable Google Authentication in **RegisterYu**, you need to configure Google Cloud Platform (GCP) and link it to Supabase.

## Prerequisite: Get SHA-1 Fingerprint
For Android integration, you need the SHA-1 fingerprint of your debug keystore.

Run this in your terminal:
```bash
cd android
./gradlew signingReport
```
Look for **SHA-1** under `Variant: debug`. Copy it.

---

## Step 1: Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/).
2. Create a **New Project** (e.g., "RegisterYu Mobile").
3. Navigate to **APIs & Services > OAuth consent screen**.
   - Choose **External**.
   - Fill in App Name ("RegisterYu"), Support Email, etc.
   - Click Save & Continue.
4. Navigate to **APIs & Services > Credentials**.

### Create Web Client ID (Required for Supabase)
1. Click **Create Credentials** > **OAuth client ID**.
2. Select **Web application**.
3. Name it "Supabase Auth".
4. Under **Authorized parameters**:
   - **Authorized redirect URIs**: Add your Supabase Callback URL. 
   - Go to Supabase > Authentication > Providers > Google to find this URL (e.g., `https://<your-ref>.supabase.co/auth/v1/callback`).
5. Click **Create**.
6. **COPY the Client ID**. This is your `WEB_CLIENT_ID`.

### Create Android Client ID (Required for App)
1. Click **Create Credentials** > **OAuth client ID** again.
2. Select **Android**.
3. Package name: `com.sambhram.events.mobile_app` (Check your `android/app/build.gradle.kts`).
4. **SHA-1 certificate fingerprint**: Paste the SHA-1 you copied earlier.
5. Click **Create**.
6. **COPY the Client ID**. This is your `ANDROID_CLIENT_ID`.

---

## Step 2: Supabase Configuration

1. Go to your **Supabase Dashboard**.
2. Navigate to **Authentication > Providers**.
3. Select **Google**.
4. Toggle **Enable Google**.
5. Client ID: Paste the `WEB_CLIENT_ID` (from Step 1).
6. Client Secret: Paste the Web Client Secret (from Step 1).
7. Toggle **Skip nonce checks** (Required for Flutter/Mobile).
8. Click **Save**.

---

## Step 3: Update App Code

1. Open `lib/core/services/supabase_service.dart`.
2. Locate the `signInWithGoogle` method.
3. Replace the placeholder constants with your actual IDs:
   ```dart
   const webClientId = 'YOUR_WEB_CLIENT_ID...';
   const iosClientId = 'YOUR_IOS_CLIENT_ID...'; // Create iOS ID if deploying to iPhone
   ```

## Step 4: Update Android Config

1. Download the `google-services.json` file from Firebase (if using Firebase) OR just ensure your `build.gradle` is set up.
   - *Note: Since we are using pure Google Sign-In + Supabase, strictly speaking `google-services.json` isn't mandatory if we pass client IDs manually, but it's good practice / required if using Firebase Auth wrapper.*
   - Ideally, create a Firebase Project linked to your Google Cloud Project to effectively manage the Android App configuration.

2. If using Firebase (Recommended for easy SHA-1 management):
   - Go to [Firebase Console](https://console.firebase.google.com/).
   - Add Project -> Select your Google Cloud Project.
   - Add Android App (`com.sambhram.events.mobile_app`, SHA-1).
   - Download `google-services.json`.
   - Place it in `mobile_app/android/app/`.

---

## Step 5: Run & Test
1. Rebuild the app: `flutter run`.
2. Tap "Continue with Google".
3. Select your account.
4. Success!
