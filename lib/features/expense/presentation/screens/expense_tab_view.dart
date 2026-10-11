import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../controllers/expense_controller.dart';
import '../states/expense_state.dart';
import '../widgets/expense_date_filter_bar.dart';
import '../widgets/expense_date_range_sheet.dart';
import '../widgets/expense_detail_sheet.dart';
import '../widgets/expense_header.dart';
import '../widgets/expense_list_section.dart';

class ExpenseTabView extends ConsumerWidget {
  const ExpenseTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseControllerProvider);
    final controller = ref.read(expenseControllerProvider.notifier);

    Future<void> refresh() async {
      final ok = await controller.refresh();
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(expenseControllerProvider).errorMessage ??
                  AppStrings.expLoadFailed,
            ),
          ),
        );
      }
    }

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          ExpenseHeader(onBack: () => context.pop()),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    const SizedBox(height: AppSizes.md),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: SearchField(
                        controller: controller.searchController,
                        hintText: AppStrings.expSearchHint,
                        onChanged: controller.onSearchChanged,
                      ),
                    ),
                    ExpenseDateFilterBar(
                      datePreset: state.datePreset,
                      fromDate: state.fromDate,
                      toDate: state.toDate,
                      shownCount: state.expenses.length,
                      totalCount: state.totalCount,
                      showCount:
                      !state.isInitialLoading && state.totalCount > 0,
                      onDateTap: () => showExpenseDateRangeSheet(
                        context: context,
                        selected: state.datePreset,
                        currentRange:
                        state.fromDate != null && state.toDate != null
                            ? DateTimeRange(
                          start: state.fromDate!,
                          end: state.toDate!,
                        )
                            : null,
                        onPresetSelected: controller.applyDatePreset,
                        onCustomRange: (range) => controller.applyDatePreset(
                          ExpenseDatePreset.custom,
                          range: range,
                        ),
                      ),
                      onClearDate: () =>
                          controller.applyDatePreset(ExpenseDatePreset.all),
                    ),
                    Expanded(
                      child: ExpenseListSection(
                        items: state.expenses,
                        isInitialLoading: state.isInitialLoading,
                        isLoadingMore: state.isLoadingMore,
                        isLoadMoreFailed: state.isLoadMoreFailed,
                        errorMessage: state.errorMessage,
                        scrollController: controller.scrollController,
                        onRefresh: refresh,
                        onRetry: controller.loadExpenses,
                        onRetryLoadMore: controller.loadMore,
                        onTapItem: (item) => showExpenseDetailSheet(
                          context: context,
                          expenseNo: item.expenseNo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}