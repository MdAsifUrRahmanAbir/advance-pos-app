import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/sales_replacement_detail_model.dart' show ResultData;
import '../states/sales_replacement_detail_format.dart';
import 'sales_replacement_detail_rows.dart';

/// "Replacement Information": who, when, bills and payment, then the
/// returned-amount breakdown ending in the payable return amount.
class SalesReplacementInfoCard extends StatelessWidget {
  final ResultData data;

  const SalesReplacementInfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final r = data.resultDataReturn;
    final s = data.replacementSale;
    final rate = r.salesDisRate?.toString().trim() ?? '';
    final discountLabel = rate.isEmpty
        ? AppStrings.invoiceDiscountLabel
        : '${AppStrings.invoiceDiscountLabel} ($rate%)';
    final hasDiscount = SalesReplacementDetailFormat.isPositive(
      r.returnDisAmount,
    );

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.repdInfoSectionTitle,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          SalesReplacementInfoRow(
            label: AppStrings.srdReturnBillNoLabel,
            value: r.returnBillNo,
          ),
          SalesReplacementInfoRow(
            label: AppStrings.srdReturnDateLabel,
            value: r.returnDate,
          ),
          SalesReplacementInfoRow(
            label: AppStrings.srdSalesBillNoLabel,
            value: r.originalSalesBillNo,
          ),
          SalesReplacementInfoRow(
            label: AppStrings.repdReplacementBillLabel,
            value: s.salesBillNo,
          ),
          SalesReplacementInfoRow(
            label: AppStrings.repdReplacementDateLabel,
            value: s.salesDate,
          ),
          SalesReplacementInfoRow(
            label: AppStrings.invoiceCustomerLabel,
            value: data.customerName,
          ),
          if (data.customerMobile.isNotEmpty)
            SalesReplacementInfoRow(
              label: AppStrings.invoiceMobileLabel,
              value: data.customerMobile,
            ),
          SalesReplacementInfoRow(
            label: AppStrings.srdReturnByLabel,
            value: data.returnBy,
          ),
          SalesReplacementInfoRow(
            label: AppStrings.invoicePaymentSystemLabel,
            value: SalesReplacementDetailFormat.names(
              s.paymentSystems.map((e) => e.name),
            ),
          ),
          SalesReplacementInfoRow(
            label: AppStrings.invoicePaymentAccountLabel,
            value: SalesReplacementDetailFormat.names(
              s.paymentAccounts.map((e) => e.name),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Divider(color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          SalesReplacementAmountRow(
            label: AppStrings.srdTotalReturnAmountLabel,
            value: SalesReplacementDetailFormat.money(r.totalReturnAmount),
          ),
          SalesReplacementAmountRow(
            label: discountLabel,
            value:
            '${hasDiscount ? '- ' : ''}${SalesReplacementDetailFormat.money(r.returnDisAmount)}',
            color: hasDiscount ? AppColors.warning : null,
          ),
          SalesReplacementAmountRow(
            label: AppStrings.srdAfterDiscountLabel,
            value: SalesReplacementDetailFormat.money(r.taAfterDiscount),
          ),
          Divider(color: context.appColors.divider),
          SalesReplacementAmountRow(
            label: AppStrings.srdPayableLabel,
            value: SalesReplacementDetailFormat.money(r.payableReturnAmount),
            bold: true,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}