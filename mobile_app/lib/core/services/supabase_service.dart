import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Supabase Service - Central point for all Supabase operations
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient get client => Supabase.instance.client;
  
  SupabaseService._();
  
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }
  
  /// Initialize Supabase - Call this in main.dart before runApp
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://cchvvapkchrqqleznxvr.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNjaHZ2YXBrY2hycXFsZXpueHZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4ODQ3MzgsImV4cCI6MjA4MzQ2MDczOH0.kirmDxY_01dx_qMTi25quoHt4l5-J8HfaWF8CZ0OpLQ',
      debug: kDebugMode,
    );
  }
  
  // ==================== AUTH ====================
  
  /// Get current user
  User? get currentUser => client.auth.currentUser;
  
  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;
  
  /// Get current session
  Session? get currentSession => client.auth.currentSession;
  
  /// Auth state changes stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail(String email, String password, {String? fullName}) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }
  
  /// Sign in with Google (requires additional setup)
  /// This method is a placeholder - OAuth requires platform configuration
  Future<void> signInWithGoogle() async {
    throw UnimplementedError('Google Sign-In requires Firebase/Google Cloud setup');
  }
  
  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }
  
  // ==================== PROFILES ====================
  
  /// Get user profile
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }
  
  /// Update user profile
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await client.from('profiles').upsert({
      'id': userId,
      ...data,
    });
  }
  
  /// Get profile by NFC tag
  Future<Map<String, dynamic>?> getProfileByNfc(String nfcTagId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('nfc_tag_id', nfcTagId)
        .maybeSingle();
    return response;
  }
  
  // ==================== EVENTS ====================
  
  /// Get all published events
  Future<List<Map<String, dynamic>>> getEvents({String? category}) async {
    var query = client.from('events').select().eq('status', 'published');
    
    if (category != null && category != 'All') {
      query = query.eq('category', category);
    }
    
    final response = await query.order('date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// Get single event by ID
  Future<Map<String, dynamic>?> getEvent(String eventId) async {
    final response = await client
        .from('events')
        .select()
        .eq('id', eventId)
        .maybeSingle();
    return response;
  }
  
  /// Get event registration count
  Future<int> getEventRegistrationCount(String eventId) async {
    final response = await client
        .from('registrations')
        .select('id')
        .eq('event_id', eventId);
    return (response as List).length;
  }
  
  /// Search events
  Future<List<Map<String, dynamic>>> searchEvents(String query) async {
    final response = await client
        .from('events')
        .select()
        .eq('status', 'published')
        .or('title.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%')
        .order('date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }
  
  // ==================== REGISTRATIONS ====================
  
  /// Register for an event
  Future<Map<String, dynamic>> registerForEvent({
    required String eventId,
    required String userId,
    String? paymentId,
  }) async {
    final response = await client.from('registrations').insert({
      'event_id': eventId,
      'user_id': userId,
      'status': 'active',
      'payment_id': paymentId,
    }).select().single();
    return response;
  }
  
  /// Get user's registrations (tickets)
  Future<List<Map<String, dynamic>>> getUserRegistrations(String userId) async {
    final response = await client
        .from('registrations')
        .select('*, events(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// Get registration by ticket code
  Future<Map<String, dynamic>?> getRegistrationByTicketCode(String ticketCode) async {
    final response = await client
        .from('registrations')
        .select('*, events(*), profiles(*)')
        .eq('ticket_code', ticketCode)
        .maybeSingle();
    return response;
  }
  
  /// Check if user is registered for event
  Future<bool> isUserRegistered(String eventId, String userId) async {
    final response = await client
        .from('registrations')
        .select('id')
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .maybeSingle();
    return response != null;
  }
  
  /// Get user stats (attended, upcoming, etc)
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final registrations = await getUserRegistrations(userId);
    
    int attended = 0;
    int upcoming = 0;
    double totalSaved = 0;
    
    final now = DateTime.now();
    
    for (var reg in registrations) {
      final event = reg['events'];
      if (event != null) {
        final eventDate = DateTime.tryParse(event['date'] ?? '');
        if (reg['status'] == 'checked_in') {
          attended++;
        } else if (eventDate != null && eventDate.isAfter(now)) {
          upcoming++;
        }
        // Calculate savings (if event was free or discounted)
        if (event['price_amount'] == 0) {
          totalSaved += 50; // Assume ₹50 value for free events
        }
      }
    }
    
    return {
      'total': registrations.length,
      'attended': attended,
      'upcoming': upcoming,
      'saved': totalSaved,
    };
  }
}
