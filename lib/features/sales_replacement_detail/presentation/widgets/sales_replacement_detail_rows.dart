import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';

/// Label / value row used by the information card.
class SalesReplacementInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const SalesReplacementInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  static const double _labelWidth = 130;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? AppStrings.emptyValue : value,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label on the left, amount on the right; [bold] for the final total.
class SalesReplacementAmountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const SalesReplacementAmountRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? AppSizes.fontMd : AppSizes.fontSm,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? context.appColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? AppSizes.fontMd : AppSizes.fontSm,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: color ?? context.appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}