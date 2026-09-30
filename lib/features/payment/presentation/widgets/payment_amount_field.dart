import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';

/// Amount input for one selected payment entry. Disabled + pinned to
/// [amount] when [enabled] is false — used when exactly one non-cash
/// system is selected (the full payable amount, no partial digital
/// payments). Editable otherwise (cash alone, or any split across two
/// selected methods).
///
/// Owns a single stable [TextEditingController]/[FocusNode] so typing is
/// never interrupted by parent rebuilds. External [amount] changes are
/// only written into the field while it is NOT focused.
class PaymentAmountField extends StatefulWidget {
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
  State<PaymentAmountField> createState() => _PaymentAmountFieldState();
}

class _PaymentAmountFieldState extends State<PaymentAmountField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.amount));
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant PaymentAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync external changes (split recalculation, lock-to-payable) only
    // when the user isn't mid-typing, and only if the numeric value
    // actually differs from what's already shown.
    if (!_focusNode.hasFocus) {
      final current = double.tryParse(_controller.text) ?? 0;
      if ((current - widget.amount).abs() > 0.0001) {
        _controller.text = _format(widget.amount);
      }
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  String _format(double value) => value.toStringAsFixed(2);

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Select everything so typing replaces the prefilled amount.
      _controller.selection =
          TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    } else {
      // Normalize on blur ("12." / "" -> "12.00" / "0.00").
      // final parsed = double.tryParse(_controller.text) ?? 0;
      // _controller.text = _format(parsed);
      _controller.text = _format(widget.amount);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
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
            color: widget.enabled ? context.appColors.surface : context.appColors.background,
            border: Border.all(color: context.appColors.border),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: widget.enabled
              ? TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: (value) => widget.onChanged?.call(double.tryParse(value) ?? 0),
          )
              : Row(
            children: [
              Text('৳', style: TextStyle(color: context.appColors.textHint, fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700)),
              const SizedBox(width: AppSizes.xs / 2),
              Text(
                widget.amount.toStringAsFixed(2),
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