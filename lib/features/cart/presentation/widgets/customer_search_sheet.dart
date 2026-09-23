import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../controllers/cart_controller.dart';

/// Searchable, paginated customer picker — backed by [CartController]
/// (same controller Cart already uses, not a new one). Opened as a
/// modal bottom sheet from [CustomerSelectorRow]; selecting a row pops
/// the sheet with the chosen customer.
class CustomerSearchSheet extends ConsumerStatefulWidget {
  const CustomerSearchSheet({super.key});

  @override
  ConsumerState<CustomerSearchSheet> createState() => _CustomerSearchSheetState();
}

class _CustomerSearchSheetState extends ConsumerState<CustomerSearchSheet> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartControllerProvider.notifier).ensureCustomersLoaded();
    });
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
    if (position.pixels >= position.maxScrollExtent - 100) {
      ref.read(cartControllerProvider.notifier).loadMoreCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);
    final hasError = state.customerErrorMessage != null && state.customerResults.isEmpty;
    final isInitialLoading = state.isCustomerLoading && state.customerResults.isEmpty;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusLg),
            topRight: Radius.circular(AppSizes.radiusLg),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.selectCustomerTitle,
                    style: TextStyle(color: AppColors.textPrimary, fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700),
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              SearchField(
                controller: controller.customerSearchController,
                hintText: AppStrings.searchCustomerHint,
                onChanged: controller.updateCustomerSearchQuery,
              ),
              const SizedBox(height: AppSizes.sm),
              Expanded(
                child: hasError
                    ? ErrorState(
                  message: state.customerErrorMessage!,
                  onRetry: () => controller.searchCustomers(reset: true),
                )
                    : (!isInitialLoading && state.customerResults.isEmpty)
                    ? const EmptyState(
                  title: AppStrings.noCustomersFoundTitle,
                  message: AppStrings.tryDifferentSearchMessage,
                  icon: Icons.person_search_outlined,
                )
                    : ListView.separated(
                  controller: _scrollController,
                  itemCount: state.customerResults.length + (state.customerHasMore ? 1 : 0),
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.divider),
                  itemBuilder: (context, index) {
                    if (index >= state.customerResults.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    final customer = state.customerResults[index];
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          customer.customerName,
                          style: const TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          customer.customerMobile,
                          style: const TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textSecondary),
                        ),
                        onTap: () => Navigator.of(context).pop(customer),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}