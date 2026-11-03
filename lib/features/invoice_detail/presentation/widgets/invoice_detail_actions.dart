import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/bottom_action_bar.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import '../../data/models/invoice_detail_model.dart';
import '../../data/models/sale_amounts.dart';

/// Sticky bottom action bar. Bill Preview is always available (share and
/// print happen inside it); Pay Dues only appears while [Sale.amountDue]
/// is > 0.
class InvoiceDetailActions extends StatelessWidget {
  final Sale sale;
  final VoidCallback onBillPreview;
  final VoidCallback? onPayDues;

  const InvoiceDetailActions({
    super.key,
    required this.sale,
    required this.onBillPreview,
    this.onPayDues,
  });

  @override
  Widget build(BuildContext context) {
    final hasDue = sale.amountDue > 0;

    return BottomActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SecondaryButton(
            label: AppStrings.billPreviewTitle,
            icon: Icons.receipt_long_outlined,
            onPressed: onBillPreview,
          ),
          if (hasDue) ...[
            const SizedBox(height: AppSizes.sm),
            PrimaryButton(
              label: AppStrings.invoicePayDuesAction,
              icon: Icons.payments_outlined,
              onPressed: onPayDues,
            ),
          ],
        ],
      ),
    );
  }
}