# RegisterYu Mobile App - Quick Start Guide

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK 3.0+
- Android Studio / VS Code with Flutter extension
- A Supabase project (already configured!)

### 1. Database Setup (One-time)

Run this migration in your Supabase SQL Editor to add mobile-specific columns:

```sql
-- Run in Supabase Dashboard > SQL Editor
-- Add nfc_tag_id and department columns to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS nfc_tag_id text UNIQUE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS department text;

-- Update role check to include 'volunteer'
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check 
  CHECK (role IN ('student', 'volunteer', 'organizer', 'admin'));

-- Create profile auto-creation trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name', 'student')
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

### 2. Run the App

```bash
cd mobile_app
flutter pub get
flutter run
```

### 3. Create a Test Account

1. Open the app
2. Click "Sign Up"
3. Enter your email and password
4. Check your email for verification link (or disable email verification in Supabase)
5. Sign in!

## ✅ What's Working

| Feature | Status |
|---------|--------|
| Email/Password Login | ✅ Working |
| Sign Up | ✅ Working |
| NFC Card Scan | ✅ Scans tag ID, needs DB link |
| Event Feed | ✅ Fetches from Supabase |
| Category Filter | ✅ Working |
| Event Registration | ✅ Saves to database |
| QR Code Tickets | ✅ Real QR data |
| Wallet/My Tickets | ✅ Fetches registered events |
| Profile | ✅ Shows auth user data |
| Logout | ✅ Properly signs out |
| Search | ✅ Real-time search |
| Google Sign-In | ⏳ Needs Firebase setup |

## 🔧 For Google Sign-In (Optional)

1. Create a Firebase project
2. Enable Google Sign-In provider
3. Add Android app with your SHA-1 fingerprint
4. Download `google-services.json` to `android/app/`
5. Enable Google provider in Supabase Auth settings

## 📁 Key Files

- `lib/core/services/supabase_service.dart` - All Supabase API calls
- `lib/core/services/auth_manager.dart` - Auth state management
- `lib/features/auth/screens/login_screen.dart` - Login/Signup UI
- `lib/features/events/screens/home_screen.dart` - Event feed
- `lib/features/wallet/screens/wallet_screen.dart` - User's tickets

## 🌐 Supabase Configuration

Credentials are already configured in `lib/core/services/supabase_service.dart`:
- URL: `https://cchvvapkchrqqleznxvr.supabase.co`
- Using the anon key (public, rate-limited)

## 📱 Building for Release

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```
