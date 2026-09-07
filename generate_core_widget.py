from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path
from textwrap import dedent


APP_COLORS = {
    "primary": "AppColors.primary",
    "primaryDark": "AppColors.primaryDark",
    "primaryLight": "AppColors.primaryLight",
    "accent": "AppColors.accent",
    "accentLight": "AppColors.accentLight",
    "background": "AppColors.background",
    "surface": "AppColors.surface",
    "surfaceDark": "AppColors.surfaceDark",
    "textPrimary": "AppColors.textPrimary",
    "textSecondary": "AppColors.textSecondary",
    "textHint": "AppColors.textHint",
    "textWhite": "AppColors.textWhite",
    "success": "AppColors.success",
    "warning": "AppColors.warning",
    "error": "AppColors.error",
    "info": "AppColors.info",
    "border": "AppColors.border",
    "divider": "AppColors.divider",
    "shimmerBase": "AppColors.shimmerBase",
    "shimmerHighlight": "AppColors.shimmerHighlight",
}

APP_SIZES = {
    "xs": "AppSizes.xs",
    "sm": "AppSizes.sm",
    "md": "AppSizes.md",
    "lg": "AppSizes.lg",
    "xl": "AppSizes.xl",
    "xxl": "AppSizes.xxl",
    "radiusSm": "AppSizes.radiusSm",
    "radiusMd": "AppSizes.radiusMd",
    "radiusLg": "AppSizes.radiusLg",
    "radiusXl": "AppSizes.radiusXl",
    "radiusFull": "AppSizes.radiusFull",
    "iconSm": "AppSizes.iconSm",
    "iconMd": "AppSizes.iconMd",
    "iconLg": "AppSizes.iconLg",
    "fontXs": "AppSizes.fontXs",
    "fontSm": "AppSizes.fontSm",
    "fontMd": "AppSizes.fontMd",
    "fontLg": "AppSizes.fontLg",
    "fontXl": "AppSizes.fontXl",
    "fontXxl": "AppSizes.fontXxl",
    "fontDisplay": "AppSizes.fontDisplay",
    "buttonHeight": "AppSizes.buttonHeight",
    "inputHeight": "AppSizes.inputHeight",
    "appBarHeight": "AppSizes.appBarHeight",
    "bottomNavBarHeight": "AppSizes.bottomNavBarHeight",
}


def dart(source: str) -> str:
    return dedent(source).strip() + "\n"


COMMON_WIDGETS: dict[str, str] = {
    "activity_filter_tabs.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_strings.dart';
        import 'package:__PACKAGE_NAME__/core/widgets/common/custom_filter_bar.dart';

        /// Today / This Week / This Month filter for the activity feed.
        class ActivityFilterTabs extends StatelessWidget {
          final String selected;
          final ValueChanged<String> onChanged;

          const ActivityFilterTabs({super.key, required this.selected, required this.onChanged});

          @override
          Widget build(BuildContext context) {
            return CustomFilterBar<String>(
              filters: const ['today', 'week', 'month'],
              selectedFilters: {selected},
              labelBuilder: (f) => switch (f) {
                'today' => AppStrings.filterToday,
                'week' => AppStrings.filterThisWeek,
                _ => AppStrings.filterThisMonth,
              },
              onSelected: onChanged,
            );
          }
        }
    '''),
    "app_header_bar.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        enum HeaderBackStyle { none, chevron, circle }

        /// Single flexible header for left-aligned-title screens — list
        /// pages, detail pages, modal-edit screens. Optional subtitle,
        /// optional back button (none / inline chevron / bordered circle),
        /// and an optional trailing action (icon button or text link, not
        /// both). Replaces what used to be three separate widgets.
        ///
        /// For a *centered* title with a square bordered back button, use
        /// [CustomAppBar] instead — together these two cover all app-bar needs.
        class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
          final String title;
          final String? subtitle;
          final HeaderBackStyle backStyle;
          final VoidCallback? onBackTap;
          final IconData? trailingIcon;
          final String? trailingLabel;
          final VoidCallback? onTrailingTap;

          const AppHeaderBar({
            super.key,
            required this.title,
            this.subtitle,
            this.backStyle = HeaderBackStyle.none,
            this.onBackTap,
            this.trailingIcon,
            this.trailingLabel,
            this.onTrailingTap,
          }) : assert(trailingIcon == null || trailingLabel == null,
              'Provide trailingIcon OR trailingLabel, not both');

          Widget? _buildBack(BuildContext context) {
            final tap = onBackTap ?? () => Navigator.of(context).maybePop();
            switch (backStyle) {
              case HeaderBackStyle.none:
                return null;
              case HeaderBackStyle.chevron:
                return InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  onTap: tap,
                  child: const Padding(
                    padding: EdgeInsets.all(AppSizes.xs),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: AppSizes.iconSm, color: AppColors.textPrimary),
                  ),
                );
              case HeaderBackStyle.circle:
                return InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  onTap: tap,
                  child: Container(
                    width: AppSizes.xl + AppSizes.xs,
                    height: AppSizes.xl + AppSizes.xs,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconSm, color: AppColors.textPrimary),
                  ),
                );
            }
          }

          Widget? _buildTrailing() {
            if (trailingIcon != null) {
              return InkWell(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                onTap: onTrailingTap,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
                  child: Icon(trailingIcon, size: AppSizes.iconSm, color: AppColors.primary),
                ),
              );
            }
            if (trailingLabel != null) {
              return InkWell(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                onTap: onTrailingTap,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  child: Text(
                    trailingLabel!,
                    style: const TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              );
            }
            return null;
          }

          @override
          Widget build(BuildContext context) {
            final back = _buildBack(context);
            final trailing = _buildTrailing();

            return Container(
              height: preferredSize.height,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  if (back != null) ...[back, const SizedBox(width: AppSizes.md)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: const TextStyle(fontSize: AppSizes.fontXl, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSizes.xs / 2),
                          Text(subtitle!, style: const TextStyle(fontSize: AppSizes.fontSm, color: AppColors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            );
          }

          @override
          Size get preferredSize => Size.fromHeight(subtitle == null ? AppSizes.appBarHeight : AppSizes.appBarHeight + AppSizes.lg);
        }
    '''),
    "app_svg_icon.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:flutter_svg/flutter_svg.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Renders an SVG icon from an asset or a network URL.
        ///
        /// Two modes:
        /// - Tinted (default): every path is recolored with [color] (falls back to
        ///   [AppColors.textPrimary]) — use for monochrome/outline icon sets.
        /// - [multicolor] = true: the SVG's own fill colors are preserved untouched
        ///   — use for brand marks, flags, illustrations.
        class AppSvgIcon extends StatelessWidget {
          final String assetPath;
          final String? networkUrl;
          final double size;
          final double? width;
          final double? height;
          final Color? color;
          final bool multicolor;
          final BoxFit fit;
          final Widget? placeholder;

          const AppSvgIcon({
            super.key,
            required this.assetPath,
            this.size = AppSizes.iconMd,
            this.width,
            this.height,
            this.color,
            this.multicolor = false,
            this.fit = BoxFit.contain,
            this.placeholder,
          }) : networkUrl = null;

          const AppSvgIcon.network({
            super.key,
            required String url,
            this.size = AppSizes.iconMd,
            this.width,
            this.height,
            this.color,
            this.multicolor = false,
            this.fit = BoxFit.contain,
            this.placeholder,
          })  : networkUrl = url,
                assetPath = '';

          @override
          Widget build(BuildContext context) {
            final ColorFilter? colorFilter = multicolor
                ? null
                : ColorFilter.mode(color ?? AppColors.textPrimary, BlendMode.srcIn);

            final fallback = placeholder ??
                SizedBox(width: width ?? size, height: height ?? size);

            if (networkUrl != null && networkUrl!.isNotEmpty) {
              return SvgPicture.network(
                networkUrl!,
                width: width ?? size,
                height: height ?? size,
                fit: fit,
                colorFilter: colorFilter,
                placeholderBuilder: (_) => fallback,
              );
            }

            return SvgPicture.asset(
              assetPath,
              width: width ?? size,
              height: height ?? size,
              fit: fit,
              colorFilter: colorFilter,
              placeholderBuilder: (_) => fallback,
            );
          }
        }
    '''),
    "avatar.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class AppAvatar extends StatelessWidget {
          final String? imageUrl;
          final String? label;
          final double radius;
          final VoidCallback? onTap;

          const AppAvatar({
            super.key,
            this.imageUrl,
            this.label,
            this.radius = AppSizes.xxl,
            this.onTap,
          });

          @override
          Widget build(BuildContext context) {
            final avatar = CircleAvatar(
              radius: radius,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl!),
              child: imageUrl != null
                  ? null
                  : Text(
                      (label?.trim().isNotEmpty ?? false) ? label!.trim()[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.primary, fontSize: AppSizes.fontXl, fontWeight: FontWeight.w700),
                    ),
            );
            return onTap == null ? avatar : GestureDetector(onTap: onTap, child: avatar);
          }
        }
    '''),
    "avatar_photo_picker.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';
        import 'avatar.dart';

        /// [AppAvatar] with a camera badge overlapping its bottom edge, plus
        /// a tappable action-label link underneath. Used on edit-profile
        /// forms.
        class AvatarPhotoPicker extends StatelessWidget {
          final String? imageUrl;
          final String? label;
          final String actionLabel;
          final VoidCallback? onTap;
          final double radius;

          const AvatarPhotoPicker({
            super.key,
            this.imageUrl,
            this.label,
            this.actionLabel = 'Change Photo',
            this.onTap,
            this.radius = AppSizes.xxl + AppSizes.md,
          });

          @override
          Widget build(BuildContext context) {
            return GestureDetector(
              onTap: onTap,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AppAvatar(imageUrl: imageUrl, label: label, radius: radius),
                      Positioned(
                        right: -AppSizes.xs / 2,
                        bottom: -AppSizes.xs / 2,
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.xs + AppSizes.xs / 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: AppSizes.iconSm - AppSizes.xs / 2, color: AppColors.textWhite),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(actionLabel, style: const TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            );
          }
        }
    '''),
    "bottom_action_bar.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Fixed footer bar with a top border, holding one persistent action
        /// (typically a [PrimaryButton]). Used for "Save Changes" / "Submit"
        /// style bars pinned below scrollable form content.
        class BottomActionBar extends StatelessWidget {
          final Widget child;

          const BottomActionBar({super.key, required this.child});

          @override
          Widget build(BuildContext context) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(top: false, child: child),
            );
          }
        }
    '''),
    "contact_method_card.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';
        import 'custom_card.dart';
        import 'square_icon_tile.dart';

        /// Card describing one support-contact channel — tinted icon, bold
        /// title, and a tappable link-styled value beneath (e.g. "Chat Now",
        /// an email, a phone number).
        class ContactMethodCard extends StatelessWidget {
          final IconData icon;
          final String title;
          final String actionLabel;
          final VoidCallback? onTap;

          const ContactMethodCard({
            super.key,
            required this.icon,
            required this.title,
            required this.actionLabel,
            this.onTap,
          });

          @override
          Widget build(BuildContext context) {
            return CustomCard(
              fullWidth: true,
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SquareIconTile(icon: icon, color: AppColors.primary),
                  const SizedBox(height: AppSizes.sm + AppSizes.xs),
                  Text(
                    title,
                    style: const TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppSizes.xs / 2),
                  Text(
                    actionLabel,
                    style: const TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ),
            );
          }
        }
    '''),
    "custom_app_bar.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// App-wide top bar — a bordered square back button on the left, a
        /// centered title, and an optional trailing widget (or a matching-size
        /// spacer to keep the title truly centered).
        class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
          final String title;
          final bool showBack;
          final VoidCallback? onBackTap;
          final Widget? trailing;

          const CustomAppBar({
            super.key,
            required this.title,
            this.showBack = true,
            this.onBackTap,
            this.trailing,
          });

          @override
          Widget build(BuildContext context) {
            final sideSpacer = const SizedBox(width: AppSizes.xl, height: AppSizes.xl);

            return SizedBox(
              height: preferredSize.height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showBack)
                      InkWell(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconSm, color: AppColors.textPrimary),
                        ),
                      )
                    else
                      sideSpacer,
                    Text(
                      title,
                      style: const TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    trailing ?? sideSpacer,
                  ],
                ),
              ),
            );
          }

          @override
          Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);
        }
    '''),
    "custom_bottom_nav.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class CustomBottomNav extends StatelessWidget {
          final int selectedIndex;
          final ValueChanged<int> onSelected;
          final List<NavigationDestination> destinations;
          final bool showLabels;
          final Color indicatorColor;

          const CustomBottomNav({
            super.key,
            required this.selectedIndex,
            required this.onSelected,
            required this.destinations,
            this.showLabels = true,
            this.indicatorColor = AppColors.primaryLight,
          });

          @override
          Widget build(BuildContext context) {
            return SizedBox(
              height: AppSizes.bottomNavBarHeight,
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: AppColors.surface,
                  indicatorColor: indicatorColor,
                  iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                    (states) {
                      if (states.contains(WidgetState.selected)) {
                        return const IconThemeData(color: AppColors.primary);
                      }
                      return const IconThemeData(color: AppColors.textSecondary);
                    },
                  ),
                  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                    (states) {
                      if (states.contains(WidgetState.selected)) {
                        return const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600);
                      }
                      return const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500);
                    },
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onSelected,
                  destinations: destinations,
                  labelBehavior: showLabels
                      ? NavigationDestinationLabelBehavior.alwaysShow
                      : NavigationDestinationLabelBehavior.onlyShowSelected,
                ),
              ),
            );
          }
        }
    '''),
    "custom_card.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Bordered, subtly-shadowed card container — the base surface for
        /// grouped content (forms, dashboard tiles, list items). Pass
        /// [accentColor] to draw a colored strip down the left edge (status/
        /// category indicator); pass [tinted] to wash the whole card in that
        /// color instead of white.
        class CustomCard extends StatelessWidget {
          final Widget child;
          final VoidCallback? onTap;
          final EdgeInsetsGeometry padding;
          final Color? accentColor;
          final bool tinted;
          final bool fullWidth;

          const CustomCard({
            super.key,
            required this.child,
            this.onTap,
            this.padding = const EdgeInsets.all(AppSizes.lg),
            this.accentColor,
            this.tinted = false,
            this.fullWidth = false,
          });

          @override
          Widget build(BuildContext context) {
            final bg = tinted ? AppColors.primaryLight : AppColors.surface;

            final content = Container(
              width: fullWidth ? double.infinity : double.maxFinite,
              padding: padding,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: child,
            );

            final withAccent = accentColor == null
                ? content
                : ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(width: AppSizes.xs / 2 + 2, color: accentColor),
                          Expanded(child: content),
                        ],
                      ),
                    ),
                  );

            return Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: withAccent,
              ),
            );
          }
        }
    '''),
    "custom_filter_bar.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class CustomFilterBar<T> extends StatelessWidget {
          final List<T> filters;
          final Set<T> selectedFilters;
          final String Function(T) labelBuilder;
          final ValueChanged<T>? onSelected;
          final VoidCallback? onClear;
          final bool showCheckmark;

          const CustomFilterBar({
            super.key,
            required this.filters,
            required this.selectedFilters,
            required this.labelBuilder,
            this.onSelected,
            this.onClear,
            this.showCheckmark = false,
          });

          @override
          Widget build(BuildContext context) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...filters.map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: AppSizes.sm),
                      child: FilterChip(
                        label: Text(labelBuilder(filter)),
                        selected: selectedFilters.contains(filter),
                        onSelected: (_) => onSelected?.call(filter),
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.border),
                        showCheckmark: showCheckmark,
                      ),
                    ),
                  ),
                  if (onClear != null)
                    ActionChip(
                      label: const Text('Clear'),
                      onPressed: onClear,
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.border),
                    ),
                ],
              ),
            );
          }
        }
    '''),
    "custom_icon_badge.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        enum IconBadgeVariant { outlined, filled }

        /// Large circular icon badge for status/confirmation screens.
        /// - [IconBadgeVariant.outlined]: white circle + border + shadow (OTP
        ///   verification, error states).
        /// - [IconBadgeVariant.filled]: soft tinted circle, no border (forgot
        ///   password, empty states, success confirmations).
        class CustomIconBadge extends StatelessWidget {
          final IconData icon;
          final Color color;
          final double size;
          final double iconSize;
          final IconBadgeVariant variant;

          const CustomIconBadge({
            super.key,
            required this.icon,
            this.color = AppColors.primary,
            this.size = AppSizes.xxl * 2 + AppSizes.xs,
            this.iconSize = AppSizes.xxl,
            this.variant = IconBadgeVariant.outlined,
          });

          @override
          Widget build(BuildContext context) {
            final isFilled = variant == IconBadgeVariant.filled;

            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? color.withValues(alpha: 0.1) : AppColors.surface,
                border: isFilled ? null : Border.all(color: AppColors.border),
                boxShadow: isFilled
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.02),
                          blurRadius: AppSizes.md,
                          offset: const Offset(0, AppSizes.xs),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: iconSize),
            );
          }
        }
    '''),
    "custom_labeled_divider.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Horizontal divider with a centered label — "or continue with",
        /// "or sign up with", etc.
        class CustomLabeledDivider extends StatelessWidget {
          final String label;

          const CustomLabeledDivider({super.key, required this.label});

          @override
          Widget build(BuildContext context) {
            return Row(
              children: [
                const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: AppSizes.fontSm, color: AppColors.textSecondary),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
              ],
            );
          }
        }
    '''),
    "custom_list_tile.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class CustomListTile extends StatelessWidget {
          final String title;
          final String? subtitle;
          final Widget? leading;
          final Widget? trailing;
          final VoidCallback? onTap;
          final bool enabled;

          const CustomListTile({
            super.key,
            required this.title,
            this.subtitle,
            this.leading,
            this.trailing,
            this.onTap,
            this.enabled = true,
          });

          @override
          Widget build(BuildContext context) {
            return ListTile(
              enabled: enabled,
              title: Text(title),
              subtitle: subtitle == null ? null : Text(subtitle!),
              leading: leading,
              trailing: trailing,
              onTap: onTap,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
              iconColor: AppColors.textSecondary,
              textColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
            );
          }
        }
    '''),
    "custom_step_indicator.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Row of progress dots — onboarding pager, multi-step checkout/forms.
        /// The active dot stretches into a short bar; inactive dots stay round.
        class CustomStepIndicator extends StatelessWidget {
          final int stepCount;
          final int currentStep;

          const CustomStepIndicator({
            super.key,
            required this.stepCount,
            required this.currentStep,
          });

          @override
          Widget build(BuildContext context) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(stepCount, (index) {
                final active = index == currentStep;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.only(right: index == stepCount - 1 ? 0 : AppSizes.xs),
                  height: AppSizes.sm,
                  width: active ? AppSizes.lg : AppSizes.sm,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                  ),
                );
              }),
            );
          }
        }
    '''),
    "custom_tab_bar.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class CustomTabBar extends StatelessWidget {
          final TabController? controller;
          final List<Widget> tabs;
          final bool isScrollable;

          const CustomTabBar({
            super.key,
            this.controller,
            required this.tabs,
            this.isScrollable = false,
          });

          @override
          Widget build(BuildContext context) {
            return TabBar(
              dividerColor: Colors.transparent,
              controller: controller,
              tabs: tabs,
              isScrollable: isScrollable,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: AppSizes.xs,
              labelStyle: const TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600),
              tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
            );
          }
        }
    '''),
    "date_field.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class DateField extends StatelessWidget {
          final String label;
          final String? hint;
          final DateTime? value;
          final DateTime? firstDate;
          final DateTime? lastDate;
          final ValueChanged<DateTime>? onChanged;
          final String Function(DateTime)? formatter;
          final String? Function(String?)? validator;
          final bool enabled;

          const DateField({
            super.key,
            this.label = 'Date',
            this.hint,
            this.value,
            this.firstDate,
            this.lastDate,
            this.onChanged,
            this.formatter,
            this.validator,
            this.enabled = true,
          });

          String _format(DateTime date) => formatter?.call(date) ?? '${date.day}/${date.month}/${date.year}';

          @override
          Widget build(BuildContext context) {
            return TextFormField(
              readOnly: true,
              enabled: enabled,
              validator: validator,
              controller: TextEditingController(text: value == null ? '' : _format(value!)),
              onTap: !enabled
                  ? null
                  : () async {
                      final selected = await showDatePicker(
                        context: context,
                        firstDate: firstDate ?? DateTime(2000),
                        lastDate: lastDate ?? DateTime(2100),
                        initialDate: value ?? DateTime.now(),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: AppColors.primary,
                              surface: AppColors.surface,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (selected != null) onChanged?.call(selected);
                    },
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: AppSizes.iconMd),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            );
          }
        }
    '''),
    "dropdown_field.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class DropdownField<T> extends StatelessWidget {
          final T? value;
          final List<DropdownMenuItem<T>> items;
          final ValueChanged<T?>? onChanged;
          final String? label;
          final String? hint;
          final String? Function(T?)? validator;
          final bool enabled;

          const DropdownField({
            super.key,
            this.value,
            required this.items,
            this.onChanged,
            this.label,
            this.hint,
            this.validator,
            this.enabled = true,
          });

          @override
          Widget build(BuildContext context) {
            return DropdownButtonFormField<T>(
              initialValue: value,
              items: items,
              onChanged: enabled ? onChanged : null,
              validator: validator,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            );
          }
        }
    '''),
    "faq_accordion_item.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Single expandable FAQ row — question + chevron that rotates on
        /// expand, answer text revealed beneath. Manages its own open/closed
        /// state; report changes upward only if the caller needs to track
        /// which question is open (e.g. accordion-style single-open lists).
        class FaqAccordionItem extends StatefulWidget {
          final String question;
          final String answer;
          final bool initiallyExpanded;

          const FaqAccordionItem({
            super.key,
            required this.question,
            required this.answer,
            this.initiallyExpanded = false,
          });

          @override
          State<FaqAccordionItem> createState() => _FaqAccordionItemState();
        }

        class _FaqAccordionItemState extends State<FaqAccordionItem> {
          late bool _expanded = widget.initiallyExpanded;

          @override
          Widget build(BuildContext context) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.question,
                            style: const TextStyle(
                              fontSize: AppSizes.fontMd,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: const Icon(Icons.keyboard_arrow_down_rounded, size: AppSizes.iconSm, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 180),
                    crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: Padding(
                      padding: const EdgeInsets.only(top: AppSizes.sm + AppSizes.xs),
                      child: Text(
                        widget.answer,
                        style: const TextStyle(fontSize: AppSizes.fontSm, color: AppColors.textSecondary, height: 1.5),
                      ),
                    ),
                    secondChild: const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            );
          }
        }
    '''),
    "gradient_cover_header.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';
        import 'avatar.dart';

        /// Gradient banner with an [AppAvatar] overlapping the bottom edge
        /// and an optional edit/camera badge on it. Used at the top of
        /// profile-style screens.
        class GradientCoverHeader extends StatelessWidget {
          final String? avatarUrl;
          final String? avatarLabel;
          final double coverHeight;
          final double avatarRadius;
          final VoidCallback? onAvatarEditTap;
          final List<Color> gradientColors;

          const GradientCoverHeader({
            super.key,
            this.avatarUrl,
            this.avatarLabel,
            this.coverHeight = AppSizes.xxl * 2 - AppSizes.xs,
            this.avatarRadius = AppSizes.xxl + AppSizes.xs,
            this.onAvatarEditTap,
            this.gradientColors = const [AppColors.primary, AppColors.primaryDark],
          });

          @override
          Widget build(BuildContext context) {
            return SizedBox(
              height: coverHeight + avatarRadius,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: coverHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                    ),
                  ),
                  Positioned(
                    top: coverHeight - avatarRadius,
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.xs),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AppAvatar(
                            imageUrl: avatarUrl,
                            label: avatarLabel,
                            radius: avatarRadius,
                          ),
                          if (onAvatarEditTap != null)
                            Positioned(
                              right: -AppSizes.xs,
                              bottom: -AppSizes.xs,
                              child: GestureDetector(
                                onTap: onAvatarEditTap,
                                child: Container(
                                  padding: const EdgeInsets.all(AppSizes.sm - AppSizes.xs / 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: AppSizes.xs,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: AppSizes.iconSm - AppSizes.xs,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
    '''),
    "hero_image_banner.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Full-width rounded hero illustration/banner — welcome screens,
        /// empty-state headers, marketing sections. Falls back to a placeholder
        /// icon if the asset/network image fails to load.
        class HeroImageBanner extends StatelessWidget {
          final String imagePath;
          final double height;
          final bool isNetworkImage;

          const HeroImageBanner({
            super.key,
            required this.imagePath,
            this.height = AppSizes.xxl * 5,
            this.isNetworkImage = false,
          });

          @override
          Widget build(BuildContext context) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: SizedBox(
                width: double.infinity,
                height: height,
                child: Image(
                  image: isNetworkImage ? NetworkImage(imagePath) as ImageProvider : AssetImage(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.background,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined, color: AppColors.textHint, size: AppSizes.iconLg),
                  ),
                ),
              ),
            );
          }
        }
    '''),
    "icon_button.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class AppIconButton extends StatelessWidget {
          final IconData icon;
          final VoidCallback? onPressed;
          final String? tooltip;
          final Color? color;
          final Color? backgroundColor;
          final double? iconSize;
          final bool filled;

          const AppIconButton({
            super.key,
            required this.icon,
            this.onPressed,
            this.tooltip,
            this.color,
            this.backgroundColor,
            this.iconSize,
            this.filled = false,
          });

          @override
          Widget build(BuildContext context) {
            final button = IconButton(
              onPressed: onPressed,
              tooltip: tooltip,
              iconSize: iconSize ?? AppSizes.iconMd,
              color: color ?? AppColors.textPrimary,
              style: IconButton.styleFrom(
                backgroundColor: filled ? (backgroundColor ?? AppColors.primaryLight) : null,
                foregroundColor: color ?? AppColors.textPrimary,
                disabledForegroundColor: AppColors.textHint,
                padding: const EdgeInsets.all(AppSizes.sm),
              ),
              icon: Icon(icon),
            );
            return button;
          }
        }
    '''),
    "link_button.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Text-only action link — "Forgot password?", "Register", "Skip".
        class LinkButton extends StatelessWidget {
          final String label;
          final VoidCallback? onPressed;
          final Color? color;
          final double fontSize;
          final FontWeight fontWeight;

          const LinkButton({
            super.key,
            required this.label,
            this.onPressed,
            this.color,
            this.fontSize = AppSizes.fontMd,
            this.fontWeight = FontWeight.w600,
          });

          @override
          Widget build(BuildContext context) {
            return TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                foregroundColor: color ?? AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight)),
            );
          }
        }
    '''),
    "numbered_list_item.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Row with a tinted numbered chip ("01", "02"...) on the left and
        /// body text on the right. Used for enumerated policy points, steps,
        /// or ordered lists inside long-form document content.
        class NumberedListItem extends StatelessWidget {
          final String number;
          final String text;

          const NumberedListItem({super.key, required this.number, required this.text});

          @override
          Widget build(BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm + AppSizes.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs / 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm - 2),
                    ),
                    child: Text(
                      number,
                      style: const TextStyle(color: AppColors.primary, fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm + AppSizes.xs),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: AppSizes.fontMd, color: AppColors.textSecondary, height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }
        }
    '''),
    "otp_input_field.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Fixed-length OTP / PIN input — one box per digit. Auto-advances
        /// focus as the user types, calls [onCompleted] once every box is filled.
        class OtpInputField extends StatefulWidget {
          final int length;
          final ValueChanged<String>? onChanged;
          final ValueChanged<String>? onCompleted;

          const OtpInputField({
            super.key,
            this.length = 6,
            this.onChanged,
            this.onCompleted,
          });

          @override
          State<OtpInputField> createState() => _OtpInputFieldState();
        }

        class _OtpInputFieldState extends State<OtpInputField> {
          late final List<TextEditingController> _controllers;
          late final List<FocusNode> _focusNodes;

          @override
          void initState() {
            super.initState();
            _controllers = List.generate(widget.length, (_) => TextEditingController());
            _focusNodes = List.generate(widget.length, (_) => FocusNode());
            for (final node in _focusNodes) {
              node.addListener(() => setState(() {}));
            }
          }

          @override
          void dispose() {
            for (final c in _controllers) {
              c.dispose();
            }
            for (final f in _focusNodes) {
              f.dispose();
            }
            super.dispose();
          }

          void _onChanged(String value, int index) {
            if (value.isNotEmpty && index < widget.length - 1) {
              _focusNodes[index + 1].requestFocus();
            }
            if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }

            final code = _controllers.map((c) => c.text).join();
            widget.onChanged?.call(code);
            if (code.length == widget.length) {
              widget.onCompleted?.call(code);
            }
          }

          @override
          Widget build(BuildContext context) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.length, (index) {
                final active = _focusNodes[index].hasFocus || _controllers[index].text.isNotEmpty;

                return Padding(
                  padding: EdgeInsets.only(right: index == widget.length - 1 ? 0 : AppSizes.sm),
                  child: SizedBox(
                    width: AppSizes.xxl,
                    height: AppSizes.xxl,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w700,
                        color: active ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '-',
                        hintStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          borderSide: BorderSide(color: active ? AppColors.primary : AppColors.border, width: active ? 2 : 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          borderSide: BorderSide(color: active ? AppColors.primary : AppColors.border, width: active ? 2 : 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      onChanged: (value) => _onChanged(value, index),
                    ),
                  ),
                );
              }),
            );
          }
        }
    '''),
    "password_input_field.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';
        import 'primary_input_field.dart';

        /// Password field with a built-in show/hide (eye icon) toggle.
        /// Drop-in replacement for [PrimaryInputField] on any password input
        /// (login, register, change password...).
        class PasswordInputField extends StatefulWidget {
          final String? label;
          final String? hint;
          final TextEditingController? controller;
          final String? Function(String?)? validator;
          final ValueChanged<String>? onChanged;

          const PasswordInputField({
            super.key,
            this.label = 'Password',
            this.hint,
            this.controller,
            this.validator,
            this.onChanged,
          });

          @override
          State<PasswordInputField> createState() => _PasswordInputFieldState();
        }

        class _PasswordInputFieldState extends State<PasswordInputField> {
          bool _obscure = true;

          @override
          Widget build(BuildContext context) {
            return PrimaryInputField(
              label: widget.label,
              hint: widget.hint,
              controller: widget.controller,
              validator: widget.validator,
              onChanged: widget.onChanged,
              obscureText: _obscure,
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: AppSizes.iconSm),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: AppSizes.iconSm,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            );
          }
        }
    '''),
    "password_strength_meter.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        enum PasswordStrength { weak, fair, good, strong }

        /// "Password Strength" label + 4-segment bar indicator, shown under a
        /// password field while the user types.
        class PasswordStrengthMeter extends StatelessWidget {
          final PasswordStrength strength;

          const PasswordStrengthMeter({super.key, required this.strength});

          int get _filledBars => switch (strength) {
                PasswordStrength.weak => 1,
                PasswordStrength.fair => 2,
                PasswordStrength.good => 3,
                PasswordStrength.strong => 4,
              };

          Color get _color => switch (strength) {
                PasswordStrength.weak => AppColors.error,
                PasswordStrength.fair => AppColors.warning,
                PasswordStrength.good => AppColors.info,
                PasswordStrength.strong => AppColors.success,
              };

          String get _label => switch (strength) {
                PasswordStrength.weak => 'Weak',
                PasswordStrength.fair => 'Medium',
                PasswordStrength.good => 'Good',
                PasswordStrength.strong => 'Strong',
              };

          @override
          Widget build(BuildContext context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Password Strength',
                      style: TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textSecondary),
                    ),
                    Text(
                      _label,
                      style: TextStyle(fontSize: AppSizes.fontXs, color: _color, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xs),
                Row(
                  children: List.generate(4, (index) {
                    final filled = index < _filledBars;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index == 3 ? 0 : AppSizes.xs),
                        child: Container(
                          height: AppSizes.xs / 2,
                          decoration: BoxDecoration(
                            color: filled ? _color : AppColors.border,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm / 2),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          }
        }
    '''),
    "primary_button.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Primary filled call-to-action button — the main action on a screen
        /// (Sign In, Save, Checkout...).
        class PrimaryButton extends StatelessWidget {
          final String label;
          final VoidCallback? onPressed;
          final bool loading;
          final IconData? icon;
          final double? width;

          const PrimaryButton({
            super.key,
            required this.label,
            this.onPressed,
            this.loading = false,
            this.icon,
            this.width,
          });

          @override
          Widget build(BuildContext context) {
            final disabled = loading || onPressed == null;

            return SizedBox(
              width: width ?? double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: disabled ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                  textStyle: const TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600),
                ),
                child: loading
                    ? const SizedBox(
                        height: AppSizes.iconMd,
                        width: AppSizes.iconMd,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textWhite),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[Icon(icon, size: AppSizes.iconSm), const SizedBox(width: AppSizes.sm)],
                          Text(label),
                        ],
                      ),
              ),
            );
          }
        }
    '''),
    "primary_checkbox.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Compact checkbox + label, e.g. "Remember Me", "I agree to the Terms".
        /// Sized to sit inline in a Row (unlike a full-width ListTile) —
        /// wrap in Expanded/Flexible if placed alongside another widget in a Row.
        class PrimaryCheckbox extends StatelessWidget {
          final bool value;
          final ValueChanged<bool?>? onChanged;
          final String? label;

          const PrimaryCheckbox({
            super.key,
            required this.value,
            this.onChanged,
            this.label,
          });

          @override
          Widget build(BuildContext context) {
            return InkWell(
              onTap: onChanged == null ? null : () => onChanged!(!value),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: AppSizes.iconMd,
                      height: AppSizes.iconMd,
                      child: Checkbox(
                        value: value,
                        onChanged: onChanged,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSm / 2)),
                      ),
                    ),
                    if (label != null) ...[
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        label!,
                        style: const TextStyle(fontSize: AppSizes.fontSm, color: AppColors.textPrimary),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
        }
    '''),
    "primary_input_field.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Standard labeled text field with consistent border, padding, and
        /// typography — the base input used across every form in the app.
        class PrimaryInputField extends StatelessWidget {
          final String? label;
          final String? hint;
          final TextEditingController? controller;
          final String? Function(String?)? validator;
          final bool obscureText;
          final TextInputType? keyboardType;
          final Widget? prefixIcon;
          final Widget? suffixIcon;
          final int maxLines;
          final bool enabled;
          final ValueChanged<String>? onChanged;

          const PrimaryInputField({
            super.key,
            this.label,
            this.hint,
            this.controller,
            this.validator,
            this.obscureText = false,
            this.keyboardType,
            this.prefixIcon,
            this.suffixIcon,
            this.maxLines = 1,
            this.enabled = true,
            this.onChanged,
          });

          @override
          Widget build(BuildContext context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null) ...[
                  Text(
                    label!,
                    style: const TextStyle(
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                ],
                TextFormField(
                  controller: controller,
                  validator: validator,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  enabled: enabled,
                  onChanged: onChanged,
                  style: const TextStyle(fontSize: AppSizes.fontMd, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: AppSizes.fontMd),
                    prefixIcon: prefixIcon,
                    suffixIcon: suffixIcon,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ],
            );
          }
        }
    '''),
    "primary_switch.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class PrimarySwitch extends StatelessWidget {
          final bool value;
          final ValueChanged<bool>? onChanged;
          final String? label;
          final String? subtitle;

          const PrimarySwitch({
            super.key,
            required this.value,
            this.onChanged,
            this.label,
            this.subtitle,
          });

          @override
          Widget build(BuildContext context) {
            return SwitchListTile(
              value: value,
              onChanged: onChanged,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
              activeThumbColor: AppColors.primary,
              title: label == null ? null : Text(label!),
              subtitle: subtitle == null ? null : Text(subtitle!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
            );
          }
        }
    '''),
    "radio_option.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class RadioOption<T> extends StatelessWidget {
          final T value;
          final T? groupValue;
          final ValueChanged<T?>? onChanged;
          final String title;
          final String? subtitle;

          const RadioOption({
            super.key,
            required this.value,
            required this.groupValue,
            required this.onChanged,
            required this.title,
            this.subtitle,
          });

          @override
          Widget build(BuildContext context) {
            return RadioListTile<T>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
              title: Text(title),
              subtitle: subtitle == null ? null : Text(subtitle!),
            );
          }
        }
    '''),
    "search_field.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';
        import 'package:__PACKAGE_NAME__/core/widgets/common/icon_button.dart';

        class SearchField extends StatelessWidget {
          final String hintText;
          final ValueChanged<String>? onChanged;
          final ValueChanged<String>? onSubmitted;
          final TextEditingController? controller;
          final FocusNode? focusNode;
          final VoidCallback? onClear;
          final bool autofocus;
          final bool enabled;

          const SearchField({
            super.key,
            this.hintText = 'Search',
            this.onChanged,
            this.onSubmitted,
            this.controller,
            this.focusNode,
            this.onClear,
            this.autofocus = false,
            this.enabled = true,
          });

          @override
          Widget build(BuildContext context) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search, size: AppSizes.iconMd),
                suffixIcon: onClear == null
                    ? null
                    : AppIconButton(
                        icon: Icons.clear,
                        tooltip: 'Clear search',
                        onPressed: onClear,
                        iconSize: AppSizes.iconSm,
                      ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            );
          }
        }
    '''),
    "secondary_button.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Outlined secondary button — social sign-in options, "Cancel", or any
        /// lower-priority action next to a PrimaryButton.
        class SecondaryButton extends StatelessWidget {
          final String label;
          final VoidCallback? onPressed;
          final IconData? icon;
          final double? width;

          const SecondaryButton({
            super.key,
            required this.label,
            this.onPressed,
            this.icon,
            this.width,
          });

          @override
          Widget build(BuildContext context) {
            return SizedBox(
              width: width ?? double.infinity,
              height: AppSizes.buttonHeight,
              child: OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                  textStyle: const TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[Icon(icon, size: AppSizes.iconSm), const SizedBox(width: AppSizes.sm)],
                    Text(label),
                  ],
                ),
              ),
            );
          }
        }
    '''),
    "section_header.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class SectionHeader extends StatelessWidget {
          final String title;
          final String? subtitle;
          final String? actionLabel;
          final VoidCallback? onAction;
          final Widget? trailing;

          const SectionHeader({
            super.key,
            required this.title,
            this.subtitle,
            this.actionLabel,
            this.onAction,
            this.trailing,
          });

          @override
          Widget build(BuildContext context) {
            final action = trailing ?? (actionLabel == null ? null : TextButton(onPressed: onAction, child: Text(actionLabel!)));
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSizes.xs),
                        Text(subtitle!, style: const TextStyle(fontSize: AppSizes.fontSm, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
                ?action,
              ],
            );
          }
        }
    '''),
    "settings_group.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Uppercase section label + a bordered, rounded container of
        /// [SettingsTile]s separated by thin dividers. Used to group related
        /// settings rows (Account, Preferences, Security & Support...).
        class SettingsGroup extends StatelessWidget {
          final String label;
          final List<Widget> children;

          const SettingsGroup({super.key, required this.label, required this.children});

          @override
          Widget build(BuildContext context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppSizes.fontXs,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (int i = 0; i < children.length; i++) ...[
                        children[i],
                        if (i != children.length - 1) const Divider(height: 1, color: AppColors.border),
                      ],
                    ],
                  ),
                ),
              ],
            );
          }
        }
    '''),
    "settings_tile.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        enum SettingsTileTrailing { chevron, externalLink, none }

        /// Single settings row covering every variant seen so far: plain
        /// nav row (chevron), external link row, value + chevron row, and a
        /// switch row — chosen by which optional params are supplied. Meant
        /// to be placed inside a [SettingsGroup].
        ///
        /// - Pass [switchValue] for a toggle row (ignores [trailing]/[value]).
        /// - Else pass [value] for a "title ... value >" row.
        /// - Else it's a plain nav row using [trailing] (chevron/link/none).
        /// - [icon]/[subtitle] are optional extras for richer rows (as used
        ///   on the Profile screen); omit both for a compact row (Settings screen).
        class SettingsTile extends StatelessWidget {
          final IconData? icon;
          final String title;
          final String? subtitle;
          final String? value;
          final bool? switchValue;
          final ValueChanged<bool>? onSwitchChanged;
          final SettingsTileTrailing trailing;
          final VoidCallback? onTap;

          const SettingsTile({
            super.key,
            required this.title,
            this.icon,
            this.subtitle,
            this.value,
            this.switchValue,
            this.onSwitchChanged,
            this.trailing = SettingsTileTrailing.chevron,
            this.onTap,
          });

          Widget? _buildTrailing() {
            if (switchValue != null) {
              return Switch(
                value: switchValue!,
                onChanged: onSwitchChanged,
                activeThumbColor: AppColors.textWhite,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: AppColors.textWhite,
                inactiveTrackColor: AppColors.border,
              );
            }

            final indicator = switch (trailing) {
              SettingsTileTrailing.chevron => const Icon(Icons.chevron_right_rounded, size: AppSizes.iconSm, color: AppColors.textHint),
              SettingsTileTrailing.externalLink => const Icon(Icons.open_in_new_rounded, size: AppSizes.iconSm - AppSizes.xs / 2, color: AppColors.textHint),
              SettingsTileTrailing.none => null,
            };

            if (value == null && indicator == null) return null;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value != null) ...[
                  Text(value!, style: const TextStyle(fontSize: AppSizes.fontMd, color: AppColors.textSecondary)),
                  if (indicator != null) const SizedBox(width: AppSizes.xs + AppSizes.xs / 2),
                ],
                ?indicator,
              ],
            );
          }

          @override
          Widget build(BuildContext context) {
            final trailingWidget = _buildTrailing();

            return InkWell(
              onTap: switchValue != null ? null : onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: icon != null ? AppSizes.sm + AppSizes.xs : AppSizes.sm),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: AppSizes.iconMd - AppSizes.xs / 2, color: AppColors.textSecondary),
                      const SizedBox(width: AppSizes.sm + AppSizes.xs),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: AppSizes.xs / 2),
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: AppSizes.fontSm, color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ?trailingWidget,
                  ],
                ),
              ),
            );
          }
        }
    '''),
    "square_icon_tile.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Small rounded-square icon tile with a tinted background. Reused
        /// for stat card icons, quick action tiles, and activity list
        /// leading icons wherever a compact "icon in a soft box" look is
        /// needed.
        class SquareIconTile extends StatelessWidget {
          final IconData icon;
          final Color color;
          final double iconSize;
          final double padding;
          final double radius;
          final bool tinted;

          const SquareIconTile({
            super.key,
            required this.icon,
            this.color = AppColors.primary,
            this.iconSize = AppSizes.iconMd,
            this.padding = AppSizes.sm,
            this.radius = AppSizes.radiusSm,
            this.tinted = true,
          });

          @override
          Widget build(BuildContext context) {
            return Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: tinted ? color.withValues(alpha: 0.1) : AppColors.divider,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Icon(icon, size: iconSize, color: color),
            );
          }
        }
    '''),
    "status_badge.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        enum StatusBadgeType { success, warning, error, info, neutral, primary }
        enum StatusBadgeShape { pill, square }

        class StatusBadge extends StatelessWidget {
          final String text;
          final StatusBadgeType type;
          final IconData? icon;
          final bool compact;
          final StatusBadgeShape shape;

          const StatusBadge({
            super.key,
            required this.text,
            this.type = StatusBadgeType.neutral,
            this.icon,
            this.compact = false,
            this.shape = StatusBadgeShape.pill,
          });

          Color get _color {
            switch (type) {
              case StatusBadgeType.success:
                return AppColors.success;
              case StatusBadgeType.warning:
                return AppColors.warning;
              case StatusBadgeType.error:
                return AppColors.error;
              case StatusBadgeType.info:
                return AppColors.info;
              case StatusBadgeType.primary:
                return AppColors.primary;
              case StatusBadgeType.neutral:
                return AppColors.textSecondary;
            }
          }

          @override
          Widget build(BuildContext context) {
            final color = _color;
            final isSquare = shape == StatusBadgeShape.square;

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? AppSizes.sm : AppSizes.md,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isSquare ? 0.1 : 0.12),
                borderRadius: BorderRadius.circular(isSquare ? AppSizes.radiusSm - 2 : AppSizes.radiusFull),
                border: isSquare ? null : Border.all(color: color.withValues(alpha: 0.24)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppSizes.iconSm, color: color),
                    const SizedBox(width: AppSizes.xs),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: color,
                      fontSize: isSquare ? AppSizes.fontXs : AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      letterSpacing: isSquare ? 0.3 : null,
                    ),
                  ),
                ],
              ),
            );
          }
        }
    '''),
    "summary_card.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';
        import 'custom_card.dart';
        import 'status_badge.dart';
        import 'square_icon_tile.dart';

        /// General-purpose stat card. Three layouts, chosen by which params
        /// are supplied:
        /// 1. [icon] + [trendLabel]: icon/trend header row, label, value (Home dashboard).
        /// 2. [trendLabel] only (no [icon]): label+trend row, then value
        ///    (+ optional [trailing] widget, e.g. a sparkline) — Analytics screen.
        /// 3. Neither: compact centered label/value (was `MiniStatCard`) — Profile screen.
        class SummaryCard extends StatelessWidget {
          final String label;
          final String value;
          final IconData? icon;
          final String? trendLabel;
          final bool isPositiveTrend;
          final Widget? trailing;

          const SummaryCard({
            super.key,
            required this.label,
            required this.value,
            this.icon,
            this.trendLabel,
            this.isPositiveTrend = true,
            this.trailing,
          });

          @override
          Widget build(BuildContext context) {
            final hasIcon = icon != null;
            final hasTrend = trendLabel != null;
            final isCompact = !hasIcon && !hasTrend;

            final trendBadge = hasTrend
                ? StatusBadge(
                    text: trendLabel!,
                    type: isPositiveTrend ? StatusBadgeType.success : StatusBadgeType.error,
                    compact: true,
                  )
                : null;

            return CustomCard(
              padding: EdgeInsets.symmetric(
                vertical: AppSizes.md,
                horizontal: isCompact ? AppSizes.sm : AppSizes.md,
              ),
              child: Column(
                crossAxisAlignment: isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  if (hasIcon) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SquareIconTile(icon: icon!, color: AppColors.primary),
                        ?trendBadge,
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(label, style: const TextStyle(fontSize: AppSizes.fontSm, color: AppColors.textSecondary)),
                    Text(value, style: const TextStyle(fontSize: AppSizes.fontXxl, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ] else if (hasTrend) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label, style: const TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        trendBadge!,
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm + AppSizes.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(value, style: const TextStyle(fontSize: AppSizes.fontXxl, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        ?trailing,
                      ],
                    ),
                  ] else ...[
                    Text(
                      label,
                      style: const TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textSecondary, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(value, style: const TextStyle(fontSize: AppSizes.fontXxl, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ],
              ),
            );
          }
        }
    '''),
    "text_button.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class AppTextButton extends StatelessWidget {
          final String label;
          final VoidCallback? onPressed;
          final IconData? icon;
          final bool compact;

          const AppTextButton({
            super.key,
            required this.label,
            this.onPressed,
            this.icon,
            this.compact = false,
          });

          @override
          Widget build(BuildContext context) {
            final child = icon == null
                ? Text(label)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: AppSizes.iconSm),
                      const SizedBox(width: AppSizes.xs),
                      Text(label),
                    ],
                  );
            return TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: compact
                    ? const EdgeInsets.symmetric(horizontal: AppSizes.sm)
                    : const EdgeInsets.symmetric(horizontal: AppSizes.md),
              ),
              child: child,
            );
          }
        }
    '''),
}

UTILITY_WIDGETS: dict[str, str] = {
    "custom_alert_dialog.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class CustomAlertDialog {
          CustomAlertDialog._();

          static Future<bool?> confirm(
            BuildContext context, {
            required String title,
            required String message,
            String confirmText = 'Confirm',
            String cancelText = 'Cancel',
            bool destructive = false,
          }) {
            return showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: Text(title),
                content: Text(message),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelText)),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: destructive ? AppColors.error : AppColors.primary),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(confirmText),
                  ),
                ],
              ),
            );
          }
        }
    '''),
    "custom_bottom_sheet.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class CustomBottomSheet {
          CustomBottomSheet._();

          static Future<T?> show<T>(
            BuildContext context, {
            required Widget child,
            bool isScrollControlled = true,
            bool useSafeArea = true,
          }) {
            return showModalBottomSheet<T>(
              context: context,
              isScrollControlled: isScrollControlled,
              useSafeArea: useSafeArea,
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
              ),
              builder: (_) => Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: child,
              ),
            );
          }
        }
    '''),
    "custom_dialog.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class CustomDialog {
          CustomDialog._();

          static Future<T?> show<T>(
            BuildContext context, {
            required String title,
            required Widget child,
            List<Widget>? actions,
            bool barrierDismissible = true,
          }) {
            return showDialog<T>(
              context: context,
              barrierDismissible: barrierDismissible,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: Text(title),
                content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppSizes.xxl * 8),
                  child: child,
                ),
                actions: actions,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
              ),
            );
          }
        }
    '''),
    "custom_loader.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class CustomLoader extends StatelessWidget {
          final double? size;
          final Color? color;
          final String? label;
          final bool overlay;

          const CustomLoader({super.key, this.size, this.color, this.label, this.overlay = false});

          @override
          Widget build(BuildContext context) {
            final loader = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: size ?? AppSizes.iconLg,
                  height: size ?? AppSizes.iconLg,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSizes.xs / 2,
                    color: color ?? AppColors.primary,
                  ),
                ),
                if (label != null) ...[
                  const SizedBox(height: AppSizes.md),
                  Text(label!, style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm)),
                ],
              ],
            );
            return overlay
                ? ColoredBox(color: AppColors.background.withValues(alpha: 0.72), child: Center(child: loader))
                : Center(child: loader);
          }
        }
    '''),
    "custom_network_image.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:cached_network_image/cached_network_image.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';
        import 'custom_shimmer.dart';

        class CustomNetworkImage extends StatelessWidget {
          final String url;
          final double? width;
          final double? height;
          final BoxFit fit;
          final BorderRadius? borderRadius;
          final Widget? placeholder;
          final Widget? errorWidget;
          final Color? backgroundColor;

          const CustomNetworkImage({
            super.key,
            required this.url,
            this.width,
            this.height,
            this.fit = BoxFit.cover,
            this.borderRadius,
            this.placeholder,
            this.errorWidget,
            this.backgroundColor,
          });

          @override
          Widget build(BuildContext context) {
            final radius = borderRadius ?? BorderRadius.circular(AppSizes.radiusMd);
            return ClipRRect(
              borderRadius: radius,
              child: ColoredBox(
                color: backgroundColor ?? AppColors.shimmerBase,
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: width,
                  height: height,
                  fit: fit,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (_, _) =>
                      placeholder ?? CustomShimmer(height: height ?? AppSizes.xxl, width: width),
                  errorWidget: (_, _, _) => errorWidget ??
                      const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textHint)),
                ),
              ),
            );
          }
        }
    '''),
    "custom_refresh_wrapper.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';

        class CustomRefreshWrapper extends StatelessWidget {
          final Widget child;
          final Future<void> Function() onRefresh;
          final ScrollPhysics? physics;

          const CustomRefreshWrapper({
            super.key,
            required this.child,
            required this.onRefresh,
            this.physics,
          });

          @override
          Widget build(BuildContext context) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: child,
            );
          }
        }
    '''),
    "custom_shimmer.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class CustomShimmer extends StatefulWidget {
          final double height;
          final double? width;
          final BorderRadius? borderRadius;

          const CustomShimmer({
            super.key,
            this.height = AppSizes.xxl,
            this.width,
            this.borderRadius,
          });

          @override
          State<CustomShimmer> createState() => _CustomShimmerState();
        }

        class _CustomShimmerState extends State<CustomShimmer> with SingleTickerProviderStateMixin {
          late final AnimationController _controller;

          @override
          void initState() {
            super.initState();
            _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
          }

          @override
          void dispose() {
            _controller.dispose();
            super.dispose();
          }

          @override
          Widget build(BuildContext context) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + (_controller.value * 2), 0),
                    end: Alignment(1 + (_controller.value * 2), 0),
                    colors: const [AppColors.shimmerBase, AppColors.shimmerHighlight, AppColors.shimmerBase],
                  ),
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: SizedBox(height: widget.height, width: widget.width ?? double.infinity),
              ),
            );
          }
        }
    '''),
    "custom_snackbar.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Static helpers for showing consistent snackbars across the app.
        class CustomSnackbar {
          CustomSnackbar._();

          static void show(BuildContext context, String message, {bool error = false}) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message, style: const TextStyle(color: AppColors.textWhite)),
                backgroundColor: error ? AppColors.error : AppColors.textPrimary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                margin: const EdgeInsets.all(AppSizes.md),
              ),
            );
          }
        }
    '''),
    "donut_chart.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class DonutSegment {
          final double value;
          final Color color;

          const DonutSegment({required this.value, required this.color});
        }

        /// Ring/donut chart with a centered label + value. Generic over any
        /// list of [DonutSegment]s — used for category or status breakdowns.
        class DonutChart extends StatelessWidget {
          final List<DonutSegment> segments;
          final String centerValue;
          final String centerLabel;
          final double size;
          final double strokeWidth;

          const DonutChart({
            super.key,
            required this.segments,
            required this.centerValue,
            required this.centerLabel,
            this.size = AppSizes.xxl * 2 + AppSizes.xl,
            this.strokeWidth = AppSizes.lg - AppSizes.xs / 2,
          });

          @override
          Widget build(BuildContext context) {
            return SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(size, size),
                    painter: _DonutPainter(segments: segments, strokeWidth: strokeWidth),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        centerValue,
                        style: const TextStyle(fontSize: AppSizes.fontXxl, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      Text(
                        centerLabel,
                        style: const TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        }

        class _DonutPainter extends CustomPainter {
          final List<DonutSegment> segments;
          final double strokeWidth;

          _DonutPainter({required this.segments, required this.strokeWidth});

          @override
          void paint(Canvas canvas, Size size) {
            final total = segments.fold<double>(0, (sum, s) => sum + s.value);
            if (total <= 0) return;

            final rect = Offset.zero & size;
            var startAngle = -3.14159265 / 2;

            for (final segment in segments) {
              final sweep = (segment.value / total) * 2 * 3.14159265;
              canvas.drawArc(
                rect.deflate(strokeWidth / 2),
                startAngle,
                sweep,
                false,
                Paint()
                  ..color = segment.color
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..strokeCap = StrokeCap.butt,
              );
              startAngle += sweep;
            }
          }

          @override
          bool shouldRepaint(covariant _DonutPainter oldDelegate) => oldDelegate.segments != segments;
        }
    '''),
    "empty_state.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class EmptyState extends StatelessWidget {
          final String title;
          final String? message;
          final String? actionLabel;
          final VoidCallback? onAction;
          final IconData icon;

          const EmptyState({
            super.key,
            required this.title,
            this.message,
            this.actionLabel,
            this.onAction,
            this.icon = Icons.inbox_outlined,
          });

          @override
          Widget build(BuildContext context) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: AppSizes.iconLg * 2, color: AppColors.textHint),
                    const SizedBox(height: AppSizes.lg),
                    Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: AppSizes.fontXl, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    if (message != null) ...[
                      const SizedBox(height: AppSizes.sm),
                      Text(message!, textAlign: TextAlign.center, style: const TextStyle(fontSize: AppSizes.fontMd, color: AppColors.textSecondary)),
                    ],
                    if (onAction != null) ...[
                      const SizedBox(height: AppSizes.lg),
                      FilledButton(onPressed: onAction, child: Text(actionLabel ?? 'Try again')),
                    ],
                  ],
                ),
              ),
            );
          }
        }
    '''),
    "error_state.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class ErrorState extends StatelessWidget {
          final String message;
          final VoidCallback? onRetry;
          final String retryLabel;

          const ErrorState({
            super.key,
            required this.message,
            this.onRetry,
            this.retryLabel = 'Retry',
          });

          @override
          Widget build(BuildContext context) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: AppSizes.iconLg * 2, color: AppColors.error),
                    const SizedBox(height: AppSizes.md),
                    Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: AppSizes.fontMd, color: AppColors.textSecondary)),
                    if (onRetry != null) ...[
                      const SizedBox(height: AppSizes.lg),
                      OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
                    ],
                  ],
                ),
              ),
            );
          }
        }
    '''),
    "info_tip_banner.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Small inline hint row — an info icon + gray helper text. Used for
        /// one-off tips shown above list content (e.g. "Swipe left to
        /// archive").
        class InfoTipBanner extends StatelessWidget {
          final String text;

          const InfoTipBanner({super.key, required this.text});

          @override
          Widget build(BuildContext context) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: AppSizes.fontMd, color: AppColors.textSecondary),
                const SizedBox(width: AppSizes.xs + AppSizes.xs / 2),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textSecondary),
                  ),
                ),
              ],
            );
          }
        }
    '''),
    "legend_dot_item.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Colored dot + label, with an optional trailing value on the same
        /// row. Used for chart legends (top of a line chart) and breakdown
        /// lists (donut chart key).
        class LegendDotItem extends StatelessWidget {
          final Color color;
          final String label;
          final String? value;
          final bool expanded;

          const LegendDotItem({
            super.key,
            required this.color,
            required this.label,
            this.value,
            this.expanded = false,
          });

          @override
          Widget build(BuildContext context) {
            return Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppSizes.xs + AppSizes.xs / 2,
                      height: AppSizes.xs + AppSizes.xs / 2,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                    ),
                    const SizedBox(width: AppSizes.xs + AppSizes.xs / 2),
                    Text(
                      label,
                      style: const TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (value != null)
                  Text(
                    value!,
                    style: const TextStyle(fontSize: AppSizes.fontXs, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
              ],
            );
          }
        }
    '''),
    "mini_sparkline.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Tiny single-series line sparkline, no axes/labels — used inline
        /// inside stat cards to show a trend shape at a glance.
        class MiniSparkline extends StatelessWidget {
          final List<double> values;
          final Color color;
          final double width;
          final double height;

          const MiniSparkline({
            super.key,
            required this.values,
            required this.color,
            this.width = AppSizes.xxl + AppSizes.md,
            this.height = AppSizes.lg,
          });

          @override
          Widget build(BuildContext context) {
            return SizedBox(
              width: width,
              height: height,
              child: CustomPaint(painter: _SparklinePainter(values: values, color: color)),
            );
          }
        }

        class _SparklinePainter extends CustomPainter {
          final List<double> values;
          final Color color;

          _SparklinePainter({required this.values, required this.color});

          @override
          void paint(Canvas canvas, Size size) {
            if (values.length < 2) return;
            final minVal = values.reduce((a, b) => a < b ? a : b);
            final maxVal = values.reduce((a, b) => a > b ? a : b);
            final range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

            final path = Path();
            for (var i = 0; i < values.length; i++) {
              final x = size.width * i / (values.length - 1);
              final y = size.height - ((values[i] - minVal) / range) * size.height;
              if (i == 0) {
                path.moveTo(x, y);
              } else {
                path.lineTo(x, y);
              }
            }

            canvas.drawPath(
              path,
              Paint()
                ..color = color
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5
                ..strokeCap = StrokeCap.round,
            );
          }

          @override
          bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
              oldDelegate.values != values || oldDelegate.color != color;
        }
    '''),
    "multi_line_chart.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class ChartSeries {
          final String label;
          final Color color;
          final List<double> values;

          const ChartSeries({required this.label, required this.color, required this.values});
        }

        /// Multi-series line chart with horizontal gridlines, y-axis value
        /// labels, and x-axis category labels. Generic — used for any
        /// time-series comparison (revenue vs expenses, etc.).
        class MultiLineChart extends StatelessWidget {
          final List<ChartSeries> series;
          final List<String> yAxisLabels;
          final List<String> xAxisLabels;
          final double height;

          const MultiLineChart({
            super.key,
            required this.series,
            required this.yAxisLabels,
            required this.xAxisLabels,
            this.height = AppSizes.xxl * 4 + AppSizes.md,
          });

          @override
          Widget build(BuildContext context) {
            return SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: AppSizes.xxl - AppSizes.xs,
                    height: height - AppSizes.lg,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final label in yAxisLabels)
                          Text(label, style: const TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textHint)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _MultiLinePainter(series: series, gridLines: yAxisLabels.length),
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final label in xAxisLabels)
                              Text(label, style: const TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textHint)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        }

        class _MultiLinePainter extends CustomPainter {
          final List<ChartSeries> series;
          final int gridLines;

          _MultiLinePainter({required this.series, required this.gridLines});

          @override
          void paint(Canvas canvas, Size size) {
            final gridPaint = Paint()
              ..color = AppColors.border
              ..strokeWidth = 1;

            for (var i = 0; i < gridLines; i++) {
              final y = size.height * i / (gridLines - 1);
              canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
            }

            final allValues = series.expand((s) => s.values).toList();
            if (allValues.isEmpty) return;
            final minVal = allValues.reduce((a, b) => a < b ? a : b);
            final maxVal = allValues.reduce((a, b) => a > b ? a : b);
            final range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

            for (final s in series) {
              if (s.values.length < 2) continue;
              final path = Path();
              for (var i = 0; i < s.values.length; i++) {
                final x = size.width * i / (s.values.length - 1);
                final y = size.height - ((s.values[i] - minVal) / range) * size.height;
                if (i == 0) {
                  path.moveTo(x, y);
                } else {
                  path.lineTo(x, y);
                }
              }
              canvas.drawPath(
                path,
                Paint()
                  ..color = s.color
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..strokeCap = StrokeCap.round
                  ..strokeJoin = StrokeJoin.round,
              );
            }
          }

          @override
          bool shouldRepaint(covariant _MultiLinePainter oldDelegate) => oldDelegate.series != series;
        }
    '''),
    "pagination_controls.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        class PaginationControls extends StatelessWidget {
          final int currentPage;
          final int totalPages;
          final ValueChanged<int> onPageChanged;

          const PaginationControls({
            super.key,
            required this.currentPage,
            required this.totalPages,
            required this.onPageChanged,
          });

          @override
          Widget build(BuildContext context) {
            final canPrevious = currentPage > 1;
            final canNext = currentPage < totalPages;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: canPrevious ? () => onPageChanged(currentPage - 1) : null,
                  icon: const Icon(Icons.chevron_left),
                  color: AppColors.primary,
                  iconSize: AppSizes.iconMd,
                ),
                Text('$currentPage / $totalPages', style: const TextStyle(fontSize: AppSizes.fontMd, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                IconButton(
                  onPressed: canNext ? () => onPageChanged(currentPage + 1) : null,
                  icon: const Icon(Icons.chevron_right),
                  color: AppColors.primary,
                  iconSize: AppSizes.iconMd,
                ),
              ],
            );
          }
        }
    '''),
    "password_requirement_item.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Single checklist row used under password fields — a small round
        /// check icon (tinted green when [met], gray otherwise) + a label.
        /// Reusable anywhere a password-strength checklist is needed
        /// (reset password, change password, register).
        class PasswordRequirementItem extends StatelessWidget {
          final String label;
          final bool met;

          const PasswordRequirementItem({
            super.key,
            required this.label,
            this.met = false,
          });

          @override
          Widget build(BuildContext context) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppSizes.iconSm + AppSizes.xs,
                    height: AppSizes.iconSm + AppSizes.xs,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: met ? AppColors.success.withValues(alpha: 0.12) : AppColors.divider,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.check_rounded,
                      size: AppSizes.iconSm - AppSizes.xs / 2,
                      color: met ? AppColors.success : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w500,
                      color: met ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
        }
    '''),
    "timeline_indicator.dart": dart(r'''
        import 'package:flutter/material.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_colors.dart';
        import 'package:__PACKAGE_NAME__/core/constants/app_sizes.dart';

        /// Vertical timeline marker — a soft-tinted circle with a solid dot,
        /// plus a connecting line below it. Used to the left of each row in
        /// timeline-style feeds (activity logs, order tracking).
        class TimelineIndicator extends StatelessWidget {
          final Color color;
          final bool showLine;
          final double lineHeight;

          const TimelineIndicator({
            super.key,
            this.color = AppColors.textSecondary,
            this.showLine = true,
            this.lineHeight = AppSizes.xxl * 2,
          });

          @override
          Widget build(BuildContext context) {
            return Column(
              children: [
                Container(
                  width: AppSizes.lg,
                  height: AppSizes.lg,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.12),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: AppSizes.xs + AppSizes.xs / 1.5,
                    height: AppSizes.xs + AppSizes.xs / 1.5,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                ),
                if (showLine)
                  Container(
                    width: 2,
                    height: lineHeight,
                    color: AppColors.border,
                  ),
              ],
            );
          }
        }
    '''),
}


def package_name_from_pubspec(pubspec: Path) -> str:
    if not pubspec.exists():
        raise FileNotFoundError(f"pubspec.yaml not found: {pubspec}")
    match = re.search(r"^name:\s*([a-zA-Z0-9_]+)\s*$", pubspec.read_text(encoding="utf-8"), re.MULTILINE)
    if not match:
        raise ValueError("Could not find a valid package name in pubspec.yaml")
    return match.group(1)


def validate_constants(root: Path) -> None:
    colors = root / "lib" / "core" / "constants" / "app_colors.dart"
    sizes = root / "lib" / "core" / "constants" / "app_sizes.dart"
    strings = root / "lib" / "core" / "constants" / "app_strings.dart"
    missing = [str(path) for path in (colors, sizes) if not path.exists()]
    if missing:
        raise FileNotFoundError("Required constant files are missing:\n" + "\n".join(missing))

    color_text = colors.read_text(encoding="utf-8")
    size_text = sizes.read_text(encoding="utf-8")
    missing_colors = [name for name in APP_COLORS if f"static const Color {name}" not in color_text]
    missing_sizes = [name for name in APP_SIZES if f"static const double {name}" not in size_text]

    # ActivityFilterTabs (core/widgets/common) depends on AppStrings — unlike every
    # other core widget, which only depends on AppColors/AppSizes. Warn rather than
    # hard-fail, since app_strings.dart is owned by the template-structure script.
    missing_strings: list[str] = []
    required_strings = ["filterToday", "filterThisWeek", "filterThisMonth"]
    if strings.exists():
        strings_text = strings.read_text(encoding="utf-8")
        missing_strings = [name for name in required_strings if f"static const String {name}" not in strings_text]
    else:
        missing_strings = required_strings

    if missing_colors or missing_sizes:
        message = ["The existing constants do not expose all names required by the widget library."]
        if missing_colors:
            message.append("Missing colors: " + ", ".join(missing_colors))
        if missing_sizes:
            message.append("Missing sizes: " + ", ".join(missing_sizes))
        raise ValueError("\n".join(message))

    if missing_strings:
        print(
            "Warning: app_strings.dart is missing constants used by ActivityFilterTabs: "
            + ", ".join(missing_strings)
            + ". The widget will be generated but will not compile until you add them.",
            file=sys.stderr,
        )


def render(content: str, package_name: str) -> str:
    return content.replace("__PACKAGE_NAME__", package_name)


def write_widget(path: Path, content: str, overwrite: bool, dry_run: bool) -> str:
    if path.exists() and not overwrite:
        return "skipped"
    if not dry_run:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
    return "written"


def write_barrel_file(root: Path, package_name: str, overwrite: bool, dry_run: bool) -> str:
    exports = [
        *[f"export 'common/{name}';" for name in sorted(COMMON_WIDGETS)],
        *[f"export 'utility/{name}';" for name in sorted(UTILITY_WIDGETS)],
    ]
    content = "// Generated core widget exports.\n" + "\n".join(exports) + "\n"
    path = root / "lib" / "core" / "widgets" / "core_widgets.dart"
    return write_widget(path, content, overwrite, dry_run)


def run_dart_format(root: Path) -> None:
    result = subprocess.run(["dart", "format", "lib/core/widgets"], cwd=root, text=True)
    if result.returncode != 0:
        raise RuntimeError("dart format failed")


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate the complete modern core widget library.")
    parser.add_argument("--root", default=".", help="Flutter project root")
    parser.add_argument("--overwrite", "-o", action="store_true", help="Overwrite existing widget files")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be generated without writing")
    parser.add_argument("--format", action="store_true", help="Run dart format after generation")
    parser.add_argument("--skip-validation", action="store_true", help="Skip pubspec and constants validation")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    try:
        package_name = package_name_from_pubspec(root / "pubspec.yaml")
        if not args.skip_validation:
            validate_constants(root)
    except (FileNotFoundError, ValueError) as error:
        print(f"Validation failed: {error}", file=sys.stderr)
        return 1

    destinations = [
        (root / "lib" / "core" / "widgets" / "common", COMMON_WIDGETS),
        (root / "lib" / "core" / "widgets" / "utility", UTILITY_WIDGETS),
    ]
    counts = {"written": 0, "skipped": 0}
    for directory, templates in destinations:
        for filename, content in templates.items():
            result = write_widget(directory / filename, render(content, package_name), args.overwrite, args.dry_run)
            counts[result] += 1
            print(f"{result:>7}: {directory / filename}")

    if args.format and not args.dry_run:
        try:
            run_dart_format(root)
        except (FileNotFoundError, RuntimeError) as error:
            print(f"Formatting failed: {error}", file=sys.stderr)
            return 1

    barrel_result = write_barrel_file(root, package_name, args.overwrite, args.dry_run)
    counts[barrel_result] += 1
    print(f"{barrel_result:>7}: {root / 'lib' / 'core' / 'widgets' / 'core_widgets.dart'}")

    total = len(COMMON_WIDGETS) + len(UTILITY_WIDGETS)
    print(f"\nCore widgets processed: {total} plus barrel export")
    print(f"Written: {counts['written']} | Skipped: {counts['skipped']}")
    print("All generated widgets use AppColors and AppSizes for custom colors and dimensions.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())