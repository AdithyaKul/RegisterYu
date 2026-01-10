import 'package:flutter/services.dart';

/// Audio and Haptic feedback service for premium interactions
/// Similar to Samsung Wallet experience
class AudioHapticService {
  static final AudioHapticService _instance = AudioHapticService._internal();
  factory AudioHapticService() => _instance;
  AudioHapticService._internal();

  /// Light tap - for button presses
  static void lightTap() {
    HapticFeedback.lightImpact();
  }

  /// Medium tap - for selections
  static void mediumTap() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy tap - for confirmations and success
  static void heavyTap() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click - for toggles and switches
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for ticket reveal (Samsung Wallet style)
  static Future<void> ticketReveal() async {
    // Pattern: short-pause-medium-pause-light
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 30));
    await HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for successful registration
  static Future<void> successPattern() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Error feedback
  static Future<void> errorPattern() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Scroll tick - for list scrolling feedback
  static void scrollTick() {
    HapticFeedback.selectionClick();
  }
}
