import 'package:flutter/material.dart';
import '../../../../core/widgets/common/contact_method_card.dart';

/// Single contact-channel card in the Help & Support screen. Thin
/// wrapper over [ContactMethodCard].
class ContactSupportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback? onTap;

  const ContactSupportTile({
    super.key,
    required this.icon,
    required this.title,
    required this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ContactMethodCard(
      icon: icon,
      title: title,
      actionLabel: actionLabel,
      onTap: onTap,
    );
  }
}