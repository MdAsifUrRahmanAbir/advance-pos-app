import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import 'avatar.dart';

/// Gradient banner with an [AppAvatar] overlapping the bottom edge
/// and an optional edit/camera badge on it. Used at the top of
/// profile-style screens.
class GradientCoverHeader extends StatelessWidget {
  final String? avatarUrl;
  final String? avatarLabel;
  final double coverHeight;
  final double avatarRadius;
  final VoidCallback? onAvatarEditTap;
  final List<Color> gradientColors;

  const GradientCoverHeader({
    super.key,
    this.avatarUrl,
    this.avatarLabel,
    this.coverHeight = AppSizes.xxl * 3 - AppSizes.xs,
    this.avatarRadius = AppSizes.xxl + AppSizes.xs,
    this.onAvatarEditTap,
    this.gradientColors = const [AppColors.primary, AppColors.primaryDark],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: coverHeight + avatarRadius,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: coverHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, 0.00),
                end: Alignment(1.00, 1.00),
                colors: [const Color(0xFF4F46E5), const Color(0xFF312E81)],
              ),
            ),
          ),
          Positioned(
            top: coverHeight - avatarRadius,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.xs),
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AppAvatar(
                    imageUrl: avatarUrl,
                    label: avatarLabel,
                    radius: avatarRadius,
                  ),
                  if (onAvatarEditTap != null)
                    Positioned(
                      right: -AppSizes.xs,
                      bottom: -AppSizes.xs,
                      child: GestureDetector(
                        onTap: onAvatarEditTap,
                        child: Container(
                          padding: const EdgeInsets.all(
                            AppSizes.sm - AppSizes.xs / 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: AppSizes.xs,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: AppSizes.iconSm - AppSizes.xs,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
