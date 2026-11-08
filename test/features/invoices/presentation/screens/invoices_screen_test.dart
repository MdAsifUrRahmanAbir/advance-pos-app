import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/core/widgets/utility/empty_state.dart';
import 'package:advance_pos_app/core/widgets/utility/error_state.dart';
import 'package:advance_pos_app/features/invoices/data/model/invoices_model.dart';
import 'package:advance_pos_app/features/invoices/presentation/screens/invoices_tab_view.dart';
import 'package:advance_pos_app/features/invoices/presentation/widgets/invoice_card_item.dart';

import '../../helpers/invoice_fixtures.dart';
import '../../helpers/invoice_test_harness.dart';

/// Skeletonizer's public constructor builds a private subclass, so
/// find.byType(Skeletonizer) never matches — match by `is` instead.
final _skeleton =
find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled);

void main() {
  late MockInvoicesRepository repo;

  setUpAll(() async {
    registerFallbackValue(DateTime(2000));
    await seedApiParams();
  });

  setUp(() => repo = MockInvoicesRepository());

  testWidgets('first load shows the skeleton', (tester) async {
    final pending = Completer<InvoicesModel>();
    when(() => anyGetInvoices(repo)).thenAnswer((_) => pending.future);

    await pumpInvoicesApp(tester, repository: repo);
    await pumpFor(tester);

    expect(_skeleton, findsOneWidget);
    pending.complete(invoicesPage(const []));
    await pumpFor(tester);
    expect(_skeleton, findsNothing);
  });

  testWidgets('failed first load shows ErrorState; retry recovers',
          (tester) async {
        when(() => anyGetInvoices(repo))
            .thenThrow(const ApiException(message: 'Server down'));
        await pumpInvoicesApp(tester, repository: repo);
        await pumpFor(tester);
        expect(find.byType(ErrorState), findsOneWidget);
        expect(find.text('Server down'), findsOneWidget);

        when(() => anyGetInvoices(repo))
            .thenAnswer((_) async => invoicesPage(rowsJson(3)));
        await tester.tap(find.descendant(
          of: find.byType(ErrorState),
          matching: find.byType(OutlinedButton),
        ));
        await pumpFor(tester);
        expect(find.byType(InvoiceCardItem), findsNWidgets(3));
      });

  testWidgets('empty result shows EmptyState', (tester) async {
    when(() => anyGetInvoices(repo))
        .thenAnswer((_) async => invoicesPage(const []));
    await pumpInvoicesApp(tester, repository: repo);
    await pumpFor(tester);
    expect(find.byType(EmptyState), findsOneWidget);
  });

  testWidgets('tablet width renders the tab view', (tester) async {
    when(() => anyGetInvoices(repo))
        .thenAnswer((_) async => invoicesPage(rowsJson(2)));
    await pumpInvoicesApp(tester, repository: repo, size: tabletSize);
    await pumpFor(tester);
    expect(find.byType(InvoicesTabView), findsOneWidget);
    expect(find.byType(InvoiceCardItem), findsNWidgets(2));
  });
}