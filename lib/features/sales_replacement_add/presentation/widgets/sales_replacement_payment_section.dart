import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/utility/custom_loader.dart';
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
import '../../../payment/presentation/states/payment_state.dart'
    show SelectedPaymentEntry;
import '../../../payment/presentation/widgets/change_due_banner.dart';
import '../../../payment/presentation/widgets/payment_entry_card.dart';
import '../../../payment/presentation/widgets/payment_system_selector.dart';

/// Payment of the net amount: method chips, one card per chosen method,
/// and the change / shortfall banner. Reuses the Payment feature's widgets.
class SalesReplacementPaymentSection extends StatelessWidget {
  final List<pa.PaymentSystem> systems;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;
  final List<SelectedPaymentEntry> selectedEntries;
  final bool amountLocked;
  final double changeDue;
  final List<pa.ResultDatum> Function(pa.PaymentSystem system) accountsFor;
  final ValueChanged<pa.PaymentSystem> onToggle;
  final void Function(int systemId, pa.ResultDatum account) onAccountChanged;
  final void Function(int systemId, double amount) onAmountChanged;

  const SalesReplacementPaymentSection({
    super.key,
    required this.systems,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.selectedEntries,
    required this.amountLocked,
    required this.changeDue,
    required this.accountsFor,
    required this.onToggle,
    required this.onAccountChanged,
    required this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.editSalePaymentMethodSection,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          AppStrings.selectPaymentMethodsHint,
          style: TextStyle(fontSize: AppSizes.fontXs, color: colors.textHint),
        ),
        const SizedBox(height: AppSizes.sm),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
            child: CustomLoader(),
          )
        else if (hasError)
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.paymentMethodsLoadError,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text(AppStrings.retry)),
            ],
          )
        else
          PaymentSystemSelector(
            systems: systems,
            selectedEntries: selectedEntries,
            onToggle: onToggle,
          ),
        if (selectedEntries.isNotEmpty) ...[
          const SizedBox(height: AppSizes.md),
          for (final entry in selectedEntries) ...[
            PaymentEntryCard(
              key: ValueKey(entry.system.id),
              entry: entry,
              accountsForThisSystem: accountsFor(entry.system),
              amountLocked: amountLocked,
              onAccountChanged: (account) =>
                  onAccountChanged(entry.system.id, account),
              onAmountChanged: (amount) => onAmountChanged(entry.system.id, amount),
              onRemove: () => onToggle(entry.system),
            ),
            const SizedBox(height: AppSizes.sm + AppSizes.xs),
          ],
          if (changeDue != 0) ChangeDueBanner(amount: changeDue),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.sm),
            child: Text(
              AppStrings.selectPaymentMethodToContinue,
              style: TextStyle(fontSize: AppSizes.fontXs, color: colors.textHint),
            ),
          ),
      ],
    );
  }
}