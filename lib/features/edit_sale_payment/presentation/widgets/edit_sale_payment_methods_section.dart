import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/utility/custom_loader.dart';
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
import '../../../payment/presentation/widgets/change_due_banner.dart';
import '../../../payment/presentation/widgets/payment_entry_card.dart';
import '../../../payment/presentation/widgets/payment_system_selector.dart';
import '../states/edit_sale_payment_state.dart';

/// "PAYMENT METHOD" block: system chips, one card per selected method
/// (account + amount), and the change/short banner. Built from the
/// payment feature's read-only widgets — the payment feature itself is
/// not modified.
class EditSalePaymentMethodsSection extends StatelessWidget {
  final EditSalePaymentState state;
  final List<pa.PaymentSystem> systems;
  final bool isLoadingMethods;
  final bool hasMethodsError;
  final VoidCallback onRetryMethods;
  final List<pa.ResultDatum> Function(pa.PaymentSystem system) accountsFor;
  final ValueChanged<pa.PaymentSystem> onToggle;
  final void Function(int systemId, pa.ResultDatum account) onAccountChanged;
  final void Function(int systemId, double amount) onAmountChanged;

  const EditSalePaymentMethodsSection({
    super.key,
    required this.state,
    required this.systems,
    required this.isLoadingMethods,
    required this.hasMethodsError,
    required this.onRetryMethods,
    required this.accountsFor,
    required this.onToggle,
    required this.onAccountChanged,
    required this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.editSalePaymentMethodSection,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          AppStrings.selectPaymentMethodsHint,
          style: TextStyle(fontSize: AppSizes.fontXs, color: colors.textHint),
        ),
        const SizedBox(height: AppSizes.sm),
        if (isLoadingMethods)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
            child: CustomLoader(),
          )
        else if (hasMethodsError)
          Column(
            children: [
              Text(
                AppStrings.paymentMethodsLoadError,
                style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontSm),
              ),
              TextButton(onPressed: onRetryMethods, child: const Text(AppStrings.retry)),
            ],
          )
        else
          PaymentSystemSelector(
            systems: systems,
            selectedEntries: state.selectedEntries,
            onToggle: onToggle,
          ),
        const SizedBox(height: AppSizes.md),
        if (state.selectedEntries.isEmpty)
          Text(
            AppStrings.selectPaymentMethodToContinue,
            style: TextStyle(fontSize: AppSizes.fontXs, color: colors.textHint),
          )
        else ...[
          for (final entry in state.selectedEntries) ...[
            PaymentEntryCard(
              key: ValueKey(entry.system.id),
              entry: entry,
              accountsForThisSystem: accountsFor(entry.system),
              amountLocked: state.lockSingleNonCashAmount,
              onAccountChanged: (account) => onAccountChanged(entry.system.id, account),
              onAmountChanged: (amount) => onAmountChanged(entry.system.id, amount),
              onRemove: () => onToggle(entry.system),
            ),
            const SizedBox(height: AppSizes.sm + AppSizes.xs),
          ],
          if (state.changeDue.abs() >= 0.005) ChangeDueBanner(amount: state.changeDue),
        ],
      ],
    );
  }
}