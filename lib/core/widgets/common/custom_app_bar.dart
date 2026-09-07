import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';

/// App-wide top bar — a bordered square back button on the left, a
/// centered title, and an optional trailing widget (or a matching-size
/// spacer to keep the title truly centered).
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBackTap;
  final Widget? trailing;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBackTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final sideSpacer = const SizedBox(width: AppSizes.xl, height: AppSizes.xl);

    return SizedBox(
      height: preferredSize.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showBack)
              InkWell(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    // border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconSm, color: AppColors.textPrimary),
                ),
              )
            else
              sideSpacer,
            Text(
              title,
              style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600, color: context.appColors.textPrimary),
            ),
            trailing ?? sideSpacer,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);
}