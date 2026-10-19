import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';

enum SalesReplacementMenuAction { edit, delete }

/// Vertical three-dot menu for a sales replacement row: Edit and Delete.
/// Shows a small spinner in place of the dots while [isBusy].
class SalesReplacementItemMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isBusy;

  const SalesReplacementItemMenu({
    super.key,
    this.onEdit,
    this.onDelete,
    this.isBusy = false,
  });

  static const double _spinnerStroke = 2; // no AppSizes token for stroke

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return const SizedBox.square(
        dimension: kMinInteractiveDimension,
        child: Center(
          child: SizedBox.square(
            dimension: AppSizes.iconSm,
            child: CircularProgressIndicator(
              strokeWidth: _spinnerStroke,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return PopupMenuButton<SalesReplacementMenuAction>(
      tooltip: AppStrings.moreOptions,
      enabled: onEdit != null || onDelete != null,
      color: context.appColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      icon: Icon(
        Icons.more_vert_rounded,
        size: AppSizes.iconMd,
        color: context.appColors.textSecondary,
      ),
      onSelected: (action) {
        switch (action) {
          case SalesReplacementMenuAction.edit:
            onEdit?.call();
          case SalesReplacementMenuAction.delete:
            onDelete?.call();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: SalesReplacementMenuAction.edit,
          child: _MenuRow(
            icon: Icons.edit_outlined,
            label: AppStrings.edit,
            color: context.appColors.textPrimary,
          ),
        ),
        const PopupMenuItem(
          value: SalesReplacementMenuAction.delete,
          child: _MenuRow(
            icon: Icons.delete_outline_rounded,
            label: AppStrings.delete,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm, color: color),
        const SizedBox(width: AppSizes.sm),
        Text(
          label,
          style: TextStyle(color: color, fontSize: AppSizes.fontSm),
        ),
      ],
    );
  }
}