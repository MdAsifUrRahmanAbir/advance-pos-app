import os
import sys
import subprocess

ROOT = os.getcwd()
LIB_PATH = os.path.join(ROOT, "lib")
PACKAGE_NAME = "template_test2"  # Change this to your actual package name

# =========================================================
# Feature-First Architecture + DI + API + Router Structure
# =========================================================
structure = {
    "core": {
        "constants": ["app_colors.dart", "app_strings.dart", "app_sizes.dart", "api_endpoints.dart"],
        "network": ["api_client.dart", "api_exception.dart"],
        "navigation": ["logging_observer.dart"],
        "di": ["injection_container.dart"],
        "theme": ["app_theme.dart"],
        "utils": ["responsive.dart", "currency_formatter.dart", "date_formatter.dart"]
    },
    "features": {
        "onboarding": {
            "data": ["models/onboarding_model.dart"],
            "presentation": {
                "controllers": ["onboarding_controller.dart"],
                "screens": ["splash_screen.dart", "onboarding_screen.dart", "welcome_screen.dart"],
                "widgets": ["onboarding_item_widget.dart"]
            }
        },
        "login": {
            "data": ["models/user_model.dart", "repositories/login_repository.dart"],
            "presentation": {
                "controllers": ["login_controller.dart"],
                "screens": ["login_screen.dart", "login_mobile_view.dart", "login_tab_view.dart"],
                "widgets": ["login_form.dart", "login_header.dart"]
            }
        },
        "forgot_password": {
            "data": ["repositories/forgot_password_repository.dart"],
            "presentation": {
                "controllers": ["forgot_password_controller.dart"],
                "screens": ["forgot_password_screen.dart", "forgot_password_mobile_view.dart", "forgot_password_tab_view.dart"],
                "widgets": ["forgot_password_form.dart"]
            }
        },
        "reset_password": {
            "data": ["repositories/reset_password_repository.dart"],
            "presentation": {
                "controllers": ["reset_password_controller.dart"],
                "screens": ["reset_password_screen.dart", "reset_password_mobile_view.dart", "reset_password_tab_view.dart"],
                "widgets": ["reset_password_form.dart"]
            }
        },
        "main_shell": {
            "data": [],
            "presentation": {
                "controllers": ["main_shell_controller.dart"],
                "screens": ["main_shell_screen.dart", "main_shell_mobile_view.dart", "main_shell_tab_view.dart"],
                "widgets": ["shell_tab_body.dart", "shell_navigation_item.dart"]
            }
        },
        "home": {
            "data": ["repositories/home_repository.dart"],
            "presentation": {
                "controllers": ["home_controller.dart"],
                "screens": ["home_screen.dart", "home_mobile_view.dart", "home_tab_view.dart"],
                "widgets": ["summary_card.dart", "quick_action_item.dart", "recent_activity_item.dart"]
            }
        },
        "activity": {
            "data": ["models/activity_model.dart", "repositories/activity_repository.dart"],
            "presentation": {
                "controllers": ["activity_controller.dart"],
                "screens": ["activity_screen.dart", "activity_mobile_view.dart", "activity_tab_view.dart"],
                "widgets": ["activity_item.dart"]
            }
        },
        "search": {
            "data": ["repositories/search_repository.dart"],
            "presentation": {
                "controllers": ["search_controller.dart"],
                "screens": ["search_screen.dart", "search_mobile_view.dart", "search_tab_view.dart"],
                "widgets": ["search_result_item.dart", "search_filter_chip.dart"]
            }
        },
        "notifications": {
            "data": ["models/notification_model.dart", "repositories/notification_repository.dart"],
            "presentation": {
                "controllers": ["notification_controller.dart"],
                "screens": ["notifications_screen.dart", "notifications_mobile_view.dart", "notifications_tab_view.dart"],
                "widgets": ["notification_tile.dart"]
            }
        },
        "profile": {
            "data": ["repositories/profile_repository.dart"],
            "presentation": {
                "controllers": ["profile_controller.dart"],
                "screens": [
                    "profile_screen.dart", "profile_mobile_view.dart", "profile_tab_view.dart"
                ],
                "widgets": [
                    "profile_header.dart", "profile_info_section.dart", "profile_action_tile.dart"
                ]
            }
        },

        "register": {
            "data": ["repositories/register_repository.dart"],
            "presentation": {
                "controllers": ["register_controller.dart"],
                "screens": ["register_screen.dart", "register_mobile_view.dart", "register_tab_view.dart"],
                "widgets": ["register_form.dart"]
            }
        },

        "otp_verification": {
            "data": ["repositories/otp_repository.dart"],
            "presentation": {
                "controllers": ["otp_controller.dart"],
                "screens": ["otp_verification_screen.dart", "otp_verification_mobile_view.dart", "otp_verification_tab_view.dart"],
                "widgets": ["otp_input_field.dart"]
            }
        },

        "change_password": {
            "data": ["repositories/change_password_repository.dart"],
            "presentation": {
                "controllers": ["change_password_controller.dart"],
                "screens": ["change_password_screen.dart", "change_password_mobile_view.dart", "change_password_tab_view.dart"],
                "widgets": ["change_password_form.dart"]
            }
        },

        "help_support": {
            "data": ["repositories/help_support_repository.dart"],
            "presentation": {
                "controllers": ["help_support_controller.dart"],
                "screens": ["help_support_screen.dart", "help_support_mobile_view.dart", "help_support_tab_view.dart"],
                "widgets": ["faq_item.dart", "contact_support_tile.dart"]
            }
        },

        "orders": {
            "data": ["models/order_model.dart", "repositories/order_repository.dart"],
            "presentation": {
                "controllers": ["order_controller.dart"],
                "screens": ["order_list_screen.dart", "order_list_mobile_view.dart", "order_list_tab_view.dart"],
                "widgets": ["order_card_item.dart", "order_status_badge.dart"]
            }
        },

        "cart": {
            "data": ["models/cart_item_model.dart", "repositories/cart_repository.dart"],
            "presentation": {
                "controllers": ["cart_controller.dart"],
                "screens": ["cart_screen.dart", "cart_mobile_view.dart", "cart_tab_view.dart"],
                "widgets": ["cart_item_tile.dart", "cart_summary_card.dart"]
            }
        },
        "settings": {
            "data": ["repositories/settings_repository.dart"],
            "presentation": {
                "controllers": ["settings_controller.dart"],
                "screens": ["settings_screen.dart", "settings_mobile_view.dart", "settings_tab_view.dart"],
                "widgets": ["settings_section.dart", "settings_tile.dart", "theme_selector.dart"]
            }
        },
        "system": {
            "data": [],
            "presentation": {
                "controllers": ["system_controller.dart"],
                "screens": [
                    "not_found_screen.dart", "error_screen.dart", "no_internet_screen.dart", "maintenance_screen.dart",
                    # Added: basic static/legal screens missing from the original template
                    "terms_screen.dart", "privacy_policy_screen.dart",
                ],
                "widgets": ["system_message.dart", "retry_action.dart"]
            }
        },
        "products": {
            "data": ["models/product_model.dart", "repositories/product_repository.dart"],
            "presentation": {
                "controllers": ["product_controller.dart"],
                "screens": ["product_list_screen.dart", "product_list_mobile_view.dart", "product_list_tab_view.dart"],
                "widgets": ["product_card_item.dart"]
            }
        },
    },
    "routes": ["app_router.dart", "route_names.dart", "app_initialization.dart"]
}


# =========================================================
# System Templates (Using safe token replacement)
# =========================================================

API_ENDPOINTS_TEMPLATE = """class ApiEndpoints {
  static const String baseUrl = "https://api.yourposapp.com/v1";

  // Auth
  static const String login = "/auth/login";
  static const String register = "/auth/register";

  // Products
  static const String products = "/products";
  static String productDetails(String id) => "/products/$id";

}

"""
LOGGING_OBSERVE = """import 'package:flutter/widgets.dart';
import 'dart:developer' as developer;

/// A [NavigatorObserver] that logs navigation events.
/// It prints the route name (if provided) and the runtime type of the route.
/// This helps during debugging to see which screen is shown and when it is
/// popped. The logs appear in the console via `debugPrint`/`developer.log`.
class LoggingObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    final name = route.settings.name ?? route.runtimeType;
    developer.log('🔁 Pushed route: $name');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final name = route.settings.name ?? route.runtimeType;
    developer.log('⤵️ Popped route: $name');
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    final name = route.settings.name ?? route.runtimeType;
    developer.log('❎ Removed route: $name');
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    final name = newRoute?.settings.name ?? newRoute?.runtimeType;
    developer.log('🔁 Replaced route with: $name');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

/*
Summary for go_router
context.push(path) -> Adds to top (Back button works).
context.replace(path) -> Swaps top screen (Back button goes to screen before the replaced one).
context.go(path) -> Clears stack and jumps to the new location.
 */
"""

API_CLIENT_TEMPLATE = """import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_endpoints.dart';
import 'api_exception.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  late final Dio _dio;
  String? _authToken;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null && _authToken!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        handler.next(e);
      },
    ));
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> patch(
      String path, {
        dynamic data,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Upload a single file (photo, document, etc.)
  Future<Response> uploadFile(
      String path,
      String filePath, {
        String fileKey = 'file',
        Map<String, dynamic>? extraData,
        ProgressCallback? onSendProgress,
        CancelToken? cancelToken,
      }) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(filePath, filename: fileName),
        if (extraData != null) ...extraData,
      });
      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Upload multiple files (photos, documents, etc.) in a single request
  Future<Response> uploadFiles(
      String path,
      List<String> filePaths, {
        String fileKey = 'files[]',
        Map<String, dynamic>? extraData,
        ProgressCallback? onSendProgress,
        CancelToken? cancelToken,
      }) async {
    try {
      List<MultipartFile> multipartFiles = [];
      for (String filePath in filePaths) {
        String fileName = filePath.split('/').last;
        multipartFiles.add(
          await MultipartFile.fromFile(filePath, filename: fileName),
        );
      }

      Map<String, dynamic> mapData = {
        fileKey: multipartFiles,
        if (extraData != null) ...extraData,
      };

      FormData formData = FormData.fromMap(mapData);

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

}
"""

API_EXCEPTION_TEMPLATE = """
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const ApiException(
          message: 'Connection timed out. Please check your internet connection and try again.',
          statusCode: 408,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection available.',
          statusCode: 0,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
          statusCode: 499,
        );

      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Security certificate validation failed.',
          statusCode: 495,
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: e.message ?? 'An unexpected error occurred. Please try again.',
          statusCode: 500,
        );
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message = 'Server error occurred.';
    dynamic errors;

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? data['msg'] ?? 'Server error ($statusCode)';
      errors = data['errors'] ?? data['data'];
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        message = message != 'Server error occurred.' ? message : 'Bad request.';
        break;
      case 401:
        message = message != 'Server error occurred.' ? message : 'Unauthorized. Please login again.';
        break;
      case 403:
        message = message != 'Server error occurred.' ? message : 'Access forbidden.';
        break;
      case 404:
        message = message != 'Server error occurred.' ? message : 'Requested resource not found.';
        break;
      case 422:
        message = message != 'Server error occurred.' ? message : 'Validation failed.';
        break;
      case 500:
      case 502:
      case 503:
      case 504:
        message = 'Internal server error. Please try again later.';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
"""

DI_CONTAINER_TEMPLATE = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:__PACKAGE_NAME__/core/network/api_client.dart';

export 'package:__PACKAGE_NAME__/core/network/api_client.dart' show apiClientProvider;
"""

ROUTE_NAMES_TEMPLATE = """class RouteNames {
  RouteNames._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String mainShell = '/main';
  static const String home = '/home';
  static const String activity = '/activity';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String products = '/products';
  static const String notFound = '/not-found';
  static const String error = '/error';
  static const String noInternet = '/no-internet';
  static const String maintenance = '/maintenance';
  // Added: routes for the newly added basic screens
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String changePassword = '/change-password';
  static const String editProfile = '/edit-profile';
  static const String helpSupport = '/help-support';
  static const String terms = '/terms';
  static const String privacyPolicy = '/privacy-policy';
  static const String orders = '/orders';
  static const String cart = '/cart';
}
"""

APP_ROUTER_TEMPLATE = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:__PACKAGE_NAME__/routes/route_names.dart';
import 'package:__PACKAGE_NAME__/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:__PACKAGE_NAME__/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:__PACKAGE_NAME__/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:__PACKAGE_NAME__/features/login/presentation/screens/login_screen.dart';
import 'package:__PACKAGE_NAME__/features/forgot_password/presentation/screens/forgot_password_screen.dart';
import 'package:__PACKAGE_NAME__/features/reset_password/presentation/screens/reset_password_screen.dart';
import 'package:__PACKAGE_NAME__/features/main_shell/presentation/screens/main_shell_screen.dart';
import 'package:__PACKAGE_NAME__/features/home/presentation/screens/home_screen.dart';
import 'package:__PACKAGE_NAME__/features/activity/presentation/screens/activity_screen.dart';
import 'package:__PACKAGE_NAME__/features/search/presentation/screens/search_screen.dart';
import 'package:__PACKAGE_NAME__/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:__PACKAGE_NAME__/features/profile/presentation/screens/profile_screen.dart';
import 'package:__PACKAGE_NAME__/features/settings/presentation/screens/settings_screen.dart';
import 'package:__PACKAGE_NAME__/features/products/presentation/screens/product_list_screen.dart';
import 'package:__PACKAGE_NAME__/features/system/presentation/screens/not_found_screen.dart';
import 'package:__PACKAGE_NAME__/features/system/presentation/screens/error_screen.dart';
import 'package:__PACKAGE_NAME__/features/system/presentation/screens/no_internet_screen.dart';
import 'package:__PACKAGE_NAME__/features/system/presentation/screens/maintenance_screen.dart';
// Added: imports for the newly added basic screens
import 'package:__PACKAGE_NAME__/features/register/presentation/screens/register_screen.dart';
import 'package:__PACKAGE_NAME__/features/otp_verification/presentation/screens/otp_verification_screen.dart';
import 'package:__PACKAGE_NAME__/features/change_password/presentation/screens/change_password_screen.dart';
import 'package:__PACKAGE_NAME__/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:__PACKAGE_NAME__/features/help_support/presentation/screens/help_support_screen.dart';
import 'package:__PACKAGE_NAME__/features/system/presentation/screens/terms_screen.dart';
import 'package:__PACKAGE_NAME__/features/system/presentation/screens/privacy_policy_screen.dart';
import 'package:__PACKAGE_NAME__/features/orders/presentation/screens/order_list_screen.dart';
import 'package:__PACKAGE_NAME__/features/cart/presentation/screens/cart_screen.dart';
import '../core/navigation/logging_observer.dart';

final routerProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: RouteNames.splash,
  errorBuilder: (context, state) => const NotFoundScreen(),
  observers: [LoggingObserver()],
  routes: [
    GoRoute(path: RouteNames.splash, builder: (_, _) => const SplashScreen()),
    GoRoute(path: RouteNames.onboarding, builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: RouteNames.welcome, builder: (_, _) => const WelcomeScreen()),
    GoRoute(path: RouteNames.login, builder: (_, _) => const LoginScreen()),
    GoRoute(path: RouteNames.forgotPassword, builder: (_, _) => const ForgotPasswordScreen()),
    GoRoute(path: RouteNames.resetPassword, builder: (_, _) => const ResetPasswordScreen()),
    GoRoute(path: RouteNames.mainShell, builder: (_, _) => const MainShellScreen()),
    GoRoute(path: RouteNames.home, builder: (_, _) => const HomeScreen()),
    GoRoute(path: RouteNames.activity, builder: (_, _) => const ActivityScreen()),
    GoRoute(path: RouteNames.search, builder: (_, _) => const SearchScreen()),
    GoRoute(path: RouteNames.notifications, builder: (_, _) => const NotificationsScreen()),
    GoRoute(path: RouteNames.profile, builder: (_, _) => const ProfileScreen()),
    GoRoute(path: RouteNames.settings, builder: (_, _) => const SettingsScreen()),
    GoRoute(path: RouteNames.products, builder: (_, _) => const ProductListScreen()),
    GoRoute(path: RouteNames.notFound, builder: (_, _) => const NotFoundScreen()),
    GoRoute(path: RouteNames.error, builder: (_, _) => const ErrorScreen()),
    GoRoute(path: RouteNames.noInternet, builder: (_, _) => const NoInternetScreen()),
    GoRoute(path: RouteNames.maintenance, builder: (_, _) => const MaintenanceScreen()),
    // Added: routes for the newly added basic screens
    GoRoute(path: RouteNames.register, builder: (_, _) => const RegisterScreen()),
    GoRoute(path: RouteNames.otpVerification, builder: (_, _) => const OtpVerificationScreen()),
    GoRoute(path: RouteNames.changePassword, builder: (_, _) => const ChangePasswordScreen()),
    GoRoute(path: RouteNames.editProfile, builder: (_, _) => const EditProfileScreen()),
    GoRoute(path: RouteNames.helpSupport, builder: (_, _) => const HelpSupportScreen()),
    GoRoute(path: RouteNames.terms, builder: (_, _) => const TermsScreen()),
    GoRoute(path: RouteNames.privacyPolicy, builder: (_, _) => const PrivacyPolicyScreen()),
    GoRoute(path: RouteNames.orders, builder: (_, _) => const OrderListScreen()),
    GoRoute(path: RouteNames.cart, builder: (_, _) => const CartScreen()),
  ],
));
"""

APP_INITIALIZATION = """import 'package:flutter/cupertino.dart';

class AppInitialization {
  AppInitialization();

  static void init(){
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent, // স্ট্যাটাস বারের ব্যাকগ্রাউন্ড ট্রান্সপারেন্ট
    //     statusBarIconBrightness: Brightness.dark, // Android-এর জন্য (Battery, WiFi আইকন ডার্ক করবে)
    //     statusBarBrightness: Brightness.light, // iOS-এর জন্য (Status bar text/icons ডার্ক করবে)
    //   ),
    // );

  }
}
"""

APP_COLORS_TEMPLATE = """import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color primaryLight = Color(0xFFEAE9FF);

  static const Color accent = Color(0xFF00C896);
  static const Color accentLight = Color(0xFFE6F9F5);

  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF636366);
  static const Color textHint = Color(0xFFAEAEB2);
  static const Color textWhite = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);

  static const Color border = Color(0xFFE5E5EA);
  static const Color divider = Color(0xFFF2F2F7);

  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
"""

APP_STRINGS_TEMPLATE = """class AppStrings {
  AppStrings._();

  static const String appName = 'POS App';
  static const String welcomeTitle = 'Welcome to POS App';
  static const String welcomeSubtitle = 'Manage your sales, products, and receipts seamlessly.';
  static const String getStarted = 'Get Started';
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String products = 'Products';
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String errorOccurred = 'Something went wrong. Please try again.';
}
"""

APP_SIZES_TEMPLATE = """class AppSizes {
  AppSizes._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 100.0;

  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  static const double fontXs = 11.0;
  static const double fontSm = 13.0;
  static const double fontMd = 15.0;
  static const double fontLg = 17.0;
  static const double fontXl = 20.0;
  static const double fontXxl = 24.0;
  static const double fontDisplay = 32.0;

  static const double buttonHeight = 52.0;
  static const double inputHeight = 52.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavBarHeight = 64.0;

  static const double mobileBreakpoint = 650.0;
  static const double tabletBreakpoint = 1100.0;
}
"""

APP_THEME_TEMPLATE = """import 'package:flutter/material.dart';
import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppSizes.fontDisplay,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppSizes.fontLg,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppSizes.fontMd,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: AppSizes.fontSm,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
"""

# =========================================================
# New Onboarding Feature Templates
# =========================================================

ONBOARDING_MODEL_TEMPLATE = """class OnboardingModel {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
"""

ONBOARDING_CONTROLLER_TEMPLATE = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:__PACKAGE_NAME__/features/onboarding/data/models/onboarding_model.dart';

class OnboardingController extends Notifier<List<OnboardingModel>> {
  @override
  List<OnboardingModel> build() {
    return const [
      OnboardingModel(
        title: 'Manage Inventory',
        description: 'Track stock and product availability in real time.',
        imagePath: 'assets/images/onboarding1.png',
      ),
      OnboardingModel(
        title: 'Fast Operations',
        description: 'Manage daily business operations efficiently and accurately.',
        imagePath: 'assets/images/onboarding2.png',
      ),
      OnboardingModel(
        title: 'Business Analytics',
        description: 'Gain valuable insights into daily sales and growth.',
        imagePath: 'assets/images/onboarding3.png',
      ),
    ];
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, List<OnboardingModel>>(OnboardingController.new);
"""

SYSTEM_SCREEN_TEMPLATES = {
    "not_found_screen.dart": ("NotFoundScreen", "Page not found", "Icons.search_off"),
    "error_screen.dart": ("ErrorScreen", "Something went wrong", "Icons.error_outline"),
    "no_internet_screen.dart": ("NoInternetScreen", "No internet connection", "Icons.wifi_off"),
    "maintenance_screen.dart": ("MaintenanceScreen", "Service under maintenance", "Icons.build_outlined"),
    # Added: basic static/legal screens
    "terms_screen.dart": ("TermsScreen", "Terms & Conditions", "Icons.description_outlined"),
    "privacy_policy_screen.dart": ("PrivacyPolicyScreen", "Privacy Policy", "Icons.privacy_tip_outlined"),
}

SYSTEM_SCREEN_TEMPLATE = """import 'package:flutter/material.dart';

class __CLASSNAME__ extends StatelessWidget {
  const __CLASSNAME__({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(__SYSTEM_ICON__, size: 56),
            const SizedBox(height: 16),
            Text('__SYSTEM_TITLE__'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
"""

SCREEN_TEMPLATE = """import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
import 'package:__PACKAGE_NAME__/core/constants/app_strings.dart';
import 'package:__PACKAGE_NAME__/routes/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go(RouteNames.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""

ONBOARDING_SCREEN_TEMPLATE = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';
import 'package:__PACKAGE_NAME__/core/constants/app_strings.dart';
import 'package:__PACKAGE_NAME__/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:__PACKAGE_NAME__/routes/route_names.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _onFinish() {
    context.go(RouteNames.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final onboardingList = ref.watch(onboardingControllerProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _onFinish,
            child: const Text(AppStrings.skip),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingList.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final item = onboardingList[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.touch_app, size: 100, color: AppColors.primary),
                        const SizedBox(height: AppSizes.xl),
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          item.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingList.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentIndex == onboardingList.length - 1) {
                    _onFinish();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  _currentIndex == onboardingList.length - 1
                      ? AppStrings.getStarted
                      : AppStrings.next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""

WELCOME_SCREEN_TEMPLATE = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';
import 'package:__PACKAGE_NAME__/core/constants/app_strings.dart';
import 'package:__PACKAGE_NAME__/routes/route_names.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.rocket_launch, size: 90, color: AppColors.primary),
              const SizedBox(height: AppSizes.lg),
              Text(
                AppStrings.welcomeTitle,
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                AppStrings.welcomeSubtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.login),
                child: const Text(AppStrings.login),
              ),
              const SizedBox(height: AppSizes.md),
              OutlinedButton(
                onPressed: () => context.go(RouteNames.products),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                child: const Text('Continue as Guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
"""

SCREEN_TEMPLATE = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:__PACKAGE_NAME__/core/utils/responsive.dart';
import '__BASE_NAME___mobile_view.dart';
import '__BASE_NAME___tab_view.dart';

class __CLASSNAME__ extends ConsumerWidget {
  const __CLASSNAME__({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // appBar: CustomAppBar(title: ""),
      body: Responsive(
        mobile: const __VIEW_CLASSNAME__MobileView(),
        tablet: const __VIEW_CLASSNAME__TabView(),
      ),
    );
  }
}
"""

VIEW_WIDGET_TEMPLATE = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class __CLASSNAME__ extends ConsumerWidget {
  const __CLASSNAME__({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text('__CLASSNAME__'),
    );
  }
}
"""

REPOSITORY_TEMPLATE = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:__PACKAGE_NAME__/core/network/api_client.dart';

final __PROVIDER_NAME__ = Provider<__CLASSNAME__>((ref) {
  return __CLASSNAME__(ref.watch(apiClientProvider));
});

class __CLASSNAME__ {
  final ApiClient _apiClient;
  __CLASSNAME__(this._apiClient);
}
"""

CONTROLLER_TEMPLATE = """import 'package:flutter_riverpod/flutter_riverpod.dart';

class __CLASSNAME__ extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }
}

final __PROVIDER_NAME__ = NotifierProvider<__CLASSNAME__, AsyncValue<void>>(__CLASSNAME__.new);
"""

USER_MODEL_TEMPLATE = """class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
"""

PRODUCT_MODEL_TEMPLATE = """class ProductModel {
  final String id;
  final String name;
  final double price;

  ProductModel({required this.id, required this.name, required this.price});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};
}
"""

AUTH_REPOSITORY_TEMPLATE = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:__PACKAGE_NAME__/core/network/api_client.dart';
import 'package:__PACKAGE_NAME__/features/auth/data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiClientProvider)));

class AuthRepository {
  final ApiClient _apiClient;
  AuthRepository(this._apiClient);

  Future<UserModel> login(String email, String password) async {
    return UserModel(id: '1', name: 'User', email: email);
  }
}
"""

AUTH_CONTROLLER_TEMPLATE = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:__PACKAGE_NAME__/features/auth/data/models/user_model.dart';

class AuthController extends Notifier<AsyncValue<UserModel?>> {
  @override
  AsyncValue<UserModel?> build() => const AsyncValue.data(null);
}

final authControllerProvider = NotifierProvider<AuthController, AsyncValue<UserModel?>>(AuthController.new);
"""

PRODUCT_REPOSITORY_TEMPLATE = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:__PACKAGE_NAME__/core/network/api_client.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) => ProductRepository(ref.watch(apiClientProvider)));

class ProductRepository {
  final ApiClient _apiClient;
  ProductRepository(this._apiClient);
}
"""

PRODUCT_CONTROLLER_TEMPLATE = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:__PACKAGE_NAME__/features/products/data/models/product_model.dart';

class ProductController extends Notifier<AsyncValue<List<ProductModel>>> {
  @override
  AsyncValue<List<ProductModel>> build() => const AsyncValue.data([]);
}

final productControllerProvider = NotifierProvider<ProductController, AsyncValue<List<ProductModel>>>(ProductController.new);
"""

CURRENCY_FORMATTER_TEMPLATE = """class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount) => '\\${amount.toStringAsFixed(2)}';
}
"""

DATE_FORMATTER_TEMPLATE = """class DateFormatter {
  DateFormatter._();

  static String format(DateTime date) => date.toIso8601String();
}
"""

MAIN_DART_TEMPLATE = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:__PACKAGE_NAME__/core/theme/app_theme.dart';
import 'package:__PACKAGE_NAME__/routes/app_router.dart';

import 'routes/app_initialization.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  AppInitialization.init();
  runApp(
    const ProviderScope(
      child: PosApp(),
    ),
  );
}

class PosApp extends ConsumerWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'POS System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
"""

COMMON_WIDGET_TEMPLATES = {
    "primary_button.dart": "// Dynamic primary button template",
    "secondary_button.dart": "// Dynamic secondary button template",
    "icon_button.dart": "// Dynamic icon button template",
    "primary_input_field.dart": "// Dynamic text input template",
    "search_field.dart": "// Dynamic search field template",
    "dropdown_field.dart": "// Dynamic dropdown template",
    "date_field.dart": "// Dynamic date field template",
    "primary_checkbox.dart": "// Dynamic checkbox template",
    "primary_switch.dart": "// Dynamic switch template",
    "custom_app_bar.dart": "// Dynamic AppBar template",
    "custom_card.dart": "// Dynamic card template",
    "custom_list_tile.dart": "// Dynamic list tile template",
    "status_badge.dart": "// Dynamic status badge template",
    "section_header.dart": "// Dynamic section header template",
    "custom_bottom_nav.dart": "// Dynamic bottom navigation template",
    "custom_tab_bar.dart": "// Dynamic tab bar template",
    "custom_loader.dart": "// Dynamic loading indicator template",
    "custom_shimmer.dart": "// Dynamic shimmer template",
    "empty_state.dart": "// Dynamic empty state template",
    "error_state.dart": "// Dynamic error state template",
    "custom_snackbar.dart": "// Dynamic snackbar template",
    "custom_dialog.dart": "// Dynamic dialog template",
    "custom_alert_dialog.dart": "// Dynamic alert dialog template",
    "custom_bottom_sheet.dart": "// Dynamic bottom sheet template",
    "custom_filter_bar.dart": "// Dynamic filter bar template",
    "custom_refresh_wrapper.dart": "// Dynamic refresh wrapper template",
    "custom_network_image.dart": "// Dynamic network image template",
    "responsive.dart": """import 'package:flutter/material.dart';
import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  const Responsive({super.key, required this.mobile, required this.tablet});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= AppSizes.mobileBreakpoint) return tablet;
      return mobile;
    });
  }
}
""",
}


SPLASH_SCREEN_TEMPLATE = """import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
"""

SPECIFIC_FILE_TEMPLATES = {
    "onboarding_model.dart": ONBOARDING_MODEL_TEMPLATE,
    "onboarding_controller.dart": ONBOARDING_CONTROLLER_TEMPLATE,
    "splash_screen.dart": SPLASH_SCREEN_TEMPLATE,
    "onboarding_screen.dart": ONBOARDING_SCREEN_TEMPLATE,
    "welcome_screen.dart": WELCOME_SCREEN_TEMPLATE,
    "user_model.dart": USER_MODEL_TEMPLATE,
    "product_model.dart": PRODUCT_MODEL_TEMPLATE,
    "auth_repository.dart": AUTH_REPOSITORY_TEMPLATE,
    "product_repository.dart": PRODUCT_REPOSITORY_TEMPLATE,
    "auth_controller.dart": AUTH_CONTROLLER_TEMPLATE,
    "product_controller.dart": PRODUCT_CONTROLLER_TEMPLATE,
    "app_colors.dart": APP_COLORS_TEMPLATE,
    "app_strings.dart": APP_STRINGS_TEMPLATE,
    "app_sizes.dart": APP_SIZES_TEMPLATE,
    "api_endpoints.dart": API_ENDPOINTS_TEMPLATE,
    "logging_observer.dart": LOGGING_OBSERVE,
    "api_client.dart": API_CLIENT_TEMPLATE,
    "api_exception.dart": API_EXCEPTION_TEMPLATE,
    "injection_container.dart": DI_CONTAINER_TEMPLATE,
    "app_theme.dart": APP_THEME_TEMPLATE,
    "currency_formatter.dart": CURRENCY_FORMATTER_TEMPLATE,
    "date_formatter.dart": DATE_FORMATTER_TEMPLATE,
    "route_names.dart": ROUTE_NAMES_TEMPLATE,
    "app_router.dart": APP_ROUTER_TEMPLATE,
    "app_initialization.dart": APP_INITIALIZATION,
}

# =========================================================
# Helpers
# =========================================================
def format_class_name(filename):
    base_name = filename.replace(".dart", "")
    return "".join([word.capitalize() for word in base_name.split("_")])

def apply_template_replacements(content, classname="", base_name="", view_classname=""):
    provider_name = classname[0].lower() + classname[1:] + "Provider" if classname else ""
    return (
        content
        .replace("__PACKAGE_NAME__", PACKAGE_NAME)
        .replace("__CLASSNAME__", classname)
        .replace("__BASE_NAME__", base_name)
        .replace("__VIEW_CLASSNAME__", view_classname)
        .replace("__PROVIDER_NAME__", provider_name)
    )

def create_file(file_path, overwrite=False):
    if os.path.exists(file_path) and not overwrite:
        print(f"  ⏭  Skipped (exists): {file_path}")
        return

    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    filename = os.path.basename(file_path)
    classname = format_class_name(filename)

    if filename in SYSTEM_SCREEN_TEMPLATES:
        class_name, title, icon = SYSTEM_SCREEN_TEMPLATES[filename]
        content = SYSTEM_SCREEN_TEMPLATE.replace("__CLASSNAME__", class_name).replace("__SYSTEM_TITLE__", title).replace("__SYSTEM_ICON__", icon)
    elif filename in SPECIFIC_FILE_TEMPLATES:
        content = SPECIFIC_FILE_TEMPLATES[filename]
    elif filename in COMMON_WIDGET_TEMPLATES:
        content = COMMON_WIDGET_TEMPLATES[filename]
    elif filename.endswith("_screen.dart"):
        base_name = filename.replace("_screen.dart", "")
        view_classname = "".join([w.capitalize() for w in base_name.split("_")])
        content = SCREEN_TEMPLATE
        content = apply_template_replacements(content, classname=classname, base_name=base_name, view_classname=view_classname)
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"  ✅ Written: {file_path}")
        return
    elif any(filename.endswith(s) for s in ["_view.dart", "_widget.dart", "_item.dart", "_preview.dart", "_tile.dart", "_card_item.dart"]):
        content = VIEW_WIDGET_TEMPLATE
    elif "repository.dart" in filename:
        content = REPOSITORY_TEMPLATE
    elif "controller.dart" in filename:
        content = CONTROLLER_TEMPLATE
    else:
        content = f"// TODO: Implement {filename}\n"

    content = apply_template_replacements(content, classname=classname)
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  ✅ Written: {file_path}")

def generate_structure(base_path, struct_dict, overwrite=False):
    for key, val in struct_dict.items():
        current_path = os.path.join(base_path, key)
        if isinstance(val, dict):
            generate_structure(current_path, val, overwrite)
        elif isinstance(val, list):
            for file in val:
                create_file(os.path.join(current_path, file), overwrite=overwrite)

# =========================================================
# Auto dependency installer (flutter pub add)
# =========================================================
# Every package actually imported by the templates above. Add more here
# if you extend the templates with new imports (e.g. shared_preferences,
# flutter_secure_storage, google_fonts, fl_chart, intl...).
PUB_DEPENDENCIES = [
    "flutter_riverpod",
    "go_router",
    "dio",
]

def run_pub_add():
    if "--skip-pub-add" in sys.argv:
        print("⏭  Skipping 'flutter pub add' (--skip-pub-add passed).")
        return

    pubspec_path = os.path.join(ROOT, "pubspec.yaml")
    if not os.path.exists(pubspec_path):
        print(f"\n⚠️  No pubspec.yaml found at {pubspec_path}")
        print("   This isn't a Flutter project root yet. Run this first:")
        print("     flutter create --platforms=android,ios .")
        print("   then re-run this script (or just run manually):")
        print(f"     flutter pub add {' '.join(PUB_DEPENDENCIES)}")
        return

    print(f"\n📦 Running: flutter pub add {' '.join(PUB_DEPENDENCIES)}")
    try:
        result = subprocess.run(
            ["flutter", "pub", "add", *PUB_DEPENDENCIES],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        print(result.stdout)
        if result.returncode != 0:
            print(result.stderr)
            print("⚠️  'flutter pub add' failed. Add them manually with:")
            print(f"     flutter pub add {' '.join(PUB_DEPENDENCIES)}")
        else:
            print("✅ Dependencies added to pubspec.yaml.")
    except FileNotFoundError:
        print("⚠️  'flutter' command not found on PATH. Install dependencies manually with:")
        print(f"     flutter pub add {' '.join(PUB_DEPENDENCIES)}")

if __name__ == "__main__":
    overwrite = "--overwrite" in sys.argv or "-o" in sys.argv or True
    print("🚀 Generating POS Clean Architecture with Onboarding Flow...")
    generate_structure(LIB_PATH, structure, overwrite=overwrite)

    main_content = apply_template_replacements(MAIN_DART_TEMPLATE)
    with open(os.path.join(LIB_PATH, "main.dart"), "w", encoding="utf-8") as f:
        f.write(main_content)
    print("\n🎉 File structure done!")

    run_pub_add()
    print("\n🎉 All done! Run 'flutter pub get' if dependencies weren't auto-installed, then 'flutter run'.")