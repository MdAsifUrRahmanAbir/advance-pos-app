import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../controllers/order_list_controller.dart';
import '../widgets/order_card_item.dart';
import '../widgets/order_filter_tabs.dart';
import '../widgets/order_status_badge.dart';

class OrderListTabView extends ConsumerWidget {
  const OrderListTabView({super.key});

  // TODO: replace hardcoded orders with orderControllerProvider once
  // features/orders/data/repositories is implemented.
  static const _orders = [
    OrderCardItem(
      orderId: '#ORD-2026-1284',
      date: 'Feb 23, 2026',
      status: OrderStatus.pending,
      itemImageUrls: ['https://placehold.co/64x64', 'https://placehold.co/64x64', 'https://placehold.co/64x64'],
      itemCount: 3,
      total: '\$253.25',
    ),
    OrderCardItem(
      orderId: '#ORD-2026-1102',
      date: 'Feb 18, 2026',
      status: OrderStatus.completed,
      itemImageUrls: ['https://placehold.co/64x64', 'https://placehold.co/64x64', 'https://placehold.co/64x64'],
      itemCount: 1,
      total: '\$49.50',
    ),
    OrderCardItem(
      orderId: '#ORD-2026-1051',
      date: 'Feb 12, 2026',
      status: OrderStatus.cancelled,
      itemImageUrls: ['https://placehold.co/64x64', 'https://placehold.co/64x64', 'https://placehold.co/64x64'],
      itemCount: 2,
      total: '\$184.99',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(orderListControllerProvider).selectedFilter;
    final filteredOrders = selectedFilter == 'all'
        ? _orders
        : _orders.where((order) => order.status.name == selectedFilter).toList();

    return Column(
      children: [
        const AppHeaderBar(title: AppStrings.myOrdersTitle),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: OrderFilterTabs(),
                    ),
                    const SizedBox(height: AppSizes.md),
                    for (final order in filteredOrders) ...[
                      order,
                      if (order != filteredOrders.last) const SizedBox(height: AppSizes.sm + AppSizes.xs),
                    ],
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