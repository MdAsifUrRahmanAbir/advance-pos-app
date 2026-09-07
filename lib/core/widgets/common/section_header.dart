import 'package:flutter/material.dart';
import 'package:template_test/core/constants/app_sizes.dart';

import '../../theme/app_color_scheme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final action = trailing ?? (actionLabel == null ? null : TextButton(onPressed: onAction, child: Text(actionLabel!)));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700, color: context.appColors.textPrimary)),
              if (subtitle != null) ...[
                const SizedBox(height: AppSizes.xs),
                Text(subtitle!, style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary)),
              ],
            ],
          ),
        ),
        ?action,
      ],
    );
  }
}
