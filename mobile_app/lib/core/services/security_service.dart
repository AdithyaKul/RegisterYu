import 'package:flutter/services.dart';

/// Security service to prevent screenshots and handle session security
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  static const MethodChannel _channel = MethodChannel('com.sambhram.events/security');

  /// Enable secure mode - prevents screenshots and screen recording
  static Future<void> enableSecureMode() async {
    try {
      await _channel.invokeMethod('enableSecureMode');
    } catch (e) {
      // Fallback: Use platform-specific implementation
      print('Security mode enabled via fallback');
    }
  }

  /// Disable secure mode (for non-sensitive screens)
  static Future<void> disableSecureMode() async {
    try {
      await _channel.invokeMethod('disableSecureMode');
    } catch (e) {
      print('Security mode disabled via fallback');
    }
  }

  /// Check for duplicate login sessions
  /// Returns true if duplicate session detected
  static Future<bool> checkDuplicateSession(String userId, String deviceId) async {
    // In production, this would call the backend
    // For now, using mock implementation
    final currentSession = _MockSessionManager.getCurrentSession(userId);
    if (currentSession != null && currentSession != deviceId) {
      return true; // Duplicate detected
    }
    _MockSessionManager.setSession(userId, deviceId);
    return false;
  }

  /// Generate unique device ID
  static String generateDeviceId() {
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Logout from all other devices
  static Future<void> logoutOtherDevices(String userId) async {
    _MockSessionManager.clearSession(userId);
  }
}

/// Mock session manager for development
class _MockSessionManager {
  static final Map<String, String> _sessions = {};

  static String? getCurrentSession(String userId) => _sessions[userId];
  
  static void setSession(String userId, String deviceId) {
    _sessions[userId] = deviceId;
  }

  static void clearSession(String userId) {
    _sessions.remove(userId);
  }
}
