import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/info_tip_banner.dart';
import '../../data/model/invoices_model.dart';
import '../states/invoice_blocked_action.dart';
import 'invoice_item_menu.dart';
import 'invoice_status_badge.dart';

/// Single invoice card: bill no, customer, status and a ⋮ menu (Edit /
/// Delete) on top; date, items and total; then a "Bill Preview" action.
///
/// Edit / Delete are hidden when the server lists them in
/// `blocked_actions`; the server's `blocked_reason` is shown instead.
class InvoiceCardItem extends StatelessWidget {
  final ResultDatum invoice;
  final VoidCallback? onTap;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReturnSale;
  final VoidCallback? onBillPreview;

  const InvoiceCardItem({
    super.key,
    required this.invoice,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onReturnSale,
    this.onBillPreview,
  });

  bool get _isEditBlocked =>
      invoice.blockedActions.contains(InvoiceBlockedAction.edit);

  bool get _isDeleteBlocked =>
      invoice.blockedActions.contains(InvoiceBlockedAction.delete);

  /// Reason shown when any action is blocked; falls back to a generic
  /// line if the server sends none.
  String? get _blockedNotice {
    if (invoice.blockedActions.isEmpty) return null;
    final reason = invoice.blockedReason?.trim();
    return (reason == null || reason.isEmpty)
        ? AppStrings.invoiceActionsLockedFallback
        : reason;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final total = parseAmount(invoice.totalPayableAmount);
    final qty = parseQuantity(invoice.totalQuantity);
    final blockedNotice = _blockedNotice;

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                          ? AppStrings.editSaleWalkInCustomer
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
              InvoiceItemMenu(
                onEdit: _isEditBlocked ? null : onEdit,
                onDelete: _isDeleteBlocked ? null : onDelete,
              ),
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
                AppStrings.dashItemsCount(qty),
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: colors.textSecondary,
                ),
              ),
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

          // Why Edit / Delete are unavailable
          if (blockedNotice != null) ...[
            const SizedBox(height: AppSizes.sm),
            InfoTipBanner(
              text: blockedNotice,
              icon: Icons.lock_outline_rounded,
            ),
          ],

          const SizedBox(height: AppSizes.md),

          // Primary action — Edit / Delete live in the ⋮ menu above.
          _InvoiceActionButton(
            icon: Icons.receipt_long_outlined,
            label: AppStrings.billPreviewTitle,
            onPressed: onBillPreview,
            foregroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Compact, full-width outlined action with automatic disabled state.
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

  /// Compact in-card button height (AppSizes.buttonHeight is too tall
  /// inside a list card) — flagged.
  static const double _height = 40;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onPressed != null;
    final color = enabled
        ? (foregroundColor ?? colors.textSecondary)
        : colors.textHint;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: AppSizes.iconSm, color: color),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.xs,
            vertical: AppSizes.sm,
          ),
          minimumSize: const Size(0, _height),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(color: colors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
        ),
      ),
    );
  }
}