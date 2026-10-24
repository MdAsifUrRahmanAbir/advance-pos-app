import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/sales_replacement_edit_controller.dart';

class SalesReplacementEditTabView extends ConsumerWidget {
  const SalesReplacementEditTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👈 Accessing State and Controller
    final state = ref.watch(salesReplacementEditControllerProvider);
    final controller = ref.read(salesReplacementEditControllerProvider.notifier);

    if (state.isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SizedBox();
  }
}
