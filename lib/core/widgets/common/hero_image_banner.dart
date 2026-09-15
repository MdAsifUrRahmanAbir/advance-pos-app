import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class HeroImageBanner extends StatelessWidget {
  final String imagePath;
  final double height;
  final bool isNetworkImage;
  final double scale;
  final BoxFit fit;
  final Alignment alignment;

  const HeroImageBanner({
    super.key,
    required this.imagePath,
    this.height = 240,
    this.isNetworkImage = false,
    this.scale = 1.0,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Transform.scale(
          scale: scale,
          child: Image(
            image: isNetworkImage
                ? NetworkImage(imagePath)
                : AssetImage(imagePath),
            fit: fit,
            alignment: alignment,
            errorBuilder: (_, _, _) => Container(
              color: AppColors.background,
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_outlined,
                color: AppColors.textHint,
                size: AppSizes.iconLg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
