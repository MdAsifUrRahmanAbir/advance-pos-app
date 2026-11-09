import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../states/edit_sale_payment_state.dart';

const double _eps = 0.005;

/// Per method: paid before → after this update, with the difference.
/// Hidden while nothing changed.
class EditSalePaymentChangesList extends StatelessWidget {
  final List<PaymentMethodChange> changes;

  const EditSalePaymentChangesList({super.key, required this.changes});

  @override
  Widget build(BuildContext context) {
    if (!changes.any((c) => c.delta.abs() >= _eps)) {
      return const SizedBox.shrink();
    }
    final colors = context.appColors;

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.editSaleChangesTitle,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          for (final c in changes) _ChangeRow(change: c),
        ],
      ),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  final PaymentMethodChange change;

  const _ChangeRow({required this.change});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final delta = change.delta;
    final changed = delta.abs() >= _eps;
    final deltaColor = delta > 0 ? AppColors.success : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              change.systemName,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            AppStrings.editSaleChangeValue(
              CurrencyFormatter.format(change.previous),
              CurrencyFormatter.format(change.now),
            ),
            style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontSm),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            changed
                ? '${delta > 0 ? '+' : '-'}${CurrencyFormatter.format(delta.abs())}'
                : AppStrings.emptyValue,
            style: TextStyle(
              color: changed ? deltaColor : colors.textHint,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}