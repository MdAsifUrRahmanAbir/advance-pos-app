import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/session/client_session_controller.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../routes/route_names.dart';
import '../widgets/login_change_company_footer.dart';
import '../widgets/login_client_brand.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';

/// Same content as [LoginMobileView], centered in a fixed-width column
/// for wider (tablet/web) viewports.
class LoginTabView extends ConsumerWidget {
  const LoginTabView({super.key});

  /// Within the project's 480–960 tablet range.
  static const double _maxContentWidth = 480;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientSessionControllerProvider);

    /// Forget the company and go back to company verification.
    Future<void> changeCompany() async {
      await ref.read(clientSessionControllerProvider.notifier).clear();
      if (!context.mounted) return;
      context.go(RouteNames.welcome);
    }

    return SafeArea(
      child: Column(
        children: [
          const CustomAppBar(title: AppStrings.signIn, showBack: false),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (client != null) ...[
                        Center(
                          child: LoginClientBrand(
                            name: client.name,
                            logoUrl: client.logo,
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),
                      ],
                      CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LoginHeader(),
                            const SizedBox(height: AppSizes.lg),
                            LoginForm(
                              onSignIn: (email, password, rememberMe) {
                                // TODO: wire to authControllerProvider.login(email, password)
                                context.go(RouteNames.mainShell);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          LoginChangeCompanyFooter(onChangeCompany: changeCompany),
        ],
      ),
    );
  }
}