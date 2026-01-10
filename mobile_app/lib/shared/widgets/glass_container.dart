import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Performance-optimized Glass Container
/// Uses conditional blur based on blur intensity to save GPU cycles
/// Provides smooth touch feedback with scale animation
class GlassContainer extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool enableBlur; // Toggle blur for performance
  final Color? backgroundColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 5.0, // Reduced default blur
    this.opacity = 0.08,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 20.0,
    this.onTap,
    this.enableBlur = true,
    this.backgroundColor,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? 
               Colors.white.withOpacity(widget.opacity),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: AppColors.glassBorder.withOpacity(0.08),
          width: 0.5,
        ),
      ),
      child: widget.child,
    );

    // Only apply blur if enabled and blur > 0
    final Widget blurredContainer = widget.enableBlur && widget.blur > 0
        ? ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: RepaintBoundary( // Isolation for performance
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: container,
              ),
            ),
          )
        : container;

    if (widget.onTap == null) {
      return blurredContainer;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: blurredContainer,
      ),
    );
  }
}

/// Lightweight version without blur for maximum performance
class SolidContainer extends StatelessWidget {
  final Widget child;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? color;

  const SolidContainer({
    super.key,
    required this.child,
    this.opacity = 0.08,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 20.0,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 0.5,
        ),
      ),
      child: child,
    );

    if (onTap == null) return container;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        child: container,
      ),
    );
  }
}
