import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/model/invoice_model.dart';
import 'invoice_status_badge.dart';

/// Single invoice row — invoice # + customer, date, item count + total,
/// and a status badge. Same layout language as [OrderCardItem] but
/// swaps fulfillment status for payment status.
class InvoiceCardItem extends StatelessWidget {
  final InvoiceItem invoice;
  final VoidCallback? onTap;

  const InvoiceCardItem({super.key, required this.invoice, this.onTap});

  @override
  Widget build(BuildContext context) {
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
                      invoice.invoiceNumber,
                      style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
                    ),
                    const SizedBox(height: AppSizes.xs / 2),
                    Text(
                      invoice.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
                    ),
                  ],
                ),
              ),
              InvoiceStatusBadge(status: invoice.status),
            ],
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          Divider(height: 1, color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.format(invoice.date),
                style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textSecondary),
              ),
              Text(
                '${invoice.itemCount} ${AppStrings.invoiceItemsSuffix}',
                style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.format(invoice.total, symbol: '৳'),
                style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}