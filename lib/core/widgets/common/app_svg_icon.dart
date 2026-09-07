import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Renders an SVG icon from an asset or a network URL.
///
/// Two modes:
/// - Tinted (default): every path is recolored with [color] (falls back to
///   [AppColors.textPrimary]) — use for monochrome/outline icon sets.
/// - [multicolor] = true: the SVG's own fill colors are preserved untouched
///   — use for brand marks, flags, illustrations.
class AppSvgIcon extends StatelessWidget {
  final String assetPath;
  final String? networkUrl;
  final double size;
  final double? width;
  final double? height;
  final Color? color;
  final bool multicolor;
  final BoxFit fit;
  final Widget? placeholder;

  const AppSvgIcon({
    super.key,
    required this.assetPath,
    this.size = AppSizes.iconMd,
    this.width,
    this.height,
    this.color,
    this.multicolor = false,
    this.fit = BoxFit.contain,
    this.placeholder,
  }) : networkUrl = null;

  const AppSvgIcon.network({
    super.key,
    required String url,
    this.size = AppSizes.iconMd,
    this.width,
    this.height,
    this.color,
    this.multicolor = false,
    this.fit = BoxFit.contain,
    this.placeholder,
  })  : networkUrl = url,
        assetPath = '';

  @override
  Widget build(BuildContext context) {
    final ColorFilter? colorFilter = multicolor
        ? null
        : ColorFilter.mode(color ?? AppColors.textPrimary, BlendMode.srcIn);

    final fallback = placeholder ??
        SizedBox(width: width ?? size, height: height ?? size);

    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return SvgPicture.network(
        networkUrl!,
        width: width ?? size,
        height: height ?? size,
        fit: fit,
        colorFilter: colorFilter,
        placeholderBuilder: (_) => fallback,
      );
    }

    return SvgPicture.asset(
      assetPath,
      width: width ?? size,
      height: height ?? size,
      fit: fit,
      colorFilter: colorFilter,
      placeholderBuilder: (_) => fallback,
    );
  }
}