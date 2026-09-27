import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';

/// Amount input for one selected payment entry. Disabled + pinned to
/// [amount] when [enabled] is false — used when exactly one non-cash
/// system is selected (the full payable amount, no partial digital
/// payments). Editable otherwise (cash alone, or any split across two
/// selected methods).
class PaymentAmountField extends StatelessWidget {
  final String label;
  final double amount;
  final bool enabled;
  final ValueChanged<double>? onChanged;

  const PaymentAmountField({
    super.key,
    required this.label,
    required this.amount,
    required this.enabled,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: context.appColors.textSecondary,
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm + 4),
          decoration: BoxDecoration(
            color: enabled ? context.appColors.surface : context.appColors.background,
            border: Border.all(color: context.appColors.border),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: enabled
              ? TextField(
            key: ValueKey('amount-$label-${amount.toStringAsFixed(2)}'),
            controller: TextEditingController(text: amount.toStringAsFixed(2)),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: context.appColors.textPrimary, fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, prefixText: '৳'),
            onChanged: (value) => onChanged?.call(double.tryParse(value) ?? 0),
          )
              : Row(
            children: [
              Text('৳', style: TextStyle(color: context.appColors.textHint, fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700)),
              const SizedBox(width: AppSizes.xs / 2),
              Text(
                amount.toStringAsFixed(2),
                style: TextStyle(color: context.appColors.textSecondary, fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: AppSizes.sm),
              Icon(Icons.lock_outline_rounded, size: AppSizes.iconSm, color: context.appColors.textHint),
            ],
          ),
        ),
      ],
    );
  }
}