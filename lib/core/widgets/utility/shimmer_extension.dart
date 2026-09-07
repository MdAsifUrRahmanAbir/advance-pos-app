import 'package:flutter/material.dart';

import 'package:skeletonizer/skeletonizer.dart';

import '../../constants/app_colors.dart';

extension WidgetSkeletonizer on Widget {
  Widget skeletonizer({required bool enabled}) {
    return Skeletonizer(
      enabled: enabled,
      effect: ShimmerEffect(
        baseColor: AppColors.primary.withValues(alpha: 0.3),
        highlightColor: Colors.white,
        duration: const Duration(seconds: 1),
      ),
      child: this,
    );
  }
}