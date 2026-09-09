import 'package:advance_pos_app/core/widgets/utility/widget_padding_extension.dart';
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
import '../widgets/stock_search_bar.dart';

class StockMobileView extends ConsumerWidget {
  const StockMobileView({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockControllerProvider);
    final controller = ref.read(stockControllerProvider.notifier);
    final items = state.filteredItems;

    return Column(
      children: [
        AppHeaderBar(
          title: AppStrings.stockTitle,
          onTrailingTap: () {},
          trailingIcon: Icons.filter_alt_sharp,
        ),
        const SizedBox(height: AppSizes.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: StockSearchBar(
            onChanged: (_) {},
            onScanTap: () => _handleScanBarcode(context, ref),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: StockFilterTabs(
            selected: state.selectedStatus,
            onChanged: controller.selectStatus,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Expanded(
          child: items.isEmpty
              ? EmptyState(
            title: AppStrings.stockTitle,
            message: AppStrings.stockEmptyMessage,
            icon: Icons.inventory_2_outlined,
          )
              : CustomRefreshWrapper(
            onRefresh: controller.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              physics: const AlwaysScrollableScrollPhysics(),
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
            ).paddingOnly(bottom: AppSizes.bottomNavBarHeight),
          ),
        ),
      ],
    );
  }
}