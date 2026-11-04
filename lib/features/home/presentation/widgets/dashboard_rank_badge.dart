import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Round rank number for ranked lists. The top three are filled so the
/// leaders stand out; the rest stay tinted.
class DashboardRankBadge extends StatelessWidget {
  final int rank;

  const DashboardRankBadge({super.key, required this.rank});

  /// Badge size and tint — no AppSizes / AppColors token fits, flagged.
  static const double _size = 26;
  static const double _tintAlpha = 0.1;
  static const int _highlightUpTo = 3;

  @override
  Widget build(BuildContext context) {
    final isTop = rank <= _highlightUpTo;
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isTop
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: _tintAlpha),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          color: isTop ? AppColors.textWhite : AppColors.primary,
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
