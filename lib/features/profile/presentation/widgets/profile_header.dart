import 'package:flutter/material.dart';
// import 'package:template_test/core/constants/app_strings.dart';
// import 'package:template_test/core/widgets/common/app_header_bar.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/status_badge.dart';
import '../../../../core/widgets/common/gradient_cover_header.dart';

/// Cover gradient + avatar, name, and role badge at the top of the
/// profile screen.
class ProfileHeader extends StatelessWidget {
  final String name;
  final String role;
  final String? avatarUrl;
  final VoidCallback? onAvatarEditTap;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.onAvatarEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppHeaderBar(title: AppStrings.appName),
        GradientCoverHeader(
          avatarUrl: avatarUrl,
          avatarLabel: name,
          onAvatarEditTap: onAvatarEditTap,
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          name,
          style: TextStyle(fontSize: AppSizes.fontXxl, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
        ),
        const SizedBox(height: AppSizes.xs),
        StatusBadge(text: role, type: StatusBadgeType.primary, compact: true),
      ],
    );
  }
}