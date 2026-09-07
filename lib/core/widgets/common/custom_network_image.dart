import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../utility/custom_shimmer.dart';

class CustomNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const CustomNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.radiusMd);
    return ClipRRect(
      borderRadius: radius,
      child: ColoredBox(
        color: backgroundColor ?? AppColors.shimmerBase,
        child: CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: (_, _) =>
          placeholder ?? CustomShimmer(height: height ?? AppSizes.xxl, width: width),
          errorWidget: (_, _, _) => errorWidget ??
              const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textHint)),
        ),
      ),
    );
  }
}