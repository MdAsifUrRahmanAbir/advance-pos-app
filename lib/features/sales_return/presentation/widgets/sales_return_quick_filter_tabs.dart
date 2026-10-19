import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';
import '../states/sales_return_format.dart';
import '../states/sales_return_state.dart';

/// Quick date chips (All · Today · Yesterday · Last 7 Days · This Month ·
/// Last Month · Custom Range) plus a "Showing x of y" counter. Single
/// select; tapping the active preset again goes back to All. Custom Range
/// asks the parent to open the calendar via [onCustomTap].
class SalesReturnQuickFilterTabs extends StatelessWidget {
  final SalesReturnDatePreset datePreset;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int shownCount;
  final int totalCount;
  final bool showCount;
  final ValueChanged<SalesReturnDatePreset> onPresetSelected;
  final VoidCallback onCustomTap;

  const SalesReturnQuickFilterTabs({
    super.key,
    required this.datePreset,
    required this.fromDate,
    required this.toDate,
    required this.shownCount,
    required this.totalCount,
    required this.showCount,
    required this.onPresetSelected,
    required this.onCustomTap,
  });

  String _label(BuildContext context, SalesReturnDatePreset preset) {
    if (preset == SalesReturnDatePreset.custom &&
        datePreset == SalesReturnDatePreset.custom &&
        fromDate != null &&
        toDate != null) {
      final l10n = MaterialLocalizations.of(context);
      return '${l10n.formatCompactDate(fromDate!)} - '
          '${l10n.formatCompactDate(toDate!)}';
    }
    return SalesReturnFormat.presetLabel(preset);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomFilterBar<SalesReturnDatePreset>(
            filters: SalesReturnDatePreset.values,
            selectedFilters: {datePreset},
            labelBuilder: (preset) => _label(context, preset),
            onSelected: (preset) {
              if (preset == SalesReturnDatePreset.custom) {
                onCustomTap();
                return;
              }
              final isActiveFilter =
                  preset == datePreset && preset != SalesReturnDatePreset.all;
              onPresetSelected(
                isActiveFilter ? SalesReturnDatePreset.all : preset,
              );
            },
          ),
          if (showCount)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.xs),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  AppStrings.expRecordsCount(shownCount, totalCount),
                  style: TextStyle(
                    color: context.appColors.textHint,
                    fontSize: AppSizes.fontXs,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}