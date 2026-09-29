import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../states/cart_state.dart';

/// Manual Discount + VAT inputs for the cart.
/// - Discount: toggle between % and ৳ — seller enters either; the other
///   value is derived and shown beneath the field.
/// - VAT: percent only; the resulting amount is shown beneath the field.
///
/// Composed manually (same style as [RemarksReferenceRow]).
class DiscountVatSection extends StatelessWidget {
  final DiscountType discountType;
  final double discountInput;
  final double discountAmount;
  final double discountPercent;
  final double taxPercent;
  final double taxAmount;
  final ValueChanged<DiscountType> onDiscountTypeChanged;
  final ValueChanged<double> onDiscountChanged;
  final ValueChanged<double> onTaxChanged;

  const DiscountVatSection({
    super.key,
    required this.discountType,
    required this.discountInput,
    required this.discountAmount,
    required this.discountPercent,
    required this.taxPercent,
    required this.taxAmount,
    required this.onDiscountTypeChanged,
    required this.onDiscountChanged,
    required this.onTaxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPercent = discountType == DiscountType.percent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _AdjustmentBlock(
            label: AppStrings.discountInputLabel,
            trailing: _TypeToggle(selected: discountType, onChanged: onDiscountTypeChanged),
            field: _NumberField(
              // Re-create the field when the mode flips so it shows the
              // converted value instead of the previously typed text.
              key: ValueKey(discountType),
              initialValue: discountInput,
              hint: AppStrings.discountInputHint,
              suffix: isPercent ? '%' : '৳',
              onChanged: onDiscountChanged,
            ),
            helper: '৳${discountAmount.toStringAsFixed(2)}  •  ${trimDecimal(discountPercent)}%',
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _AdjustmentBlock(
            label: AppStrings.vatInputLabel,
            field: _NumberField(
              initialValue: taxPercent,
              hint: AppStrings.vatInputHint,
              suffix: '%',
              onChanged: onTaxChanged,
            ),
            helper: '৳${taxAmount.toStringAsFixed(2)}',
          ),
        ),
      ],
    );
  }
}

class _AdjustmentBlock extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final Widget field;
  final String helper;

  const _AdjustmentBlock({
    required this.label,
    this.trailing,
    required this.field,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        field,
        const SizedBox(height: AppSizes.xs),
        Text(
          helper,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Numeric input (max 2 decimals). Keeps its own controller so typing
/// isn't overwritten by state rebuilds; only [initialValue] seeds it.
class _NumberField extends StatefulWidget {
  final double initialValue;
  final String hint;
  final String suffix;
  final ValueChanged<double> onChanged;

  const _NumberField({
    super.key,
    required this.initialValue,
    required this.hint,
    required this.suffix,
    required this.onChanged,
  });

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue == 0 ? '' : trimDecimal(widget.initialValue),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm + 4, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
        onChanged: (text) => widget.onChanged(double.tryParse(text) ?? 0),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm),
          suffixText: widget.suffix,
          suffixStyle: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Compact % | ৳ segmented toggle for the discount mode.
class _TypeToggle extends StatelessWidget {
  final DiscountType selected;
  final ValueChanged<DiscountType> onChanged;

  const _TypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment('%', DiscountType.percent),
          _segment('৳', DiscountType.amount),
        ],
      ),
    );
  }

  Widget _segment(String text, DiscountType type) {
    final isSelected = selected == type;
    return InkWell(
      onTap: () => onChanged(type),
      borderRadius: BorderRadius.circular(AppSizes.radiusSm - 2),
      child: Container(
        width: 28,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm - 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}