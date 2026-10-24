import 'package:advance_pos_app/core/widgets/common/add_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/utility/custom_alert_dialog.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../routes/route_names.dart';
import '../../data/model/expense_model.dart' show ResultDatum;
import '../controllers/expense_controller.dart';
import '../states/expense_state.dart';
import '../widgets/expense_date_range_picker.dart';
import '../widgets/expense_detail_sheet.dart';
import '../widgets/expense_header.dart';
import '../widgets/expense_list_section.dart';
import '../widgets/expense_quick_filter_tabs.dart';

class ExpenseMobileView extends ConsumerWidget {
  const ExpenseMobileView({super.key});

  /// FAB (56) + its margin (16) + breathing room, so the last row is reachable.
  static const double _fabClearance = AppSizes.xxl + AppSizes.xl;

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

    Future<void> pickCustomRange() async {
      final range = await showExpenseDateRangePicker(
        context: context,
        current: state.fromDate != null && state.toDate != null
            ? DateTimeRange(start: state.fromDate!, end: state.toDate!)
            : null,
      );
      if (range != null) {
        controller.applyDatePreset(ExpenseDatePreset.custom, range: range);
      }
    }

    /// Add (expenseNo == null) or edit. The form pops `true` when it saved.
    Future<void> openForm({String? expenseNo}) async {
      final changed = await context.push<bool>(
        RouteNames.expenseForm,
        extra: expenseNo,
      );
      if (changed == true && context.mounted) await refresh();
    }

    Future<void> confirmDelete(ResultDatum item) async {
      final confirmed = await CustomAlertDialog.confirm(
        context,
        title: AppStrings.expDeleteTitle,
        message: AppStrings.expDeleteMessage(item.expenseNo),
        confirmText: AppStrings.delete,
        cancelText: AppStrings.cancel,
        destructive: true,
      );
      if (confirmed != true || !context.mounted) return;

      final ok = await controller.deleteExpense(item.expenseNo);
      if (!context.mounted) return;
      CustomSnackbar.show(
        context,
        ok
            ? AppStrings.expDeleted(item.expenseNo)
            : (ref.read(expenseControllerProvider).errorMessage ??
                  AppStrings.expDeleteFailed),
        error: !ok,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: AddButtonWidget(onTap: () => openForm()),
      body: Column(
        children: [
          ExpenseHeader(onBack: () => context.pop()),
          const SizedBox(height: AppSizes.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: SearchField(
              controller: controller.searchController,
              hintText: AppStrings.expSearchHint,
              onChanged: controller.onSearchChanged,
            ),
          ),
          ExpenseQuickFilterTabs(
            datePreset: state.datePreset,
            fromDate: state.fromDate,
            toDate: state.toDate,
            shownCount: state.expenses.length,
            totalCount: state.totalCount,
            showCount: !state.isInitialLoading && state.totalCount > 0,
            onPresetSelected: controller.applyDatePreset,
            onCustomTap: pickCustomRange,
          ),
          Expanded(
            child: ExpenseListSection(
              items: state.expenses,
              isInitialLoading: state.isInitialLoading,
              isLoadingMore: state.isLoadingMore,
              isLoadMoreFailed: state.isLoadMoreFailed,
              errorMessage: state.errorMessage,
              deletingExpenseNo: state.deletingExpenseNo,
              scrollController: controller.scrollController,
              bottomSpace: _fabClearance,
              onRefresh: refresh,
              onRetry: controller.loadExpenses,
              onRetryLoadMore: controller.loadMore,
              onTapItem: (item) => showExpenseDetailSheet(
                context: context,
                expenseNo: item.expenseNo,
              ),
              onEditItem: (item) => openForm(expenseNo: item.expenseNo),
              onDeleteItem: confirmDelete,
            ),
          ),
        ],
      ),
    );
  }
}
