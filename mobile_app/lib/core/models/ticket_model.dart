import 'user_model.dart';

/// Ticket model containing all registration and participant data
class TicketModel {
  final String id;
  final String eventId;
  final String eventName;
  final String eventCategory;
  final String eventImageUrl;
  final DateTime eventDate;
  final String eventLocation;
  
  // Participant info (personal, non-shareable)
  final UserModel participant;
  
  // Ticket-specific data
  final String ticketNumber;
  final String ticketTier; // 'early_bird', 'regular', 'vip'
  final double price;
  final String status; // 'pending', 'confirmed', 'cancelled', 'checked_in'
  final String qrCodeData; // Encrypted QR data
  final DateTime purchasedAt;
  final DateTime? checkedInAt;
  final String? paymentId;
  
  // Visual customization
  final List<int> gradientColors;

  const TicketModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.eventCategory,
    required this.eventImageUrl,
    required this.eventDate,
    required this.eventLocation,
    required this.participant,
    required this.ticketNumber,
    this.ticketTier = 'regular',
    this.price = 0,
    this.status = 'confirmed',
    required this.qrCodeData,
    required this.purchasedAt,
    this.checkedInAt,
    this.paymentId,
    this.gradientColors = const [0xFF667EEA, 0xFF764BA2],
  });

  bool get isCheckedIn => status == 'checked_in';
  bool get isActive => status == 'confirmed';
  bool get isPending => status == 'pending';

  /// Generate secure QR data (would be encrypted in production)
  static String generateQrData({
    required String ticketId,
    required String eventId,
    required String participantId,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'RYU:$ticketId:$eventId:$participantId:$timestamp';
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      eventName: json['event_name'] as String,
      eventCategory: json['event_category'] as String,
      eventImageUrl: json['event_image_url'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventLocation: json['event_location'] as String,
      participant: UserModel.fromJson(json['participant'] as Map<String, dynamic>),
      ticketNumber: json['ticket_number'] as String,
      ticketTier: json['ticket_tier'] as String? ?? 'regular',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'confirmed',
      qrCodeData: json['qr_code_data'] as String,
      purchasedAt: DateTime.parse(json['purchased_at'] as String),
      checkedInAt: json['checked_in_at'] != null 
          ? DateTime.parse(json['checked_in_at'] as String) 
          : null,
      paymentId: json['payment_id'] as String?,
      gradientColors: (json['gradient_colors'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? [0xFF667EEA, 0xFF764BA2],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'event_name': eventName,
      'event_category': eventCategory,
      'event_image_url': eventImageUrl,
      'event_date': eventDate.toIso8601String(),
      'event_location': eventLocation,
      'participant': participant.toJson(),
      'ticket_number': ticketNumber,
      'ticket_tier': ticketTier,
      'price': price,
      'status': status,
      'qr_code_data': qrCodeData,
      'purchased_at': purchasedAt.toIso8601String(),
      'checked_in_at': checkedInAt?.toIso8601String(),
      'payment_id': paymentId,
      'gradient_colors': gradientColors,
    };
  }
}

/// Mock tickets for development
final List<TicketModel> mockTickets = [
  TicketModel(
    id: 'ticket_001',
    eventId: '1',
    eventName: 'HackHorizon 2024',
    eventCategory: 'Hackathon',
    eventImageUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&q=80',
    eventDate: DateTime(2024, 10, 14, 9, 0),
    eventLocation: 'Main Block Auditorium',
    participant: mockCurrentUser,
    ticketNumber: 'TKT-2024-HH-001',
    ticketTier: 'early_bird',
    price: 0,
    status: 'confirmed',
    qrCodeData: 'RYU:ticket_001:1:user_001:${DateTime.now().millisecondsSinceEpoch}',
    purchasedAt: DateTime(2024, 10, 1, 14, 30),
    gradientColors: [0xFF667EEA, 0xFF764BA2],
  ),
  TicketModel(
    id: 'ticket_002',
    eventId: '2',
    eventName: 'AI & The Future',
    eventCategory: 'Seminar',
    eventImageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800&q=80',
    eventDate: DateTime(2024, 10, 18, 10, 0),
    eventLocation: 'Seminar Hall 2',
    participant: mockCurrentUser,
    ticketNumber: 'TKT-2024-AI-042',
    ticketTier: 'regular',
    price: 150,
    status: 'confirmed',
    qrCodeData: 'RYU:ticket_002:2:user_001:${DateTime.now().millisecondsSinceEpoch}',
    purchasedAt: DateTime(2024, 10, 5, 11, 15),
    paymentId: 'pay_abc123xyz',
    gradientColors: [0xFFF093FB, 0xFFF5576C],
  ),
];
