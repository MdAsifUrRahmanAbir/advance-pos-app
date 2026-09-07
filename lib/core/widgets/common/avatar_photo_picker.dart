import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';
import 'avatar.dart';

/// [AppAvatar] with a camera badge overlapping its bottom edge, plus
/// a tappable action-label link underneath. Used on edit-profile
/// forms.
class AvatarPhotoPicker extends StatelessWidget {
  final String? imageUrl;
  final String? label;
  final String actionLabel;
  final VoidCallback? onTap;
  final double radius;

  const AvatarPhotoPicker({
    super.key,
    this.imageUrl,
    this.label,
    this.actionLabel = 'Change Photo',
    this.onTap,
    this.radius = AppSizes.xxl + AppSizes.md,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppAvatar(imageUrl: imageUrl, label: label, radius: radius),
              Positioned(
                right: -AppSizes.xs / 2,
                bottom: -AppSizes.xs / 2,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.xs + AppSizes.xs / 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.appColors.surface, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: AppSizes.iconSm - AppSizes.xs / 2, color: AppColors.textWhite),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(actionLabel, style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ],
      ),
    );
  }
}