import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../invoice_detail/data/models/invoice_detail_model.dart';
import '../../../invoice_detail/data/models/sale_amounts.dart';
import '../../../invoice_detail/presentation/widgets/invoice_detail_status_badge.dart';

/// Read-only summary of the invoice being edited: bill no, date, status,
/// and the original payable / paid amounts for comparison.
class EditSaleInvoiceBanner extends StatelessWidget {
  final ResultData invoice;

  const EditSaleInvoiceBanner({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sale = invoice.sale;

    return CustomCard(
      accentColor: AppColors.primary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.editSaleEditingLabel,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: AppSizes.fontXs,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  sale.salesBillNo,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  sale.salesDate,
                  style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontXs),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InvoiceDetailStatusBadge(sale: sale),
              const SizedBox(height: AppSizes.xs),
              Text(
                '${AppStrings.editSaleOriginalTotalLabel}: '
                    '${CurrencyFormatter.format(sale.totalPayableAmountValue)}',
                style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontXs),
              ),
              Text(
                '${AppStrings.editSaleOriginalPaidLabel}: '
                    '${CurrencyFormatter.format(sale.paidAmountValue)}',
                style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontXs),
              ),
            ],
          ),
        ],
      ),
    );
  }
}