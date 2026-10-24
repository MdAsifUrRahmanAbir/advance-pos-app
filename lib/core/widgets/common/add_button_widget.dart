import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class AddButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String tooltip;

  const AddButtonWidget({
    super.key,
    required this.onTap,
    this.tooltip = AppStrings.expAddTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      tooltip: tooltip,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textWhite,
      child: const Icon(Icons.add_rounded),
    );
  }
}