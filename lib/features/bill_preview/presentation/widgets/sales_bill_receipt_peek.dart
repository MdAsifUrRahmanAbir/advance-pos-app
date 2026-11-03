import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../data/models/sales_bill_preview_model.dart';
import 'sales_bill_receipt.dart';

/// Card showing the top of the thermal receipt with a fade, tappable to
/// open the full Bill Preview. The whole receipt is still laid out and
/// painted (only clipped), so [boundaryKey] captures the full paper for
/// print / share.
class SalesBillReceiptPeek extends StatelessWidget {
  final SalesBillPreviewModel bill;
  final DateTime? printedAt;
  final GlobalKey boundaryKey;
  final VoidCallback? onViewFull;

  const SalesBillReceiptPeek({
    super.key,
    required this.bill,
    required this.printedAt,
    required this.boundaryKey,
    required this.onViewFull,
  });

  /// Visible receipt height before the fade — no AppSizes token, flagged.
  static const double _peekHeight = 200;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.background,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onViewFull,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: AppSizes.iconSm,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: AppSizes.xs),
                  Expanded(
                    child: Text(
                      AppStrings.billPreviewTitle,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    AppStrings.saleDoneViewFullBill,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: AppSizes.iconSm,
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              SizedBox(
                height: _peekHeight,
                child: Stack(
                  children: [
                    ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topCenter,
                        minHeight: 0,
                        maxHeight: double.infinity,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SalesBillReceipt(
                            bill: bill,
                            printedAt: printedAt,
                            boundaryKey: boundaryKey,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [_fadeStart, 1],
                              colors: [
                                colors.background.withValues(alpha: 0),
                                colors.background,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Where the bottom fade begins (fraction of the peek) — flagged.
  static const double _fadeStart = 0.55;
}
