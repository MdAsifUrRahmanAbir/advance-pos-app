import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/invoice_detail_model.dart';
import 'invoice_detail_status_badge.dart';

/// Two-column "Cash Sale Information" summary — bill/customer/sales
/// details on the left, payment/amount breakdown on the right.
class InvoiceInfoCard extends StatelessWidget {
  final InvoiceDetailModel invoice;

  const InvoiceInfoCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
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
              InvoiceDetailStatusBadge(status: invoice.status, compact: false),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          _row(context, AppStrings.invoiceBillNoLabel, invoice.invoiceNumber),
          _row(context, AppStrings.invoiceCustomerLabel, invoice.customerName),
          if (invoice.customerMobile != null) _row(context, AppStrings.invoiceMobileLabel, invoice.customerMobile!),
          if (invoice.customerNationalId != null) _row(context, AppStrings.invoiceNationalIdLabel, invoice.customerNationalId!),
          if (invoice.salesBy != null) _row(context, AppStrings.invoiceSalesByLabel, invoice.salesBy!),
          if (invoice.branch != null) _row(context, AppStrings.invoiceBranchLabel, invoice.branch!),
          _row(context, AppStrings.invoiceDateLabel, DateFormatter.format(invoice.date)),
          if (invoice.dueDate != null) _row(context, AppStrings.invoiceDueDateLabel, DateFormatter.format(invoice.dueDate!)),
          if (invoice.vatInvoiceNo != null) _row(context, AppStrings.invoiceVatNoLabel, invoice.vatInvoiceNo!),
          _row(context, AppStrings.invoicePaymentSystemLabel, invoice.paymentSystem),
          _row(context, AppStrings.invoicePaymentAccountLabel, invoice.paymentAccount),
          const SizedBox(height: AppSizes.sm),
          Divider(color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          _amountRow(context, AppStrings.invoiceSubtotalLabel, invoice.subtotal),
          if (invoice.discountPercent > 0)
            _amountRow(context, '${AppStrings.invoiceDiscountLabel} (${invoice.discountPercent.toStringAsFixed(0)}%)', invoice.discountAmount, negative: true),
          if (invoice.vatPercent > 0)
            _amountRow(context, '${AppStrings.invoiceVatLabel} (${invoice.vatPercent.toStringAsFixed(2)}%)', invoice.vatAmount),
          Divider(color: context.appColors.divider),
          _amountRow(context, AppStrings.invoiceTotalPayableLabel, invoice.total, bold: true),
          _amountRow(context, AppStrings.invoicePaidLabel, invoice.amountPaid, color: AppColors.success),
          _amountRow(context, AppStrings.invoiceDueLabel, invoice.amountDue, color: invoice.amountDue > 0 ? AppColors.error : null),
          if (invoice.remarks != null) ...[
            const SizedBox(height: AppSizes.sm),
            _row(context, AppStrings.invoiceRemarksLabel, invoice.remarks!),
          ],
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