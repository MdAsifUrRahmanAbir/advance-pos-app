import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/utility/barcode_scanner_screen.dart';
import '../../../../core/widgets/utility/custom_bottom_sheet.dart';
import '../../../../core/widgets/utility/custom_refresh_wrapper.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../controllers/stock_controller.dart';
import '../widgets/stock_card_tile.dart';
import '../widgets/stock_detail_sheet.dart';
import '../widgets/stock_filter_tabs.dart';
import '../widgets/stock_list_skeleton.dart';
import '../widgets/stock_search_bar.dart';

class StockTabView extends ConsumerStatefulWidget {
  const StockTabView({super.key});

  @override
  ConsumerState<StockTabView> createState() => _StockTabViewState();
}

class _StockTabViewState extends ConsumerState<StockTabView> {
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

    final match = ref.read(stockControllerProvider.notifier).handleScannedCode(code);
    if (!context.mounted) return;

    if (match != null) {
      CustomBottomSheet.show<void>(context, child: StockDetailSheet(item: match));
    } else {
      CustomSnackbar.show(context, 'Product not found.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockControllerProvider);
    final controller = ref.read(stockControllerProvider.notifier);
    final items = state.filteredItems;

    final isInitialLoad = state.isStocksLoading && state.allItems.isEmpty;

    return Column(
      children: [
        AppHeaderBar(
          title: AppStrings.stockTitle,
          onTrailingTap: () {},
          trailingIcon: Icons.filter_alt_sharp,
        ),
        const SizedBox(height: AppSizes.md),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: StockSearchBar(
                onChanged: (_) {},
                onScanTap: () => _handleScanBarcode(context, ref),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: StockFilterTabs(
                selected: state.selectedStatus,
                onChanged: controller.selectStatus,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Expanded(
          child: isInitialLoad
              ? Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: const StockListSkeleton(itemCount: 6),
            ),
          )
              : items.isEmpty
              ? EmptyState(
            title: AppStrings.stockTitle,
            message: AppStrings.stockEmptyMessage,
            icon: Icons.inventory_2_outlined,
          )
              : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: CustomRefreshWrapper(
                onRefresh: controller.refresh,
                child: ListView(
                  controller: _scrollController,
                  children: [
                    ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
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
                        );
                      },
                    ),
                    if (state.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    const SizedBox(height: AppSizes.bottomNavBarHeight / 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}