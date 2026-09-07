import 'package:flutter/material.dart';

/// Icon + label data for one bottom-nav tab. Kept as plain data (not
/// a widget) so the destination list can be built once and reused by
/// both [ShellTabBody] index lookups and the nav bar itself — add or
/// reorder a feature here and both the tab content and the nav icons
/// update together.
class ShellNavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const ShellNavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

const List<ShellNavItemData> shellNavItems = [
  ShellNavItemData(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
  ShellNavItemData(icon: Icons.access_time_rounded, selectedIcon: Icons.access_time_filled_rounded, label: 'Activity'),
  ShellNavItemData(icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart_rounded, label: 'Analytics'),
  ShellNavItemData(icon: Icons.shopping_bag_outlined, selectedIcon: Icons.shopping_bag_rounded, label: 'Orders'),
  ShellNavItemData(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Profile'),
];