import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

/// ⚠️ Composed manually pending PrimaryInputField's source — same caveat
/// as GivenAmountField in the Payment feature.
class RemarksReferenceRow extends StatelessWidget {
  final ValueChanged<String> onRemarksChanged;
  final ValueChanged<String> onReferenceChanged;

  const RemarksReferenceRow({
    super.key,
    required this.onRemarksChanged,
    required this.onReferenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _LabeledField(
            label: AppStrings.remarksLabel,
            hint: AppStrings.remarksHint,
            onChanged: onRemarksChanged,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _LabeledField(
            label: AppStrings.referenceNoLabel,
            hint: AppStrings.referenceNoHint,
            onChanged: onReferenceChanged,
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm + 4,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: TextField(
            onChanged: onChanged,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontSm,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontSm,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
