import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/technical_error_screen.dart';
import '../../../../core/utils/widget_animation_extension.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/utility/custom_alert_dialog.dart';
import '../../../../core/widgets/utility/custom_refresh_wrapper.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../../routes/route_names.dart';
import '../../data/models/sales_replacement_model.dart' show ResultDatum;
import '../controllers/sales_replacement_controller.dart';
import '../states/sales_replacement_state.dart';
import '../widgets/sales_replacement_card_tile.dart';
import '../widgets/sales_replacement_date_range_picker.dart';
import '../widgets/sales_replacement_list_footer.dart';
import '../widgets/sales_replacement_list_skeleton.dart';
import '../widgets/sales_replacement_quick_filter_tabs.dart';

class SalesReplacementMobileView extends ConsumerWidget {
  const SalesReplacementMobileView({super.key});

  static const int _staggerResetAt = 15;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesReplacementControllerProvider);
    final controller = ref.read(salesReplacementControllerProvider.notifier);
    final items = state.items;

    final isInitialLoad = state.isInitialLoading && items.isEmpty;
    final hasError =
        !isInitialLoad && state.errorMessage != null && items.isEmpty;
    final hasFooter = state.isLoadingMore || state.isLoadMoreFailed;

    Future<void> refresh() async {
      final ok = await controller.refresh();
      if (!ok && context.mounted) {
        CustomSnackbar.show(
          context,
          ref.read(salesReplacementControllerProvider).errorMessage ??
              AppStrings.repLoadFailed,
          error: true,
        );
      }
    }

    Future<void> pickCustomRange() async {
      final range = await showSalesReplacementDateRangePicker(
        context: context,
        current: state.fromDate != null && state.toDate != null
            ? DateTimeRange(start: state.fromDate!, end: state.toDate!)
            : null,
      );
      if (range != null) {
        controller.applyDatePreset(SalesReplacementDatePreset.custom, range: range);
      }
    }

    void showInfo(ResultDatum item) {
      context.push(RouteNames.salesReplacementDetail, extra: item.returnBillNo);
    }

    void editItem(ResultDatum item) {
      // TODO: navigate to the sales replacement form (RouteNames.salesReplacementForm)
      // once the edit API and screen exist.
      CustomSnackbar.show(context, AppStrings.repEditComingSoon);
    }

    Future<void> confirmDelete(ResultDatum item) async {
      final confirmed = await CustomAlertDialog.confirm(
        context,
        title: AppStrings.repDeleteTitle,
        message: AppStrings.repDeleteMessage(item.returnBillNo),
        confirmText: AppStrings.delete,
        cancelText: AppStrings.cancel,
        destructive: true,
      );
      if (confirmed != true || !context.mounted) return;

      final ok = await controller.deleteSalesReplacement(item.returnBillNo);
      if (!context.mounted) return;
      CustomSnackbar.show(
        context,
        ok
            ? AppStrings.repDeleted(item.returnBillNo)
            : (ref.read(salesReplacementControllerProvider).errorMessage ??
            AppStrings.repDeleteFailed),
        error: !ok,
      );
    }

    void viewTechnicalDetails() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TechnicalErrorScreen(
            errorDetails: state.technicalDetails ?? '',
            onRetry: () {
              Navigator.of(context).pop();
              controller.loadItems();
            },
            onReportIssue: () {
              Clipboard.setData(
                ClipboardData(text: state.technicalDetails ?? ''),
              );
              CustomSnackbar.show(context, AppStrings.technicalDetailsCopied);
            },
          ),
        ),
      );
    }

    final Widget body;
    if (isInitialLoad) {
      body = const SalesReplacementListSkeleton(itemCount: 6);
    } else if (hasError) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ErrorState(
              message: state.errorMessage!,
              onRetry: controller.loadItems,
            ),
          ),
          if (state.technicalDetails != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: TextButton(
                onPressed: viewTechnicalDetails,
                child: const Text(AppStrings.viewTechnicalDetails),
              ),
            ),
        ],
      );
    } else if (items.isEmpty) {
      body = const EmptyState(
        title: AppStrings.repTitle,
        message: AppStrings.repEmptyMessage,
        icon: Icons.swap_horiz_rounded,
      );
    } else {
      body = CustomRefreshWrapper(
        onRefresh: refresh,
        child: ListView.separated(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md,
            0,
            AppSizes.md,
            AppSizes.bottomNavBarHeight / 2,
          ),
          itemCount: items.length + (hasFooter ? 1 : 0),
          separatorBuilder: (_, _) =>
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          itemBuilder: (context, index) {
            if (index >= items.length) {
              return SalesReplacementListFooter(
                isLoading: state.isLoadingMore,
                onRetry: controller.loadMore,
              );
            }
            final item = items[index];
            return SalesReplacementCardTile(
              item: item,
              isDeleting: state.deletingBillNo == item.returnBillNo,
              onShowInfo: () => showInfo(item),
              onEdit: () => editItem(item),
              onDelete: () => confirmDelete(item),
            ).fadeSlideIn(delay: ((index % _staggerResetAt) * 40).ms);
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeaderBar(
          title: AppStrings.repTitle,
          backStyle: context.canPop()
              ? HeaderBackStyle.chevron
              : HeaderBackStyle.none,
          onBackTap: () => context.pop(),
        ),
        const SizedBox(height: AppSizes.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: SearchField(
            controller: controller.searchController,
            hintText: AppStrings.repSearchHint,
            onChanged: controller.onSearchChanged,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        if (!isInitialLoad)
          SalesReplacementQuickFilterTabs(
            datePreset: state.datePreset,
            fromDate: state.fromDate,
            toDate: state.toDate,
            shownCount: items.length,
            totalCount: state.totalCount,
            showCount: state.totalCount > 0,
            onPresetSelected: controller.applyDatePreset,
            onCustomTap: pickCustomRange,
          ),
        const SizedBox(height: AppSizes.sm),
        Expanded(child: body),
      ],
    );
  }
}