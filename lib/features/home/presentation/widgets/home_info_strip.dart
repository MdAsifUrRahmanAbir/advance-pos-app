import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';

/// One labelled value in [HomeInfoStrip].
class HomeInfoItem {
  final IconData icon;
  final String label;
  final String value;

  const HomeInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

/// Small card of side-by-side info chips (branch, employee ID…).
class HomeInfoStrip extends StatelessWidget {
  final List<HomeInfoItem> items;

  const HomeInfoStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.sm),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSizes.sm),
            Expanded(child: _InfoChip(item: items[i])),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final HomeInfoItem item;

  const _InfoChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: AppSizes.iconSm, color: colors.textSecondary),
              const SizedBox(width: AppSizes.xs),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: AppSizes.fontXs,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs / 2),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}