import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'expense_form_mobile_view.dart';

/// Tablet: the same single-column form, centered.
class ExpenseFormTabView extends StatelessWidget {
  final String? expenseNo;

  const ExpenseFormTabView({super.key, this.expenseNo});

  static const double _contentMaxWidth = 720; // no AppSizes token

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: ExpenseFormMobileView(expenseNo: expenseNo),
        ),
      ),
    );
  }
}