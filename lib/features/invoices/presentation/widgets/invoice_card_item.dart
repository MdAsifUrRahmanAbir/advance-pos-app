import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/model/invoices_model.dart';
import 'invoice_status_badge.dart';

/// Single invoice row — invoice # + customer, product summary, date,
/// item count + total, and a computed payment-status badge.
class InvoiceCardItem extends StatelessWidget {
  final ResultDatum invoice;
  final VoidCallback? onTap;

  const InvoiceCardItem({super.key, required this.invoice, this.onTap});

  @override
  Widget build(BuildContext context) {
    final total = parseAmount(invoice.totalPayableAmount);
    final qty = parseQuantity(invoice.totalQuantity);

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.salesBillNo,
                      style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
                    ),
                    const SizedBox(height: AppSizes.xs / 2),
                    Text(
                      invoice.customerName.isEmpty ? 'Walk-in Customer' : invoice.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
                    ),
                  ],
                ),
              ),
              InvoiceStatusBadge(invoice: invoice),
            ],
          ),
          if (invoice.productNames.isNotEmpty) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              invoice.productNames.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textHint),
            ),
          ],
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          Divider(height: 1, color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.salesDate,
                style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textSecondary),
              ),
              Text(
                '$qty items',
                style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.format(total, ),
                style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}