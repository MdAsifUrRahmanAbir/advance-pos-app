import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/html_text.dart';
import '../../data/models/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_format.dart';
import 'sales_bill_dashed_divider.dart';

/// Web bill order: terms and conditions (HTML from the server), bill no +
/// Code128 barcode, "Thank you for shopping.", a dotted line, "System By".
class SalesBillFooterSection extends StatelessWidget {
  final String billNo;
  final Config config;

  const SalesBillFooterSection({
    super.key,
    required this.billNo,
    required this.config,
  });

  /// Barcode width on the paper (web: 80%) — no AppSizes token, flagged.
  static const double _barcodeWidth = 240;

  /// Smaller than AppSizes.fontXs, like the printed bill — flagged.
  static const double _fontTiny = 8;

  @override
  Widget build(BuildContext context) {
    // Terms arrive as HTML: <strong> stays bold, <br> / </p> break lines.
    final terms = HtmlText.toSpans(
      SalesBillPreviewFormat.text(config.termsAndConditions),
    );
    const tiny = TextStyle(fontSize: _fontTiny);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (terms.isNotEmpty) ...[
          const SizedBox(height: AppSizes.xs),
          Text.rich(TextSpan(children: terms)),
        ],
        // A barcode can't be drawn from an empty bill no — skip both.
        if (SalesBillPreviewFormat.isPresent(billNo)) ...[
          const SizedBox(height: AppSizes.sm),
          Text(billNo, textAlign: TextAlign.center, style: tiny),
          const SizedBox(height: AppSizes.xs),
          Center(
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: billNo,
              drawText: false,
              width: _barcodeWidth,
              height: AppSizes.xxl,
              color: AppColors.textPrimary,
              backgroundColor: AppColors.surface,
            ),
          ),
        ],
        const SizedBox(height: AppSizes.sm),
        const Text(
          AppStrings.billThankYouShopping,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: _fontTiny, fontWeight: FontWeight.w700),
        ),
        const SalesBillDashedDivider(),
        const Text(
          AppStrings.billSystemBy,
          textAlign: TextAlign.center,
          style: tiny,
        ),
      ],
    );
  }
}
