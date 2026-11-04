import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// System bars (status bar / navigation bar) styling for the whole app.
///
/// - [darkIcons]: transparent status bar with black time, battery and
///   network icons. Applied app-wide (see main.dart and AppTheme), so no
///   screen can leave the bar in a white-icon state.
/// - [hideForSplash] / [restoreAfterSplash]: the splash runs full screen
///   with no status or navigation bar.
abstract final class AppSystemUi {
  static const SystemUiOverlayStyle darkIcons = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    // Android: dark (black) status bar icons.
    statusBarIconBrightness: Brightness.dark,
    // iOS: "light" bar background = dark text.
    statusBarBrightness: Brightness.light,
  );

  /// Applies [darkIcons] before the first frame.
  static void applyDefaults() => SystemChrome.setSystemUIOverlayStyle(darkIcons);

  /// Hides the status and navigation bars (they reappear briefly on a
  /// swipe from the edge, then hide again).
  static Future<void> hideForSplash() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  /// Brings both bars back (Flutter's default mode) with [darkIcons].
  static Future<void> restoreAfterSplash() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(darkIcons);
  }
}
