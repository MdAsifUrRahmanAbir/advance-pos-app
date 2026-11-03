import 'package:flutter/material.dart';

import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';
import 'icon_button.dart';
import 'search_field.dart';

/// [SearchField] with a bordered barcode-scan button beside it.
///
/// Generic: the caller supplies the hint and both callbacks, so any list
/// that can be searched by a scanned code (stock, invoices, returns…)
/// can use it. The scan button is hidden when [onScanTap] is null.
class ScanSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onScanTap;
  final String? scanTooltip;

  const ScanSearchBar({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onScanTap,
    this.scanTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: SearchField(
            controller: controller,
            hintText: hintText,
            onChanged: onChanged,
          ),
        ),
        if (onScanTap != null) ...[
          const SizedBox(width: AppSizes.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              border: Border.all(color: colors.border),
            ),
            child: AppIconButton(
              icon: Icons.qr_code_scanner_rounded,
              tooltip: scanTooltip,
              onPressed: onScanTap,
            ),
          ),
        ],
      ],
    );
  }
}