import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/sales_replacement_add_controller.dart';

class SalesReplacementAddTabView extends ConsumerWidget {
  const SalesReplacementAddTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👈 Accessing State and Controller
    final state = ref.watch(salesReplacementAddControllerProvider);
    final controller = ref.read(salesReplacementAddControllerProvider.notifier);

    if (state.isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SizedBox();
  }
}
