import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Auth State Manager - Manages authentication state throughout the app
class AuthManager extends ChangeNotifier {
  static AuthManager? _instance;
  
  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;
  
  AuthManager._() {
    // Listen to auth state changes
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      if (_currentUser != null) {
        _loadProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
    
    // Initialize with current user
    _currentUser = SupabaseService.instance.currentUser;
    if (_currentUser != null) {
      _loadProfile();
    }
  }
  
  static AuthManager get instance {
    _instance ??= AuthManager._();
    return _instance!;
  }
  
  // Getters
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String get userEmail => _currentUser?.email ?? '';
  String get userId => _currentUser?.id ?? '';
  String get userName => _userProfile?['full_name'] ?? _currentUser?.userMetadata?['full_name'] ?? 'Guest';
  String get userInitials {
    final name = userName;
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
  
  /// Load user profile from database
  Future<void> _loadProfile() async {
    if (_currentUser == null) return;
    
    try {
      _userProfile = await SupabaseService.instance.getProfile(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }
  
  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await SupabaseService.instance.signInWithEmail(email, password);
      _currentUser = response.user;
      if (_currentUser != null) {
        await _loadProfile();
      }
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _error = e.toString().replaceAll('AuthException: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Sign up with email and password
  Future<bool> signUpWithEmail(String email, String password, {String? fullName}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await SupabaseService.instance.signUpWithEmail(
        email, 
        password,
        fullName: fullName,
      );
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('AuthException: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Sign in with NFC tag
  Future<bool> signInWithNfc(String nfcTagId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Look up profile by NFC tag ID
      final profile = await SupabaseService.instance.getProfileByNfc(nfcTagId);
      
      if (profile == null) {
        _error = 'NFC card not registered. Please link your card in settings.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // For NFC login, we need to use a different approach
      // Since Supabase requires email/password, we'll need a custom token or admin API
      // For now, we'll store the profile and show that NFC was detected
      _userProfile = profile;
      _error = 'NFC detected! Please complete login with email.';
      _isLoading = false;
      notifyListeners();
      return false; // Return false since we can't fully authenticate with just NFC
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await SupabaseService.instance.signOut();
      _currentUser = null;
      _userProfile = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await SupabaseService.instance.updateProfile(_currentUser!.id, data);
      await _loadProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
