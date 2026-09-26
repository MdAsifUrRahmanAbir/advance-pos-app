import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/utility/custom_bottom_sheet.dart';
import '../../../../core/widgets/utility/custom_loader.dart';
import '../../../../core/widgets/utility/custom_refresh_wrapper.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../data/models/customers_model.dart';
import '../controllers/customers_controller.dart';
import '../widgets/customer_card_item.dart';
import '../widgets/customer_detail_sheet.dart';
import '../widgets/customer_filter_tabs.dart';

/// Same content as [CustomersMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class CustomersTabView extends ConsumerStatefulWidget {
  const CustomersTabView({super.key});

  @override
  ConsumerState<CustomersTabView> createState() => _CustomersTabViewState();
}

class _CustomersTabViewState extends ConsumerState<CustomersTabView> {
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
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(customersControllerProvider.notifier).loadMore();
    }
  }

  void _showInfo(BuildContext context, ResultDatum item) {
    CustomBottomSheet.show<void>(context, child: CustomerDetailSheet(item: item));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customersControllerProvider);
    final controller = ref.read(customersControllerProvider.notifier);
    final items = state.filteredItems;

    final isInitialLoad = state.isCustomersLoading && state.allItems.isEmpty;
    final hasError = state.errorMessage != null && state.allItems.isEmpty;

    return Column(
      children: [
        const AppHeaderBar(title: AppStrings.customersTitle),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.md, AppSizes.lg, 0),
                    child: SearchField(
                      controller: controller.searchController,
                      hintText: AppStrings.searchCustomerHint,
                      onChanged: controller.updateSearchQuery,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: CustomerFilterTabs(
                      selectedType: state.selectedType,
                      onTypeSelected: controller.selectType,
                    ),
                  ),
                  Expanded(
                    child: isInitialLoad
                        ? const CustomLoader()
                        : hasError
                        ? ErrorState(
                      message: state.errorMessage!,
                      onRetry: () => controller.getCustomers(reset: true),
                    )
                        : items.isEmpty
                        ? EmptyState(
                      title: AppStrings.customersTitle,
                      message: AppStrings.customersEmptyMessage,
                      icon: Icons.people_outline_rounded,
                    )
                        : CustomRefreshWrapper(
                      onRefresh: controller.refresh,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(AppSizes.lg, 0, AppSizes.lg, AppSizes.lg),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= items.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          }
                          final item = items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.sm + AppSizes.xs),
                            child: CustomerCardItem(
                              item: item,
                              onShowInfo: () => _showInfo(context, item),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}