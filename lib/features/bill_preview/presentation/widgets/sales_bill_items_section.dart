import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../data/models/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_format.dart';
import 'sales_bill_dashed_divider.dart';

/// SL · ITEM · RATE · QNT · AMOUNT table, like the web bill: headers
/// centered, "Name (barcode)" on one wrapping line, rate and qty
/// centered, amount right, a dotted line under the header and every row.
class SalesBillItemsSection extends StatelessWidget {
  final List<ProductRowDatum> rows;

  const SalesBillItemsSection({super.key, required this.rows});

  // Column widths of the web bill (7 / 33 / 20 / 10 / 30 %) — flagged.
  static const int _slFlex = 7;
  static const int _itemFlex = 33;
  static const int _rateFlex = 20;
  static const int _qtyFlex = 10;
  static const int _amountFlex = 30;

  /// Smaller than AppSizes.fontXs for the "(BDT)" hint — flagged.
  static const double _fontTiny = 8;

  @override
  Widget build(BuildContext context) {
    const bold = TextStyle(fontWeight: FontWeight.w700);
    const medium = TextStyle(fontWeight: FontWeight.w500);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SalesBillDashedDivider(),
        _TableRow(
          sl: const Text(AppStrings.billColSl, textAlign: TextAlign.center, style: bold),
          item: const Text(AppStrings.billColItem, textAlign: TextAlign.center, style: bold),
          rate: const Text(AppStrings.billColRate, textAlign: TextAlign.center, style: bold),
          qty: const Text(AppStrings.billColQty, textAlign: TextAlign.center, style: bold),
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
            textAlign: TextAlign.center,
            style: bold,
          ),
        ),
        const SalesBillDashedDivider(),
        for (final (index, row) in rows.indexed) ...[
          _TableRow(
            sl: Text('${index + 1}.', textAlign: TextAlign.center),
            item: Text(
              SalesBillPreviewFormat.withDetail(row.productName, row.prodBarcode),
              style: medium,
            ),
            rate: Text(
              SalesBillPreviewFormat.amount(row.unitPrice),
              textAlign: TextAlign.center,
            ),
            qty: Text(
              SalesBillPreviewFormat.quantity(row.quantity),
              textAlign: TextAlign.center,
            ),
            amount: Text(
              SalesBillPreviewFormat.amount(row.totalSalesPrice),
              textAlign: TextAlign.end,
              style: medium,
            ),
          ),
          const SalesBillDashedDivider(),
        ],
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
