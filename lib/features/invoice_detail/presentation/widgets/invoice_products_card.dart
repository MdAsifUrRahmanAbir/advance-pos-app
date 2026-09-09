import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/invoice_detail_model.dart';

class InvoiceProductsCard extends StatelessWidget {
  final InvoiceDetailModel invoice;

  const InvoiceProductsCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.invoiceProductsSectionTitle,
            style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          for (final line in invoice.lineItems) ...[
            _LineRow(line: line),
            const SizedBox(height: AppSizes.sm),
          ],
          Divider(color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.invoiceTotalQuantityLabel}: ${invoice.itemCount}',
                style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
              ),
              Text(
                '${AppStrings.invoiceTotalAmountLabel}: ${CurrencyFormatter.format(invoice.subtotal, symbol: '৳')}',
                style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  final InvoiceDetailLineItem line;

  const _LineRow({required this.line});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.name,
                style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600, color: context.appColors.textPrimary),
              ),
              if (line.serialNo != null) ...[
                const SizedBox(height: AppSizes.xs / 2),
                Text(
                  '${AppStrings.invoiceSerialNoLabel}: ${line.serialNo}',
                  style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textHint),
                ),
              ],
            ],
          ),
        ),
        SizedBox(
          width: 40,
          child: Text('×${line.quantity}', textAlign: TextAlign.center, style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary)),
        ),
        SizedBox(
          width: 90,
          child: Text(
            CurrencyFormatter.format(line.lineTotal, symbol: '৳'),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
          ),
        ),
      ],
    );
  }
}