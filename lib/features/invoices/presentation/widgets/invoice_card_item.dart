
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/model/invoices_model.dart';
import 'invoice_status_badge.dart';

/// Single invoice card with invoice details and contextual actions.
class InvoiceCardItem extends StatelessWidget {
  final ResultDatum invoice;
  final VoidCallback? onTap;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReturnSale;

  const InvoiceCardItem({
    super.key,
    required this.invoice,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onReturnSale,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final total = parseAmount(invoice.totalPayableAmount);
    final qty = parseQuantity(invoice.totalQuantity);

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.salesBillNo,
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs / 2),
                    Text(
                      invoice.customerName.isEmpty
                          ? 'Walk-in Customer'
                          : invoice.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              InvoiceStatusBadge(invoice: invoice),
            ],
          ),

          // Product summary
          if (invoice.productNames.isNotEmpty) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              invoice.productNames.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppSizes.fontXs,
                color: colors.textHint,
              ),
            ),
          ],

          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          Divider(height: 1, color: colors.divider),
          const SizedBox(height: AppSizes.sm),

          // Invoice metadata and total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.salesDate,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '$qty items',
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: colors.textSecondary,
                ),
              ),
              // const SizedBox(width: AppSizes.sm),
              Flexible(
                child: Text(
                  CurrencyFormatter.format(total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          // Action buttons
          // const SizedBox(height: AppSizes.sm),
          // Divider(height: 1, color: colors.divider),
          const SizedBox(height: AppSizes.md),

          Row(
            children: [
              Expanded(
                child: _InvoiceActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _InvoiceActionButton(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  onPressed: onDelete,
                  foregroundColor: AppColors.error,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _InvoiceActionButton(
                  icon: Icons.assignment_return_outlined,
                  label: 'Return Sale',
                  onPressed: onReturnSale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact, consistent action button with automatic disabled state.
class _InvoiceActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? foregroundColor;

  const _InvoiceActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onPressed != null;
    final color = foregroundColor ?? colors.textSecondary;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 16,
        color: enabled ? color : colors.textHint,
      ),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w600,
          color: enabled ? color : colors.textHint,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 10,
        ),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(
          color: enabled ? colors.divider : colors.divider,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}