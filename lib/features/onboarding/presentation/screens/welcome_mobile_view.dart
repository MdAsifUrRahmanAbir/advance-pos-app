import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../controllers/company_code_controller.dart';
import '../widgets/company_code_form.dart';
import '../widgets/welcome_content.dart';

/// Welcome: hero + title, then the company code form. A verified company
/// opens Login (replacing Welcome, so Back doesn't return here).
///
/// Scrollable and anchored to the bottom ([SingleChildScrollView.reverse]):
/// when the keyboard opens, the code field and Verify button stay right
/// above it while the hero scrolls away. With the keyboard closed the
/// content still sits at the bottom of the screen, as before.
class WelcomeMobileView extends ConsumerWidget {
  const WelcomeMobileView({super.key});

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.lg,
    vertical: AppSizes.xl,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companyCodeControllerProvider);
    final controller = ref.read(companyCodeControllerProvider.notifier);

    Future<void> onVerify() async {
      FocusScope.of(context).unfocus();
      final verified = await controller.verify();
      if (!verified || !context.mounted) return;
      context.go(RouteNames.login);
    }

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          reverse: true,
          padding: _padding,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            // Fill the screen when there's room, so the form stays at the
            // bottom; grow past it (and scroll) when the keyboard is open.
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - _padding.vertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const WelcomeContent(),
                const SizedBox(height: AppSizes.xxl),
                CompanyCodeForm(
                  formKey: controller.formKey,
                  controller: controller.codeController,
                  validator: controller.validateCode,
                  onChanged: controller.onCodeChanged,
                  onVerify: onVerify,
                  isVerifying: state.isVerifying,
                  errorMessage: state.errorMessage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}