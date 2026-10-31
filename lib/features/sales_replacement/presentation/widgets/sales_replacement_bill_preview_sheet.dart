import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import '../../../sales_replacement_add/presentation/states/sales_replacement_receipt.dart';
import '../../../sales_replacement_add/presentation/widgets/sales_replacement_receipt_card.dart';

/// "Bill Preview": the replacement's receipt with Share (image) and Print.
/// The callbacks do the work (and show their own messages); the sheet only
/// keeps the buttons disabled while one of them runs.
class SalesReplacementBillPreviewSheet extends StatefulWidget {
  final SalesReplacementReceipt receipt;
  final Future<void> Function(GlobalKey boundaryKey) onShare;
  final Future<void> Function() onPrint;
  final VoidCallback onClose;

  const SalesReplacementBillPreviewSheet({
    super.key,
    required this.receipt,
    required this.onShare,
    required this.onPrint,
    required this.onClose,
  });

  @override
  State<SalesReplacementBillPreviewSheet> createState() =>
      _SalesReplacementBillPreviewSheetState();
}

class _SalesReplacementBillPreviewSheetState
    extends State<SalesReplacementBillPreviewSheet> {
  final _boundaryKey = GlobalKey();
  bool _isSharing = false;
  bool _isPrinting = false;

  Future<void> _share() async {
    setState(() => _isSharing = true);
    try {
      await widget.onShare(_boundaryKey);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _print() async {
    setState(() => _isPrinting = true);
    try {
      await widget.onPrint();
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.lg,
        AppSizes.md,
        AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.repBillPreviewAction,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              SalesReplacementReceiptCard(
                receipt: widget.receipt,
                boundaryKey: _boundaryKey,
              ),
              const SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: AppStrings.actionShareReceipt,
                      icon: Icons.ios_share_rounded,
                      onPressed: _isSharing ? null : _share,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: SecondaryButton(
                      label: AppStrings.actionPrintReceipt,
                      icon: Icons.print_outlined,
                      onPressed: _isPrinting ? null : _print,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              PrimaryButton(
                label: AppStrings.editSaleCloseResults,
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}