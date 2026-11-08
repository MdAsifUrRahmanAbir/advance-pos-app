import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/core/widgets/common/add_button_widget.dart';
import 'package:advance_pos_app/core/widgets/utility/error_state.dart';
import 'package:advance_pos_app/features/expense/presentation/states/expense_format.dart';
import 'package:advance_pos_app/features/expense/presentation/states/expense_state.dart';
import 'package:advance_pos_app/features/expense/presentation/widgets/expense_list_item.dart';

import '../test/features/bill_preview/helpers/fake_platforms.dart';
import '../test/features/expense/helpers/expense_fixtures.dart';
import '../test/features/expense/helpers/expense_test_host.dart';
import '../test/features/expense/helpers/fake_expense_repository.dart';
import '../test/features/invoices/helpers/invoice_test_harness.dart' show pumpFor;

final _skeleton =
find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled);

/// The tappable part of a date chip. The chip's label sits under an
/// AnimatedOpacity and is not itself hit-testable, so tap its ancestor.
Finder presetChip(String label) => find
    .ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate((w) => w is InkWell || w is GestureDetector),
)
    .first;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final share = FakeSharePlatform();
  late FakeExpenseRepository repo;

  // Before anything reads SharePlus.instance.
  setUpAll(() => SharePlatform.instance = share);

  setUp(() {
    share.calls.clear();
    repo = FakeExpenseRepository();
  });

  Future<void> openExpense(WidgetTester tester) =>
      pumpExpenseApp(tester, repository: repo);

  // ─────────────────────────────── List
  group('list', () {
    testWidgets('skeleton, then rows with totals and count', (tester) async {
      repo.gate = Completer<void>();
      final gate = repo.gate!;
      await openExpense(tester);
      expect(_skeleton, findsOneWidget);

      gate.complete();
      await pumpFor(tester);

      expect(_skeleton, findsNothing);
      expect(find.text('$todayApi · Dhanmondi'), findsOneWidget);
      expect(
        find.descendant(
          of: rowOf(expenseNoFor(1)),
          matching: find.text(ExpenseFormat.money(1500)),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: rowOf(expenseNoFor(1)),
          matching: find.text(AppStrings.expHeadsCount(2)),
        ),
        findsOneWidget,
      );
      expect(find.text(AppStrings.expRecordsCount(20, 25)), findsOneWidget);

      final first = repo.calls.single;
      expect(first.start, 0);
      expect(first.length, 20);
      expect(first.fromDate, isNull);
    });

    testWidgets('scrolling loads the next page', (tester) async {
      await openExpense(tester);

      await tester.scrollUntilVisible(
        find.text(expenseNoFor(25)),
        400,
        scrollable: expenseList(),
      );
      await pumpFor(tester);

      expect(repo.calls.last.start, 20);
      expect(find.text(AppStrings.expRecordsCount(25, 25)), findsOneWidget);
    });

    testWidgets('failed next page: footer Retry loads it', (tester) async {
      await openExpense(tester);
      repo.nextListError = const ApiException(message: 'Timeout');

      await tester.scrollUntilVisible(
        find.text(AppStrings.expLoadMoreFailed),
        400,
        scrollable: expenseList(),
      );
      await pumpFor(tester);
      expect(expenseState(tester).isLoadMoreFailed, isTrue);

      await tester.tap(find.descendant(
        of: find.ancestor(
          of: find.text(AppStrings.expLoadMoreFailed),
          matching: find.byType(Row),
        ),
        matching: find.text(AppStrings.retry),
      ));
      await pumpFor(tester);

      expect(expenseState(tester).expenses, hasLength(25));
    });

    testWidgets('failed first load shows ErrorState; Retry recovers',
            (tester) async {
          repo.nextListError = const ApiException(message: 'Server down');
          await openExpense(tester);

          expect(find.byType(ErrorState), findsOneWidget);
          expect(find.text('Server down'), findsOneWidget);

          await tester.tap(find.text(AppStrings.retry));
          await pumpFor(tester);
          expect(rowOf(expenseNoFor(1)), findsOneWidget);
        });

    testWidgets('no expenses shows the empty view', (tester) async {
      repo = FakeExpenseRepository(count: 0);
      await openExpense(tester);

      expect(find.byType(ExpenseListItem), findsNothing);
      expect(find.text(AppStrings.expEmptyTitle), findsOneWidget);
    });

    testWidgets('pull to refresh reloads page 1', (tester) async {
      await openExpense(tester);
      final before = repo.calls.length;

      await tester.fling(expenseList(), const Offset(0, 400), 1000);
      await pumpFrames(tester);

      expect(repo.calls.length, greaterThan(before));
      expect(repo.calls.last.start, 0);
      expect(_skeleton, findsNothing);
      expect(rowOf(expenseNoFor(1)), findsOneWidget);
    });

    testWidgets('failed refresh keeps the list and shows a snackbar',
            (tester) async {
          await openExpense(tester);
          repo.nextListError = const ApiException(message: 'Refresh failed');

          await tester.fling(expenseList(), const Offset(0, 400), 1000);
          await pumpFrames(tester);

          expect(find.text('Refresh failed'), findsOneWidget);
          expect(rowOf(expenseNoFor(1)), findsOneWidget);
          expect(expenseState(tester).expenses, hasLength(20));
        });
  });

  // ─────────────────────────────── Search and dates
  group('filters', () {
    testWidgets('search waits for the debounce', (tester) async {
      await openExpense(tester);

      await tester.enterText(find.byType(TextField).first, 'EXP-0002');
      await tester.pump(const Duration(milliseconds: 200));
      expect(repo.calls, hasLength(1));

      await pumpFor(tester, afterDebounce);
      expect(repo.calls.last.search, 'EXP-0002');
      expect(find.byType(ExpenseListItem), findsOneWidget);
      expect(find.text(AppStrings.expRecordsCount(1, 1)), findsOneWidget);
    });

    testWidgets('Today sends today\'s range; tapping again clears it',
            (tester) async {
          await openExpense(tester);

          await tester.tap(presetChip(AppStrings.invoiceDatePresetToday));
          await pumpFor(tester);
          expect(repo.calls.last.fromDate, todayApi);
          expect(repo.calls.last.toDate, todayApi);
          expect(find.byType(ExpenseListItem), findsOneWidget);
          expect(rowOf(expenseNoFor(1)), findsOneWidget);

          await tester.tap(presetChip(AppStrings.invoiceDatePresetToday));
          await pumpFor(tester);
          expect(expenseState(tester).datePreset, ExpenseDatePreset.all);
          expect(repo.calls.last.fromDate, isNull);
        });

    testWidgets('custom range is sent and labels the chip', (tester) async {
      await openExpense(tester);
      final from = DateTime(2026, 1, 1);
      final to = DateTime(2026, 1, 31);

      expenseController(tester).applyDatePreset(
        ExpenseDatePreset.custom,
        range: DateTimeRange(start: from, end: to),
      );
      await pumpFor(tester);

      expect(repo.calls.last.fromDate, '2026-01-01');
      expect(repo.calls.last.toDate, '2026-01-31');
      final l10n = MaterialLocalizations.of(
        tester.element(find.byType(ExpenseListItem).first),
      );
      expect(
        find.text('${l10n.formatCompactDate(from)} - ${l10n.formatCompactDate(to)}'),
        findsOneWidget,
      );
      // 23 old fillers match; page 1 holds 20. The list builds only the
      // rows on screen, so check the count, not the widgets.
      expect(expenseState(tester).totalCount, 23);
      expect(find.text(AppStrings.expRecordsCount(20, 23)), findsOneWidget);
      expect(rowOf(expenseNoFor(1)), findsNothing); // today is out of range
    });
  });

  // ─────────────────────────────── Add / Edit / Delete
  group('row actions', () {
    Future<void> openMenu(WidgetTester tester, String expenseNo) async {
      await tester.tap(rowMenu(expenseNo));
      await pumpFor(tester);
    }

    testWidgets('Edit opens the form for that expense; save refreshes',
            (tester) async {
          await openExpense(tester);
          await openMenu(tester, expenseNoFor(1));
          await tester.tap(find.text(AppStrings.edit));
          await pumpFor(tester);

          expect(find.text(formOpenedFor(expenseNoFor(1))), findsOneWidget);
          final before = repo.calls.length;

          await tester.tap(find.text(formSave));
          await pumpFrames(tester);

          expect(repo.calls.length, before + 1);
          expect(rowOf(expenseNoFor(1)), findsOneWidget);
        });

    testWidgets('add button opens an empty form; cancel does not reload',
            (tester) async {
          await openExpense(tester);

          await tester.tap(find.byType(AddButtonWidget));
          await pumpFor(tester);
          expect(find.text(formOpenedFor(null)), findsOneWidget);
          final before = repo.calls.length;

          await tester.tap(find.text(formCancel));
          await pumpFor(tester);

          expect(repo.calls, hasLength(before));
        });

    testWidgets('Delete asks first; confirm removes the row',
            (tester) async {
          await openExpense(tester);
          await openMenu(tester, expenseNoFor(2));
          await tester.tap(find.text(AppStrings.delete));
          await pumpFor(tester);

          expect(find.text(AppStrings.expDeleteTitle), findsOneWidget);
          expect(find.text(AppStrings.expDeleteMessage(expenseNoFor(2))),
              findsOneWidget);

          await tester.tap(find.text(AppStrings.delete).last);
          await pumpFor(tester);

          expect(repo.deleted, [expenseNoFor(2)]);
          expect(rowOf(expenseNoFor(2)), findsNothing);
          expect(find.text(AppStrings.expDeleted(expenseNoFor(2))), findsOneWidget);
          expect(find.text(AppStrings.expRecordsCount(19, 24)), findsOneWidget);
        });

    testWidgets('cancelling Delete keeps the row', (tester) async {
      await openExpense(tester);
      await openMenu(tester, expenseNoFor(2));
      await tester.tap(find.text(AppStrings.delete));
      await pumpFor(tester);

      await tester.tap(find.text(AppStrings.cancel));
      await pumpFor(tester);

      expect(repo.deleted, isEmpty);
      expect(rowOf(expenseNoFor(2)), findsOneWidget);
    });

    testWidgets('failed Delete keeps the row and explains', (tester) async {
      repo.nextDeleteError =
      const ApiException(message: 'Linked to a closed day');
      await openExpense(tester);
      await openMenu(tester, expenseNoFor(2));
      await tester.tap(find.text(AppStrings.delete));
      await pumpFor(tester);
      await tester.tap(find.text(AppStrings.delete).last);
      await pumpFor(tester);

      expect(find.text('Linked to a closed day'), findsOneWidget);
      expect(rowOf(expenseNoFor(2)), findsOneWidget);
    });
  });

  // ─────────────────────────────── Detail sheet
  group('detail sheet', () {
    Future<void> openDetail(WidgetTester tester, String expenseNo) async {
      await tester.tap(find.text(expenseNo));
      await pumpFor(tester);
    }

    testWidgets('heads, accounts and narration', (tester) async {
      await openExpense(tester);
      await openDetail(tester, expenseNoFor(1));

      expect(find.text(AppStrings.expDetailTitle), findsOneWidget);
      expect(repo.detailLoads, [expenseNoFor(1)]);
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Utility'), findsOneWidget);
      expect(find.text('Cash in hand'), findsOneWidget);
      expect(find.text('bKash Merchant [01700000001]'), findsOneWidget);
      expect(find.text('November'), findsOneWidget);
      expect(find.text('Monthly costs'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('failed detail shows ErrorState; Retry loads it',
            (tester) async {
          await openExpense(tester);
          repo.nextDetailError = const ApiException(message: 'Detail down');
          await openDetail(tester, expenseNoFor(1));

          expect(find.text('Detail down'), findsOneWidget);
          await tester.tap(find.descendant(
            of: find.byType(ErrorState),
            matching: find.text(AppStrings.retry),
          ));
          await pumpFor(tester);

          expect(find.text('Rent'), findsOneWidget);
        });

    testWidgets('Share sends a text summary', (tester) async {
      await openExpense(tester);
      await openDetail(tester, expenseNoFor(1));

      await tester.tap(find.byIcon(Icons.share_outlined));
      await pumpFor(tester);

      final params = share.calls.single;
      expect(params.subject, AppStrings.expShareSubject(expenseNoFor(1)));
      expect(params.text, contains(expenseNoFor(1)));
      expect(params.text, contains('Rent'));
      expect(params.text, contains('bKash Merchant [01700000001]'));
      expect(params.text, contains('Monthly costs'));
    });

    testWidgets('close button dismisses the sheet', (tester) async {
      await openExpense(tester);
      await openDetail(tester, expenseNoFor(1));

      await tester.tap(find.byIcon(Icons.close_rounded));
      await pumpFor(tester);

      expect(find.text(AppStrings.expDetailTitle), findsNothing);
    });
  });
}