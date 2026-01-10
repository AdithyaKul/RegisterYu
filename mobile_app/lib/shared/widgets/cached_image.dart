import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

/// Optimized cached network image with shimmer loading
class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _ShimmerPlaceholder(
          width: width,
          height: height,
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: AppColors.surfaceCharcoal,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textSecondary,
            size: 32,
          ),
        ),
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;

  const _ShimmerPlaceholder({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceCharcoal,
      highlightColor: Colors.grey[800]!,
      child: Container(
        width: width,
        height: height,
        color: AppColors.surfaceCharcoal,
      ),
    );
  }
}

/// Shimmer loading skeleton for cards
class ShimmerCard extends StatelessWidget {
  final double height;
  final double borderRadius;

  const ShimmerCard({
    super.key,
    this.height = 250,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceCharcoal,
      highlightColor: Colors.grey[850]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceCharcoal,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
