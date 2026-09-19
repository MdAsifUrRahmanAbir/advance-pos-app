import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/technical_error_screen.dart';
import '../../../../core/utils/widget_animation_extension.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/utility/barcode_scanner_screen.dart';
import '../../../../core/widgets/utility/custom_bottom_sheet.dart';
import '../../../../core/widgets/utility/custom_refresh_wrapper.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../controllers/stock_controller.dart';
import '../states/stock_state.dart';
import '../widgets/stock_card_tile.dart';
import '../widgets/stock_detail_sheet.dart';
import '../widgets/stock_list_skeleton.dart';
import '../widgets/stock_quick_filter_tabs.dart';
import '../widgets/stock_search_bar.dart';

class StockMobileView extends ConsumerStatefulWidget {
  const StockMobileView({super.key});

  @override
  ConsumerState<StockMobileView> createState() => _StockMobileViewState();
}

class _StockMobileViewState extends ConsumerState<StockMobileView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger loadMore when within 200px of the bottom.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(stockControllerProvider.notifier).loadMore();
    }
  }

  void _showInfo(BuildContext context, dynamic item) {
    CustomBottomSheet.show<void>(context, child: StockDetailSheet(item: item));
  }

  Future<void> _handleScanBarcode(BuildContext context, WidgetRef ref) async {
    final code = await BarcodeScannerScreen.scan(context);
    if (code == null) return;

    final match = await ref
        .read(stockControllerProvider.notifier)
        .handleScannedCode(code);
    if (!context.mounted) return;

    if (match != null) {
      CustomBottomSheet.show<void>(
        context,
        child: StockDetailSheet(item: match),
      );
    } else {
      CustomSnackbar.show(context, 'Product not found.', error: true);
    }
  }

  void _selectTopCategory(int? categoryId) {
    final currentFilter = ref.read(stockControllerProvider).filter;
    ref.read(stockControllerProvider.notifier).applyFilter(
      categoryId == null ? currentFilter.clearing(categoryId: true) : currentFilter.copyWith(categoryId: categoryId),
    );
  }

  void _viewTechnicalDetails(StockState state, StockController controller) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TechnicalErrorScreen(
          errorDetails: state.technicalDetails ?? '',
          onRetry: () {
            Navigator.of(context).pop();
            controller.getStocks(reset: true);
          },
          onReportIssue: () {
            Clipboard.setData(ClipboardData(text: state.technicalDetails ?? ''));
            CustomSnackbar.show(context, 'Technical details copied.');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockControllerProvider);
    final controller = ref.read(stockControllerProvider.notifier);
    final items = state.filteredItems;

    final isInitialLoad = state.isStocksLoading && state.allItems.isEmpty;
    final hasError = state.errorMessage != null && state.allItems.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeaderBar(
          title: AppStrings.stockTitle,
          onTrailingTap: () => Scaffold.of(context).openEndDrawer(),
          trailingIcon: Icons.filter_alt_sharp,
        ),
        const SizedBox(height: AppSizes.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: StockSearchBar(
            controller: controller.searchController,
            onChanged: controller.updateSearchQuery,
            onScanTap: () => _handleScanBarcode(context, ref),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        isInitialLoad
            ? SizedBox.shrink()
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: StockQuickFilterTabs(
            selectedStatus: state.selectedStatus,
            selectedCategoryId: state.filter.categoryId,
            topCategories: ref.watch(masterDataControllerProvider).categoryData?.topCategories ?? const [],
            onStatusSelected: controller.selectStatus,
            onCategorySelected: _selectTopCategory,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Expanded(
          child: isInitialLoad
              ? const StockListSkeleton(itemCount: 6)
              : hasError
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ErrorState(
                  message: state.errorMessage!,
                  onRetry: () => controller.getStocks(reset: true),
                ),
              ),
              if (state.technicalDetails != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.md),
                  child: TextButton(
                    onPressed: () => _viewTechnicalDetails(state, controller),
                    child: const Text('View technical details'),
                  ),
                ),
            ],
          )
              : items.isEmpty
              ? EmptyState(
            title: AppStrings.stockTitle,
            message: AppStrings.stockEmptyMessage,
            icon: Icons.inventory_2_outlined,
          )
              : CustomRefreshWrapper(
            onRefresh: controller.refresh,
            child: ListView(
              controller: _scrollController,
              children: [
                ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSizes.sm + AppSizes.xs),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return StockCardTile(
                      item: item,
                      onShowInfo: () => _showInfo(context, item),
                    ).fadeSlideIn(delay: (index * 60).ms);
                  },
                ),
                if (state.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                SizedBox(height: AppSizes.bottomNavBarHeight / 2),
              ],
            ),
          ),
        ),
      ],
    );
  }
}