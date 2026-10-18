import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../controllers/edit_sale_cart_controller.dart';

/// Searchable, paginated customer picker for Edit Sale — the same UX as
/// the cart's picker, but bound to [editSaleCartControllerProvider]
/// (the cart's sheet is hard-wired to the New Sale cart). Pops with the
/// chosen customer.
class EditSaleCustomerSearchSheet extends ConsumerStatefulWidget {
  final String billNo;

  const EditSaleCustomerSearchSheet({super.key, required this.billNo});

  /// Share of the screen height the sheet takes. ⚠️ A ratio, not a size
  /// token — no AppSizes entry fits; promote if another sheet needs it.
  static const double heightFactor = 0.8;

  @override
  ConsumerState<EditSaleCustomerSearchSheet> createState() =>
      _EditSaleCustomerSearchSheetState();
}

class _EditSaleCustomerSearchSheetState extends ConsumerState<EditSaleCustomerSearchSheet> {
  final _scrollController = ScrollController();

  EditSaleCartController get _controller =>
      ref.read(editSaleCartControllerProvider(widget.billNo).notifier);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.ensureCustomersLoaded();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - AppSizes.xxl * 2) {
      _controller.loadMoreCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cart = ref.watch(editSaleCartControllerProvider(widget.billNo)).cart;
    final results = cart.customerResults;
    final isInitialLoading = cart.isCustomerLoading && results.isEmpty;
    final hasError = cart.customerErrorMessage != null && results.isEmpty;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * EditSaleCustomerSearchSheet.heightFactor,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.selectCustomerTitle,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              SearchField(
                controller: _controller.customerSearchController,
                hintText: AppStrings.searchCustomerHint,
                onChanged: _controller.updateCustomerSearchQuery,
              ),
              const SizedBox(height: AppSizes.sm),
              Expanded(
                child: hasError
                    ? ErrorState(
                  message: cart.customerErrorMessage!,
                  onRetry: () => _controller.searchCustomers(reset: true),
                )
                    : isInitialLoading
                    ? const Center(child: CircularProgressIndicator())
                    : results.isEmpty
                    ? const EmptyState(
                  title: AppStrings.noCustomersFoundTitle,
                  message: AppStrings.tryDifferentSearchMessage,
                  icon: Icons.person_search_outlined,
                )
                    : ListView.separated(
                  controller: _scrollController,
                  itemCount: results.length + (cart.customerHasMore ? 1 : 0),
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: colors.divider),
                  itemBuilder: (context, index) {
                    if (index >= results.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final customer = results[index];
                    return Material(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          customer.customerName,
                          style: TextStyle(
                            fontSize: AppSizes.fontSm,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          customer.customerMobile,
                          style: TextStyle(
                            fontSize: AppSizes.fontXs,
                            color: colors.textSecondary,
                          ),
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