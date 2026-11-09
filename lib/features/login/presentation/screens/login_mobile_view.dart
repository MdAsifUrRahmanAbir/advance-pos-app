import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/session/client_session_controller.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/custom_alert_dialog.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../routes/route_names.dart';
import '../controllers/login_controller.dart';
import '../widgets/login_client_brand.dart';
import '../widgets/login_company_footer.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';

class LoginMobileView extends ConsumerWidget {
  const LoginMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientSessionControllerProvider);
    final loginState = ref.watch(loginFormControllerProvider);
    final controller = ref.read(loginFormControllerProvider.notifier);

    /// Confirm, then forget the company and go back to company verification.
    Future<void> switchCompany() async {
      final confirmed = await CustomAlertDialog.confirm(
        context,
        title: AppStrings.companySwitchTitle,
        message: AppStrings.companySwitchMessage(client?.name ?? ''),
        confirmText: AppStrings.companySwitchAction,
        cancelText: AppStrings.cancel,
      );
      if (confirmed != true || !context.mounted) return;
      await ref.read(clientSessionControllerProvider.notifier).clear();
      if (!context.mounted) return;
      context.go(RouteNames.welcome);
    }

    Future<void> signIn() async {
      final ok = await controller.submit();
      if (!context.mounted) return;
      if (ok) {
        context.go(RouteNames.mainShell);
        return;
      }
      final message = ref.read(loginFormControllerProvider).errorMessage;
      if (message != null) CustomSnackbar.show(context, message, error: true);
    }

    return SafeArea(
      child: Column(
        children: [
          const CustomAppBar(title: AppStrings.signIn, showBack: false),
          const SizedBox(height: AppSizes.lg),

          // client is null for a frame after "Switch company" clears it.
          LoginClientBrand(name: '', logoUrl: client?.logo ?? ''),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LoginHeader(),
                    const SizedBox(height: AppSizes.lg),
                    LoginForm(
                      formKey: controller.formKey,
                      usernameController: controller.usernameController,
                      passwordController: controller.passwordController,
                      usernameValidator: controller.validateUsername,
                      passwordValidator: controller.validatePassword,
                      rememberMe: loginState.rememberMe,
                      onRememberMeChanged: controller.setRememberMe,
                      loading: loginState.isSubmitting,
                      onSubmit: signIn,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (client != null)
            LoginCompanyFooter(
              name: client.name,
              compCode: client.compCode,
              logoUrl: client.logo,
              onSwitch: switchCompany,
            ),
        ],
      ),
    );
  }
}