import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibration/vibration.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue == null) continue;
      
      final String code = barcode.rawValue!;
      // Assume code is the UUID of the registration or the ticket_code
      // For now, let's assume it's the raw UUID for simplicity, or handle both.
      
      _isProcessing = true;
      try {
        await Vibration.vibrate(duration: 50); // Haptic feedback
        
        await _verifyTicket(code);
        
      } catch (e) {
        _showResultDialog(false, 'Error: ${e.toString()}');
      } finally {
        // Wait a bit before scanning again
         await Future.delayed(const Duration(seconds: 2));
        _isProcessing = false;
      }
      break; // Process only one code
    }
  }

  Future<void> _verifyTicket(String code) async {
    final supabase = Supabase.instance.client;
    
    // Check if valid UUID
    final bool isUuid = code.length == 36; // UUID v4 length
    
    final Map<String, dynamic>? data = await supabase
        .from('registrations')
        .select('*, events(title), profiles(full_name, email)')
        .eq(isUuid ? 'id' : 'ticket_code', code)
        .maybeSingle();

    if (data == null) {
      _showResultDialog(false, 'Ticket Not Found');
      return;
    }

    final String status = data['status'];
    final String eventName = data['events']['title'];
    final String userName = data['profiles']['full_name'] ?? 'Unknown User';

    if (status == 'checked_in') {
      _showResultDialog(false, 'ALREADY USED\n$userName\n$eventName', isWarning: true);
    } else if (status == 'cancelled') {
        _showResultDialog(false, 'TICKET CANCELLED');
    } else {
      // Check in
      await supabase
          .from('registrations')
          .update({'status': 'checked_in', 'check_in_time': DateTime.now().toIso8601String()})
          .eq('id', data['id']);
          
      _showResultDialog(true, 'WELCOME!\n$userName\n$eventName');
    }
  }

  void _showResultDialog(bool success, String message, {bool isWarning = false}) {
    Color bgColor = success ? Colors.green : (isWarning ? Colors.orange : Colors.red);
    IconData icon = success ? Icons.check_circle : (isWarning ? Icons.warning : Icons.error);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: bgColor, width: 4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: bgColor),
            const SizedBox(height: 16),
            Text(
              success ? 'Success' : (isWarning ? 'Warning' : 'Invalid'),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: bgColor),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: bgColor),
                child: const Text('Scan Next', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _processBarcode,
        overlayBuilder: (context, constraints) {
          return Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2997FF), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }
}
