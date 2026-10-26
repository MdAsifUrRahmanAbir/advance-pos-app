import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../sales_replacement_detail/presentation/widgets/sales_replacement_detail_rows.dart';

/// Read-only reminder of which sale and customer the replacement is for.
/// The customer comes from the original sale, so it can't be changed here.
class SalesReplacementSaleBanner extends StatelessWidget {
  final String billNo;
  final String customerName;
  final String customerNo;

  const SalesReplacementSaleBanner({
    super.key,
    required this.billNo,
    required this.customerName,
    required this.customerNo,
  });

  @override
  Widget build(BuildContext context) {
    final customer = customerNo.isEmpty
        ? customerName
        : '$customerName ($customerNo)';

    return CustomCard(
      tinted: true,
      child: Column(
        children: [
          SalesReplacementInfoRow(
            label: AppStrings.invoiceBillNoLabel,
            value: billNo,
          ),
          SalesReplacementInfoRow(
            label: AppStrings.invoiceCustomerLabel,
            value: customer,
          ),
        ],
      ),
    );
  }
}