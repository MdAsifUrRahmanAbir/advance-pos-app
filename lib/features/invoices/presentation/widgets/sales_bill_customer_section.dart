import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../data/model/sales_bill_preview_model.dart';
import '../states/sales_bill_preview_format.dart';
import 'sales_bill_dashed_divider.dart';

/// "CUSTOMER: NAME (mobile)", reward points, then "SALES BY: NAME [code]".
/// Each block is hidden when its name is not present.
class SalesBillCustomerSection extends StatelessWidget {
  final Customer customer;
  final Employee employee;

  const SalesBillCustomerSection({
    super.key,
    required this.customer,
    required this.employee,
  });

  /// Smaller than AppSizes.fontXs, like the printed bill — flagged.
  static const double _fontTiny = 8;

  @override
  Widget build(BuildContext context) {
    final customerName = SalesBillPreviewFormat.text(customer.customerName);
    final employeeName = SalesBillPreviewFormat.text(employee.empName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (customerName != null) ...[
          _SmallLine(
            '${AppStrings.billCustomerLabel}'
                '${SalesBillPreviewFormat.withDetail(customerName.toUpperCase(), customer.customerMobile)}',
          ),
          _SmallLine('${AppStrings.billRewardPoints}${customer.rewardPoints}'),
          const SalesBillDashedDivider(),
        ],
        if (employeeName != null) ...[
          _SmallLine(
            '${AppStrings.billSalesBy}'
                '${SalesBillPreviewFormat.withDetail(employeeName.toUpperCase(), employee.empCode, square: true)}',
          ),
          const SalesBillDashedDivider(),
        ],
      ],
    );
  }
}

class _SmallLine extends StatelessWidget {
  final String text;

  const _SmallLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: SalesBillCustomerSection._fontTiny),
    );
  }
}