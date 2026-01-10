import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // TODO: Replace with your actual Supabase keys
    // If you don't have them yet, the app will launch but login will fail.
    await Supabase.initialize(
      url: 'https://cchvvapkchrqqleznxvr.supabase.co', // Dummy valid-looking URL to pass regex if any
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNjaHZ2YXBrY2hycXFsZXpueHZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4ODQ3MzgsImV4cCI6MjA4MzQ2MDczOH0.kirmDxY_01dx_qMTi25quoHt4l5-J8HfaWF8CZ0OpLQ', // Dummy JWT format
    );
  } catch (e) {
    debugPrint('Supabase init failed: $e');
  }

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RegisterYu Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.iosTheme,
      home: const LoginPage(),
    );
  }
}
