import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../master_data/data/models/payment_system_model.dart' as ps;
import '../states/payment_state.dart';
import 'payment_icon_mapper.dart';

/// Multi-select chip grid for choosing up to
/// [PaymentState.maxSelectable] payment systems. Tapping a selected
/// chip deselects it; tapping an unselected chip once the cap is
/// reached is a no-op (the chip renders dimmed).
class PaymentSystemSelector extends StatelessWidget {
  final List<ps.ResultDatum> systems;
  final List<SelectedPaymentEntry> selectedEntries;
  final ValueChanged<ps.ResultDatum> onToggle;

  const PaymentSystemSelector({
    super.key,
    required this.systems,
    required this.selectedEntries,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final atCap = selectedEntries.length >= PaymentState.maxSelectable;

    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: [
        for (final system in systems)
          _SystemChip(
            system: system,
            selectionOrder: selectedEntries.indexWhere((e) => e.system.id == system.id),
            disabled: atCap && selectedEntries.indexWhere((e) => e.system.id == system.id) == -1,
            onTap: () => onToggle(system),
          ),
      ],
    );
  }
}

class _SystemChip extends StatelessWidget {
  final ps.ResultDatum system;
  final int selectionOrder; // -1 if not selected, else 0/1
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
    final color = context.appColors.primary;

    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm + AppSizes.xs),
          decoration: BoxDecoration(
            color: _isSelected ? color.withValues(alpha: 0.1) : context.appColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: _isSelected ? color : context.appColors.border, width: _isSelected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                paymentSystemIcon(system.shortName, system.paymentSystemName),
                size: AppSizes.iconSm,
                color: _isSelected ? color : context.appColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.xs + AppSizes.xs / 2),
              Text(
                system.paymentSystemName,
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w700,
                  color: _isSelected ? color : context.appColors.textPrimary,
                ),
              ),
              if (_isSelected) ...[
                const SizedBox(width: AppSizes.xs),
                Container(
                  width: AppSizes.md,
                  height: AppSizes.md,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    '${selectionOrder + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}