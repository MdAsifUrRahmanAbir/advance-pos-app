import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../routes/route_names.dart';
import '../widgets/reset_password_header.dart';
import '../widgets/reset_password_form.dart';

/// Same content as [ResetPasswordMobileView], centered in a
/// fixed-width column for wider (tablet/web) viewports.
class ResetPasswordTabView extends ConsumerWidget {
  const ResetPasswordTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.xl,
              AppSizes.xxl,
              AppSizes.xl,
              AppSizes.xl,
            ),
            child: Column(
              children: [
                const ResetPasswordHeader(),
                const SizedBox(height: AppSizes.xl),
                CustomCard(
                  child: ResetPasswordForm(
                    onSubmit: (newPassword) {
                      // TODO: wire to resetPasswordControllerProvider.updatePassword(newPassword)
                      CustomSnackbar.show(
                        context,
                        'Password updated successfully',
                        // type: SnackbarType.success,
                      );
                      context.go(RouteNames.login);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}