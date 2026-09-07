import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_filter_bar.dart';
import '../controllers/order_list_controller.dart';

class OrderFilterTabs extends ConsumerWidget {
  const OrderFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(orderListControllerProvider).selectedFilter;

    return CustomFilterBar<String>(
      filters: const ['all', 'pending', 'completed', 'cancelled'],
      selectedFilters: {selected},
      labelBuilder: (f) => switch (f) {
        'all' => AppStrings.orderTabAll,
        'pending' => AppStrings.orderTabPending,
        'completed' => AppStrings.orderTabCompleted,
        _ => AppStrings.orderTabCancelled,
      },
      onSelected: (f) => ref.read(orderListControllerProvider.notifier).selectFilter(f),
    );
  }
}