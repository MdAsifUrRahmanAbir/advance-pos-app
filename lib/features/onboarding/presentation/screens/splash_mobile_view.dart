import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../widgets/splash_background.dart';
import '../widgets/splash_brand_text.dart';
import '../widgets/splash_entrance.dart';
import '../widgets/splash_feature_chips.dart';
import '../widgets/splash_loading_indicator.dart';
import '../widgets/splash_pulse_logo.dart';

class SplashMobileView extends StatelessWidget {
  const SplashMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: const [
                Spacer(flex: 3),
                SplashEntrance(
                  curve: Curves.easeOutBack,
                  child: SplashPulseLogo(),
                ),
                SizedBox(height: AppSizes.xl),
                SplashEntrance(step: 1, child: SplashBrandText()),
                SizedBox(height: AppSizes.lg),
                SplashEntrance(step: 2, child: SplashFeatureChips()),
                Spacer(flex: 3),
                SplashEntrance(step: 3, child: SplashLoadingIndicator()),
                SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}