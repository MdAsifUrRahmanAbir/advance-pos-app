import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../routes/route_names.dart';
import '../widgets/register_header.dart';
import '../widgets/register_form.dart';
import '../widgets/login_prompt.dart';

/// Same content as [RegisterMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class RegisterTabView extends ConsumerWidget {
  const RegisterTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          const CustomAppBar(title: AppStrings.registerWorkspace),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const RegisterHeader(),
                            const SizedBox(height: AppSizes.lg),
                            RegisterForm(
                              onRegister: (fullName, email, password) {
                                // TODO: wire to registerControllerProvider.register(...)
                                context.push(RouteNames.otpVerification);
                              },
                              onTermsTap: () => context.push(RouteNames.termsPrivacy),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      LoginPrompt(
                        onLoginTap: () => context.go(RouteNames.login),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}