import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive.dart';
import '../controllers/stock_controller.dart';
import '../widgets/stock_filter_drawer.dart';
import 'stock_mobile_view.dart';
import 'stock_tab_view.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      endDrawer: StockFilterDrawer(
        initialFilter: ref.watch(stockControllerProvider).filter,
        onApply: (filter) => ref.read(stockControllerProvider.notifier).applyFilter(filter),
      ),
      body: const Responsive(
        mobile: StockMobileView(),
        tablet: StockTabView(),
      ),
    );
  }
}