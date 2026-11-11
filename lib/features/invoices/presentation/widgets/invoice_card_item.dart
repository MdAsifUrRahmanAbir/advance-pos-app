import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/dashed_divider.dart';
import '../../data/model/invoices_model.dart';
import '../states/invoice_blocked_action.dart';
import 'invoice_item_menu.dart';

/// Invoice list card:
///
///   Customer name            #BILL-NO  ⋮
///   08 Nov 2026 at 2:30 PM
///   - - - - - - - - - - - - - - - - - -
///   Total Amount                  5,220
///
/// Tapping the card opens the invoice detail. Bill Preview, Edit and
/// Delete live in the ⋮ menu; Edit / Delete are hidden when the server
/// lists them in `blocked_actions`, and its `blocked_reason` is shown.
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
    final blockedNotice = _blockedNotice;
    final customer = invoice.customerName.trim().isEmpty
        ? AppStrings.editSaleWalkInCustomer
        : invoice.customerName;

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.xs,
        AppSizes.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer · bill no · menu
          Row(
            children: [
              Expanded(
                child: Text(
                  customer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                AppStrings.invoiceBillNoTag(invoice.salesBillNo),
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
              InvoiceItemMenu(
                onBillPreview: onBillPreview,
                onEdit: _isEditBlocked ? null : onEdit,
                onDelete: _isDeleteBlocked ? null : onDelete,
              ),
            ],
          ),

          // Date and time
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: Text(
              DateFormatter.displayDateTime(invoice.salesDate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                color: colors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: AppSizes.md),
          const Padding(
            padding: EdgeInsets.only(right: AppSizes.sm),
            child: DashedDivider(),
          ),
          const SizedBox(height: AppSizes.md),

          // Total
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.invoiceTotalAmountLabel,
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(
                    parseAmount(invoice.totalPayableAmount),
                  ),
                  style: TextStyle(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Why Edit / Delete are missing from the menu
          if (blockedNotice != null) ...[
            const SizedBox(height: AppSizes.sm),
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: AppSizes.iconSm,
                    color: colors.textHint,
                  ),
                  const SizedBox(width: AppSizes.xs),
                  Expanded(
                    child: Text(
                      blockedNotice,
                      style: TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: colors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}