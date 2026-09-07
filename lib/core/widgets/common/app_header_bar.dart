import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';

enum HeaderBackStyle { none, chevron, circle }

/// Single flexible header for left-aligned-title screens — list
/// pages, detail pages, modal-edit screens. Optional subtitle,
/// optional back button (none / inline chevron / bordered circle),
/// and an optional trailing action (icon button or text link, not
/// both). Replaces what used to be three separate widgets.
///
/// For a *centered* title with a square bordered back button, use
/// [CustomAppBar] instead — together these two cover all app-bar needs.
class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final HeaderBackStyle backStyle;
  final VoidCallback? onBackTap;
  final IconData? trailingIcon;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  /// Overrides the trailing text link's color (defaults to
  /// [AppColors.primary]). Use for destructive actions like "Clear All" /
  /// "Delete" — pass [AppColors.error]. Has no effect on [trailingIcon].
  final Color? trailingLabelColor;

  const AppHeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.backStyle = HeaderBackStyle.none,
    this.onBackTap,
    this.trailingIcon,
    this.trailingLabel,
    this.onTrailingTap,
    this.trailingLabelColor,
  }) : assert(trailingIcon == null || trailingLabel == null,
  'Provide trailingIcon OR trailingLabel, not both');

  Widget? _buildBack(BuildContext context) {
    final tap = onBackTap ?? () => Navigator.of(context).maybePop();
    switch (backStyle) {
      case HeaderBackStyle.none:
        return null;
      case HeaderBackStyle.chevron:
        return InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          onTap: tap,
          child: Container(
            padding: EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              border: Border.all(
                color: AppColors.borderDark.withValues(alpha: .6),
                width: .1
              )
            ),
            child: Icon(Icons.arrow_back_rounded, size: AppSizes.iconSm, color: AppColors.textPrimary),
          ),
        );
      case HeaderBackStyle.circle:
        return InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          onTap: tap,
          child: Container(
            width: AppSizes.xl + AppSizes.xs,
            height: AppSizes.xl + AppSizes.xs,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.appColors.surface,
              // border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconSm, color: AppColors.textPrimary),
          ),
        );
    }
  }

  Widget? _buildTrailing() {
    if (trailingIcon != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        onTap: onTrailingTap,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
          child: Icon(trailingIcon, size: AppSizes.iconSm, color: AppColors.primary),
        ),
      );
    }
    if (trailingLabel != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        onTap: onTrailingTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xs),
          child: Text(
            trailingLabel!,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: trailingLabelColor ?? AppColors.primary,
            ),
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final back = _buildBack(context);
    final trailing = _buildTrailing();

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        // border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (back != null) ...[back, const SizedBox(width: AppSizes.md)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontSize: AppSizes.fontXl, fontWeight: FontWeight.w700, color: context.appColors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSizes.xs / 2),
                  Text(subtitle!, style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary)),
                ]else ...[
                  SizedBox(height: AppSizes.xs,)
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? AppSizes.appBarHeight : AppSizes.appBarHeight + AppSizes.lg);
}