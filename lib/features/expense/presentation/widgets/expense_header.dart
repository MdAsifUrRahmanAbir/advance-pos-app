import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';

/// Screen header: optional back button (only when there is a route to pop),
/// title, optional trailing action.
class ExpenseHeader extends AppHeaderBar {
  const ExpenseHeader({
    super.key,
    required VoidCallback onBack,
  }) : super(
    title: AppStrings.expense,
    backStyle: HeaderBackStyle.chevron,
    onBackTap: onBack,
  );
}