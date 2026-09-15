import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';

class PaymentSuccessActions extends StatelessWidget {
  final bool isSharing;
  final bool isPrinting;
  final VoidCallback onNewSale;
  final VoidCallback onGoToDashboard;
  final VoidCallback onShareReceipt;
  final VoidCallback onPrintReceipt;

  const PaymentSuccessActions({
    super.key,
    required this.isSharing,
    required this.isPrinting,
    required this.onNewSale,
    required this.onGoToDashboard,
    required this.onShareReceipt,
    required this.onPrintReceipt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          label: AppStrings.actionNewSale,
          icon: Icons.add_shopping_cart_rounded,
          onPressed: onNewSale,
        ),
        const SizedBox(height: AppSizes.sm),
        SecondaryButton(
          label: AppStrings.actionGoToDashboard,
          icon: Icons.dashboard_outlined,
          onPressed: onGoToDashboard,
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Expanded(
              child: _OutlinedActionButton(
                icon: Icons.ios_share_rounded,
                label: AppStrings.actionShareReceipt,
                isLoading: isSharing,
                onPressed: isSharing ? null : onShareReceipt,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _OutlinedActionButton(
                icon: Icons.print_outlined,
                label: AppStrings.actionPrintReceipt,
                isLoading: isPrinting,
                onPressed: isPrinting ? null : onPrintReceipt,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _OutlinedActionButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 2),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: AppSizes.iconSm,
              width: AppSizes.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textSecondary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: AppSizes.iconSm,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
              ],
            ),
    );
  }
}
