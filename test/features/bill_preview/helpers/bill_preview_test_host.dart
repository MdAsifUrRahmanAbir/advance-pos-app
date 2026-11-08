import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/features/bill_preview/data/repositories/bill_preview_repository.dart';
import 'package:advance_pos_app/features/bill_preview/presentation/screens/sale_complete_launcher.dart';
import 'package:advance_pos_app/features/bill_preview/presentation/screens/sales_bill_preview_launcher.dart';

const hostOpenPreview = 'open-preview';
const hostOpenComplete = 'open-complete';
const hostCompleteTitle = 'Sale complete';
const hostCompleteSubtitle = 'Invoice SB-0001 · Received 990.00';

/// Test-only page with two buttons that open the real launchers, the
/// same way Invoices and Payment do. Exit callbacks pop the sheet and
/// record into [events].
Future<void> pumpBillPreviewHost(
    WidgetTester tester, {
      required BillPreviewRepository repository,
      required List<String> events,
      String billNo = 'SB-0001',
      bool withDone = false,
    }) async {
  void exit(BuildContext sheetContext, String event) {
    Navigator.of(sheetContext).pop();
    events.add(event);
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [billPreviewRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => showSalesBillPreview(context, billNo),
                    child: const Text(hostOpenPreview),
                  ),
                  ElevatedButton(
                    onPressed: () => showSaleCompleteSheet(
                      context,
                      billNo: billNo,
                      title: hostCompleteTitle,
                      subtitle: hostCompleteSubtitle,
                      onNewSale: (s) => exit(s, 'newSale'),
                      onGoToDashboard: (s) => exit(s, 'dashboard'),
                      onDone: withDone ? (s) => exit(s, 'done') : null,
                    ),
                    child: const Text(hostOpenComplete),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}