import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../routes/route_names.dart';
import '../widgets/forgot_password_header.dart';
import '../widgets/forgot_password_form.dart';
import '../widgets/back_to_login_link.dart';

/// Same content as [ForgotPasswordMobileView], centered in a
/// fixed-width column for wider (tablet/web) viewports.
class ForgotPasswordTabView extends ConsumerWidget {
  const ForgotPasswordTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(AppSizes.xl, AppSizes.xxl, AppSizes.xl, AppSizes.xl),
                  child: Column(
                    children: [
                      const ForgotPasswordHeader(),
                      const SizedBox(height: AppSizes.xl),
                      CustomCard(
                        child: ForgotPasswordForm(
                          onSend: (email) {
                            // TODO: wire to forgotPasswordControllerProvider.sendResetLink(email)
                            CustomSnackbar.show(context, 'Reset link sent to $email');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.xl),
            child: BackToLoginLink(
              onTap: () => context.go(RouteNames.login),
            ),
          ),
        ],
      ),
    );
  }
}