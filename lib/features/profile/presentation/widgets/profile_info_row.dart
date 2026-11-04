import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';

/// Read-only row for a [SettingsGroup]: leading icon, label on the left,
/// value on the right. A missing value shows [AppStrings.emptyValue].
class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = value?.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + AppSizes.xs,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSm, color: colors.textSecondary),
          const SizedBox(width: AppSizes.sm + AppSizes.xs),
          Text(
            label,
            style: TextStyle(fontSize: AppSizes.fontSm, color: colors.textSecondary),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              (text == null || text.isEmpty) ? AppStrings.emptyValue : text,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
