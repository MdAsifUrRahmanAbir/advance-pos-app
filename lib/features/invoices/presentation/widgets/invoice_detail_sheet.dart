import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import '../../data/model/invoice_model.dart';
import 'invoice_status_badge.dart';

/// Full invoice breakdown shown in a [CustomBottomSheet] when an
/// [InvoiceCardItem] is tapped — line items, paid/due amounts, and
/// placeholder Share/Download actions.
class InvoiceDetailSheet extends StatelessWidget {
  final InvoiceItem invoice;

  const InvoiceDetailSheet({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: TextStyle(fontSize: AppSizes.fontXl, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
                  ),
                  const SizedBox(height: AppSizes.xs / 2),
                  Text(invoice.customerName, style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary)),
                ],
              ),
            ),
            InvoiceStatusBadge(status: invoice.status, compact: false),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            _DateChip(label: AppStrings.invoiceDateLabel, value: DateFormatter.format(invoice.date)),
            if (invoice.dueDate != null) ...[
              const SizedBox(width: AppSizes.sm),
              _DateChip(label: AppStrings.invoiceDueDateLabel, value: DateFormatter.format(invoice.dueDate!)),
            ],
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: invoice.lineItems.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm),
            itemBuilder: (context, index) {
              final line = invoice.lineItems[index];
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      '${line.name}  ×${line.quantity}',
                      style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textPrimary),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(line.lineTotal, symbol: '৳'),
                    style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600, color: context.appColors.textPrimary),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Divider(color: context.appColors.divider),
        const SizedBox(height: AppSizes.sm),
        _SummaryRow(label: AppStrings.invoiceTotalLabel, value: invoice.total, bold: true),
        _SummaryRow(label: AppStrings.invoicePaidLabel, value: invoice.amountPaid, color: AppColors.success),
        _SummaryRow(label: AppStrings.invoiceDueLabel, value: invoice.amountDue, color: AppColors.error),
        const SizedBox(height: AppSizes.lg),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: AppStrings.invoiceShareAction,
                icon: Icons.share_outlined,
                onPressed: () {
                  // TODO: wire to a share/print flow once available.
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: SecondaryButton(
                label: AppStrings.invoiceDownloadAction,
                icon: Icons.download_outlined,
                onPressed: () {
                  // TODO: wire to a PDF-export flow once available.
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final String value;

  const _DateChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm + AppSizes.xs, vertical: AppSizes.xs + AppSizes.xs / 2),
      decoration: BoxDecoration(color: context.appColors.background, borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textSecondary),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  final Color? color;

  const _SummaryRow({required this.label, required this.value, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? AppSizes.fontMd : AppSizes.fontSm,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? context.appColors.textSecondary,
            ),
          ),
          Text(
            CurrencyFormatter.format(value, symbol: '৳'),
            style: TextStyle(
              fontSize: bold ? AppSizes.fontMd : AppSizes.fontSm,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: color ?? context.appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}