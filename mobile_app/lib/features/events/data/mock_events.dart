/// Event model that maps to our Supabase events table
class Event {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String imageUrl;
  final DateTime date;
  final String location;
  final double priceAmount;
  final String priceCurrency;
  final int capacity;
  final String status;
  final String? organizerId;
  final DateTime createdAt;
  
  // Computed property for display
  String get price => priceAmount == 0 ? 'Free' : '₹${priceAmount.toInt()}';
  
  // Formatted date for display
  String get formattedDate {
    final now = DateTime.now();
    final diff = date.difference(now);
    
    if (diff.inDays == 0) {
      return 'Today • ${_formatTime(date)}';
    } else if (diff.inDays == 1) {
      return 'Tomorrow • ${_formatTime(date)}';
    } else {
      return '${_formatMonth(date.month)} ${date.day} • ${_formatTime(date)}';
    }
  }
  
  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }
  
  String _formatMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.imageUrl,
    required this.date,
    required this.location,
    required this.priceAmount,
    this.priceCurrency = 'INR',
    required this.capacity,
    required this.status,
    this.organizerId,
    required this.createdAt,
  });

  /// Create Event from Supabase JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Event',
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'Event',
      imageUrl: json['image_url'] as String? ?? 
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&q=80',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      location: json['location'] as String? ?? 'TBA',
      priceAmount: (json['price_amount'] as num?)?.toDouble() ?? 0,
      priceCurrency: json['price_currency'] as String? ?? 'INR',
      capacity: json['capacity'] as int? ?? 100,
      status: json['status'] as String? ?? 'published',
      organizerId: json['organizer_id'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'image_url': imageUrl,
      'date': date.toIso8601String(),
      'location': location,
      'price_amount': priceAmount,
      'price_currency': priceCurrency,
      'capacity': capacity,
      'status': status,
      'organizer_id': organizerId,
    };
  }
}

/// Mock events for fallback/testing when Supabase is unavailable
final List<Event> mockEvents = [
  Event(
    id: '1',
    title: 'HackHorizon 2024',
    description: 'Annual 24-hour hackathon with amazing prizes!',
    category: 'Hackathon',
    imageUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&q=80',
    date: DateTime.now().add(const Duration(days: 7)),
    location: 'Main Block Auditorium',
    priceAmount: 0,
    capacity: 200,
    status: 'published',
    createdAt: DateTime.now(),
  ),
  Event(
    id: '2',
    title: 'AI & The Future',
    description: 'Explore the cutting edge of artificial intelligence.',
    category: 'Seminar',
    imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800&q=80',
    date: DateTime.now().add(const Duration(days: 14)),
    location: 'Seminar Hall 2',
    priceAmount: 150,
    capacity: 100,
    status: 'published',
    createdAt: DateTime.now(),
  ),
  Event(
    id: '3',
    title: 'Cloud Native Summit',
    description: 'Learn about Kubernetes, Docker, and cloud architecture.',
    category: 'Workshop',
    imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&q=80',
    date: DateTime.now().add(const Duration(days: 21)),
    location: 'CS Department Lab',
    priceAmount: 300,
    capacity: 50,
    status: 'published',
    createdAt: DateTime.now(),
  ),
  Event(
    id: '4',
    title: 'Design Thinking Lab',
    description: 'Hands-on workshop for creative problem solving.',
    category: 'Workshop',
    imageUrl: 'https://images.unsplash.com/photo-1558655146-9f40138edfeb?w=800&q=80',
    date: DateTime.now().add(const Duration(days: 28)),
    location: 'Innovation Hub',
    priceAmount: 200,
    capacity: 30,
    status: 'published',
    createdAt: DateTime.now(),
  ),
];
