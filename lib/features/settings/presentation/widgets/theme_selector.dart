import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/common/settings_tile.dart';

/// Cycles System → Light → Dark on tap, shown as a SettingsTile with the
/// current mode as its trailing value.
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  String _label(ThemeMode mode) => switch (mode) {
    ThemeMode.system => AppStrings.themeSystem,
    ThemeMode.light => AppStrings.themeLight,
    ThemeMode.dark => AppStrings.themeDark,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    return SettingsTile(
      icon: Icons.dark_mode_outlined,
      title: AppStrings.appearance,
      value: _label(mode),
      trailing: SettingsTileTrailing.chevron,
      onTap: () {
        final next = switch (mode) {
          ThemeMode.system => ThemeMode.light,
          ThemeMode.light => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.system,
          // TODO: Handle this case.
          Object() => throw UnimplementedError(),
          // // TODO: Handle this case.
          // null => throw UnimplementedError(),
        };
        controller.setThemeMode(next);
      },
    );
  }
}