import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';

/// Tap-to-open field that shows the current selection of a picker whose
/// options live in a bottom sheet (see `PaginatedPickerSheet`). Unlike
/// `SearchableDropdownField` it holds no list itself, so it suits options
/// that are searched and paged on the server.
///
/// Shows [hintText] until [valueText] is set; [onClear] adds an × button
/// for optional pickers.
class PickerTriggerField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? valueText;
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const PickerTriggerField({
    super.key,
    required this.label,
    required this.hintText,
    this.valueText,
    this.enabled = true,
    this.isLoading = false,
    this.onTap,
    this.onClear,
  });

  static const double _spinnerStroke = 2; // no AppSizes token for stroke

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasValue = valueText != null && valueText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w700,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: enabled ? onTap : null,
          child: Container(
            height: AppSizes.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              color: colors.surface,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? valueText! : hintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      color: hasValue ? colors.textPrimary : colors.textHint,
                    ),
                  ),
                ),
                if (isLoading)
                  const SizedBox.square(
                    dimension: AppSizes.iconSm,
                    child: CircularProgressIndicator(
                      strokeWidth: _spinnerStroke,
                      color: AppColors.primary,
                    ),
                  )
                else if (hasValue && onClear != null)
                  InkWell(
                    onTap: onClear,
                    child: Icon(
                      Icons.close_rounded,
                      size: AppSizes.iconMd,
                      color: colors.textSecondary,
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: AppSizes.iconMd,
                    color: colors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}