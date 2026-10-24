import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/sales_replacement_detail_model.dart' show ResultData;
import '../states/sales_replacement_detail_format.dart';
import 'sales_replacement_detail_rows.dart';

/// "Payment Summary": the replacement sale totals, what is still payable
/// after the return, what the customer gave, change, and the collection
/// split per payment system.
class SalesReplacementPaymentCard extends StatelessWidget {
  final ResultData data;

  const SalesReplacementPaymentCard({super.key, required this.data});

  String _withRate(String label, Object? rate) {
    final text = rate?.toString().trim() ?? '';
    return SalesReplacementDetailFormat.isPositive(text)
        ? '$label ($text%)'
        : label;
  }

  @override
  Widget build(BuildContext context) {
    final s = data.replacementSale;
    final returnAmount = data.resultDataReturn.payableReturnAmount;
    final hasDiscount = SalesReplacementDetailFormat.isPositive(
      s.discountAmount,
    );
    final hasChange = SalesReplacementDetailFormat.isPositive(s.changedAmount);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.repdPaymentSectionTitle,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          SalesReplacementAmountRow(
            label: AppStrings.subtotalLabel,
            value: SalesReplacementDetailFormat.money(s.totalAmount),
          ),
          SalesReplacementAmountRow(
            label: _withRate(AppStrings.invoiceDiscountLabel, s.discountRate),
            value:
            '${hasDiscount ? '- ' : ''}${SalesReplacementDetailFormat.money(s.discountAmount)}',
            color: hasDiscount ? AppColors.warning : null,
          ),
          if (SalesReplacementDetailFormat.isPositive(s.vatAmount))
            SalesReplacementAmountRow(
              label: _withRate(AppStrings.invoiceVatLabel, s.vatRate),
              value: SalesReplacementDetailFormat.money(s.vatAmount),
            ),
          if (SalesReplacementDetailFormat.isPositive(s.deliveryCharge))
            SalesReplacementAmountRow(
              label: AppStrings.dashDeliveryCharge,
              value: SalesReplacementDetailFormat.money(s.deliveryCharge),
            ),
          if (SalesReplacementDetailFormat.isPositive(s.processingFee))
            SalesReplacementAmountRow(
              label: AppStrings.repdProcessingFeeLabel,
              value: SalesReplacementDetailFormat.money(s.processingFee),
            ),
          Divider(color: context.appColors.divider),
          SalesReplacementAmountRow(
            label: AppStrings.repdGrandTotalLabel,
            value: SalesReplacementDetailFormat.money(s.grandTotal),
          ),
          if (SalesReplacementDetailFormat.isPositive(returnAmount))
            SalesReplacementAmountRow(
              label: AppStrings.repdReturnAmountLabel,
              value: '- ${SalesReplacementDetailFormat.money(returnAmount)}',
              color: AppColors.warning,
            ),
          SalesReplacementAmountRow(
            label: AppStrings.repdPayableAfterReturnLabel,
            value: SalesReplacementDetailFormat.money(s.payableAfterReturn),
            bold: true,
            color: AppColors.primary,
          ),
          Divider(color: context.appColors.divider),
          for (final c in s.collection)
            SalesReplacementAmountRow(
              label: c.paymentSystemName,
              value: SalesReplacementDetailFormat.money(c.amount),
            ),
          SalesReplacementAmountRow(
            label: AppStrings.repdGivenAmountLabel,
            value: SalesReplacementDetailFormat.money(s.givenAmount),
          ),
          if (hasChange)
            SalesReplacementAmountRow(
              label: AppStrings.change,
              value: SalesReplacementDetailFormat.money(s.changedAmount),
            ),
          if (s.grandTotalWords.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              s.grandTotalWords,
              style: TextStyle(
                fontSize: AppSizes.fontXs,
                color: context.appColors.textHint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}