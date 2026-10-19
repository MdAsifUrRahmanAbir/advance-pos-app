import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/sales_return_detail_model.dart';
import '../states/sales_return_detail_format.dart';

/// "Sales Return Information": who, when, payment, remarks, then the
/// amount breakdown ending in the payable return amount.
class SalesReturnInfoCard extends StatelessWidget {
  final SalesReturnDetailData data;

  const SalesReturnInfoCard({super.key, required this.data});

  static const double _labelWidth = 130;

  @override
  Widget build(BuildContext context) {
    final r = data.returnInfo;
    final hasRate =
        r.salesDisRate != null && r.salesDisRate!.trim().isNotEmpty;
    final discountLabel = hasRate
        ? '${AppStrings.invoiceDiscountLabel} (${r.salesDisRate}%)'
        : AppStrings.invoiceDiscountLabel;
    final hasDiscount = SalesReturnDetailFormat.isPositive(r.returnDisAmount);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.srdInfoSectionTitle,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _row(context, AppStrings.srdReturnBillNoLabel, r.returnBillNo),
          _row(context, AppStrings.srdReturnDateLabel, r.returnDate),
          _row(context, AppStrings.srdSalesBillNoLabel, r.salesBillNo),
          _row(context, AppStrings.customerLabel, data.customerName),
          _row(context, AppStrings.srdReturnByLabel, data.returnBy),
          _row(
            context,
            AppStrings.invoicePaymentSystemLabel,
            SalesReturnDetailFormat.names(data.payment.paymentSystems),
          ),
          _row(
            context,
            AppStrings.invoicePaymentAccountLabel,
            SalesReturnDetailFormat.names(data.payment.paymentAccounts),
          ),
          _row(
            context,
            AppStrings.remarksLabel,
            r.remarks.isEmpty ? AppStrings.emptyValue : r.remarks,
          ),
          const SizedBox(height: AppSizes.sm),
          Divider(color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          _amountRow(
            context,
            AppStrings.srdTotalReturnAmountLabel,
            SalesReturnDetailFormat.money(r.totalReturnAmount),
          ),
          _amountRow(
            context,
            discountLabel,
            '${hasDiscount ? '- ' : ''}${SalesReturnDetailFormat.money(r.returnDisAmount)}',
            color: hasDiscount ? AppColors.warning : null,
          ),
          _amountRow(
            context,
            AppStrings.srdAfterDiscountLabel,
            SalesReturnDetailFormat.money(r.taAfterDiscount),
          ),
          Divider(color: context.appColors.divider),
          _amountRow(
            context,
            AppStrings.srdPayableLabel,
            SalesReturnDetailFormat.money(r.payableReturnAmount),
            bold: true,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? AppStrings.emptyValue : value,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(
      BuildContext context,
      String label,
      String value, {
        bool bold = false,
        Color? color,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? AppSizes.fontMd : AppSizes.fontSm,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? context.appColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? AppSizes.fontMd : AppSizes.fontSm,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: color ?? context.appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}