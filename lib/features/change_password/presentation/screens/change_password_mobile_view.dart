import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../widgets/change_password_form.dart';

class ChangePasswordMobileView extends ConsumerWidget {
  const ChangePasswordMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          const CustomAppBar(title: AppStrings.changePasswordTitle),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: CustomCard(
                child: ChangePasswordForm(
                  onSave: (currentPassword, newPassword) {
                    // TODO: wire to changePasswordControllerProvider.save(...)
                    // once the change_password/data/repositories layer is ready.
                    CustomSnackbar.show(context, 'Password updated');
                    context.pop();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}