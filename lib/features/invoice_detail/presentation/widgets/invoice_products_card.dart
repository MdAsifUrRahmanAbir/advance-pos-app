import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/invoice_detail_model.dart';
import '../../data/models/sale_amounts.dart';

class InvoiceProductsCard extends StatelessWidget {
  final ResultData resultData;

  const InvoiceProductsCard({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final sale = resultData.sale;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.invoiceProductsSectionTitle,
            style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          for (final line in resultData.saleDetails) ...[
            _LineRow(line: line),
            const SizedBox(height: AppSizes.sm),
          ],
          Divider(color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.invoiceTotalQuantityLabel}: ${sale.totalQuantityValue}',
                style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
              ),
              Text(
                '${AppStrings.invoiceTotalAmountLabel}: ${CurrencyFormatter.format(sale.totalAmountValue, symbol: '৳')}',
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
  final SaleDetail line;

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
                line.productName,
                style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600, color: context.appColors.textPrimary),
              ),
              const SizedBox(height: AppSizes.xs / 2),
              Text(
                '${AppStrings.invoiceBarcodeLabel}: ${line.productBarcode.isEmpty ? '-' : line.productBarcode}',
                style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textHint),
              ),
              const SizedBox(height: AppSizes.xs / 2),
              Text(
                'Unit Price: ${CurrencyFormatter.format(line.unitPriceValue, symbol: '৳')}  •  Discount: ${line.disRate}% (- ${CurrencyFormatter.format(line.disAmountValue, symbol: '৳')})',
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: line.disRateValue > 0 ? AppColors.warning : context.appColors.textHint,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 40,
          child: Text('×${line.quantityValue}', textAlign: TextAlign.center, style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary)),
        ),
        SizedBox(
          width: 90,
          child: Text(
            CurrencyFormatter.format(line.totalPrice.toDouble(), symbol: '৳'),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
          ),
        ),
      ],
    );
  }
}