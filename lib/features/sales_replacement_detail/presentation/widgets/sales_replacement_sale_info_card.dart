import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/sales_replacement_detail_model.dart' show ResultData;
import '../states/sales_replacement_detail_format.dart';
import 'sales_replacement_detail_rows.dart';

/// "Replacement Sale": the new sale's bill, date, customer, VAT invoice
/// and payment method. Products and amounts follow in their own cards.
class SalesReplacementSaleInfoCard extends StatelessWidget {
  final ResultData data;

  const SalesReplacementSaleInfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final s = data.replacementSale;
    final customerNo = data.customerNo;
    final customer = customerNo is String && customerNo.isNotEmpty
        ? '${data.customerName} ($customerNo)'
        : data.customerName;
    final vatChalan = s.vatChalanNo?.toString() ?? '';

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.repdSaleSectionTitle,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          SalesReplacementInfoRow(
            label: AppStrings.repdReplacementBillLabel,
            value: s.salesBillNo,
          ),
          SalesReplacementInfoRow(
            label: AppStrings.repdReplacementDateLabel,
            value: s.salesDate,
          ),
          SalesReplacementInfoRow(
            label: AppStrings.invoiceCustomerLabel,
            value: customer,
          ),
          if (data.customerMobile.isNotEmpty)
            SalesReplacementInfoRow(
              label: AppStrings.invoiceMobileLabel,
              value: data.customerMobile,
            ),
          if (vatChalan.isNotEmpty)
            SalesReplacementInfoRow(
              label: AppStrings.repdVatChalanLabel,
              value: vatChalan,
            ),
          SalesReplacementInfoRow(
            label: AppStrings.invoicePaymentSystemLabel,
            value: SalesReplacementDetailFormat.names(
              s.paymentSystems.map((e) => e.name),
            ),
          ),
          SalesReplacementInfoRow(
            label: AppStrings.invoicePaymentAccountLabel,
            value: SalesReplacementDetailFormat.names(
              s.paymentAccounts.map((e) => e.name),
            ),
          ),
        ],
      ),
    );
  }
}