import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/bottom_action_bar.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../data/models/invoice_detail_model.dart';
import '../../data/models/sale_amounts.dart';

/// Sticky bottom action row — Share and Print Receipt are always
/// available; Pay Dues only appears while [Sale.amountDue] is > 0.
class InvoiceDetailActions extends StatelessWidget {
  final Sale sale;
  final VoidCallback? onPayDues;

  const InvoiceDetailActions({super.key, required this.sale, this.onPayDues});

  @override
  Widget build(BuildContext context) {
    final hasDue = sale.amountDue > 0;

    return BottomActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: AppStrings.invoiceShareAction,
                  icon: Icons.share_outlined,
                  onPressed: () {
                    // TODO: wire to a real share flow (e.g. share_plus)
                    // once available.
                    CustomSnackbar.show(
                      context,
                      'Sharing invoice ${sale.salesBillNo}...',
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: SecondaryButton(
                  label: AppStrings.invoicePrintAction,
                  icon: Icons.print_outlined,
                  onPressed: () {
                    // TODO: wire to a real printer/PDF flow once available.
                    CustomSnackbar.show(
                      context,
                      'Preparing receipt for printing...',
                    );
                  },
                ),
              ),
            ],
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
