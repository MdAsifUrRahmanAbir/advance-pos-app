import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

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