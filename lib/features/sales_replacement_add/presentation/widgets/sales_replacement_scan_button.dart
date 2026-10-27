import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';

/// Square barcode-scan button sized to sit beside an input field (a
/// `PickerTriggerField` or a `SearchField`).
class SalesReplacementScanButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SalesReplacementScanButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Tooltip(
      message: AppStrings.repaScanTooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onPressed,
        child: Container(
          width: AppSizes.inputHeight,
          height: AppSizes.inputHeight,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            size: AppSizes.iconMd,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}