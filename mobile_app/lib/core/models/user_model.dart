/// User/Participant model with all personal data
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String role; // 'student', 'organizer', 'admin'
  
  // Student Details
  final String? collegeId;
  final String? department;
  final String? phoneNumber;
  final String? usn;      // University Seat Number
  final String? semester; // e.g. "5th"
  final String? year;     // e.g. "3rd"
  final String? section;  // e.g. "A"
  
  // System Fields
  final String? nfcTagId; // For NFC card login
  final DateTime createdAt;
  final bool isVerified;
  final String? deviceId; // For duplicate login detection

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.role = 'student',
    this.collegeId,
    this.department,
    this.phoneNumber,
    this.usn,
    this.semester,
    this.year,
    this.section,
    this.nfcTagId,
    required this.createdAt,
    this.isVerified = false,
    this.deviceId,
  });

  /// Create from JSON (for API responses)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'student',
      collegeId: json['college_id'] as String?,
      department: json['department'] as String?,
      phoneNumber: json['phone_number'] as String?,
      usn: json['usn'] as String?,
      semester: json['semester'] as String?,
      year: json['year'] as String?,
      section: json['section'] as String?,
      nfcTagId: json['nfc_tag_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isVerified: json['is_verified'] as bool? ?? false,
      deviceId: json['device_id'] as String?,
    );
  }

  /// Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
      'college_id': collegeId,
      'department': department,
      'phone_number': phoneNumber,
      'usn': usn,
      'semester': semester,
      'year': year,
      'section': section,
      'nfc_tag_id': nfcTagId,
      'created_at': createdAt.toIso8601String(),
      'is_verified': isVerified,
      'device_id': deviceId,
    };
  }

  /// Get initials for avatar
  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}

/// Mock current user for development
final mockCurrentUser = UserModel(
  id: 'user_001',
  email: 'adithya.student@sambhram.edu',
  fullName: 'Adithya Kumar',
  role: 'student',
  collegeId: 'SCE2024001',
  department: 'Computer Science',
  phoneNumber: '+91 98765 43210',
  usn: '1SB20CS001',
  semester: '7th',
  year: '4th',
  section: 'A',
  nfcTagId: 'NFC:A1:B2:C3:D4',
  createdAt: DateTime(2024, 8, 15),
  isVerified: true,
  deviceId: 'device_current',
);
