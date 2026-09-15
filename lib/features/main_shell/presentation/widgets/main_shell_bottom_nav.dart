import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';
import 'pos_fab_button.dart';
import 'shell_navigation_item.dart';

/// Floating pill-shaped bottom navigation bar for [MainShellMobileView].
/// Holds the four [shellNavItems] (Home / Stock / Report / More) with a
/// circular notch at top-center where [PosFabButton] docks — the FAB
/// itself is NOT drawn here; it's supplied to `Scaffold.floatingActionButton`
/// with `FloatingActionButtonLocation.centerDocked` so Flutter positions
/// it half above / half nested into this bar automatically.
///
/// Horizontal margin around the pill (see [_horizontalMargin]) is what
/// keeps the sides transparent — screen content shows through there,
/// matching a floating dock rather than an edge-to-edge bar.
class MainShellBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const MainShellBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const double _barHeight = AppSizes.bottomNavBarHeight; // 64
  static const double _horizontalMargin = AppSizes.md; // floating pill inset
  static const double _notchGap = AppSizes.xs; // breathing room around the FAB

  @override
  Widget build(BuildContext context) {
    final notchRadius = PosFabButton.diameter / 2 + _notchGap + 5;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _horizontalMargin,
        0,
        _horizontalMargin,
        MediaQuery.paddingOf(context).bottom > 0 ? AppSizes.md : AppSizes.md,
      ),
      child: SizedBox(
        height: _barHeight,
        child: ClipPath(
          clipper: _NotchedPillClipper(
            notchRadius: 0,
            cornerRadius: _barHeight / 2,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: context.appColors.border,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      index: 0,
                      item: shellNavItems[0],
                      selectedIndex: selectedIndex,
                      onSelected: onSelected,
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      index: 1,
                      item: shellNavItems[1],
                      selectedIndex: selectedIndex,
                      onSelected: onSelected,
                    ),
                  ),
                  SizedBox(width: PosFabButton.diameter + AppSizes.md),
                  Expanded(
                    child: _NavItem(
                      index: 2,
                      item: shellNavItems[2],
                      selectedIndex: selectedIndex,
                      onSelected: onSelected,
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      index: 3,
                      item: shellNavItems[3],
                      selectedIndex: selectedIndex,
                      onSelected: onSelected,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final ShellNavItemData item;
  final ValueChanged<int> onSelected;

  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.item,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == selectedIndex;
    final color = active ? AppColors.primary : context.appColors.textSecondary;

    return InkWell(
      onTap: () => onSelected(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon.string(
            svgString: active ? item.selectedIcon : item.svgIcon,
            size: AppSizes.iconMd,
            color: color,
          ),
          const SizedBox(height: AppSizes.xs / 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: AppSizes.fontXs,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Clips the pill into a full stadium shape (fully rounded left/right
/// ends, per the reference floating-dock design) with a circular notch
/// dipped into the top-center edge where [PosFabButton] nests. The notch
/// is an approximated semicircle (two quadratic curves) sized to clear
/// the FAB's diameter plus [notchRadius]'s built-in gap.
class _NotchedPillClipper extends CustomClipper<Path> {
  final double notchRadius;
  final double cornerRadius;

  const _NotchedPillClipper({
    required this.notchRadius,
    required this.cornerRadius,
  });

  @override
  Path getClip(Size size) {
    final centerX = size.width / 2;
    final r = notchRadius;

    return Path()
      ..moveTo(0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..lineTo(centerX - r, 0)
      ..quadraticBezierTo(centerX - r, r * 1.15, centerX, r * 1.15)
      ..quadraticBezierTo(centerX + r, r * 1.15, centerX + r, 0)
      ..lineTo(size.width - cornerRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, cornerRadius)
      ..lineTo(size.width, size.height - cornerRadius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - cornerRadius,
        size.height,
      )
      ..lineTo(cornerRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - cornerRadius)
      ..close();
  }

  @override
  bool shouldReclip(covariant _NotchedPillClipper oldClipper) =>
      oldClipper.notchRadius != notchRadius ||
      oldClipper.cornerRadius != cornerRadius;
}
