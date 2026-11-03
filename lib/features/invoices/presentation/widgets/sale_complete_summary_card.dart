import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../data/model/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_format.dart';

/// Bill summary from `GET /sales/invoice`: bill no and date, then
/// subtotal, discount, VAT, total, paid and change. Discount, VAT and
/// change rows are hidden when zero.
class SaleCompleteSummaryCard extends StatelessWidget {
  final SalesBillPreviewModel bill;

  const SaleCompleteSummaryCard({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = bill.summary;
    final discount = SalesBillPreviewFormat.number(s.discountAmount);
    final vat = SalesBillPreviewFormat.number(s.vatAmount);
    final change = s.changedAmount;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.billLabel,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: AppSizes.fontXs,
                      ),
                    ),
                    Text(
                      bill.invoice.salesBillNo,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                bill.invoice.date,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: AppSizes.fontXs,
                ),
              ),
            ],
          ),
          Divider(height: AppSizes.lg, color: colors.divider),
          _Row(
            label: AppStrings.subtotalLabel,
            value: SalesBillPreviewFormat.amount(s.totalAmount),
          ),
          if (discount != 0)
            _Row(
              label: AppStrings.invoiceDiscountLabel,
              value: '- ${SalesBillPreviewFormat.grouped(discount.abs())}',
            ),
          if (vat != 0)
            _Row(
              label: AppStrings.invoiceVatLabel,
              value: SalesBillPreviewFormat.grouped(vat),
            ),
          Divider(height: AppSizes.md, color: colors.divider),
          _Row(
            label: AppStrings.totalLabel,
            value: SalesBillPreviewFormat.amount(s.grandTotal),
            emphasized: true,
          ),
          _Row(
            label: AppStrings.invoicePaidLabel,
            value: SalesBillPreviewFormat.amount(s.givenAmount),
          ),
          if (change > 0)
            _Row(
              label: AppStrings.change,
              value: SalesBillPreviewFormat.grouped(change),
              valueColor: AppColors.success,
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;
  final Color? valueColor;

  const _Row({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final weight = emphasized ? FontWeight.w800 : FontWeight.w500;
    final size = emphasized ? AppSizes.fontLg : AppSizes.fontSm;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasized ? colors.textPrimary : colors.textSecondary,
                fontSize: size,
                fontWeight: weight,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ??
                  (emphasized ? AppColors.primary : colors.textPrimary),
              fontSize: size,
              fontWeight: weight,
            ),
          ),
        ],
      ),
    );
  }
}
