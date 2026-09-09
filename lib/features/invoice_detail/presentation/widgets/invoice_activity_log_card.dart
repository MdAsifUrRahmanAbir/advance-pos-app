import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/square_icon_tile.dart';
import '../../data/models/invoice_detail_model.dart';

class InvoiceActivityLogCard extends StatelessWidget {
  final List<InvoiceActivityLogEntry> entries;

  const InvoiceActivityLogCard({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.invoiceActivityLogTitle,
            style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          for (final entry in entries) ...[
            Row(
              children: [
                SquareIconTile(
                  icon: entry.action.toLowerCase() == 'create' ? Icons.add_circle_outline_rounded : Icons.edit_outlined,
                  color: entry.action.toLowerCase() == 'create' ? AppColors.success : AppColors.info,
                ),
                const SizedBox(width: AppSizes.sm + AppSizes.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.action} • ${entry.performedBy}',
                        style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600, color: context.appColors.textPrimary),
                      ),
                      Text(
                        _formatDateTime(entry.dateTime),
                        style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (entry != entries.last) const SizedBox(height: AppSizes.sm + AppSizes.xs),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year % 100} $hour:$minute $period';
  }
}