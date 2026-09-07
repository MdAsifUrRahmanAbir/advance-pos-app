import 'package:template_test/features/product/presentation/screens/product_screen.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:template_test/features/analytics_mode/presentation/screens/analytics_mode_screen.dart';
import 'package:template_test/features/order_list/presentation/screens/order_list_screen.dart';
import 'package:template_test/features/audit_log/presentation/screens/audit_log_screen.dart';
import 'package:template_test/features/terms_privacy/presentation/screens/terms_privacy_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_test/routes/route_names.dart';
import 'package:template_test/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:template_test/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:template_test/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:template_test/features/login/presentation/screens/login_screen.dart';
import 'package:template_test/features/forgot_password/presentation/screens/forgot_password_screen.dart';
import 'package:template_test/features/reset_password/presentation/screens/reset_password_screen.dart';
import 'package:template_test/features/main_shell/presentation/screens/main_shell_screen.dart';
import 'package:template_test/features/home/presentation/screens/home_screen.dart';
import 'package:template_test/features/activity/presentation/screens/activity_screen.dart';
import 'package:template_test/features/search/presentation/screens/search_screen.dart';
import 'package:template_test/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:template_test/features/profile/presentation/screens/profile_screen.dart';
import 'package:template_test/features/settings/presentation/screens/settings_screen.dart';
import 'package:template_test/features/system/presentation/screens/not_found_screen.dart';
import 'package:template_test/features/system/presentation/screens/error_screen.dart';
import 'package:template_test/features/system/presentation/screens/no_internet_screen.dart';
import 'package:template_test/features/system/presentation/screens/maintenance_screen.dart';
// Added: imports for the newly added basic screens
import 'package:template_test/features/register/presentation/screens/register_screen.dart';
import 'package:template_test/features/otp_verification/presentation/screens/otp_verification_screen.dart';
import 'package:template_test/features/change_password/presentation/screens/change_password_screen.dart';
import 'package:template_test/features/help_support/presentation/screens/help_support_screen.dart';
import 'package:template_test/features/cart/presentation/screens/cart_screen.dart';

import '../core/network/connectivity_provider.dart';
import '../core/observers/logging_observer.dart';
import '../features/edit_profile/presentation/screens/edit_profile_screen.dart';

final hasCompletedInitialNavigationProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    errorBuilder: (context, state) => const NotFoundScreen(),
    observers: [LoggingObserver()],
    refreshListenable: GoRouterRefreshStream(connectivityService.onStatusChange),

    redirect: (context, state) {
      if (state.matchedLocation == RouteNames.splash) return null;

      if (!ref.read(hasCompletedInitialNavigationProvider)) {
        ref.read(hasCompletedInitialNavigationProvider.notifier).state = true;
        return null;
      }

      final isConnected = ref.read(connectivityServiceProvider).isConnected;
      final offlineModeEnabled = ref.read(offlineModeProvider);
      final onNoInternetRoute = state.matchedLocation == RouteNames.noInternet;

      if (!isConnected && !offlineModeEnabled) {
        return onNoInternetRoute ? null : RouteNames.noInternet;
      }

      if (isConnected && offlineModeEnabled) {
        ref.read(offlineModeProvider.notifier).disable();
      }

      return null;
    },

    routes: [
      GoRoute(path: RouteNames.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.welcome,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(path: RouteNames.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (_, _) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.mainShell,
        builder: (_, _) => const MainShellScreen(),
      ),
      GoRoute(path: RouteNames.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: RouteNames.activity,
        builder: (_, _) => const ActivityScreen(),
      ),
      GoRoute(path: RouteNames.search, builder: (_, _) => const SearchScreen()),
      GoRoute(
        path: RouteNames.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.notFound,
        builder: (_, _) => const NotFoundScreen(),
      ),
      GoRoute(path: RouteNames.error, builder: (_, _) => const ErrorScreen()),
      GoRoute(
        path: RouteNames.noInternet,
        builder: (_, _) => const NoInternetScreen(),
      ),
      GoRoute(
        path: RouteNames.maintenance,
        builder: (_, _) => const MaintenanceScreen(),
      ),
      // Added: routes for the newly added basic screens
      GoRoute(
        path: RouteNames.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.otpVerification,
        builder: (_, _) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: RouteNames.changePassword,
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.helpSupport,
        builder: (_, _) => const HelpSupportScreen(),
      ),
      GoRoute(path: RouteNames.cart, builder: (_, _) => const CartScreen()),
      GoRoute(
        path: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.termsPrivacy,
        builder: (context, state) => const TermsPrivacyScreen(),
      ),
      GoRoute(
        path: RouteNames.auditLog,
        builder: (context, state) => const AuditLogScreen(),
      ),
      GoRoute(
        path: RouteNames.orderList,
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: RouteNames.analyticsMode,
        builder: (context, state) => const AnalyticsModeScreen(),
      ),
      GoRoute(path: RouteNames.product, builder: (context, state) => const ProductScreen()),
  ],
  );
});
