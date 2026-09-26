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

class CustomersMobileView extends ConsumerStatefulWidget {
  const CustomersMobileView({super.key});

  @override
  ConsumerState<CustomersMobileView> createState() => _CustomersMobileViewState();
}

class _CustomersMobileViewState extends ConsumerState<CustomersMobileView> {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppHeaderBar(title: AppStrings.customersTitle, backStyle: HeaderBackStyle.chevron,),
        const SizedBox(height: AppSizes.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: SearchField(
            controller: controller.searchController,
            hintText: AppStrings.searchCustomerHint,
            onChanged: controller.updateSearchQuery,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        isInitialLoad
            ? const SizedBox.shrink()
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: CustomerFilterTabs(
            selectedType: state.selectedType,
            onTypeSelected: controller.selectType,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
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
            child: ListView(
              controller: _scrollController,
              children: [
                ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm + AppSizes.xs),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CustomerCardItem(
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
      ],
    );
  }
}