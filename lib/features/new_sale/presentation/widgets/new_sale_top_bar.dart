import 'package:flutter/material.dart';

import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/constants/app_strings.dart';

/// Top bar for New Sale: back chevron, title and an optional barcode-scan
/// trailing icon (hidden when [onScanBarcode] is null — the views now put
/// the scan button beside the search field instead).
/// Thin wrapper around AppHeaderBar — no styling here, since AppHeaderBar
/// already handles the trailing icon's background chip + color internally.
///
/// AppHeaderBar implements PreferredSizeWidget, so it's used as
/// Scaffold.appBar, not as a body-level child.
class NewSaleTopBar extends AppHeaderBar {
  const NewSaleTopBar({
    super.key,
    required VoidCallback onBack,
    VoidCallback? onScanBarcode,
  }) : super(
    title: AppStrings.newSaleTitle,
    backStyle: HeaderBackStyle.chevron,
    onBackTap: onBack,
    trailingIcon:
    onScanBarcode == null ? null : Icons.qr_code_scanner_rounded,
    onTrailingTap: onScanBarcode,
  );
}