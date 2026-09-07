import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';

enum SettingsTileTrailing { chevron, externalLink, none }

/// Single settings row covering every variant seen so far: plain
/// nav row (chevron), external link row, value + chevron row, and a
/// switch row — chosen by which optional params are supplied. Meant
/// to be placed inside a [SettingsGroup].
///
/// - Pass [switchValue] for a toggle row (ignores [trailing]/[value]).
/// - Else pass [value] for a "title ... value >" row.
/// - Else it's a plain nav row using [trailing] (chevron/link/none).
/// - [icon]/[subtitle] are optional extras for richer rows (as used
///   on the Profile screen); omit both for a compact row (Settings screen).
class SettingsTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? value;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final SettingsTileTrailing trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.value,
    this.switchValue,
    this.onSwitchChanged,
    this.trailing = SettingsTileTrailing.chevron,
    this.onTap,
  });

  Widget? _buildTrailing() {
    if (switchValue != null) {
      return Switch(
        value: switchValue!,
        onChanged: onSwitchChanged,
        activeThumbColor: AppColors.textWhite,
        activeTrackColor: AppColors.primary,
        inactiveThumbColor: AppColors.textWhite,
        inactiveTrackColor: AppColors.border,
      );
    }

    final indicator = switch (trailing) {
      SettingsTileTrailing.chevron => const Icon(Icons.chevron_right_rounded, size: AppSizes.iconSm, color: AppColors.textHint),
      SettingsTileTrailing.externalLink => const Icon(Icons.open_in_new_rounded, size: AppSizes.iconSm - AppSizes.xs / 2, color: AppColors.textHint),
      SettingsTileTrailing.none => null,
    };

    if (value == null && indicator == null) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value != null) ...[
          Text(value!, style: TextStyle(fontSize: AppSizes.fontMd, color: AppColors.textSecondary)),
          if (indicator != null) const SizedBox(width: AppSizes.xs + AppSizes.xs / 2),
        ],
        ?indicator,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final trailingWidget = _buildTrailing();

    return InkWell(
      onTap: switchValue != null ? null : onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: icon != null ? AppSizes.sm + AppSizes.xs : AppSizes.sm),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSizes.iconMd - AppSizes.xs / 2, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.sm + AppSizes.xs),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600, color: context.appColors.textPrimary),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSizes.xs / 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            ?trailingWidget,
          ],
        ),
      ),
    );
  }
}