import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/core/widgets/utility/error_state.dart';
import 'package:advance_pos_app/features/invoices/presentation/widgets/invoice_card_item.dart';

import '../test/features/invoices/helpers/fake_invoices_repository.dart';
import '../test/features/invoices/helpers/invoice_fixtures.dart';
import '../test/features/invoices/helpers/invoice_test_harness.dart';

const _reason = 'This data has Dependencies.';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeInvoicesRepository repo;

  setUpAll(seedApiParams);

  setUp(() {
    repo = FakeInvoicesRepository(rowsJson(20, overrides: {
      1: {'blocked_actions': ['delete', 'edit'], 'blocked_reason': _reason},
      3: {'blocked_actions': ['delete'], 'blocked_reason': _reason},
    }));
  });

  /// Real device size — no view override on a live binding.
  Future<void> pumpApp(WidgetTester tester) async {
    await pumpInvoicesApp(tester, repository: repo, size: null);
    await pumpFor(tester);
  }

  /// The list the user actually scrolls. The mobile view nests a
  /// non-scrolling, shrink-wrapped list inside it; ancestors are listed
  /// nearest-first, so `.last` is the outer, scrollable one.
  Finder listScrollable() => find
      .ancestor(of: find.text('SB-0001'), matching: find.byType(Scrollable))
      .last;

  Finder menuOf(String billNo) => find.descendant(
    of: find.ancestor(
      of: find.text(billNo),
      matching: find.byType(InvoiceCardItem),
    ),
    matching: find.byIcon(Icons.more_vert_rounded),
  );

  testWidgets('loads page 1 and infinite-scrolls to the last row',
          (tester) async {
        await pumpApp(tester);
        expect(find.text('SB-0001'), findsOneWidget);

        final scrollable = listScrollable();
        await tester.scrollUntilVisible(
          find.text('SB-0020'),
          400,
          scrollable: scrollable,
        );
        await pumpFor(tester);
        expect(find.text('SB-0020'), findsOneWidget);
        expect(repo.getCalls, 2);
      });

  testWidgets('search narrows after the debounce; clearing restores',
          (tester) async {
        await pumpApp(tester);

        await tester.enterText(find.byType(TextField), 'SB-0007');
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(InvoiceCardItem), findsWidgets); // not yet searched
        await pumpFor(tester, const Duration(milliseconds: 500));
        expect(find.byType(InvoiceCardItem), findsOneWidget);

        await tester.enterText(find.byType(TextField), '');
        await pumpFor(tester);
        expect(find.text('SB-0001'), findsOneWidget);
      });

  testWidgets('blocked rows hide actions and show the reason',
          (tester) async {
        await pumpApp(tester);

        expect(menuOf('SB-0001'), findsNothing);
        expect(find.text(_reason), findsNWidgets(2)); // rows 1 and 3

        await tester.tap(menuOf('SB-0003'));
        await pumpFor(tester);
        expect(find.text(AppStrings.edit), findsOneWidget);
        expect(find.text(AppStrings.delete), findsNothing);
      });

  testWidgets('delete with confirm removes the row', (tester) async {
    await pumpApp(tester);

    await tester.tap(menuOf('SB-0002'));
    await pumpFor(tester);
    await tester.tap(find.text(AppStrings.delete));
    await pumpFor(tester);
    // Dialog title and confirm button share the text; the button is last.
    await tester.tap(find.text(AppStrings.deleteInvoice).last);
    await pumpFor(tester);

    expect(find.text('SB-0002'), findsNothing);
  });

  testWidgets('cancelling the confirm keeps the row', (tester) async {
    await pumpApp(tester);

    await tester.tap(menuOf('SB-0002'));
    await pumpFor(tester);
    await tester.tap(find.text(AppStrings.delete));
    await pumpFor(tester);
    await tester.tap(find.text(AppStrings.cancel));
    await pumpFor(tester);

    expect(find.text('SB-0002'), findsOneWidget);
  });

  testWidgets('tapping a card opens the detail route', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('SB-0002'));
    await pumpFor(tester);
    expect(find.text('detail:SB-0002'), findsOneWidget);
  });

  testWidgets('Edit opens Edit Sale for that bill', (tester) async {
    await pumpApp(tester);

    await tester.tap(menuOf('SB-0002'));
    await pumpFor(tester);
    await tester.tap(find.text(AppStrings.edit));
    await pumpFor(tester);
    expect(find.text('edit:SB-0002'), findsOneWidget);
  });

  testWidgets('pull-to-refresh reloads page 1', (tester) async {
    await pumpApp(tester);
    final before = repo.getCalls;

    await tester.fling(listScrollable(), const Offset(0, 400), 1000);
    await pumpFor(tester, const Duration(seconds: 2));
    expect(repo.getCalls, greaterThan(before));
  });

  testWidgets('failed first load, then retry', (tester) async {
    repo.nextError = const ApiException(message: 'Server down');
    await pumpApp(tester);
    expect(find.byType(ErrorState), findsOneWidget);

    await tester.tap(find.descendant(
      of: find.byType(ErrorState),
      matching: find.byType(OutlinedButton),
    ));
    await pumpFor(tester);
    expect(find.text('SB-0001'), findsOneWidget);
  });
}