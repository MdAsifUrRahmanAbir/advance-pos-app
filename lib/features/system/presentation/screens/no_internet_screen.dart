import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/session/auth_session_state.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../routes/route_names.dart';
import '../widgets/no_internet_content.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Responsive(
        mobile: NoInternetMobileView(),
        tablet: NoInternetTabView(),
      ),
    );
  }
}

/// Shared callback wiring for both breakpoints, kept out of the layout
/// widgets so [NoInternetMobileView]/[NoInternetTabView] stay pure layout.
class _NoInternetActions {
  const _NoInternetActions(this.context, this.ref);

  final BuildContext context;
  final WidgetRef ref;

  Future<void> checkConnection() async {
    final isConnected = await ref.read(connectivityServiceProvider).checkNow();
    if (!context.mounted) return;
    if (isConnected) {
      context.go(RouteNames.splash);
    } else {
      CustomSnackbar.show(
        context,
        'Still no internet connection.',
        error: true,
      );
    }
  }

  void workOffline() {
    ref.read(offlineModeProvider.notifier).enable();
    // TODO: once cached/local data exists for the shell, point this at
    final status = ref.read(authSessionControllerProvider).status;

    context.go(
      status == AuthStatus.authenticated
          ? RouteNames.mainShell
          : RouteNames.welcome,
    );
  }
}

class NoInternetMobileView extends ConsumerWidget {
  const NoInternetMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = _NoInternetActions(context, ref);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.xl,
        vertical: AppSizes.xxl,
      ),
      child: NoInternetContent(
        onCheckConnection: actions.checkConnection,
        onWorkOffline: actions.workOffline,
      ),
    );
  }
}

/// Same content as [NoInternetMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class NoInternetTabView extends ConsumerWidget {
  const NoInternetTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = _NoInternetActions(context, ref);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: NoInternetContent(
            onCheckConnection: actions.checkConnection,
            onWorkOffline: actions.workOffline,
          ),
        ),
      ),
    );
  }
}
