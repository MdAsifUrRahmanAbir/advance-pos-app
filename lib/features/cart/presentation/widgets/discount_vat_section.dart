import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/radio_option.dart';
import '../states/cart_state.dart';

/// Discount + VAT block for the cart.
/// - Regular rule: seller types a discount (% or ৳), capped by the server.
/// - Product / Bill rule: read-only, auto-applied from /get_discount.
/// - Both: Product wise / Bill wise radio (re-fetches on change).
/// - VAT: percent only.
class DiscountVatSection extends StatelessWidget {
  final CartState state;
  final ValueChanged<DiscountType> onDiscountTypeChanged;
  final ValueChanged<double> onDiscountChanged;
  final ValueChanged<double> onTaxChanged;
  final ValueChanged<DiscountBasis> onBasisChanged;

  const DiscountVatSection({
    super.key,
    required this.state,
    required this.onDiscountTypeChanged,
    required this.onDiscountChanged,
    required this.onTaxChanged,
    required this.onBasisChanged,
  });

  String get _helper =>
      '৳${state.discountAmount.toStringAsFixed(2)}  •  ${trimDecimal(state.discountPercent)}%';

  @override
  Widget build(BuildContext context) {
    final isPercent = state.discountType == DiscountType.percent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.showBasisChoice) ...[
          const Text(
            AppStrings.discountTypeChoiceLabel,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: RadioOption<DiscountBasis>(
                  value: DiscountBasis.product,
                  groupValue: state.discountBasis,
                  title: AppStrings.discountProductWise,
                  onChanged: (v) => v == null ? null : onBasisChanged(v),
                ),
              ),
              Expanded(
                child: RadioOption<DiscountBasis>(
                  value: DiscountBasis.bill,
                  groupValue: state.discountBasis,
                  title: AppStrings.discountBillWise,
                  onChanged: (v) => v == null ? null : onBasisChanged(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: state.canEnterDiscount
                  ? _AdjustmentBlock(
                label: AppStrings.discountInputLabel,
                trailing: _TypeToggle(
                  selected: state.discountType,
                  onChanged: onDiscountTypeChanged,
                ),
                field: _NumberField(
                  key: ValueKey('${state.discountType}-${state.discountFieldRevision}'),
                  initialValue: state.discountInput,
                  hint: AppStrings.discountInputHint,
                  suffix: isPercent ? '%' : '৳',
                  onChanged: onDiscountChanged,
                ),
                helper: state.hasDiscountCap
                    ? '$_helper  •  ${AppStrings.discountMaxHint(isPercent ? '${trimDecimal(state.maxDiscountInput)}%' : '৳${trimDecimal(state.maxDiscountInput)}')}'
                    : _helper,
              )
                  : _AdjustmentBlock(
                label: AppStrings.discountAutoLabel,
                field: _LockedBox(
                  text: state.isGetDiscountLoading
                      ? AppStrings.discountChecking
                      : state.effectiveRule == DiscountRule.none
                      ? AppStrings.discountNotAvailable
                      : state.discountAmount.toStringAsFixed(2),
                ),
                helper: state.effectiveRule == DiscountRule.none
                    ? (state.discountErrorMessage ?? '')
                    : state.discountCodes.isEmpty
                    ? _helper
                    : AppStrings.discountCodesLabel(state.discountCodes.join(', ')),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _AdjustmentBlock(
                label: AppStrings.vatInputLabel,
                field: _NumberField(
                  initialValue: state.taxPercent,
                  hint: AppStrings.vatInputHint,
                  suffix: '%',
                  onChanged: onTaxChanged,
                ),
                helper: '৳${state.taxAmount.toStringAsFixed(2)}',
              ),
            ),
          ],
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
          maxLines: 2,
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

/// Read-only box for server-applied discounts.
class _LockedBox extends StatelessWidget {
  final String text;
  const _LockedBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm + 4, vertical: AppSizes.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.lock_outline_rounded, size: AppSizes.iconSm, color: AppColors.textHint),
        ],
      ),
    );
  }
}

/// Numeric input (max 2 decimals). Keeps its own controller so typing
/// isn't overwritten by rebuilds; only [initialValue] seeds it. Change
/// the widget key to force a re-seed.
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