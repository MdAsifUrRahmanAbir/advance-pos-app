import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';

enum InvoiceMenuAction { edit, delete }

/// Vertical three-dot menu on an invoice card: Edit and Delete.
///
/// An item whose callback is null is hidden. When both are null the
/// menu renders nothing.
class InvoiceItemMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InvoiceItemMenu({super.key, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) return const SizedBox.shrink();

    final colors = context.appColors;

    return PopupMenuButton<InvoiceMenuAction>(
      tooltip: AppStrings.moreOptions,
      color: colors.surface,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      icon: Icon(
        Icons.more_vert_rounded,
        size: AppSizes.iconMd,
        color: colors.textSecondary,
      ),
      onSelected: (action) {
        switch (action) {
          case InvoiceMenuAction.edit:
            onEdit?.call();
          case InvoiceMenuAction.delete:
            onDelete?.call();
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          PopupMenuItem(
            value: InvoiceMenuAction.edit,
            child: _MenuRow(
              icon: Icons.edit_outlined,
              label: AppStrings.edit,
              color: colors.textPrimary,
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: InvoiceMenuAction.delete,
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

  const _MenuRow({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm, color: color),
        const SizedBox(width: AppSizes.sm),
        Text(label, style: TextStyle(color: color, fontSize: AppSizes.fontSm)),
      ],
    );
  }
}