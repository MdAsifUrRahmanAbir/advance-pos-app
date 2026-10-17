import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';

/// Thin wrapper around AppHeaderBar — same pattern as PaymentTopBar,
/// with the bill number as subtitle.
class EditSalePaymentTopBar extends AppHeaderBar {
  const EditSalePaymentTopBar({
    super.key,
    required String billNo,
    required VoidCallback onBack,
  }) : super(
    title: AppStrings.editSalePaymentTitle,
    subtitle: billNo,
    backStyle: HeaderBackStyle.chevron,
    onBackTap: onBack,
  );
}