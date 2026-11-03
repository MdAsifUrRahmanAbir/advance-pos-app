import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// White thermal-paper surface for the Bill Preview. Everything inside the
/// RepaintBoundary ([boundaryKey]) is what gets captured and printed, so the
/// paper is always white with dark text, in light and dark mode.
class SalesBillPaper extends StatelessWidget {
  final GlobalKey boundaryKey;
  final List<Widget> children;

  const SalesBillPaper({
    super.key,
    required this.boundaryKey,
    required this.children,
  });

  /// Logical width of a thermal roll; scaled to the printer's dot width on
  /// print. No AppSizes token fits — flagged.
  static const double _paperWidth = 320;

  /// Tight receipt line height. No AppSizes token — flagged.
  static const double _lineHeight = 1.3;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: RepaintBoundary(
          key: boundaryKey,
          child: Container(
            width: _paperWidth,
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm + AppSizes.xs,
              vertical: AppSizes.md,
            ),
            child: DefaultTextStyle(
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontXs,
                height: _lineHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}