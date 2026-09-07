import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the app's current [ThemeMode] (light / dark / system).
/// Read it in main.dart to drive MaterialApp.router's `themeMode`,
/// and update it from anywhere (e.g. ThemeSelector on the Settings screen).
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;

  void toggleLightDark() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeControllerProvider =
NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);