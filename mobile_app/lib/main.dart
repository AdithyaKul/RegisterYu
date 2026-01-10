import 'dart:ui';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/events/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';

import 'core/theme/theme_manager.dart';

void main() {
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
          home: const LoginScreen(),
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.trackpad},
            physics: const FastScrollPhysics(),
          ),
        );
      },
    );
  }
}

class FastScrollPhysics extends BouncingScrollPhysics {
  const FastScrollPhysics({super.parent});

  @override
  FastScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Increase sensitivity: multiply user drag distance by 1.5
    return super.applyPhysicsToUserOffset(position, offset * 1.5);
  }
}
