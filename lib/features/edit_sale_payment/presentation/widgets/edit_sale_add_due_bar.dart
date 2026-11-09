import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../payment/presentation/states/payment_state.dart'
    show SelectedPaymentEntry;
import '../../../payment/presentation/widgets/payment_icon_mapper.dart';

/// "Add X to: [Cash] [bKash]" — puts the missing amount on the method the
/// customer pays it with.
class EditSaleAddDueBar extends StatelessWidget {
  final double amount;
  final List<SelectedPaymentEntry> entries;
  final ValueChanged<int> onAdd;

  const EditSaleAddDueBar({
    super.key,
    required this.amount,
    required this.entries,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.editSaleAddDueLabel(CurrencyFormatter.format(amount)),
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: [
            for (final e in entries)
              ActionChip(
                avatar: Icon(
                  paymentSystemIcon(
                      e.system.shortName, e.system.paymentSystemName),
                  size: AppSizes.iconSm,
                  color: paymentSystemColor(
                      e.system.shortName, e.system.paymentSystemName),
                ),
                label: Text(e.system.paymentSystemName),
                onPressed: () => onAdd(e.system.id),
              ),
          ],
        ),
      ],
    );
  }
}