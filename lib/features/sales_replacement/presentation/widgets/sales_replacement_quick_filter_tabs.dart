import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';
import '../states/sales_replacement_format.dart';
import '../states/sales_replacement_state.dart';

/// Quick date chips (All · Today · Yesterday · Last 7 Days · This Month ·
/// Last Month · Custom Range) plus a "Showing x of y" counter. Single
/// select; tapping the active preset again goes back to All. Custom Range
/// asks the parent to open the calendar via [onCustomTap].
class SalesReplacementQuickFilterTabs extends StatelessWidget {
  final SalesReplacementDatePreset datePreset;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int shownCount;
  final int totalCount;
  final bool showCount;
  final ValueChanged<SalesReplacementDatePreset> onPresetSelected;
  final VoidCallback onCustomTap;

  const SalesReplacementQuickFilterTabs({
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

  String _label(BuildContext context, SalesReplacementDatePreset preset) {
    if (preset == SalesReplacementDatePreset.custom &&
        datePreset == SalesReplacementDatePreset.custom &&
        fromDate != null &&
        toDate != null) {
      final l10n = MaterialLocalizations.of(context);
      return '${l10n.formatCompactDate(fromDate!)} - '
          '${l10n.formatCompactDate(toDate!)}';
    }
    return SalesReplacementFormat.presetLabel(preset);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomFilterBar<SalesReplacementDatePreset>(
            filters: SalesReplacementDatePreset.values,
            selectedFilters: {datePreset},
            labelBuilder: (preset) => _label(context, preset),
            onSelected: (preset) {
              if (preset == SalesReplacementDatePreset.custom) {
                onCustomTap();
                return;
              }
              final isActiveFilter =
                  preset == datePreset && preset != SalesReplacementDatePreset.all;
              onPresetSelected(
                isActiveFilter ? SalesReplacementDatePreset.all : preset,
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