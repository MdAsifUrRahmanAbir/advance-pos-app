import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/order_list_state.dart';


class OrderListController extends Notifier<OrderListState> {
  @override
  OrderListState build() => const OrderListState();

  void selectFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

final orderListControllerProvider =
NotifierProvider.autoDispose<OrderListController, OrderListState>(OrderListController.new);