import 'package:flutter/material.dart';
import 'package:template_test/core/constants/app_colors.dart';

import '../../theme/app_color_scheme.dart';

class CustomRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final ScrollPhysics? physics;

  const CustomRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      backgroundColor: context.appColors.surface,
      // physics: physics ?? const AlwaysScrollableScrollPhysics(),
      child: child,
    );
  }
}
