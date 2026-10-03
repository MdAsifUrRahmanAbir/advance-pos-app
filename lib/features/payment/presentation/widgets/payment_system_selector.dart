import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../master_data/data/models/payment_accounts_model.dart' as pa;
import '../states/payment_state.dart';
import 'payment_icon_mapper.dart';

/// Multi-select chip grid for choosing up to
/// [PaymentState.maxSelectable] payment systems. Tapping a selected
/// chip deselects it; tapping an unselected chip once the cap is
/// reached is a no-op (the chip renders dimmed).
class PaymentSystemSelector extends StatelessWidget {
  final List<pa.PaymentSystem> systems;
  final List<SelectedPaymentEntry> selectedEntries;
  final ValueChanged<pa.PaymentSystem> onToggle;

  const PaymentSystemSelector({
    super.key,
    required this.systems,
    required this.selectedEntries,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final atCap = selectedEntries.length >= PaymentState.maxSelectable;

    print(systems);
    print(selectedEntries);

    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: [
        for (final system in systems)
          _SystemChip(
            system: system,
            selectionOrder: selectedEntries.indexWhere(
              (e) => e.system.id == system.id,
            ),
            disabled:
                atCap &&
                selectedEntries.indexWhere((e) => e.system.id == system.id) ==
                    -1,
            onTap: () => onToggle(system),
          ),
      ],
    );
  }
}

class _SystemChip extends StatelessWidget {
  final pa.PaymentSystem system;
  final int selectionOrder; // -1 if not selected
  final bool disabled;
  final VoidCallback onTap;

  const _SystemChip({
    required this.system,
    required this.selectionOrder,
    required this.disabled,
    required this.onTap,
  });

  bool get _isSelected => selectionOrder != -1;

  @override
  Widget build(BuildContext context) {
    final color = paymentSystemColor(
      system.shortName,
      system.paymentSystemName,
    );

    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm + AppSizes.xs,
          ),
          decoration: BoxDecoration(
            color: _isSelected ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: _isSelected ? color : color.withValues(alpha: 0.35),
              width: _isSelected ? 1.5 : 1,
            ),
            boxShadow: _isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                paymentSystemIcon(system.shortName, system.paymentSystemName),
                size: AppSizes.iconSm,
                color: _isSelected ? Colors.white : color,
              ),
              const SizedBox(width: AppSizes.xs + AppSizes.xs / 2),
              Text(
                system.paymentSystemName,
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w700,
                  color: _isSelected
                      ? Colors.white
                      : context.appColors.textPrimary,
                ),
              ),
              if (_isSelected) ...[
                const SizedBox(width: AppSizes.xs),
                const Icon(
                  Icons.check_circle_rounded,
                  size: AppSizes.iconSm,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
