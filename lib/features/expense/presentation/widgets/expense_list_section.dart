import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/utility/error_state.dart';
// TODO: adjust path to wherever WidgetSkeletonizer lives.
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../data/model/expense_model.dart' show ResultDatum;
import '../states/expense_skeleton_data.dart';
import 'expense_empty_view.dart';
import 'expense_list_item.dart';

/// Scrollable expense list: skeleton on first load, error / empty states,
/// pull-to-refresh, and a footer for load-more progress / retry.
class ExpenseListSection extends StatelessWidget {
  final List<ResultDatum> items;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool isLoadMoreFailed;
  final String? errorMessage;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final VoidCallback onRetryLoadMore;
  final ValueChanged<ResultDatum> onTapItem;

  const ExpenseListSection({
    super.key,
    required this.items,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.isLoadMoreFailed,
    required this.errorMessage,
    required this.scrollController,
    required this.onRefresh,
    required this.onRetry,
    required this.onRetryLoadMore,
    required this.onTapItem,
  });

  static const double _emptyTopSpace = 64;

  @override
  Widget build(BuildContext context) {
    final showSkeleton = isInitialLoading && items.isEmpty;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    if (!showSkeleton && items.isEmpty && errorMessage != null) {
      return ErrorState(
        message: errorMessage!,
        onRetry: onRetry,
        retryLabel: AppStrings.expRetry,
      );
    }

    if (!showSkeleton && items.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: _emptyTopSpace),
          children: const [ExpenseEmptyView()],
        ),
      );
    }

    final data = showSkeleton ? ExpenseSkeletonData.items : items;
    final hasFooter = !showSkeleton && (isLoadingMore || isLoadMoreFailed);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: scrollController,
        physics: showSkeleton
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.sm,
          AppSizes.md,
          AppSizes.md + bottomInset,
        ),
        itemCount: data.length + (hasFooter ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm),
        itemBuilder: (context, index) {
          if (index >= data.length) {
            return _Footer(
              isLoading: isLoadingMore,
              onRetry: onRetryLoadMore,
            );
          }
          final item = data[index];
          return ExpenseListItem(
            data: item,
            onTap: showSkeleton ? null : () => onTapItem(item),
          );
        },
      ).skeletonizer(enabled: showSkeleton),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRetry;

  const _Footer({required this.isLoading, required this.onRetry});

  static const double _spinnerSize = 20;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Center(
        child: isLoading
            ? const SizedBox(
          width: _spinnerSize,
          height: _spinnerSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.expLoadMoreFailed,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontSm,
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text(AppStrings.expRetry),
            ),
          ],
        ),
      ),
    );
  }
}