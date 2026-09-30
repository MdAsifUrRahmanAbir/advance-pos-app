import 'package:advance_pos_app/features/customers/presentation/screens/customers_screen.dart';
import 'package:advance_pos_app/features/invoice_detail/presentation/screens/invoice_detail_screen.dart';
import 'package:advance_pos_app/features/invoices/presentation/screens/invoices_screen.dart';
import 'package:advance_pos_app/features/product/presentation/screens/product_screen.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:advance_pos_app/features/order_list/presentation/screens/order_list_screen.dart';
import 'package:advance_pos_app/features/terms_privacy/presentation/screens/terms_privacy_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:advance_pos_app/routes/route_names.dart';
import 'package:advance_pos_app/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:advance_pos_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:advance_pos_app/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:advance_pos_app/features/login/presentation/screens/login_screen.dart';
import 'package:advance_pos_app/features/forgot_password/presentation/screens/forgot_password_screen.dart';
import 'package:advance_pos_app/features/reset_password/presentation/screens/reset_password_screen.dart';
import 'package:advance_pos_app/features/main_shell/presentation/screens/main_shell_screen.dart';
import 'package:advance_pos_app/features/home/presentation/screens/home_screen.dart';
import 'package:advance_pos_app/features/search/presentation/screens/search_screen.dart';
import 'package:advance_pos_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:advance_pos_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:advance_pos_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:advance_pos_app/features/system/presentation/screens/not_found_screen.dart';
import 'package:advance_pos_app/features/system/presentation/screens/error_screen.dart';
import 'package:advance_pos_app/features/system/presentation/screens/no_internet_screen.dart';
import 'package:advance_pos_app/features/system/presentation/screens/maintenance_screen.dart';
// Added: imports for the newly added basic screens
import 'package:advance_pos_app/features/register/presentation/screens/register_screen.dart';
import 'package:advance_pos_app/features/otp_verification/presentation/screens/otp_verification_screen.dart';
import 'package:advance_pos_app/features/change_password/presentation/screens/change_password_screen.dart';
import 'package:advance_pos_app/features/help_support/presentation/screens/help_support_screen.dart';
import 'package:advance_pos_app/features/cart/presentation/screens/cart_screen.dart';

import '../core/network/connectivity_provider.dart';
import '../core/observers/logging_observer.dart';
import '../features/edit_profile/presentation/screens/edit_profile_screen.dart';
import '../features/new_sale/presentation/screens/new_sale_screen.dart';
import '../features/payment/presentation/screens/payment_screen.dart';
import '../features/stock/presentation/screens/stock_screen.dart';
import 'build_page_with_transition.dart';

final hasCompletedInitialNavigationProvider = StateProvider<bool>(
  (ref) => false,
);

final routerProvider = Provider<GoRouter>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    errorBuilder: (context, state) => const NotFoundScreen(),
    observers: [LoggingObserver()],
    refreshListenable: GoRouterRefreshStream(
      connectivityService.onStatusChange,
    ),

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
      GoRoute(
        path: RouteNames.splash,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
          animationType: PageTransitionType.fade,
        ),
      ),

      GoRoute(
        path: RouteNames.onboarding,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.welcome,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const WelcomeScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.login,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.forgotPassword,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.resetPassword,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ResetPasswordScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.mainShell,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const MainShellScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.home,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.search,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const SearchScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.notifications,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const NotificationsScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.profile,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.notFound,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const NotFoundScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.error,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ErrorScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.noInternet,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const NoInternetScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.maintenance,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const MaintenanceScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.register,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const RegisterScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.otpVerification,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const OtpVerificationScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.settings,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.editProfile,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const EditProfileScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.changePassword,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ChangePasswordScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.helpSupport,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const HelpSupportScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.cart,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const CartScreen(),
          animationType: PageTransitionType.slideFromBottom,
        ),
      ),

      GoRoute(
        path: RouteNames.termsPrivacy,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const TermsPrivacyScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.orderList,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const OrderListScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.product,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ProductScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.stock,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const StockScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.newSale,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const NewSaleScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.payment,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const PaymentScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.invoices,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const InvoicesScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.invoiceDetail,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: InvoiceDetailScreen(invoiceId: state.extra as String),
        ),
      ),

      GoRoute(
        path: RouteNames.customers,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const CustomersScreen(),
        ),
      ),
    ],
  );
});
