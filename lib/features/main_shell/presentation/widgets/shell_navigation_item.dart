import '../../../../core/constants/app_svgs.dart';

/// SVG icon + label data for one bottom-nav / rail section. Kept as
/// plain data (not a widget) so the destination list is defined once and
/// reused by [ShellTabBody] (index lookups), [MainShellBottomNav], and
/// the tablet [NavigationRail] — add or reorder a section here and every
/// consumer updates together.
class ShellNavItemData {
  final String svgIcon;
  final String label;

  const ShellNavItemData({
    required this.svgIcon,
    required this.label,
  });
}

const List<ShellNavItemData> shellNavItems = [
  ShellNavItemData(svgIcon: AppSvgs.home, label: 'Home'),
  ShellNavItemData(svgIcon: AppSvgs.stock, label: 'Stock'),
  ShellNavItemData(svgIcon: AppSvgs.report, label: 'Report'),
  ShellNavItemData(svgIcon: AppSvgs.more, label: 'More'),
];