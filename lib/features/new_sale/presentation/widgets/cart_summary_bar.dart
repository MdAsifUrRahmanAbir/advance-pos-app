import 'package:advance_pos_app/core/theme/app_color_scheme.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Pinned bottom cart-summary bar (item badge, total, expand chevron).
///
/// Feature-local for now — no existing core widget clearly matched this
/// exact "sticky action bar with count badge + amount + chevron" shape.
/// If this pattern shows up in other sale/checkout flows, it's a good
/// candidate to promote into generate_core_widget.py.
///
/// [badgeKey] marks the count badge (landing spot for the add-to-cart
/// flight). The badge pulses whenever [pulse] changes.
class CartSummaryBar extends StatelessWidget {
  final int itemCount;
  final double total;
  final VoidCallback onTap;
  final Key? badgeKey;
  final int pulse;

  const CartSummaryBar({
    super.key,
    required this.itemCount,
    required this.total,
    required this.onTap,
    this.badgeKey,
    this.pulse = 0,
  });

  /// Badge pulse: how big it pops and how long it settles — no tokens,
  /// flagged.
  static const double _pulseScale = 1.35;
  static const Duration _pulseDuration = Duration(milliseconds: 450);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: context.appColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusLg),
            topRight: Radius.circular(AppSizes.radiusLg),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                TweenAnimationBuilder<double>(
                  key: ValueKey(pulse),
                  tween: Tween(begin: pulse == 0 ? 1 : _pulseScale, end: 1),
                  duration: _pulseDuration,
                  curve: Curves.elasticOut,
                  builder: (_, scale, badge) =>
                      Transform.scale(scale: scale, child: badge),
                  child: Container(
                    key: badgeKey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      '$itemCount',
                      style: TextStyle(
                        color: context.appColors.primary,
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  AppStrings.viewCartLabel(CurrencyFormatter.format(total)),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
