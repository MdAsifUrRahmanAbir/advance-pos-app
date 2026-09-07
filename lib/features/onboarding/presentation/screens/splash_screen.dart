import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/session/auth_session_state.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../routes/route_names.dart';
import '../widgets/splash_logo.dart';
import '../widgets/splash_brand_text.dart';
import '../widgets/splash_loading_indicator.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await ref.read(authSessionControllerProvider.notifier).restoreSession();

    if (!mounted) return;

    final status = ref.read(authSessionControllerProvider).status;

    context.go(
      status == AuthStatus.authenticated
          ? RouteNames.mainShell
          : RouteNames.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: const SplashMobileView(),
        tablet: const SplashTabView(),
      ),
    );
  }
}

class SplashMobileView extends StatelessWidget {
  const SplashMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const Spacer(flex: 3),
                const SplashLogo(),
                const SizedBox(height: AppSizes.lg),
                const SplashBrandText(),
                const Spacer(flex: 4),
                const SplashLoadingIndicator(),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SplashTabView extends StatelessWidget {
  const SplashTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Spacer(flex: 3),
                    const SplashLogo(),
                    const SizedBox(height: AppSizes.lg),
                    const SplashBrandText(),
                    const Spacer(flex: 4),
                    const SplashLoadingIndicator(),
                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}