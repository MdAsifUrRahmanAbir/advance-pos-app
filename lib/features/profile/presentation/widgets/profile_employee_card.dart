import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/avatar.dart';
import '../../../../core/widgets/common/custom_card.dart';

/// Signed-in employee: initials avatar, name, then Employee ID and
/// Employee No side by side. Missing values show [AppStrings.emptyValue].
class ProfileEmployeeCard extends StatelessWidget {
  final String? name;
  final int? employeeId;
  final String? employeeNo;

  const ProfileEmployeeCard({
    super.key,
    required this.name,
    required this.employeeId,
    required this.employeeNo,
  });

  static String _orEmpty(String? value) {
    final text = value?.trim();
    return (text == null || text.isEmpty) ? AppStrings.emptyValue : text;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return CustomCard(
      fullWidth: true,
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppAvatar(label: name, radius: AppSizes.lg),
              const SizedBox(width: AppSizes.sm + AppSizes.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _orEmpty(name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs / 2),
                    Text(
                      AppStrings.profileSignedInCaption,
                      style: TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.badge_outlined,
                  label: AppStrings.profileEmployeeIdLabel,
                  value: _orEmpty(employeeId?.toString()),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _InfoTile(
                  icon: Icons.tag_rounded,
                  label: AppStrings.profileEmployeeNoLabel,
                  value: _orEmpty(employeeNo),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm + AppSizes.xs),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconSm, color: colors.textSecondary),
              const SizedBox(width: AppSizes.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: AppSizes.fontXs, color: colors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
