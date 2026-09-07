import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_step_indicator.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../routes/route_names.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_top_bar.dart';
import '../widgets/onboarding_item_widget.dart';

import '../../../../core/utils/responsive.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        mobile: const OnboardingMobileView(),
        tablet: const OnboardingTabView(),
      ),
    );
  }
}


class OnboardingMobileView extends ConsumerStatefulWidget {
  const OnboardingMobileView({super.key});

  @override
  ConsumerState<OnboardingMobileView> createState() => _OnboardingMobileViewState();
}

class _OnboardingMobileViewState extends ConsumerState<OnboardingMobileView> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() => context.go(RouteNames.welcome);

  @override
  Widget build(BuildContext context) {
    final slides = ref.watch(onboardingControllerProvider);
    final isLastSlide = _currentIndex == slides.length - 1;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
            child: OnboardingTopBar(onSkip: _finish),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: slides.length,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemBuilder: (context, index) => OnboardingItemWidget(data: slides[index]),
                  ),
                  Positioned(
                    bottom: 120,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        const SizedBox(height: AppSizes.lg),
                        CustomStepIndicator(stepCount: slides.length, currentStep: _currentIndex),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: PrimaryButton(
              label: isLastSlide ? AppStrings.getStarted : AppStrings.next,
              onPressed: () {
                if (isLastSlide) {
                  _finish();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


/// Same content as [OnboardingMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class OnboardingTabView extends ConsumerStatefulWidget {
  const OnboardingTabView({super.key});

  @override
  ConsumerState<OnboardingTabView> createState() => _OnboardingTabViewState();
}

class _OnboardingTabViewState extends ConsumerState<OnboardingTabView> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() => context.go(RouteNames.welcome);

  @override
  Widget build(BuildContext context) {
    final slides = ref.watch(onboardingControllerProvider);
    final isLastSlide = _currentIndex == slides.length - 1;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.sm),
                child: OnboardingTopBar(onSkip: _finish),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: slides.length,
                          onPageChanged: (index) => setState(() => _currentIndex = index),
                          itemBuilder: (context, index) => OnboardingItemWidget(data: slides[index]),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      CustomStepIndicator(stepCount: slides.length, currentStep: _currentIndex),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: PrimaryButton(
                  label: isLastSlide ? AppStrings.getStarted : AppStrings.next,
                  onPressed: () {
                    if (isLastSlide) {
                      _finish();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
