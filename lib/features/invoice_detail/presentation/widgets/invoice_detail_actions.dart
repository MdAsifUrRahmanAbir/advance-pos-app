import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/bottom_action_bar.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../data/models/invoice_detail_model.dart';

class InvoiceDetailActions extends StatelessWidget {
  final InvoiceDetailModel invoice;
  final VoidCallback? onPayDues;

  const InvoiceDetailActions({super.key, required this.invoice, this.onPayDues});

  @override
  Widget build(BuildContext context) {
    final hasDue = invoice.amountDue > 0;

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
                    CustomSnackbar.show(context, 'Sharing invoice ${invoice.invoiceNumber}...');
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
                    CustomSnackbar.show(context, 'Preparing receipt for printing...');
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