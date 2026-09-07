import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive.dart';
import 'edit_profile_mobile_view.dart';
import 'edit_profile_tab_view.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        mobile: const EditProfileMobileView(),
        tablet: const EditProfileTabView(),
      ),
    );
  }
}
