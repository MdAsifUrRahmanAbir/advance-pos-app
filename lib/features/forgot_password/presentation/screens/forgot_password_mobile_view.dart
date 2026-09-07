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

class ForgotPasswordMobileView extends ConsumerWidget {
  const ForgotPasswordMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.xxl, AppSizes.lg, AppSizes.lg),
              child: Column(
                children: [
                  const ForgotPasswordHeader(),
                  const SizedBox(height: AppSizes.xl),
                  CustomCard(
                    child: ForgotPasswordForm(
                      onSend: (email) {
                        // TODO: wire to forgotPasswordControllerProvider.sendResetLink(email)
                        // once the forgot_password/data/repositories layer is ready.
                        CustomSnackbar.show(context, 'Reset link sent to $email');
                        context.push(RouteNames.resetPassword);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.lg),
            child: BackToLoginLink(
              onTap: () => context.go(RouteNames.login),
            ),
          ),
        ],
      ),
    );
  }
}