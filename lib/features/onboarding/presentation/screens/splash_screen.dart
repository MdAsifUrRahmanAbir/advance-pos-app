import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_system_ui.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../routes/route_names.dart';
import '../controllers/splash_controller.dart';
import 'splash_mobile_view.dart';
import 'splash_tab_view.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Full-screen splash: no status / navigation bar.
    AppSystemUi.hideForSplash();
    _bootstrap();
  }

  @override
  void dispose() {
    AppSystemUi.restoreAfterSplash();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final destination =
    await ref.read(splashControllerProvider.notifier).bootstrap();
    if (!mounted) return;
    await AppSystemUi.restoreAfterSplash();
    if (!mounted) return;
    context.go(switch (destination) {
      SplashDestination.welcome => RouteNames.welcome,
      SplashDestination.login => RouteNames.login,
      SplashDestination.home => RouteNames.mainShell,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.darkIcons,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Responsive(
          mobile: const SplashMobileView(),
          tablet: const SplashTabView(),
        ),
      ),
    );
  }
}