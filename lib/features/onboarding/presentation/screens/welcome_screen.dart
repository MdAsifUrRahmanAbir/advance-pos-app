import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../widgets/welcome_content.dart';
import '../widgets/welcome_actions.dart';
import '../../../../core/utils/responsive.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        mobile: const WelcomeMobileView(),
        tablet: const WelcomeTabView(),
      ),
    );
  }
}

class WelcomeMobileView extends ConsumerWidget {
  const WelcomeMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: AppSizes.xl),
            const WelcomeContent(),
            const SizedBox(height: AppSizes.xxl),
            // Spacer(),
            WelcomeActions(
              onLoginTap: () => context.push(RouteNames.login),
              onRegisterTap: () => context.push(RouteNames.register),
            ),
          ],
        ),
      ),
    );
  }
}

/// Same content as [WelcomeMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class WelcomeTabView extends ConsumerWidget {
  const WelcomeTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.xl,
              vertical: AppSizes.xl,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: AppSizes.xl),
                const WelcomeContent(),
                const SizedBox(height: AppSizes.xxl),
                // Spacer(),
                WelcomeActions(
                  onLoginTap: () => context.push(RouteNames.login),
                  onRegisterTap: () => context.push(RouteNames.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
