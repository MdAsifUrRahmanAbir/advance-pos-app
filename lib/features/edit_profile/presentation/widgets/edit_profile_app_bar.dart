import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';

/// Top bar for the edit-profile screen — back chevron, "Edit Profile"
/// title, and a "Done" text action.
class EditProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onDoneTap;

  const EditProfileAppBar({super.key, this.onDoneTap});

  @override
  Widget build(BuildContext context) {
    return AppHeaderBar (
      title: AppStrings.editProfileTitle,
      trailingLabel: AppStrings.done,
      onTrailingTap: onDoneTap,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}