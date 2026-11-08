import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Small inline hint row — an icon + gray helper text. Used for
/// one-off tips shown above list content (e.g. "Swipe left to
/// archive") or short inline notices (e.g. why an action is locked).
///
/// [icon] defaults to an info icon, so existing usages are unchanged.
class InfoTipBanner extends StatelessWidget {
  final String text;
  final IconData icon;

  const InfoTipBanner({
    super.key,
    required this.text,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: AppSizes.fontMd,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSizes.xs + AppSizes.xs / 2),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: AppSizes.fontXs,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}