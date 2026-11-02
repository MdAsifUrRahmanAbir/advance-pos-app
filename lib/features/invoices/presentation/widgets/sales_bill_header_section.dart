import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/utility/custom_network_image.dart';
import '../../data/model/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_format.dart';
import '../../../../core/utils/html_text.dart';

/// Receipt top: logo / company / branch / address, "RECEIPT", then the
/// BIN·MUSHAK, BILL·DATE and DUPLICATE·PRINT pairs.
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

  @override
  Widget build(BuildContext context) {
    final showLogo =
        company.logoViewBill == _shown && SalesBillPreviewFormat.isPresent(company.logoUrl);
    // Branch fields may arrive as HTML (e.g. "<p>39&amp; 41, ...</p>").
    final branchName = SalesBillPreviewFormat.text(
      HtmlText.toSingleLine(branch.branchName),
    );
    final address = SalesBillPreviewFormat.text(
      HtmlText.toSingleLine(branch.branchAddr),
    );    final showCompanyName =
        company.nameViewBill == _shown && SalesBillPreviewFormat.isPresent(company.name);
    final showAddress = company.brAddViewBill == _shown;

    final phone = SalesBillPreviewFormat.text(branch.branchPhone);
    final bin = SalesBillPreviewFormat.text(branch.branchCode);
    final counterName = SalesBillPreviewFormat.text(counter.counterName);
    final vatChalan = SalesBillPreviewFormat.text(invoice.vatChalanNo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLogo) ...[
          Center(
            child: CustomNetworkImage(
              url: company.logoUrl,
              height: AppSizes.xxl,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.zero,
              backgroundColor: AppColors.surface,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
        ],        if (showCompanyName) _Centered(company.name, size: AppSizes.fontLg),
        if (branchName != null) _Centered(branchName, size: AppSizes.fontLg),
        if (showAddress && address != null)
          _Centered(address, weight: FontWeight.w400),
        if (showAddress && phone != null)
          _Centered('${AppStrings.billMobilePrefix}$phone',
              weight: FontWeight.w400),
        const SizedBox(height: AppSizes.xs),
        const _Centered(
          AppStrings.billReceiptHeading,
          size: AppSizes.fontLg,
          weight: FontWeight.w800,
        ),
        const SizedBox(height: AppSizes.xs),
        // TODO: confirm BIN maps to branch.branch_code with the backend.
        _PairRow(
          left: bin == null ? null : '${AppStrings.billBinLabel}$bin',
          right: AppStrings.billMushakLabel,
        ),
        _PairRow(
          left: SalesBillPreviewFormat.isPresent(invoice.salesBillNo)
              ? '${AppStrings.billBillLabel}${invoice.salesBillNo}'
              : null,
          right: SalesBillPreviewFormat.isPresent(invoice.date)
              ? '${AppStrings.billDateLabel}${invoice.date}'
              : null,
        ),
        _PairRow(
          left: invoice.isDuplicate ? AppStrings.billDuplicateCopy : null,
          right: printedAt == null
              ? null
              : '${AppStrings.billPrintLabel}${SalesBillPreviewFormat.stamp(printedAt!)}',
        ),
        _PairRow(
          left: counterName == null
              ? null
              : '${AppStrings.billCounterLabel}$counterName',
          right: vatChalan == null
              ? null
              : '${AppStrings.billVatChalanLabel}$vatChalan',
        ),
      ],
    );
  }
}

class _Centered extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;

  const _Centered(
      this.text, {
        this.size = AppSizes.fontXs,
        this.weight = FontWeight.w700,
      });

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