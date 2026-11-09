import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:advance_pos_app/core/network/api_client.dart';
import 'package:advance_pos_app/core/session/auth_session_controller.dart';
import 'package:advance_pos_app/core/session/auth_session_state.dart';
import 'package:advance_pos_app/core/session/client_profile.dart';
import 'package:advance_pos_app/core/session/client_session_controller.dart';
import 'package:advance_pos_app/core/storage/local_cache_service.dart';
import 'package:advance_pos_app/core/storage/secure_storage_service.dart';
import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/core/widgets/common/primary_button.dart';
import 'package:advance_pos_app/features/login/data/repositories/login_repository.dart';
import 'package:advance_pos_app/features/login/presentation/screens/login_screen.dart';
import 'package:advance_pos_app/features/login/presentation/widgets/login_form.dart';
import 'package:advance_pos_app/routes/route_names.dart';

import '../../invoices/helpers/invoice_test_harness.dart' show pumpFor;
import 'fake_secure_storage.dart';

const mainStub = 'main-stub';
const welcomeStub = 'welcome-stub';
const stubLogout = 'stub-logout';
const _bootPath = '/test-boot';

const testClient = ClientProfile(
  name: 'Advance Mart',
  compCode: 'AM01',
  logo: '', // no network image in tests
  product: 'pos',
  baseUrl: 'https://example.test/',
);

/// The company is already verified (as after the splash restore).
class FakeClientSession extends ClientSessionController {
  @override
  ClientProfile? build() => testClient;
}

/// Hive is not initialised in tests; only clearing is used here.
class FakeLocalCacheService extends LocalCacheService {
  FakeLocalCacheService(SecureStorageService storage) : super(storage);

  int clears = 0;

  @override
  Future<void> clearOnLogout({bool clearStandard = true}) async => clears++;
}

/// Mirrors SplashController's session step without its 2.5 s delay:
/// restore the session, then main shell when signed in, else Login.
class _BootStub extends ConsumerStatefulWidget {
  const _BootStub();

  @override
  ConsumerState<_BootStub> createState() => _BootStubState();
}

class _BootStubState extends ConsumerState<_BootStub> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await ref.read(authSessionControllerProvider.notifier).restoreSession();
    if (!mounted) return;
    final signedIn = ref.read(authSessionControllerProvider).status ==
        AuthStatus.authenticated;
    context.go(signedIn ? RouteNames.mainShell : RouteNames.login);
  }

  @override
  Widget build(BuildContext context) => const Scaffold();
}

/// Opens Login, or with [coldStart] runs the startup session restore
/// first (like opening the app). Pass the same [storage] to keep what a
/// previous run saved.
Future<void> pumpLoginApp(
    WidgetTester tester, {
      required LoginRepository repository,
      required FakeSecureStorage storage,
      bool coldStart = false,
    }) async {
  final router = GoRouter(
    initialLocation: coldStart ? _bootPath : RouteNames.login,
    routes: [
      GoRoute(path: _bootPath, builder: (_, _) => const _BootStub()),
      GoRoute(
        path: RouteNames.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.mainShell,
        builder: (context, _) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(mainStub),
                Consumer(
                  builder: (context, ref, _) => ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(authSessionControllerProvider.notifier)
                          .logout();
                      if (context.mounted) context.go(RouteNames.login);
                    },
                    child: const Text(stubLogout),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.welcome,
        builder: (_, _) => const Scaffold(body: Text(welcomeStub)),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(), // always a fresh container, like a cold start
      overrides: [
        loginRepositoryProvider.overrideWithValue(repository),
        secureStorageServiceProvider.overrideWithValue(storage),
        clientSessionControllerProvider.overrideWith(FakeClientSession.new),
        localCacheServiceProvider
            .overrideWithValue(FakeLocalCacheService(storage)),
        apiClientProvider.overrideWithValue(ApiClient()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await pumpFor(tester); // restore + remembered username load
  await pumpFor(tester);
}

/// Closes the app and opens it again on the same storage.
Future<void> restartApp(
    WidgetTester tester, {
      required LoginRepository repository,
      required FakeSecureStorage storage,
    }) async {
  await tester.pumpWidget(const SizedBox());
  await pumpLoginApp(
    tester,
    repository: repository,
    storage: storage,
    coldStart: true,
  );
}

// ── Finders ──

Finder get usernameField => find.byType(TextFormField).at(0);
Finder get passwordField => find.byType(TextFormField).at(1);
Finder get rememberBox => find.byType(Checkbox);

/// The Sign In button (the app bar shows the same text).
Finder get signInButton => find.descendant(
  of: find.byType(LoginForm),
  matching: find.byType(PrimaryButton),
);

String usernameText(WidgetTester tester) =>
    tester.widget<TextFormField>(usernameField).controller!.text;

String passwordText(WidgetTester tester) =>
    tester.widget<TextFormField>(passwordField).controller!.text;

bool isRemembered(WidgetTester tester) =>
    tester.widget<Checkbox>(rememberBox).value ?? false;