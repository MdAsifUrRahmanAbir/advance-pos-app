import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
import '../states/payment_state.dart';
import 'payment_account_dropdown.dart';
import 'payment_amount_field.dart';
import 'payment_icon_mapper.dart';

/// One selected payment system's inline settings — icon/name header,
/// an account picker (non-cash only, filtered by shortName), and an
/// amount field (locked to the full payable amount when this is the
/// only method selected and it's non-cash).
class PaymentEntryCard extends StatelessWidget {
  final SelectedPaymentEntry entry;
  final List<pa.ResultDatum> accountsForThisSystem;
  final bool amountLocked;
  final ValueChanged<pa.ResultDatum> onAccountChanged;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onRemove;

  const PaymentEntryCard({
    super.key,
    required this.entry,
    required this.accountsForThisSystem,
    required this.amountLocked,
    required this.onAccountChanged,
    required this.onAmountChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.xs + AppSizes.xs / 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  paymentSystemIcon(entry.system.shortName, entry.system.paymentSystemName),
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  entry.system.paymentSystemName,
                  style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm),
                color: context.appColors.textHint,
                onPressed: onRemove,
                tooltip: 'Remove',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          if (!entry.isCash) ...[
            PaymentAccountDropdown(accounts: accountsForThisSystem, selected: entry.account, onChanged: onAccountChanged),
            const SizedBox(height: AppSizes.sm + AppSizes.xs),
          ],
          PaymentAmountField(
            label: entry.isCash ? AppStrings.givenAmountLabel : AppStrings.paymentAmountLabel,
            amount: entry.amount,
            enabled: !amountLocked,
            onChanged: onAmountChanged,
          ),
        ],
      ),
    );
  }
}