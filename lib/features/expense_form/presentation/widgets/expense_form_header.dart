import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';

/// Add / Edit title with a back chevron.
class ExpenseFormHeader extends AppHeaderBar {
  const ExpenseFormHeader({
    super.key,
    required bool isEdit,
    required VoidCallback onBack,
  }) : super(
    title: isEdit ? AppStrings.expFormEditTitle : AppStrings.expFormAddTitle,
    backStyle: HeaderBackStyle.chevron,
    onBackTap: onBack,
  );
}