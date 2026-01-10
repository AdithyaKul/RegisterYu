import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRepository {
  final _supabase = Supabase.instance.client;

  // ==================== EVENTS ====================
  
  /// Get all events
  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final data = await _supabase
          .from('events')
          .select('*')
          .order('date', ascending: false); // Changed from event_date
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }
  
  /// Get active events (upcoming or today)
  Future<List<Map<String, dynamic>>> getActiveEvents() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final data = await _supabase
          .from('events')
          .select('*')
          .gte('date', today) // Changed from event_date
          .order('date', ascending: true);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error fetching active events: $e");
      return [];
    }
  }

  /// Get stats for a specific event
  Future<Map<String, dynamic>> getEventStats(String eventId) async {
    try {
      // Total registrations for this event
      final totalResponse = await _supabase
          .from('registrations')
          .select('id')
          .eq('event_id', eventId)
          .count(CountOption.exact);
      
      // Checked in for this event
      final checkedInResponse = await _supabase
          .from('registrations')
          .select('id')
          .eq('event_id', eventId)
          .eq('status', 'checked_in')
          .count(CountOption.exact);
      
      return {
        'total': totalResponse.count,
        'checked_in': checkedInResponse.count,
        'pending': totalResponse.count - checkedInResponse.count,
      };
    } catch (e) {
      print("Error fetching event stats: $e");
      return {'total': 0, 'checked_in': 0, 'pending': 0};
    }
  }

  // ==================== GLOBAL STATS ====================
  
  /// Get live dashboard stats (all events)
  Future<Map<String, int>> getStats({String? eventId}) async {
    try {
      var totalQuery = _supabase.from('registrations').select('id');
      var checkedInQuery = _supabase.from('registrations').select('id');
      
      if (eventId != null) {
        totalQuery = totalQuery.eq('event_id', eventId);
        checkedInQuery = checkedInQuery.eq('event_id', eventId);
      }
      
      final totalResponse = await totalQuery.count(CountOption.exact);
      final checkedInResponse = await checkedInQuery
          .eq('status', 'checked_in')
          .count(CountOption.exact);
          
      return {
        'total': totalResponse.count,
        'checked_in': checkedInResponse.count,
      };
    } catch (e) {
      print("Err fetching stats: $e");
      return {'total': 0, 'checked_in': 0};
    }
  }

  /// Get recent check-ins stream
  Stream<List<Map<String, dynamic>>> getLiveActivity({String? eventId}) {
    // Note: 'check_in_time' might be null for non-checked-in, but we filter for status=checked_in
    // However, ordering by a nullable column is OK.
    var stream = _supabase
        .from('registrations')
        .stream(primaryKey: ['id'])
        .order('check_in_time', ascending: false) // Changed from updated_at
        .limit(20);
    
    return stream.map((data) {
      var filtered = data.where((row) => row['status'] == 'checked_in');
      if (eventId != null) {
        filtered = filtered.where((row) => row['event_id'] == eventId);
      }
      return filtered.take(10).toList();
    });
  }
  
  // ==================== GUESTS ====================
  
  /// Get Full Guest List (optionally filtered by event)
  Future<List<Map<String, dynamic>>> getGuests({String? eventId, String? query}) async {
    // Fixed column names: phone instead of phone_number, college_id instead of roll_no (assumed)
    var builder = _supabase
        .from('registrations')
        // We select *, then nested profiles. 
        // Note: Relation names must match. 'profiles' is correct.
        // If 'name' in events table is 'title', we should query events(title, name) to be safe or just title.
        .select('*, profiles(full_name, email, phone, college_id), events(title, name)');
    
    if (eventId != null) {
      builder = builder.eq('event_id', eventId);
    }
     
    final data = await builder;
    return List<Map<String, dynamic>>.from(data);
  }

  // ==================== CHECK-IN ====================
  
  /// Check In a User by Ticket ID (Registration UUID) or Ticket Code
  Future<Map<String, dynamic>> checkInUser(String ticketId, {String? eventId}) async {
    try {
      // Support scanning ticket_code (8 chars) OR UUID
      var query = _supabase
          .from('registrations')
          .select('*, profiles(full_name, email), events(title, name)');
          
      if (ticketId.length == 8) {
         query = query.eq('ticket_code', ticketId);
      } else {
         query = query.eq('id', ticketId);
      }

      final check = await query.single();
      
      // Verify event if specified
      if (eventId != null && check['event_id'] != eventId) {
        final evtName = check['events']?['title'] ?? check['events']?['name'] ?? 'Unknown';
        throw "Ticket is for a different event: $evtName";
      }
          
      if (check['status'] == 'checked_in') {
        throw "Already Checked In";
      }

      // Update check_in_time
      await _supabase
          .from('registrations')
          .update({
            'status': 'checked_in', 
            'check_in_time': DateTime.now().toIso8601String() // Changed from updated_at
          })
          .eq('id', check['id']); // Update by UUID for safety
      
      return {
        'success': true,
        'name': check['profiles']?['full_name'] ?? 'Guest',
        'email': check['profiles']?['email'] ?? '',
        'event': check['events']?['title'] ?? check['events']?['name'] ?? '',
      };
    } catch (e) {
      print("Checkin Error: $e");
      rethrow;
    }
  }
  
  /// Validate ticket without checking in (for preview)
  Future<Map<String, dynamic>?> validateTicket(String ticketId) async {
    try {
      var query = _supabase
          .from('registrations')
          .select('*, profiles(full_name, email), events(title, name)');
          
      if (ticketId.length == 8) {
         query = query.eq('ticket_code', ticketId);
      } else {
         query = query.eq('id', ticketId);
      } 
          
      final data = await query.single();
      return data;
    } catch (e) {
      return null;
    }
  }
}
