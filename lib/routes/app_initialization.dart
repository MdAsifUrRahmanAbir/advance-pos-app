import '../core/theme/app_system_ui.dart';

class AppInitialization {
  AppInitialization();

  /// Call after `WidgetsFlutterBinding.ensureInitialized()`.
  static void init() {
    // Transparent status bar with black icons everywhere.
    AppSystemUi.applyDefaults();
  }
}
