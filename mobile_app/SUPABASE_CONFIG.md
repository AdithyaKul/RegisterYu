# Supabase Configuration for Mobile App
# 
# ⚠️ IMPORTANT: Replace the placeholder values in supabase_service.dart with your actual Supabase credentials!
#
# STEPS TO CONFIGURE:
# 1. Go to your Supabase project dashboard: https://app.supabase.com
# 2. Navigate to Settings > API
# 3. Copy your Project URL and anon/public key
# 4. Update mobile_app/lib/core/services/supabase_service.dart with these values:
#
#    static Future<void> initialize() async {
#      await Supabase.initialize(
#        url: 'https://YOUR_PROJECT_ID.supabase.co',  // <-- Replace this
#        anonKey: 'YOUR_ANON_KEY_HERE',               // <-- Replace this
#      );
#    }
#
# GOOGLE SIGN-IN CONFIGURATION (Optional):
# 1. Enable Google provider in Supabase Dashboard > Authentication > Providers
# 2. For Android: Add SHA-1 fingerprint to Firebase/Google Cloud Console
# 3. For iOS: Configure URL schemes in Info.plist
#
# RAZORPAY CONFIGURATION (For Payments):
# 1. Get your API keys from https://dashboard.razorpay.com/
# 2. Update event_detail_screen.dart with your test/live key:
#    'key': 'rzp_test_YOUR_KEY_HERE'
#
# DATABASE SCHEMA:
# Make sure your Supabase database has these tables (as defined in backend/schema.sql):
# - profiles (id, email, full_name, avatar_url, role, college_id, phone, nfc_tag_id, etc.)
# - events (id, title, description, date, location, category, price_amount, etc.)
# - registrations (id, event_id, user_id, ticket_code, status, payment_id, etc.)
