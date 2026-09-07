import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../controllers/edit_profile_controller.dart';
import '../widgets/edit_profile_app_bar.dart';
import '../widgets/edit_profile_photo_section.dart';
import '../widgets/edit_profile_form.dart';

class EditProfileMobileView extends ConsumerWidget {
  const EditProfileMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      editProfileControllerProvider.notifier,
    );

    return Scaffold(
      appBar: EditProfileAppBar(
        onDoneTap: () {
          controller.submit((values) {
            CustomSnackbar.show(
              context,
              'Profile updated successfully',
            );

            context.pop();
          });
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            const EditProfilePhotoSection(
              name: 'Alex Johnson',
            ),

            EditProfileForm(
              onSave: (values) {
                CustomSnackbar.show(
                  context,
                  'Profile updated successfully',
                );

                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}