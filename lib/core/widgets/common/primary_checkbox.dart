import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';

/// Compact checkbox + label, e.g. "Remember Me", "I agree to the Terms".
/// Sized to sit inline in a Row (unlike a full-width ListTile) —
/// wrap in Expanded/Flexible if placed alongside another widget in a Row.
class PrimaryCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;

  const PrimaryCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: AppSizes.iconMd,
              height: AppSizes.iconMd,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSm / 2)),
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: AppSizes.xs),
              Text(
                label!,
                style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
