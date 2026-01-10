import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:admin_app/core/theme/app_colors.dart';
import 'package:admin_app/core/data/admin_repository.dart';
import 'package:vibration/vibration.dart';

class ScannerScreen extends StatefulWidget {
  final String? eventId;
  final String? eventName;
  
  const ScannerScreen({
    super.key,
    this.eventId,
    this.eventName,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  
  final _repository = AdminRepository();
  bool _isProcessing = false;
  bool _flashEnabled = false;
  List<Map<String, dynamic>> _scanHistory = []; // Store more info
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _manualEntry() async {
    HapticFeedback.mediumImpact();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => const _ManualEntryDialog(),
    );
    if (code != null && code.isNotEmpty) {
      _handleCode(code);
    }
  }

  void _showHistory() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _HistorySheet(history: _scanHistory),
    );
  }

  Future<void> _handleCode(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }
      
      // Check in with optional event validation
      final result = await _repository.checkInUser(code, eventId: widget.eventId);
      
      setState(() {
        _scanHistory.insert(0, {
          'id': code,
          'name': result['name'] ?? 'Guest',
          'time': DateTime.now().toIso8601String(),
        });
        if (_scanHistory.length > 20) _scanHistory.removeLast();
      });

      if (mounted) {
        _showStatusSheet(
          context, 
          true, 
          result['name'] ?? 'Guest', 
          code,
          subtitle: result['email'],
        );
      }
    } catch (e) {
      if (mounted) {
        _showStatusSheet(context, false, e.toString().replaceAll("Exception: ", ""), code);
      }
    } finally {
       await Future.delayed(const Duration(seconds: 2));
       if (mounted) setState(() => _isProcessing = false);
    }
  }
  
  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null) return;
    _handleCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Feed
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          
          // Premium Overlay with Animated Corners - IgnorePointer to not block scanner
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: PremiumScannerOverlay(
                    borderColor: _isProcessing 
                      ? AppColors.warning 
                      : Color.lerp(
                          Colors.white.withOpacity(0.6), 
                          Colors.white, 
                          _pulseAnimation.value
                        )!,
                    glowIntensity: _pulseAnimation.value,
                    cutOutSize: 280,
                  ),
                );
              },
            ),
          ),
          
          // Top Section
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  _GlassButton(
                    icon: Icons.close_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                  ),
                  
                  // Session Counter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, 
                          color: AppColors.success, 
                          size: 18
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${_scanHistory.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Title Section
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  widget.eventName != null 
                    ? "Scanning for" 
                    : "Scan QR Code",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                if (widget.eventName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.eventName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(
                    "Point at a code to scan",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 15,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Bottom Glass Control Panel
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _PremiumControlButton(
                        icon: _flashEnabled 
                          ? Icons.flash_on_rounded 
                          : Icons.flash_off_rounded,
                        label: "FLASH",
                        isActive: _flashEnabled,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _controller.toggleTorch();
                          setState(() => _flashEnabled = !_flashEnabled);
                        },
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      _PremiumControlButton(
                        icon: Icons.keyboard_alt_outlined,
                        label: "MANUAL",
                        isActive: false,
                        onTap: _manualEntry,
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      _PremiumControlButton(
                        icon: Icons.history_rounded,
                        label: "HISTORY",
                        isActive: false,
                        onTap: _showHistory,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusSheet(BuildContext context, bool success, String message, String id, {String? subtitle}) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _StatusSheet(
        success: success,
        message: message,
        id: id,
        subtitle: subtitle,
      ),
    );
  }
}

// Premium Glass Button
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

// Premium Control Button
class _PremiumControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PremiumControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive 
                  ? Colors.white.withOpacity(0.25) 
                  : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Status Sheet
class _StatusSheet extends StatelessWidget {
  final bool success;
  final String message;
  final String id;
  final String? subtitle;

  const _StatusSheet({
    required this.success,
    required this.message,
    required this.id,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: success 
              ? AppColors.success.withOpacity(0.3) 
              : AppColors.error.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (success ? AppColors.success : AppColors.error).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              success ? Icons.check_rounded : Icons.close_rounded,
              color: success ? AppColors.success : AppColors.error,
              size: 44,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            success ? "Verified!" : "Error",
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: success ? AppColors.textSecondary : AppColors.error,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              id,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontFamily: 'Courier',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: success ? AppColors.success : AppColors.surfaceSecondary,
                foregroundColor: success ? Colors.black : AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Scan Next",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Manual Entry Dialog
class _ManualEntryDialog extends StatefulWidget {
  const _ManualEntryDialog();

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Manual Entry",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter the ticket ID manually",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _textController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: "TKT-XXXXX",
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary,
                      letterSpacing: 2,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, 
                      vertical: 16
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(
                          context, 
                          _textController.text.trim()
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Check In",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// History Sheet
class _HistorySheet extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _HistorySheet({required this.history});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    const Text(
                      "Recent Scans",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${history.length} items",
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No scans yet",
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        final name = item['name'] ?? 'Guest';
                        final id = item['id'] ?? '';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.success,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      id,
                                      style: TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 12,
                                        fontFamily: 'Courier',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "#${history.length - index}",
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Premium Scanner Overlay Painter
class PremiumScannerOverlay extends CustomPainter {
  final Color borderColor;
  final double glowIntensity;
  final double cutOutSize;

  PremiumScannerOverlay({
    required this.borderColor,
    required this.glowIntensity,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    
    final double left = (size.width - cutOutSize) / 2;
    final double top = (size.height - cutOutSize) / 2;
    final double right = left + cutOutSize;
    final double bottom = top + cutOutSize;
    final double radius = 24;
    final double cornerLength = 50;
    final double strokeWidth = 4;

    // Dark overlay
    final Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.75);
    final Path overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, cutOutSize, cutOutSize),
          Radius.circular(radius),
        ),
      )
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlayPath, overlayPaint);

    // Glow effect
    if (glowIntensity > 0) {
      final Paint glowPaint = Paint()
        ..color = borderColor.withOpacity(0.3 * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left - 5, top - 5, cutOutSize + 10, cutOutSize + 10),
          Radius.circular(radius + 5),
        ),
        glowPaint,
      );
    }

    // Corner strokes
    final Paint cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path cornerPath = Path();

    // Top Left
    cornerPath.moveTo(left, top + cornerLength);
    cornerPath.lineTo(left, top + radius);
    cornerPath.quadraticBezierTo(left, top, left + radius, top);
    cornerPath.lineTo(left + cornerLength, top);

    // Top Right
    cornerPath.moveTo(right - cornerLength, top);
    cornerPath.lineTo(right - radius, top);
    cornerPath.quadraticBezierTo(right, top, right, top + radius);
    cornerPath.lineTo(right, top + cornerLength);

    // Bottom Right
    cornerPath.moveTo(right, bottom - cornerLength);
    cornerPath.lineTo(right, bottom - radius);
    cornerPath.quadraticBezierTo(right, bottom, right - radius, bottom);
    cornerPath.lineTo(right - cornerLength, bottom);

    // Bottom Left
    cornerPath.moveTo(left + cornerLength, bottom);
    cornerPath.lineTo(left + radius, bottom);
    cornerPath.quadraticBezierTo(left, bottom, left, bottom - radius);
    cornerPath.lineTo(left, bottom - cornerLength);

    canvas.drawPath(cornerPath, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant PremiumScannerOverlay oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
