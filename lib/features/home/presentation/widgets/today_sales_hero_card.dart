import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../states/dashboard_format.dart';
import '../states/home_state.dart';

/// Brand-gradient hero: today's sales amount, orders · items, and a
/// tilted calendar tile with today's date.
class TodaySalesHeroCard extends StatelessWidget {
  final OverviewData data;
  final DateTime date;

  const TodaySalesHeroCard({super.key, required this.data, required this.date});

  /// FLAG: no alpha / decoration tokens.
  static const double _mutedAlpha = 0.8;
  static const double _decorAlpha = 0.08;
  static const double _decorSize = 160;
  static const double _tileTilt = 0.06; // radians

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textWhite.withValues(alpha: _mutedAlpha);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              right: -_decorSize / 3,
              top: -_decorSize / 3,
              child: _DecorCircle(size: _decorSize, alpha: _decorAlpha),
            ),
            const Positioned(
              left: -_decorSize / 4,
              bottom: -_decorSize / 2,
              child: _DecorCircle(size: _decorSize, alpha: _decorAlpha),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.homeTodaySales,
                          style: TextStyle(
                            color: muted,
                            fontSize: AppSizes.fontSm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            DashboardFormat.money(data.amount),
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: AppSizes.fontDisplay,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          AppStrings.homeSalesMeta(data.orders, data.items),
                          style: TextStyle(color: muted, fontSize: AppSizes.fontSm),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Transform.rotate(
                    angle: _tileTilt,
                    child: _DateTile(date: date),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double alpha;

  const _DecorCircle({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textWhite.withValues(alpha: alpha),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final DateTime date;

  const _DateTile({required this.date});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.weekdayShortNames[date.weekday - 1],
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${date.day}',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: AppSizes.fontDisplay,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            AppStrings.homeMonthYear(
              AppStrings.monthShortNames[date.month - 1],
              date.year,
            ),
            style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontXs),
          ),
        ],
      ),
    );
  }
}