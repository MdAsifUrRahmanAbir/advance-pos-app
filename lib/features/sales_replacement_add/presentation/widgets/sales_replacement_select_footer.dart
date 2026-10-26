import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/bottom_action_bar.dart';
import '../../../../core/widgets/common/primary_button.dart';

/// Bottom bar of step 1: what is being returned so far, and Next.
class SalesReplacementSelectFooter extends StatelessWidget {
  final int itemCount;
  final double returnTotal;
  final bool canProceed;
  final VoidCallback onNext;

  const SalesReplacementSelectFooter({
    super.key,
    required this.itemCount,
    required this.returnTotal,
    required this.canProceed,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return BottomActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            itemCount == 0
                ? AppStrings.repaSelectReturnHint
                : AppStrings.repaReturnSummaryLabel(
              itemCount,
              CurrencyFormatter.format(returnTotal),
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          PrimaryButton(
            label: AppStrings.next,
            icon: Icons.arrow_forward_rounded,
            onPressed: canProceed ? onNext : null,
          ),
        ],
      ),
    );
  }
}