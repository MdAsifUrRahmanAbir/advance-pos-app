import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';

/// Bordered, subtly-shadowed card container — the base surface for
/// grouped content (forms, dashboard tiles, list items). Pass
/// [accentColor] to draw a colored strip down the left edge (status/
/// category indicator); pass [tinted] to wash the whole card in that
/// color instead of white.
class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? accentColor;
  final bool tinted;
  final bool fullWidth;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSizes.lg),
    this.accentColor,
    this.tinted = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = tinted ? AppColors.primaryLight : context.appColors.surface;

    final content = Container(
      width: fullWidth ? double.infinity : double.maxFinite,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        // border: Border.all(color: AppColors.border),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppColors.textPrimary.withValues(alpha: 0.02),
        //     blurRadius: AppSizes.md,
        //     offset: const Offset(0, AppSizes.xs),
        //   ),
        // ],
      ),
      child: child,
    );

    final withAccent = accentColor == null
        ? content
        : ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: AppSizes.xs / 2 + 2, color: accentColor),
            Expanded(child: content),
          ],
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: withAccent,
      ),
    );
  }
}