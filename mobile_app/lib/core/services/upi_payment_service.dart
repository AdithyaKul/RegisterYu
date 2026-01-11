/// UPI Payment Service for handling payments
/// Supports direct UPI app redirect for Indian payments
class UpiPaymentService {
  static const String merchantVpa = 'kul.adithya@axl';
  static const String merchantName = 'RegisterYu Events';
  
  /// Generate UPI payment URL for deep linking
  static String generateUpiUrl({
    required double amount,
    required String transactionRef,
    required String eventName,
    String? note,
  }) {
    final description = note ?? 'Registration for $eventName';
    
    // UPI deep link format
    final upiUrl = Uri.encodeFull(
      'upi://pay?pa=$merchantVpa'
      '&pn=$merchantName'
      '&am=${amount.toStringAsFixed(2)}'
      '&cu=INR'
      '&tn=$description'
      '&tr=$transactionRef'
    );
    
    return upiUrl;
  }
  
  /// Generate PhonePe specific URL
  static String generatePhonePeUrl({
    required double amount,
    required String transactionRef,
    required String eventName,
  }) {
    final baseUrl = generateUpiUrl(
      amount: amount,
      transactionRef: transactionRef,
      eventName: eventName,
    );
    
    return baseUrl.replaceFirst('upi://', 'phonepe://');
  }
  
  /// Generate Google Pay specific URL
  static String generateGpayUrl({
    required double amount,
    required String transactionRef,
    required String eventName,
  }) {
    final description = 'Registration for $eventName';
    
    return Uri.encodeFull(
      'tez://upi/pay?pa=$merchantVpa'
      '&pn=$merchantName'
      '&am=${amount.toStringAsFixed(2)}'
      '&cu=INR'
      '&tn=$description'
      '&tr=$transactionRef'
    );
  }
  
  /// Generate Paytm specific URL
  static String generatePaytmUrl({
    required double amount,
    required String transactionRef,
    required String eventName,
  }) {
    final baseUrl = generateUpiUrl(
      amount: amount,
      transactionRef: transactionRef,
      eventName: eventName,
    );
    
    return baseUrl.replaceFirst('upi://', 'paytmmp://');
  }
  
  /// Generate unique transaction reference
  static String generateTransactionRef(String eventId, String oderId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'RYU${eventId}T${timestamp}O$oderId';
  }
  
  /// Mock payment verification (in production, verify with backend)
  static Future<PaymentResult> verifyPayment(String transactionRef) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    // For demo, randomly succeed (in production, check with payment gateway)
    return PaymentResult(
      success: true,
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      message: 'Payment successful',
    );
  }
}

/// Payment result model
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String message;
  final String? errorCode;

  PaymentResult({
    required this.success,
    this.transactionId,
    required this.message,
    this.errorCode,
  });
}

/// Available UPI apps
enum UpiApp {
  generic,
  phonepe,
  gpay,
  paytm,
}

extension UpiAppExtension on UpiApp {
  String get name {
    switch (this) {
      case UpiApp.generic: return 'UPI';
      case UpiApp.phonepe: return 'PhonePe';
      case UpiApp.gpay: return 'Google Pay';
      case UpiApp.paytm: return 'Paytm';
    }
  }
  
  String get icon {
    switch (this) {
      case UpiApp.generic: return '💳';
      case UpiApp.phonepe: return '📱';
      case UpiApp.gpay: return '🔵';
      case UpiApp.paytm: return '🔷';
    }
  }
}
