import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/core/widgets/utility/empty_state.dart';
import 'package:advance_pos_app/core/widgets/utility/error_state.dart';
import 'package:advance_pos_app/features/customers/presentation/states/customer_type.dart';
import 'package:advance_pos_app/features/customers/presentation/widgets/customer_card_item.dart';
import 'package:advance_pos_app/features/customers/presentation/widgets/customer_list_skeleton.dart';

import '../test/features/customers/helpers/customers_fixtures.dart';
import '../test/features/customers/helpers/customers_test_host.dart';
import '../test/features/customers/helpers/fake_customers_repository.dart';
import '../test/features/invoices/helpers/invoice_test_harness.dart' show pumpFor;

/// On a device the screen only redraws on pump(), and one long pump is
/// one frame. Multi-step flows (pull, snap, refresh, data arrives) need
/// a frame per step, so pump short steps several times.
Future<void> pumpFrames(WidgetTester tester, {int frames = 20}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeCustomersRepository repo;

  setUp(() => repo = FakeCustomersRepository());

  Future<void> openCustomers(WidgetTester tester) =>
      pumpCustomersApp(tester, repository: repo);

  // ─────────────────────────────── List
  group('list', () {
    testWidgets('skeleton, then cards with every field', (tester) async {
      repo.gate = Completer<void>();
      final gate = repo.gate!;
      await openCustomers(tester);

      expect(find.byType(CustomerListSkeleton), findsOneWidget);

      gate.complete();
      await pumpFor(tester);

      expect(find.byType(CustomerListSkeleton), findsNothing);
      expect(inCard('Rahim', find.text('C-1')), findsOneWidget);
      expect(inCard('Rahim', find.text('01711111111')), findsOneWidget);
      expect(inCard('Rahim', find.text('Dhanmondi')), findsOneWidget);
      expect(inCard('Rahim', find.text('Road 27, Dhanmondi')),
          findsOneWidget);
      expect(inCard('Rahim', find.text(customerTypeLabel(1))),
          findsOneWidget);
      expect(inCard('Karim', find.text(customerTypeLabel(2))),
          findsOneWidget);
      // No address -> no address row.
      expect(inCard('Karim', find.byIcon(Icons.location_on)), findsNothing);

      final first = repo.calls.single;
      expect(first.start, 0);
      expect(first.length, 20);
      expect(first.search, '');
    });

    testWidgets('scrolling down loads the next page', (tester) async {
      await openCustomers(tester);

      await tester.scrollUntilVisible(
        find.text(fillerCustomerName(25)),
        400,
        scrollable: customerList(),
      );
      await pumpFor(tester);

      expect(find.text(fillerCustomerName(25)), findsOneWidget);
      expect(repo.calls, hasLength(2));
      expect(repo.calls.last.start, 20);
    });

    testWidgets('no customers shows the empty state', (tester) async {
      repo = FakeCustomersRepository(const []);
      await openCustomers(tester);

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text(AppStrings.customersEmptyMessage), findsOneWidget);
    });

    testWidgets('failed first load shows ErrorState; Retry recovers',
            (tester) async {
          repo.nextError = const ApiException(message: 'Server down');
          await openCustomers(tester);

          expect(find.byType(ErrorState), findsOneWidget);
          expect(find.text('Server down'), findsOneWidget);

          await tester.tap(find.descendant(
            of: find.byType(ErrorState),
            matching: find.byType(OutlinedButton),
          ));
          await pumpFor(tester);
          expect(find.text('Rahim'), findsOneWidget);
        });

    testWidgets('pull to refresh reloads page 1', (tester) async {
      await openCustomers(tester);
      final before = repo.calls.length;

      await tester.fling(customerList(), const Offset(0, 400), 1000);
      await pumpFrames(tester);

      expect(repo.calls.length, greaterThan(before));
      expect(repo.calls.last.start, 0);
      expect(find.byType(CustomerListSkeleton), findsNothing);
      expect(customerCard('Rahim'), findsOneWidget);
    });
  });

  // ─────────────────────────────── Search
  group('search', () {
    testWidgets('waits for 3 characters and the debounce', (tester) async {
      await openCustomers(tester);

      await tester.enterText(searchField(), 'Ra');
      await pumpFor(tester, afterDebounce);
      expect(repo.calls, hasLength(1)); // too short

      await tester.enterText(searchField(), 'Rah');
      await tester.pump(const Duration(milliseconds: 200));
      expect(repo.calls, hasLength(1)); // still debouncing
      await pumpFor(tester, afterDebounce);

      expect(repo.calls.last.search, 'Rah');
      expect(find.byType(CustomerCardItem), findsOneWidget);
      expect(customerCard('Rahim'), findsOneWidget);
    });

    testWidgets('matches mobile number too', (tester) async {
      await openCustomers(tester);

      await tester.enterText(searchField(), '01722');
      await pumpFor(tester, afterDebounce);

      expect(find.byType(CustomerCardItem), findsOneWidget);
      expect(customerCard('Karim'), findsOneWidget);
    });

    testWidgets('clearing the search reloads at once', (tester) async {
      await openCustomers(tester);
      await tester.enterText(searchField(), 'Rah');
      await pumpFor(tester, afterDebounce);

      await tester.enterText(searchField(), '');
      await pumpFor(tester);

      expect(repo.calls.last.search, '');
      expect(customerCard('Karim'), findsOneWidget);
    });

    testWidgets('a slower, older search never overwrites a newer one',
            (tester) async {
          await openCustomers(tester);

          repo.gate = Completer<void>(); // hold the 'Rahim' search
          final slow = repo.gate!;
          await tester.enterText(searchField(), 'Rahim');
          await pumpFor(tester, afterDebounce);

          await tester.enterText(searchField(), 'Karim');
          await pumpFor(tester, afterDebounce);
          // The search box also holds "Karim", so look for the card.
          expect(customerCard('Karim'), findsOneWidget);

          slow.complete(); // the stale 'Rahim' answer lands now
          await pumpFor(tester);

          expect(find.byType(CustomerCardItem), findsOneWidget);
          expect(customerCard('Karim'), findsOneWidget);
          expect(customerCard('Rahim'), findsNothing);
        });
  });

  // ─────────────────────────────── Detail sheet
  group('detail sheet', () {
    Future<void> openDetail(WidgetTester tester, String name) async {
      await tester.tap(customerCard(name));
      await pumpFor(tester);
    }

    testWidgets('shows every field of a full profile', (tester) async {
      await openCustomers(tester);
      await openDetail(tester, 'Rahim');

      expect(detailSheet, findsOneWidget);
      expect(inDetail(find.text('Rahim')), findsOneWidget);
      expect(inDetail(find.text(customerTypeLabel(1))), findsOneWidget);
      expect(inDetail(find.text(AppStrings.customerNoLabel)), findsOneWidget);
      expect(inDetail(find.text('C-1')), findsOneWidget);
      expect(inDetail(find.text('01711111111')), findsOneWidget);
      expect(inDetail(find.text('rahim@example.com')), findsOneWidget);
      expect(inDetail(find.text(AppStrings.customerAddressLabel)),
          findsOneWidget);
      expect(inDetail(find.text('Road 27, Dhanmondi')), findsOneWidget);
      expect(inDetail(find.text('Purchase status: 1')), findsOneWidget);
    });

    testWidgets('missing fields show placeholders; no address row',
            (tester) async {
          await openCustomers(tester);
          await openDetail(tester, 'Karim');

          expect(inDetail(find.text('-')), findsOneWidget); // email
          expect(inDetail(find.text(AppStrings.customerAddressLabel)),
              findsNothing);
          expect(inDetail(find.text('No recorded purchases')), findsOneWidget);
        });

    testWidgets('tapping outside closes it', (tester) async {
      await openCustomers(tester);
      await openDetail(tester, 'Rahim');

      await tester.tapAt(const Offset(20, 20));
      await pumpFor(tester);

      expect(detailSheet, findsNothing);
    });
  });

  // ─────────────────────────────── Navigation
  testWidgets('Back returns to the previous screen', (tester) async {
    await openCustomers(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await pumpFor(tester);

    expect(find.text(customersHostOpen), findsOneWidget);
  });
}