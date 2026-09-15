import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/invoice_detail_model.dart';
import '../../data/models/sale_amounts.dart';
import 'invoice_detail_status_badge.dart';

/// Full "Cash Sale Information" summary built from the real [ResultData]
/// payload. Every field is shown, even when empty/zero, so this reads
/// as a complete record rather than a conditionally-trimmed view —
/// matches the exhaustive layout of a printed sales report.
class InvoiceInfoCard extends StatelessWidget {
  final ResultData resultData;

  const InvoiceInfoCard({super.key, required this.resultData});

  static const _placeholder = '-';

  @override
  Widget build(BuildContext context) {
    final sale = resultData.sale;
    final paymentSystemNames = resultData.payment.paymentSystems.map((p) => p.name).join(', ');
    final paymentAccountNames = resultData.payment.paymentAccounts.map((a) => a.name).join(', ');
    final mobile = resultData.customerMobile?.toString();
    final collection = resultData.payment.collection;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.invoiceInfoSectionTitle,
                style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
              ),
              InvoiceDetailStatusBadge(sale: sale, compact: false),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          _row(context, AppStrings.invoiceBillNoLabel, sale.salesBillNo),
          _row(context, AppStrings.invoiceCustomerLabel, resultData.customerName.isEmpty ? 'Walk-in Customer' : resultData.customerName),
          _row(context, AppStrings.invoiceMobileLabel, (mobile == null || mobile.isEmpty) ? _placeholder : mobile),
          _row(context, AppStrings.invoiceSalesByLabel, resultData.salesBy.isEmpty ? _placeholder : resultData.salesBy),
          _row(context, AppStrings.invoiceDateLabel, sale.salesDate),
          _row(context, 'Reference No.', resultData.referenceNo.isEmpty ? _placeholder : resultData.referenceNo),
          _row(context, AppStrings.invoicePaymentSystemLabel, paymentSystemNames.isEmpty ? _placeholder : paymentSystemNames),
          _row(context, AppStrings.invoicePaymentAccountLabel, paymentAccountNames.isEmpty ? _placeholder : paymentAccountNames),
          _row(context, AppStrings.invoiceRemarksLabel, resultData.remarks.isEmpty ? _placeholder : resultData.remarks),
          const SizedBox(height: AppSizes.sm),
          Divider(color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          _amountRow(context, AppStrings.invoiceSubtotalLabel, sale.totalAmountValue),
          _amountRow(context, '${AppStrings.invoiceDiscountLabel} (${sale.discountRate}%)', sale.discountAmountValue, negative: sale.discountAmountValue > 0),
          _amountRow(context, 'T/A After Discount', sale.taAfterDiscountValue),
          _amountRow(context, '${AppStrings.invoiceVatLabel} (${sale.vatRate}%)', sale.vatAmountValue),
          _amountRow(context, 'Delivery Charge', sale.deliveryChargeValue),
          Divider(color: context.appColors.divider),
          _amountRow(context, AppStrings.invoiceTotalPayableLabel, sale.totalPayableAmountValue, bold: true),
          _amountRow(context, AppStrings.invoicePaidLabel, sale.paidAmountValue, color: AppColors.success),
          _amountRow(context, AppStrings.invoiceDueLabel, sale.amountDue, color: sale.amountDue > 0 ? AppColors.error : null),
          const SizedBox(height: AppSizes.sm),
          Divider(color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Payment Breakdown',
            style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700, color: context.appColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.xs),
          if (collection.isEmpty)
            Text(_placeholder, style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary))
          else
            for (final entry in collection) _amountRow(context, entry.paymentSystemName, entry.amount.toDouble()),
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
            width: 130,
            child: Text(label, style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600, color: context.appColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(BuildContext context, String label, double value, {bool bold = false, bool negative = false, Color? color}) {
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
            '${negative ? '- ' : ''}${CurrencyFormatter.format(value, symbol: '৳')}',
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