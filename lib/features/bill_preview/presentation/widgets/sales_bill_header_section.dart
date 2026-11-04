import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/html_text.dart';
import '../../../../core/widgets/utility/custom_network_image.dart';
import '../../data/models/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_format.dart';

/// Receipt top, laid out like the web bill (shopinvoice.blade.php):
/// logo and company name side by side (or centered alone), "Branch
/// [Counter]", address with "Mob:", "RECEIPT", then BIN·MUSHAK and
/// BILL·DATE. Duplicate bills add "DUPLICATE-BILL-COPY · PRINT: …".
class SalesBillHeaderSection extends StatelessWidget {
  final Company company;
  final Branch branch;
  final Counter counter;
  final Invoice invoice;
  final DateTime? printedAt;

  const SalesBillHeaderSection({
    super.key,
    required this.company,
    required this.branch,
    required this.counter,
    required this.invoice,
    this.printedAt,
  });

  /// Server flag value meaning "show on bill".
  static const int _shown = 1;

  /// Web bill sizes the logo in rem (`logo_bill_width_pos`, default 7) —
  /// no tokens, flagged.
  static const double _remToPx = 16;
  static const double _defaultLogoRem = 7;

  /// Logo / name split when both are shown (web: 40% / 60%).
  static const int _logoFlex = 2;
  static const int _nameFlex = 3;

  @override
  Widget build(BuildContext context) {
    final showLogo = company.logoViewBill == _shown &&
        SalesBillPreviewFormat.isPresent(company.logoUrl);
    final showName = company.nameViewBill == _shown &&
        SalesBillPreviewFormat.isPresent(company.name);
    final showAddress = company.brAddViewBill == _shown;

    // Branch fields may arrive as HTML (e.g. "<p>39&amp; 41, ...</p>").
    final branchName =
        SalesBillPreviewFormat.text(HtmlText.toSingleLine(branch.branchName));
    final address =
        SalesBillPreviewFormat.text(HtmlText.toSingleLine(branch.branchAddr));
    final phone = SalesBillPreviewFormat.text(branch.branchPhone);
    final counterName = SalesBillPreviewFormat.text(counter.counterName);

    final branchLine = branchName == null
        ? null
        : counterName == null
            ? branchName
            : AppStrings.billBranchWithCounter(branchName, counterName);
    final addressLine = [
      ?address,
      if (phone != null) '${AppStrings.billMobilePrefix}$phone',
    ].join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLogo || showName) _brandRow(showLogo, showName),
        if (branchLine != null)
          _Centered(branchLine, size: AppSizes.fontSm, weight: FontWeight.w700),
        if (showAddress && addressLine.isNotEmpty)
          _Centered(addressLine, size: AppSizes.fontXs, weight: FontWeight.w400),
        const _Centered(
          AppStrings.billReceiptHeading,
          size: AppSizes.fontLg,
          weight: FontWeight.w700,
        ),
        // TODO: wire to company.bin_no once the invoice API sends it —
        // left: '${AppStrings.billBinLabel}$bin'. branch_code is not the
        // BIN, so the BIN stays hidden until then.
        const _PairRow(right: AppStrings.billMushakLabel),
        _PairRow(
          left: SalesBillPreviewFormat.isPresent(invoice.salesBillNo)
              ? '${AppStrings.billBillLabel}${invoice.salesBillNo}'
              : null,
          right: SalesBillPreviewFormat.isPresent(invoice.date)
              ? '${AppStrings.billDateLabel}${invoice.date}'
              : null,
        ),
        if (invoice.isDuplicate)
          _PairRow(
            left: AppStrings.billDuplicateCopy,
            right: printedAt == null
                ? null
                : '${AppStrings.billPrintLabel}'
                    '${SalesBillPreviewFormat.stamp(printedAt!)}',
          ),
      ],
    );
  }

  Widget _brandRow(bool showLogo, bool showName) {
    final rem = SalesBillPreviewFormat.number(company.logoWidthPos);
    final logo = CustomNetworkImage(
      url: company.logoUrl,
      width: (rem > 0 ? rem : _defaultLogoRem) * _remToPx,
      fit: BoxFit.contain,
      borderRadius: BorderRadius.zero,
      backgroundColor: AppColors.surface,
    );
    final name = Text(
      company.name.toUpperCase(),
      textAlign: showLogo ? TextAlign.start : TextAlign.center,
      style: const TextStyle(
        fontSize: AppSizes.fontXxl,
        fontWeight: FontWeight.w700,
      ),
    );

    if (showLogo && showName) {
      return Row(
        children: [
          Expanded(
            flex: _logoFlex,
            child: Align(alignment: Alignment.centerRight, child: logo),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(flex: _nameFlex, child: name),
        ],
      );
    }
    return showLogo ? Center(child: logo) : name;
  }
}

class _Centered extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;

  const _Centered(this.text, {required this.size, required this.weight});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: size, fontWeight: weight),
    );
  }
}

/// Bold left/right pair; hidden when both sides are absent.
class _PairRow extends StatelessWidget {
  final String? left;
  final String? right;

  const _PairRow({this.left, this.right});

  @override
  Widget build(BuildContext context) {
    if (left == null && right == null) return const SizedBox.shrink();
    const style = TextStyle(fontWeight: FontWeight.w700);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(left ?? '', style: style)),
        if (right != null) ...[
          const SizedBox(width: AppSizes.sm),
          Text(right!, textAlign: TextAlign.end, style: style),
        ],
      ],
    );
  }
}
