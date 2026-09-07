import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Full-width rounded hero illustration/banner — welcome screens,
/// empty-state headers, marketing sections. Falls back to a placeholder
/// icon if the asset/network image fails to load.
class HeroImageBanner extends StatelessWidget {
  final String imagePath;
  final double height;
  final bool isNetworkImage;

  const HeroImageBanner({
    super.key,
    required this.imagePath,
    this.height = 240,
    this.isNetworkImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Image(
          image: isNetworkImage ? NetworkImage(imagePath) as ImageProvider : AssetImage(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: AppColors.background,
            alignment: Alignment.center,
            child: const Icon(Icons.image_outlined, color: AppColors.textHint, size: AppSizes.iconLg),
          ),
        ),
      ),
    );
  }
}