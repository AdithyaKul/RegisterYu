import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LiquidBackground extends StatefulWidget {
  final Widget child;
  const LiquidBackground({super.key, required this.child});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Blob 1: Top Left - Blue
  late Animation<Offset> _content1Offset;
  
  // Blob 2: Bottom Right - Purple
  late Animation<Offset> _content2Offset;
  
  // Blob 3: Center/Moving - Violet
  late Animation<Offset> _content3Offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _content1Offset = Tween<Offset>(
      begin: const Offset(-0.2, -0.2),
      end: const Offset(0.2, 0.2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

    _content2Offset = Tween<Offset>(
      begin: const Offset(0.2, 0.2),
      end: const Offset(-0.2, -0.2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

    _content3Offset = Tween<Offset>(
      begin: const Offset(-0.2, 0.2),
      end: const Offset(0.2, -0.2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuad,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Stack(
        children: [
          // --- BLOBS LAYER ---
          // Wrapped in RepaintBoundary to isolate animation repaints
          RepaintBoundary(
            child: Stack(
              children: [
                // Blob 1 (Blue)
                SlideTransition(
                  position: _content1Offset,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accentBlue.withOpacity(0.4), // Lower opacity for blending
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.8], // Softer edge
                        ),
                      ),
                    ),
                  ),
                ),

                // Blob 2 (Purple)
                SlideTransition(
                  position: _content2Offset,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accentPurple.withOpacity(0.4),
                            Colors.transparent,
                          ],
                           stops: const [0.0, 0.8],
                        ),
                      ),
                    ),
                  ),
                ),

                // Blob 3 (Violet Mix)
                SlideTransition(
                  position: _content3Offset,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.deepPurpleAccent.withOpacity(0.3),
                            Colors.transparent,
                          ],
                           stops: const [0.0, 0.8],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- CONTENT LAYER ---
           SizedBox.expand(
             child: widget.child,
           ),
        ],
      ),
    );
  }
}
