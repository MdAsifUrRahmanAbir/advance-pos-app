import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../routes/route_names.dart';
import '../widgets/reset_password_header.dart';
import '../widgets/reset_password_form.dart';

class ResetPasswordMobileView extends ConsumerWidget {
  const ResetPasswordMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.xxl,
          AppSizes.lg,
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
                  // once features/reset_password/data/repositories is implemented.
                  CustomSnackbar.show(
                    context,
                    'Password updated successfully',
                  );
                  context.go(RouteNames.login);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}