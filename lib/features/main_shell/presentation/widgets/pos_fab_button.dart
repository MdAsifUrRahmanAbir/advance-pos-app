import 'package:advance_pos_app/core/constants/app_assets.dart';
import 'package:advance_pos_app/core/theme/app_color_scheme.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';

/// Circular POS/Sales trigger, handed to `Scaffold.floatingActionButton`
/// with `FloatingActionButtonLocation.centerDocked` so Flutter positions
/// it centered and exactly half-overlapping the top edge of
/// [MainShellBottomNav] — no manual offset math needed.
class PosFabButton extends StatelessWidget {
  final VoidCallback? onTap;

  const PosFabButton({super.key, this.onTap});

  static const double diameter = AppSizes.xxl - AppSizes.sm; // 44

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: diameter + 10,
        height: diameter + 10,
        decoration: BoxDecoration(
          color: context.appColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: context.appColors.primary.withValues(alpha: 0.45),
              blurRadius: AppSizes.lg,
              offset: const Offset(0, AppSizes.sm),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: AppSvgIcon(
          // svgString: AppSvgs.plus,
          size: AppSizes.iconMd,
          color: AppColors.textWhite,
          assetPath: AppAssets.posSale,
        ),
      ),
    );
  }
}
