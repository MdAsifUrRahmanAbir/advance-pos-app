import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';

/// Row with a tinted numbered chip ("01", "02"...) on the left and
/// body text on the right. Used for enumerated policy points, steps,
/// or ordered lists inside long-form document content.
class NumberedListItem extends StatelessWidget {
  final String number;
  final String text;

  const NumberedListItem({super.key, required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm + AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs / 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm - 2),
            ),
            child: Text(
              number,
              style: const TextStyle(color: AppColors.primary, fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: AppSizes.sm + AppSizes.xs),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: AppSizes.fontMd, color: context.appColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}