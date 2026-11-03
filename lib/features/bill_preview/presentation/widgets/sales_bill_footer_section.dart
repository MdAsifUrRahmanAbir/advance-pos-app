import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/html_text.dart';
import '../../data/models/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_format.dart';
import 'sales_bill_dashed_divider.dart';

/// Bill no + Code128 barcode, "Thank You For Shopping.", optional return
/// days, terms and conditions (HTML from the server), then "System By".
class SalesBillFooterSection extends StatelessWidget {
  final String billNo;
  final Config config;

  const SalesBillFooterSection({
    super.key,
    required this.billNo,
    required this.config,
  });

  /// Barcode width on the paper — no AppSizes token fits, flagged.
  static const double _barcodeWidth = 240;

  /// Smaller than AppSizes.fontXs, like the printed bill — flagged.
  static const double _fontTiny = 8;

  @override
  Widget build(BuildContext context) {
    final returnDays = SalesBillPreviewFormat.text(config.returnDayTime);
    // Terms arrive as HTML: <strong> stays bold, <br> / </p> break lines.
    final terms = HtmlText.toSpans(
      SalesBillPreviewFormat.text(config.termsAndConditions),
    );
    const tiny = TextStyle(fontSize: _fontTiny);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A barcode can't be drawn from an empty bill no — skip both.
        if (SalesBillPreviewFormat.isPresent(billNo)) ...[
          const SizedBox(height: AppSizes.xs),
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
          AppStrings.billThankYou,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        // TODO: confirm return_day_time is a number of days with the backend.
        if (returnDays != null)
          Text(
            AppStrings.billReturnWithinDays(returnDays),
            textAlign: TextAlign.center,
            style: tiny,
          ),
        if (terms.isNotEmpty) ...[
          const SalesBillDashedDivider(),
          Text.rich(TextSpan(children: terms), style: tiny),
        ],
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