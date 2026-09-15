import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';

class CartTopBar extends AppHeaderBar {
  const CartTopBar({
    super.key,
    required VoidCallback onBack,
    required VoidCallback onClearAll,
  }) : super(
         title: AppStrings.reviewCartTitle,
         backStyle: HeaderBackStyle.chevron,
         onBackTap: onBack,
         trailingLabel: AppStrings.clearAllAction,
         trailingLabelColor: AppColors.error,
         onTrailingTap: onClearAll,
       );
}
