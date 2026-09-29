import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;

/// Dropdown of payment accounts for one selected non-cash payment
/// system, filtered (by the caller) to that system's `shortName`.
class PaymentAccountDropdown extends StatelessWidget {
  final List<pa.ResultDatum> accounts;
  final pa.ResultDatum? selected;
  final ValueChanged<pa.ResultDatum> onChanged;

  const PaymentAccountDropdown({
    super.key,
    required this.accounts,
    required this.selected,
    required this.onChanged,
  });

  String _labelFor(pa.ResultDatum account) {
    final holder = account.accHolderName.trim();
    return holder.isEmpty ? account.accountNo : '$holder • ${account.accountNo}';
  }

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm + AppSizes.xs),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Text(
          AppStrings.noAccountsAvailableForSystem,
          style: const TextStyle(color: AppColors.warning, fontSize: AppSizes.fontSm),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border.all(color: context.appColors.border),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selected?.id,
          isExpanded: true,
          hint: Text(
            AppStrings.selectAccountLabel,
            style: TextStyle(color: context.appColors.textHint, fontSize: AppSizes.fontSm),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.appColors.textSecondary),
          style: TextStyle(color: context.appColors.textPrimary, fontSize: AppSizes.fontSm),
          items: [
            for (final account in accounts)
              DropdownMenuItem(value: account.id, child: Text(_labelFor(account))),
          ],
          onChanged: (id) {
            if (id == null) return;
            onChanged(accounts.firstWhere((a) => a.id == id));
          },
        ),
      ),
    );
  }
}