import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/model/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_format.dart';
import 'sales_bill_dashed_divider.dart';

/// SL · ITEM · RATE · QNT · AMOUNT table. Item name with "(barcode)" below.
class SalesBillItemsSection extends StatelessWidget {
  final List<ProductRowDatum> rows;

  const SalesBillItemsSection({super.key, required this.rows});

  // Column proportions of the 58/80 mm receipt table — flagged, no tokens.
  static const int _slFlex = 2;
  static const int _itemFlex = 8;
  static const int _rateFlex = 5;
  static const int _qtyFlex = 3;
  static const int _amountFlex = 6;

  /// Smaller than AppSizes.fontXs for the "(BDT)" hint — flagged.
  static const double _fontTiny = 8;

  @override
  Widget build(BuildContext context) {
    const bold = TextStyle(fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SalesBillDashedDivider(),
        _TableRow(
          sl: const Text(AppStrings.billColSl, style: bold),
          item: const Text(
            AppStrings.billColItem,
            textAlign: TextAlign.center,
            style: bold,
          ),
          rate: const Text(
            AppStrings.billColRate,
            textAlign: TextAlign.end,
            style: bold,
          ),
          qty: const Text(
            AppStrings.billColQty,
            textAlign: TextAlign.center,
            style: bold,
          ),
          amount: Text.rich(
            const TextSpan(
              text: AppStrings.billColAmount,
              children: [
                TextSpan(
                  text: AppStrings.billColCurrency,
                  style: TextStyle(fontSize: _fontTiny),
                ),
              ],
            ),
            textAlign: TextAlign.end,
            style: bold,
          ),
        ),
        const SalesBillDashedDivider(),
        for (final (index, row) in rows.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
            child: _TableRow(
              sl: Text('${index + 1}.'),
              item: Text(
                SalesBillPreviewFormat.isPresent(row.prodBarcode)
                    ? '${row.productName}\n(${row.prodBarcode})'
                    : row.productName,
              ),
              rate: Text(
                SalesBillPreviewFormat.amount(row.unitPrice),
                textAlign: TextAlign.end,
              ),
              qty: Text(
                SalesBillPreviewFormat.quantity(row.quantity),
                textAlign: TextAlign.center,
              ),
              amount: Text(
                SalesBillPreviewFormat.amount(row.totalSalesPrice),
                textAlign: TextAlign.end,
              ),
            ),
          ),
        const SalesBillDashedDivider(),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final Widget sl;
  final Widget item;
  final Widget rate;
  final Widget qty;
  final Widget amount;

  const _TableRow({
    required this.sl,
    required this.item,
    required this.rate,
    required this.qty,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: SalesBillItemsSection._slFlex, child: sl),
        Expanded(flex: SalesBillItemsSection._itemFlex, child: item),
        Expanded(flex: SalesBillItemsSection._rateFlex, child: rate),
        Expanded(flex: SalesBillItemsSection._qtyFlex, child: qty),
        Expanded(flex: SalesBillItemsSection._amountFlex, child: amount),
      ],
    );
  }
}