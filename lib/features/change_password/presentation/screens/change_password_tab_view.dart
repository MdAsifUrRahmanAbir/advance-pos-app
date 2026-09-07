import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../widgets/change_password_form.dart';

/// Same content as [ChangePasswordMobileView], centered in a
/// fixed-width column for wider (tablet/web) viewports.
class ChangePasswordTabView extends ConsumerWidget {
  const ChangePasswordTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          const CustomAppBar(title: AppStrings.changePasswordTitle),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  child: CustomCard(
                    child: ChangePasswordForm(
                      onSave: (currentPassword, newPassword) {
                        // TODO: wire to changePasswordControllerProvider.save(...)
                        CustomSnackbar.show(context, 'Password updated');
                        context.pop();
                      },
                    ),
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