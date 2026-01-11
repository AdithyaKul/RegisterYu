# 🚧 Known Issues & Pending Tasks

This document tracks the current known issues, pending configurations, and future planned improvements for the **RegisterYu** application.

## 🔴 Critical - Needs Immediate Action

### 1. Supabase RLS Policy Recursion (✅ Resolved)
- **Status**: Fixed via SQL patch.
- **Reference**: If you set up a new environment, you MUST run this one-time fix:
  ```sql
  DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
  DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
  DROP POLICY IF EXISTS "Enable insert for authenticated users" ON profiles;
  DROP POLICY IF EXISTS "Allow profile creation" ON profiles;

  CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
  CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
  CREATE POLICY "Allow profile creation" ON profiles FOR INSERT WITH CHECK (true);
  ```

### 2. Google Sign-In Configuration
- **Issue**: Google Sign-In button is functional in terms of the call, but requires backend configuration.
- **Action**: 
  - Set up a Google Cloud Project.
  - configure OAuth consent screen.
  - Add client IDs to Supabase Auth -> Providers -> Google.
  - Update `google-services.json` in `android/app/`.

## 🟡 High Priority - UX & Flow

### 3. Profile Completion Flow
- **Current Behavior**: If a user logs in but has missing data (College ID/Department), the app prompts them via a SnackBar when trying to register.
- **Required Improvement**: Implement a dedicated "Complete Your Profile" screen or modal that writes to the `profiles` table before allowing event registration.

### 4. Image Decoding Logs
- **Issue**: Android logs show `E/FlutterJNI: Failed to decode image` warnings on startup.
- **Impact**: Non-fatal, app works fine, but indicates malformed image URLs or SVG rendering issues.
- **Fix**: formatting of image URLs in the database or `CachedNetworkImage` error handling.

## 🟢 Future / Enhancement

### 5. Payment Gateway Integration
- **Status**: Razorpay package is installed and basic service logic exists.
- **Action**: Replace test API keys with live keys in `upi_payment_service.dart`. Validate the flow with a real small transaction.

### 6. Admin Dashboard Sync
- **Status**: Mobile app is using `public.events`.
- **Action**: Ensure the Web Admin Dashboard writes to the exactly same table and uses compatible RLS policies.
