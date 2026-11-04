import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/settings_group.dart';
import 'profile_info_row.dart';

/// EMPLOYEE group: the signed-in employee's name, ID and employee no.
class ProfileEmployeeSection extends StatelessWidget {
  final String? name;
  final int? employeeId;
  final String? employeeNo;

  const ProfileEmployeeSection({
    super.key,
    required this.name,
    required this.employeeId,
    required this.employeeNo,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      label: AppStrings.profileEmployeeSection,
      children: [
        ProfileInfoRow(
          icon: Icons.person_outline_rounded,
          label: AppStrings.profileEmployeeNameLabel,
          value: name,
        ),
        ProfileInfoRow(
          icon: Icons.badge_outlined,
          label: AppStrings.profileEmployeeIdLabel,
          value: employeeId?.toString(),
        ),
        ProfileInfoRow(
          icon: Icons.tag_rounded,
          label: AppStrings.profileEmployeeNoLabel,
          value: employeeNo,
        ),
      ],
    );
  }
}
