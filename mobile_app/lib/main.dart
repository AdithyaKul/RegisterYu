import 'dart:ui';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'core/services/auth_manager.dart';
import 'features/events/screens/home_screen.dart';
import 'core/theme/scroll_behavior.dart'; // Imported optimized scroll behavior

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  runApp(const SambhramEventsApp());
}

class SambhramEventsApp extends StatelessWidget {
  const SambhramEventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RegisterYu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Force Dark Theme
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Enforce Dark Mode
      home: const AuthWrapper(),
      scrollBehavior: const SmoothScrollBehavior(),
    );
  }
}

/// AuthWrapper - Shows HomeScreen always (Guest mode supported)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthManager.instance,
      builder: (context, _) {
        // Always show home screen, allowing guest access
        return const HomeScreen();
      },
    );
  }
}

