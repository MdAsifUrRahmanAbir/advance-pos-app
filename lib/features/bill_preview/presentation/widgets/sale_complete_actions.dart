import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';

/// Sale-complete actions: Share / Print / Preview quick actions, then
/// New Sale (primary) and Go to Dashboard. When [onDone] is given (Edit
/// Sale), Done becomes the primary action and New Sale / Dashboard sit
/// side by side under it. Bill actions are disabled while the bill is
/// not loaded (null callbacks).
class SaleCompleteActions extends StatelessWidget {
  final bool isSharing;
  final bool isPrinting;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;
  final VoidCallback? onPreview;
  final VoidCallback onNewSale;
  final VoidCallback onGoToDashboard;
  final VoidCallback? onDone;

  const SaleCompleteActions({
    super.key,
    required this.isSharing,
    required this.isPrinting,
    required this.onShare,
    required this.onPrint,
    required this.onPreview,
    required this.onNewSale,
    required this.onGoToDashboard,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.ios_share_rounded,
                label: AppStrings.invoiceShareAction,
                isLoading: isSharing,
                onPressed: onShare,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _QuickAction(
                icon: Icons.print_outlined,
                label: AppStrings.billPrintAction,
                isLoading: isPrinting,
                onPressed: onPrint,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _QuickAction(
                icon: Icons.receipt_long_outlined,
                label: AppStrings.saleDonePreviewAction,
                isLoading: false,
                onPressed: onPreview,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        if (onDone != null) ...[
          PrimaryButton(label: AppStrings.done, onPressed: onDone),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: AppStrings.newSaleTitle,
                  icon: Icons.add_shopping_cart_rounded,
                  onPressed: onNewSale,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: SecondaryButton(
                  label: AppStrings.saleDoneDashboardAction,
                  icon: Icons.dashboard_outlined,
                  onPressed: onGoToDashboard,
                ),
              ),
            ],
          ),
        ] else ...[
          PrimaryButton(
            label: AppStrings.newSaleTitle,
            icon: Icons.add_shopping_cart_rounded,
            onPressed: onNewSale,
          ),
          const SizedBox(height: AppSizes.sm),
          SecondaryButton(
            label: AppStrings.actionGoToDashboard,
            icon: Icons.dashboard_outlined,
            onPressed: onGoToDashboard,
          ),
        ],
      ],
    );
  }
}

/// Icon-over-label tonal tile for a quick bill action.
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  /// Spinner stroke — no AppSizes token, flagged.
  static const double _spinnerStroke = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onPressed != null && !isLoading;
    final tint = enabled ? colors.primary : colors.textHint;

    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + AppSizes.xs),
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: AppSizes.iconMd,
            child: isLoading
                ? Padding(
                    padding: const EdgeInsets.all(AppSizes.xs),
                    child: CircularProgressIndicator(
                      strokeWidth: _spinnerStroke,
                      color: colors.primary,
                    ),
                  )
                : Icon(icon, size: AppSizes.iconMd, color: tint),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: enabled ? colors.textPrimary : colors.textHint,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
