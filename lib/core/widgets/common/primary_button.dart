import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Primary filled call-to-action button — the main action on a screen
/// (Sign In, Save, Checkout...).
///
/// Defaults to [AppColors.primary]. Pass [backgroundColor] to override for
/// screens where the primary action carries different semantic weight
/// (e.g. a green "Complete Sale" confirming a successful transaction).
/// Foreground stays [AppColors.textWhite] regardless — only the fill color
/// is overridable, so button contrast/legibility stays consistent app-wide.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final double? width;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.width,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onPressed == null;
    final fillColor = backgroundColor ?? AppColors.primary;

    return SizedBox(
      width: width ?? double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: fillColor,
          foregroundColor: AppColors.textWhite,
          disabledBackgroundColor: fillColor.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: loading
            ? const SizedBox(
                height: AppSizes.iconMd,
                width: AppSizes.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textWhite,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppSizes.iconSm),
                    const SizedBox(width: AppSizes.sm),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}
