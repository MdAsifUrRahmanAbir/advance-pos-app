import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';

/// Top bar for Edit Sale: back chevron, title + bill number, and a
/// barcode-scan trailing icon (same pattern as New Sale's top bar).
class EditSaleCartTopBar extends AppHeaderBar {
  EditSaleCartTopBar({
    super.key,
    required String billNo,
    required VoidCallback onBack,
    VoidCallback? onScanBarcode,
  }) : super(
    title: AppStrings.editSaleTitle,
    subtitle: billNo,
    backStyle: HeaderBackStyle.chevron,
    onBackTap: onBack,
    trailingIcon: onScanBarcode == null ? null : Icons.qr_code_scanner_rounded,
    onTrailingTap: onScanBarcode,
  );
}