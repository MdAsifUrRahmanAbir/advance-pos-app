import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/core/widgets/utility/error_state.dart';
import 'package:advance_pos_app/features/bill_preview/presentation/widgets/sale_complete_sheet.dart';
import 'package:advance_pos_app/features/bill_preview/presentation/widgets/sales_bill_preview_sheet.dart';

import '../test/features/bill_preview/helpers/bill_preview_test_host.dart';
import '../test/features/bill_preview/helpers/fake_bill_preview_repository.dart';
import '../test/features/bill_preview/helpers/fake_platforms.dart';
import '../test/features/invoices/helpers/invoice_test_harness.dart' show pumpFor;

/// Skeletonizer's public constructor builds a private subclass, so
/// find.byType(Skeletonizer) never matches — match by `is` instead.
final _skeleton =
find.byWidgetPredicate((w) => w is Skeletonizer && w.enabled);

const _receiptFileName = 'receipt_SB-0001.png';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final share = FakeSharePlatform();
  late GalChannelMock gal;
  late FakeBillPreviewRepository repo;
  late List<String> events;

  // Must run before anything reads SharePlus.instance.
  setUpAll(() => SharePlatform.instance = share);

  setUp(() {
    share.calls.clear();
    share.nextError = null;
    gal = GalChannelMock()..install();
    repo = FakeBillPreviewRepository();
    events = [];
  });

  tearDown(() => gal.uninstall());

  Future<void> pumpHost(WidgetTester tester, {bool withDone = false}) async {
    await pumpBillPreviewHost(
      tester,
      repository: repo,
      events: events,
      withDone: withDone,
    );
    await pumpFor(tester);
  }

  Future<void> open(WidgetTester tester, String button) async {
    await tester.tap(find.text(button));
    await pumpFor(tester);
  }

  /// Taps the dimmed area above a bottom sheet.
  Future<void> tapBarrier(WidgetTester tester) async {
    await tester.tapAt(const Offset(20, 20));
    await pumpFor(tester);
  }

  // ─────────────────────────────── Bill Preview sheet
  group('Bill Preview sheet', () {
    testWidgets('skeleton while loading, then the full receipt',
            (tester) async {
          repo.gate = Completer<void>();
          await pumpHost(tester);
          await open(tester, hostOpenPreview);

          expect(find.byType(SalesBillPreviewSheet), findsOneWidget);
          expect(_skeleton, findsWidgets);

          // Save is disabled until the bill arrives.
          await tester.tap(find.text(AppStrings.billSaveAction),
              warnIfMissed: false);
          await pumpFor(tester);
          expect(gal.savedNames, isEmpty);

          repo.gate!.complete();
          await pumpFor(tester);

          expect(_skeleton, findsNothing);
          expect(find.text('ADVANCE MART'), findsOneWidget);
          expect(find.textContaining('Rice 5kg'), findsOneWidget);
          expect(find.textContaining('SB-0001'), findsWidgets);
          expect(find.text(AppStrings.billGrandTotal), findsOneWidget);
          expect(find.textContaining('990.00'), findsWidgets);
          expect(repo.requested, ['SB-0001']);
        });

    testWidgets('failed load shows the error; Retry recovers',
            (tester) async {
          repo.nextError = const ApiException(message: 'Server down');
          await pumpHost(tester);
          await open(tester, hostOpenPreview);

          expect(find.byType(ErrorState), findsOneWidget);
          expect(find.text('Server down'), findsOneWidget);

          await tester.tap(find.text(AppStrings.retry));
          await pumpFor(tester);
          expect(find.byType(ErrorState), findsNothing);
          expect(find.textContaining('Rice 5kg'), findsOneWidget);
          expect(repo.requested, hasLength(2));
        });

    testWidgets('Save writes the captured receipt to the gallery',
            (tester) async {
          await pumpHost(tester);
          await open(tester, hostOpenPreview);

          await tester.tap(find.text(AppStrings.billSaveAction));
          await pumpFor(tester);

          expect(gal.savedNames, ['receipt_SB-0001']);
          expect(gal.savedByteCounts.single, greaterThan(0));
          expect(find.text(AppStrings.billSavedMessage), findsOneWidget);
        });

    testWidgets('Save with photo access denied shows the failure',
            (tester) async {
          gal
            ..hasAccess = false
            ..grantOnRequest = false;
          await pumpHost(tester);
          await open(tester, hostOpenPreview);

          await tester.tap(find.text(AppStrings.billSaveAction));
          await pumpFor(tester);

          expect(gal.savedNames, isEmpty);
          expect(find.text(AppStrings.billSaveFailed), findsOneWidget);
        });

    testWidgets('Share sends the receipt PNG with subject and text',
            (tester) async {
          await pumpHost(tester);
          await open(tester, hostOpenPreview);

          await tester.tap(find.text(AppStrings.invoiceShareAction));
          await pumpFor(tester);

          final params = share.calls.single;
          expect(params.files, hasLength(1));
          expect(params.files!.single.mimeType, 'image/png');
          expect(await params.files!.single.length(), greaterThan(0));
          expect(params.fileNameOverrides, [_receiptFileName]);
          expect(params.subject, AppStrings.billShareSubject('SB-0001'));
          expect(params.text, AppStrings.billShareText('SB-0001'));
          expect(find.text(AppStrings.shareFailedMessage), findsNothing);
        });

    testWidgets('Share failure shows the error snackbar', (tester) async {
      share.nextError = PlatformException(code: 'share_failed');
      await pumpHost(tester);
      await open(tester, hostOpenPreview);

      await tester.tap(find.text(AppStrings.invoiceShareAction));
      await pumpFor(tester);

      expect(find.text(AppStrings.shareFailedMessage), findsOneWidget);
    });

    testWidgets('tap outside closes it; reopening loads fresh',
            (tester) async {
          await pumpHost(tester);
          await open(tester, hostOpenPreview);

          await tapBarrier(tester);
          expect(find.byType(SalesBillPreviewSheet), findsNothing);

          // autoDispose: the controller died with the sheet.
          await open(tester, hostOpenPreview);
          expect(repo.requested, hasLength(2));
        });
  });

  // ─────────────────────────────── Sale complete sheet
  group('Sale complete sheet', () {
    testWidgets('shows header, summary and receipt peek', (tester) async {
      await pumpHost(tester);
      await open(tester, hostOpenComplete);

      expect(find.byType(SaleCompleteSheet), findsOneWidget);
      expect(find.text(hostCompleteTitle), findsOneWidget);
      expect(find.text(hostCompleteSubtitle), findsOneWidget);
      expect(find.text(AppStrings.billLabel), findsOneWidget);
      expect(find.textContaining('SB-0001'), findsWidgets);
      expect(find.text(AppStrings.saleDoneViewFullBill), findsOneWidget);
    });

    testWidgets('cannot be dismissed by tap outside or back',
            (tester) async {
          await pumpHost(tester);
          await open(tester, hostOpenComplete);

          await tapBarrier(tester);
          expect(find.byType(SaleCompleteSheet), findsOneWidget);

          final navigator =
          tester.state<NavigatorState>(find.byType(Navigator).first);
          await navigator.maybePop();
          await pumpFor(tester);
          expect(find.byType(SaleCompleteSheet), findsOneWidget);
        });

    testWidgets('New Sale exits through its callback', (tester) async {
      await pumpHost(tester);
      await open(tester, hostOpenComplete);

      await tester.tap(find.text(AppStrings.newSaleTitle));
      await pumpFor(tester);

      expect(events, ['newSale']);
      expect(find.byType(SaleCompleteSheet), findsNothing);
    });

    testWidgets('Go to Dashboard exits through its callback',
            (tester) async {
          await pumpHost(tester);
          await open(tester, hostOpenComplete);

          await tester.ensureVisible(find.text(AppStrings.actionGoToDashboard));
          await tester.tap(find.text(AppStrings.actionGoToDashboard));
          await pumpFor(tester);

          expect(events, ['dashboard']);
        });

    testWidgets('Edit Sale layout: Done is primary', (tester) async {
      await pumpHost(tester, withDone: true);
      await open(tester, hostOpenComplete);

      expect(find.text(AppStrings.saleDoneDashboardAction), findsOneWidget);
      expect(find.text(AppStrings.actionGoToDashboard), findsNothing);

      await tester.ensureVisible(find.text(AppStrings.done));
      await tester.tap(find.text(AppStrings.done));
      await pumpFor(tester);
      expect(events, ['done']);
    });

    testWidgets('Preview opens the full bill without a second request',
            (tester) async {
          await pumpHost(tester);
          await open(tester, hostOpenComplete);

          await tester.tap(find.text(AppStrings.saleDonePreviewAction));
          await pumpFor(tester);

          expect(find.byType(SalesBillPreviewSheet), findsOneWidget);
          expect(find.byType(SaleCompleteSheet), findsOneWidget); // underneath
          expect(repo.requested, ['SB-0001']); // shared family controller
        });

    testWidgets('Share uses the peek receipt', (tester) async {
      await pumpHost(tester);
      await open(tester, hostOpenComplete);

      await tester.tap(find.text(AppStrings.invoiceShareAction));
      await pumpFor(tester);

      final params = share.calls.single;
      expect(params.fileNameOverrides, [_receiptFileName]);
      expect(await params.files!.single.length(), greaterThan(0));
    });

    testWidgets('bill actions stay disabled while loading', (tester) async {
      repo.gate = Completer<void>();
      await pumpHost(tester);
      await open(tester, hostOpenComplete);

      await tester.tap(find.text(AppStrings.invoiceShareAction),
          warnIfMissed: false);
      await tester.tap(find.text(AppStrings.saleDonePreviewAction),
          warnIfMissed: false);
      await pumpFor(tester);

      expect(share.calls, isEmpty);
      expect(find.byType(SalesBillPreviewSheet), findsNothing);
      repo.gate!.complete();
      await pumpFor(tester);
    });

    testWidgets('failed load shows its message; Retry recovers',
            (tester) async {
          repo.nextError = const ApiException(message: 'Server down');
          await pumpHost(tester);
          await open(tester, hostOpenComplete);

          expect(find.text(AppStrings.saleDoneBillLoadFailed), findsOneWidget);
          // Exits still work while the bill is missing.
          expect(find.text(AppStrings.newSaleTitle), findsOneWidget);

          await tester.tap(find.text(AppStrings.retry));
          await pumpFor(tester);
          expect(find.text(AppStrings.saleDoneBillLoadFailed), findsNothing);
          expect(find.text(AppStrings.saleDoneViewFullBill), findsOneWidget);
        });
  });
}