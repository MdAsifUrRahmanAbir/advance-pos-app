import 'package:flutter/material.dart';
import 'package:template_test/core/constants/app_colors.dart';
import 'package:template_test/core/constants/app_sizes.dart';

import '../../theme/app_color_scheme.dart';

class DateField extends StatelessWidget {
  final String label;
  final String? hint;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onChanged;
  final String Function(DateTime)? formatter;
  final String? Function(String?)? validator;
  final bool enabled;

  const DateField({
    super.key,
    this.label = 'Date',
    this.hint,
    this.value,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.formatter,
    this.validator,
    this.enabled = true,
  });

  String _format(DateTime date) => formatter?.call(date) ?? '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      enabled: enabled,
      validator: validator,
      controller: TextEditingController(text: value == null ? '' : _format(value!)),
      onTap: !enabled
          ? null
          : () async {
              final selected = await showDatePicker(
                context: context,
                firstDate: firstDate ?? DateTime(2000),
                lastDate: lastDate ?? DateTime(2100),
                initialDate: value ?? DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppColors.primary,
                      surface: context.appColors.surface,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (selected != null) onChanged?.call(selected);
            },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: AppSizes.iconMd),
        filled: true,
        fillColor: context.appColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
