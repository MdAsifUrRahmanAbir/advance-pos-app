import 'package:flutter/material.dart';
import 'package:template_test/core/constants/app_colors.dart';
import 'package:template_test/core/constants/app_sizes.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? label;
  final double radius;
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.label,
    this.radius = AppSizes.xxl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl!),
      child: imageUrl != null
          ? null
          : Text(
              (label?.trim().isNotEmpty ?? false) ? label!.trim()[0].toUpperCase() : '?',
              style: TextStyle(color: AppColors.primary, fontSize: AppSizes.fontXl, fontWeight: FontWeight.w700),
            ),
    );
    return onTap == null ? avatar : GestureDetector(onTap: onTap, child: avatar);
  }
}
