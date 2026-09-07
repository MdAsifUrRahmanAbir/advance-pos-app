import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
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