import 'package:flutter/material.dart';
import 'package:template_test/core/constants/app_colors.dart';
import 'package:template_test/core/constants/app_sizes.dart';

import '../../theme/app_color_scheme.dart';

class CustomLoader extends StatelessWidget {
  final double? size;
  final Color? color;
  final String? label;
  final bool overlay;

  const CustomLoader({super.key, this.size, this.color, this.label, this.overlay = false});

  @override
  Widget build(BuildContext context) {
    final loader = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size ?? AppSizes.iconLg,
          height: size ?? AppSizes.iconLg,
          child: CircularProgressIndicator(
            strokeWidth: AppSizes.xs / 2,
            color: color ?? AppColors.primary,
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: AppSizes.md),
          Text(label!, style: TextStyle(color: context.appColors.textSecondary, fontSize: AppSizes.fontSm)),
        ],
      ],
    );
    return overlay
        ? ColoredBox(color: AppColors.background.withValues(alpha: 0.72), child: Center(child: loader))
        : Center(child: loader);
  }
}
