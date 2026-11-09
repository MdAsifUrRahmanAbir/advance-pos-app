import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:advance_pos_app/core/constants/app_strings.dart';
import 'package:advance_pos_app/core/network/api_exception.dart';
import 'package:advance_pos_app/core/session/api_params.dart';
import 'package:advance_pos_app/core/widgets/common/primary_button.dart';
import 'package:advance_pos_app/features/login/presentation/screens/login_screen.dart';

import '../test/features/invoices/helpers/invoice_test_harness.dart' show pumpFor;
import '../test/features/login/helpers/fake_login_repository.dart';
import '../test/features/login/helpers/fake_secure_storage.dart';
import '../test/features/login/helpers/login_test_host.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeLoginRepository repo;
  late FakeSecureStorage storage;

  setUp(() {
    repo = FakeLoginRepository();
    storage = FakeSecureStorage();
  });

  Future<void> openLogin(WidgetTester tester) =>
      pumpLoginApp(tester, repository: repo, storage: storage);

  Future<void> restart(WidgetTester tester) =>
      restartApp(tester, repository: repo, storage: storage);

  Future<void> fillAndSignIn(
      WidgetTester tester, {
        String username = validUsername,
        String password = validPassword,
        bool? remember,
      }) async {
    await tester.enterText(usernameField, username);
    await tester.enterText(passwordField, password);
    if (remember != null && isRemembered(tester) != remember) {
      await tester.tap(rememberBox);
      await pumpFor(tester);
    }
    await tester.tap(signInButton);
    await pumpFor(tester);
  }

  Future<void> logout(WidgetTester tester) async {
    await tester.tap(find.text(stubLogout));
    await pumpFor(tester);
  }

  // ─────────────────────────────── Sign in
  group('sign in', () {
    testWidgets('empty form shows both errors and sends nothing',
            (tester) async {
          await openLogin(tester);

          await tester.tap(signInButton);
          await pumpFor(tester);

          expect(find.text(AppStrings.loginUsernameRequired), findsOneWidget);
          expect(find.text(AppStrings.passwordRequired), findsOneWidget);
          expect(repo.calls, isEmpty);
        });

    testWidgets('wrong password: message, stays on Login, nothing saved',
            (tester) async {
          await openLogin(tester);

          await fillAndSignIn(tester, password: 'nope');

          expect(find.text(wrongCredentialsMessage), findsOneWidget);
          expect(find.byType(LoginScreen), findsOneWidget);
          expect(storage.sessionProfile, isNull);
          expect(storage.apiParams, isNull);
        });

    testWidgets('server error is shown', (tester) async {
      repo.nextError = const ApiException(message: 'Server down');
      await openLogin(tester);

      await fillAndSignIn(tester);

      expect(find.text('Server down'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('success: trims username, saves session, opens main',
            (tester) async {
          await openLogin(tester);

          await fillAndSignIn(tester, username: '  $validUsername  ');

          expect(repo.calls.single.username, validUsername);
          expect(find.text(mainStub), findsOneWidget);
          expect(storage.sessionProfile, contains('Rahim Cashier'));
          expect(ApiParams.current.branchId, loginBranchId);
        });

    testWidgets('while signing in: loading, no second request',
            (tester) async {
          repo.gate = Completer<void>();
          final gate = repo.gate!;
          await openLogin(tester);

          await fillAndSignIn(tester);
          expect(tester.widget<PrimaryButton>(signInButton).loading, isTrue);

          await tester.tap(signInButton, warnIfMissed: false);
          await pumpFor(tester);
          expect(repo.calls, hasLength(1));

          gate.complete();
          await pumpFor(tester);
          expect(find.text(mainStub), findsOneWidget);
        });
  });

  // ─────────────────────────────── Remember me
  group('remember me', () {
    testWidgets('first open: empty and unticked', (tester) async {
      await openLogin(tester);

      expect(usernameText(tester), isEmpty);
      expect(isRemembered(tester), isFalse);
    });

    testWidgets('NOT ticked: reopening the app shows Login, session wiped',
            (tester) async {
          await openLogin(tester);
          await fillAndSignIn(tester, remember: false);
          expect(find.text(mainStub), findsOneWidget);
          expect(storage.sessionRemembered, isFalse);

          await restart(tester);

          expect(find.byType(LoginScreen), findsOneWidget);
          expect(find.text(mainStub), findsNothing);
          expect(storage.sessionProfile, isNull);
          expect(storage.apiParams, isNull);
          expect(usernameText(tester), isEmpty);
          expect(isRemembered(tester), isFalse);
        });

    testWidgets('ticked: reopening the app stays signed in', (tester) async {
      await openLogin(tester);
      await fillAndSignIn(tester, remember: true);
      expect(storage.sessionRemembered, isTrue);

      await restart(tester);

      expect(find.text(mainStub), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('ticked + logout: Login with username, also after restart',
            (tester) async {
          await openLogin(tester);
          await fillAndSignIn(tester, remember: true);

          await logout(tester);

          expect(find.byType(LoginScreen), findsOneWidget);
          expect(usernameText(tester), validUsername);
          expect(passwordText(tester), isEmpty);
          expect(isRemembered(tester), isTrue);
          expect(storage.sessionProfile, isNull);
          expect(storage.sessionRemembered, isFalse);

          // Logout ended the session: a restart must not sign back in.
          await restart(tester);

          expect(find.byType(LoginScreen), findsOneWidget);
          expect(usernameText(tester), validUsername);
        });

    testWidgets('not ticked + logout: nothing remembered', (tester) async {
      await openLogin(tester);
      await fillAndSignIn(tester, remember: false);

      await logout(tester);

      expect(storage.rememberedUsername, isNull);
      expect(usernameText(tester), isEmpty);
      expect(isRemembered(tester), isFalse);
    });

    testWidgets('unticking at the next sign-in forgets username and session',
            (tester) async {
          await storage.saveRememberedUsername(validUsername);
          await openLogin(tester);
          expect(usernameText(tester), validUsername);
          expect(isRemembered(tester), isTrue);

          await fillAndSignIn(tester, remember: false);
          expect(storage.rememberedUsername, isNull);

          await restart(tester);

          expect(find.byType(LoginScreen), findsOneWidget);
          expect(usernameText(tester), isEmpty);
        });

    testWidgets('failed sign-in does not change what is remembered',
            (tester) async {
          await storage.saveRememberedUsername('previous');
          await openLogin(tester);

          await fillAndSignIn(tester, password: 'nope', remember: false);

          expect(find.text(wrongCredentialsMessage), findsOneWidget);
          expect(storage.rememberedUsername, 'previous');
        });

    testWidgets('Switch company forgets the username', (tester) async {
      await storage.saveRememberedUsername(validUsername);
      await openLogin(tester);

      await tester.ensureVisible(find.text(AppStrings.companySwitchAction));
      await tester.tap(find.text(AppStrings.companySwitchAction));
      await pumpFor(tester);
      expect(find.text(AppStrings.companySwitchTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.companySwitchAction).last);
      await pumpFor(tester);

      expect(tester.takeException(), isNull); // no client! crash
      expect(find.text(welcomeStub), findsOneWidget);
      expect(storage.rememberedUsername, isNull);
    });
  });
}