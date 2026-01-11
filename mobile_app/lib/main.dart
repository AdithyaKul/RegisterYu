import 'dart:ui';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'core/services/auth_manager.dart';
import 'features/events/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';

import 'core/theme/theme_manager.dart';

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager().themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'RegisterYu',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const AuthWrapper(),
          scrollBehavior: const SmoothScrollBehavior(),
        );
      },
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

class SmoothScrollBehavior extends ScrollBehavior {
  const SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Pure BouncingScrollPhysics is usually the "smoothest" feel users want
    // It prevents the hard stops of ClampingPhysics
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

