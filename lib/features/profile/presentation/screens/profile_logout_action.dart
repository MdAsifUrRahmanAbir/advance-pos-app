import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/widgets/utility/custom_alert_dialog.dart';
import '../../../../routes/route_names.dart';

/// View-layer wiring shared by the Profile mobile and tab views: asks for
/// confirmation, signs out (clears tokens, session and cache) and goes
/// to Login — the same sign-out Settings uses.
Future<void> confirmAndLogout(BuildContext context, WidgetRef ref) async {
  final confirmed = await CustomAlertDialog.confirm(
    context,
    title: AppStrings.profileLogoutConfirmTitle,
    message: AppStrings.profileLogoutConfirmMessage,
    confirmText: AppStrings.logOut,
    destructive: true,
  );
  if (confirmed != true || !context.mounted) return;

  await ref.read(authSessionControllerProvider.notifier).logout();
  if (!context.mounted) return;
  context.go(RouteNames.login);
}