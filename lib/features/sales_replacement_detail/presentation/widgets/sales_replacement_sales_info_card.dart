import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../../invoice_detail/data/models/invoice_detail_model.dart'
    show InvoiceDetailModel, ResultData;
import '../states/sales_replacement_detail_format.dart';
import 'sales_replacement_detail_rows.dart';
import 'sales_replacement_line_row.dart';
import 'sales_replacement_totals_row.dart';

/// "Sales Information": the ORIGINAL sale (invoice API) with a "Returned"
/// badge on every line that was returned. Loads on its own, so it shows a
/// skeleton while the invoice loads and an inline retry if it fails —
/// the replacement details below stay visible either way.
class SalesReplacementSalesInfoCard extends StatelessWidget {
  final InvoiceDetailModel? invoice;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  /// Returned quantity per product id (see
  /// `SalesReplacementDetailFormat.returnedQuantities`).
  final Map<int, num> returnedQuantities;

  const SalesReplacementSalesInfoCard({
    super.key,
    required this.invoice,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.returnedQuantities,
  });

  @override
  Widget build(BuildContext context) {
    final data = invoice?.resultData;
    final Widget content;
    if (data != null) {
      content = _Content(data: data, returnedQuantities: returnedQuantities);
    } else if (errorMessage != null && !isLoading) {
      content = _InlineError(message: errorMessage!, onRetry: onRetry);
    } else {
      content = const _Placeholder().skeletonizer(enabled: true);
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.repdSalesInfoSectionTitle,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          content,
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ResultData data;
  final Map<int, num> returnedQuantities;

  const _Content({required this.data, required this.returnedQuantities});

  @override
  Widget build(BuildContext context) {
    final sale = data.sale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SalesReplacementInfoRow(
          label: AppStrings.invoiceBillNoLabel,
          value: sale.salesBillNo,
        ),
        SalesReplacementInfoRow(
          label: AppStrings.repdSaleDateLabel,
          value: sale.salesDate,
        ),
        const SizedBox(height: AppSizes.sm),
        Divider(color: context.appColors.divider),
        const SizedBox(height: AppSizes.sm),
        for (final line in data.saleDetails) ...[
          SalesReplacementLineRow(
            name: line.productName,
            barcode: line.productBarcode,
            unitPrice: line.unitPrice,
            discountRate: line.disRate,
            discountAmount: line.disAmount,
            quantity: line.quantity,
            total: line.taAfterDiscount,
            returnedQuantity: returnedQuantities[line.productId],
          ),
          const SizedBox(height: AppSizes.sm),
        ],
        Divider(color: context.appColors.divider),
        const SizedBox(height: AppSizes.sm),
        SalesReplacementTotalsRow(
          quantity: SalesReplacementDetailFormat.quantity(sale.totalQuantity),
          amount: SalesReplacementDetailFormat.money(sale.totalAmount),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: context.appColors.textSecondary,
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text(AppStrings.retry)),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SalesReplacementInfoRow(
          label: AppStrings.invoiceBillNoLabel,
          value: 'SL00000000000',
        ),
        const SalesReplacementInfoRow(
          label: AppStrings.repdSaleDateLabel,
          value: '0000-00-00',
        ),
        const SizedBox(height: AppSizes.sm),
        for (var i = 0; i < 2; i++) ...[
          const SalesReplacementLineRow(
            name: 'Sample product name',
            barcode: '0000000000',
            unitPrice: '0.00',
            discountRate: '0',
            discountAmount: '0',
            quantity: '1',
            total: '0.00',
          ),
          const SizedBox(height: AppSizes.sm),
        ],
      ],
    );
  }
}