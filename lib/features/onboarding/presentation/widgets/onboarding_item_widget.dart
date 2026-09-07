import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/onboarding_model.dart';

/// One onboarding slide — illustration + title + description inside the
/// shared [CustomCard] container. Used as the PageView's itemBuilder.
class OnboardingItemWidget extends StatelessWidget {
  final OnboardingModel data;

  const OnboardingItemWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: AspectRatio(
                  aspectRatio: 287 / 180,
                  child: Image.asset(
                    data.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: context.appColors.background,
                      alignment: Alignment.center,
                      child: Icon(Icons.image_outlined, color: context.appColors.textHint, size: AppSizes.iconLg),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppSizes.fontXl, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppSizes.fontMd, color: context.appColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}