import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/routes/app_router.dart';

import 'core/network/connectivity_banner.dart';
import 'core/observers/riverpod_logging_observer.dart';
import 'core/storage/local_cache_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_system_ui.dart';
import 'core/theme/theme_controller.dart';
import 'routes/app_initialization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppInitialization.init();

  final secureStorage = SecureStorageService();
  final localCache = LocalCacheService(secureStorage);
  await localCache.init();

  runApp(
    ProviderScope(
      overrides: [
        secureStorageServiceProvider.overrideWithValue(secureStorage),
        localCacheServiceProvider.overrideWithValue(localCache),
      ],
      observers: [RiverpodLoggingObserver()],
      child: PosApp(),
    ),
  );
}

class PosApp extends ConsumerWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      // themeMode: themeMode,
      themeMode: ThemeMode.light,
      routerConfig: router,
      // Black status bar icons on every screen; a screen can still set its
      // own AnnotatedRegion (the deeper one wins).
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppSystemUi.darkIcons,
          child: Stack(children: [?child, const ConnectivityBanner()]),
        );
      },
    );
  }
}