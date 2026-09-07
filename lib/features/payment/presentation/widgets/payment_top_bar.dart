import 'package:flutter/material.dart';

import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/constants/app_strings.dart';

/// Thin wrapper around AppHeaderBar — same pattern as NewSaleTopBar.
class PaymentTopBar extends AppHeaderBar {
  const PaymentTopBar({
    super.key,
    required VoidCallback onBack,
  }) : super(
    title: AppStrings.paymentTitle,
    backStyle: HeaderBackStyle.chevron,
    onBackTap: onBack,
  );
}