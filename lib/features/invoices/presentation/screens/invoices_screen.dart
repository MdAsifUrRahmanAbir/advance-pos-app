import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive.dart';
import '../controllers/invoices_controller.dart';
import '../widgets/invoice_filter_drawer.dart';
import 'invoices_mobile_view.dart';
import 'invoices_tab_view.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      endDrawer: InvoiceFilterDrawer(
        initialFilter: ref.watch(invoicesControllerProvider).filter,
        onApply: (filter) => ref.read(invoicesControllerProvider.notifier).applyFilter(filter),
      ),
      body: const Responsive(
        mobile: InvoicesMobileView(),
        tablet: InvoicesTabView(),
      ),
    );
  }
}