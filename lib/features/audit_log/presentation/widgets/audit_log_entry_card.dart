import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/avatar.dart';
import '../../../../core/widgets/common/status_badge.dart';

enum AuditLogStatus { success, failed, pending }

/// Single audit-log entry — timestamp + transaction ID header, an
/// event title, and a footer row of actor avatar/name, a category
/// tag, and a status badge. Composes entirely from existing core
/// widgets ([CustomCard], [AppAvatar], [StatusBadge]) — no new core
/// primitive needed for this card shape.
class AuditLogEntryCard extends StatelessWidget {
  final String timestamp;
  final String transactionId;
  final String title;
  final String actorName;
  final String? actorAvatarUrl;
  final String category;
  final AuditLogStatus status;
  final VoidCallback? onTap;

  const AuditLogEntryCard({
    super.key,
    required this.timestamp,
    required this.transactionId,
    required this.title,
    required this.actorName,
    required this.category,
    required this.status,
    this.actorAvatarUrl,
    this.onTap,
  });

  StatusBadgeType get _statusType {
    switch (status) {
      case AuditLogStatus.success:
        return StatusBadgeType.success;
      case AuditLogStatus.failed:
        return StatusBadgeType.error;
      case AuditLogStatus.pending:
        return StatusBadgeType.warning;
    }
  }

  String get _statusLabel {
    switch (status) {
      case AuditLogStatus.success:
        return 'Success';
      case AuditLogStatus.failed:
        return 'Failed';
      case AuditLogStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      // fullWidth: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timestamp,
                style: TextStyle(fontSize: AppSizes.fontXs, fontWeight: FontWeight.w500, color: context.appColors.textSecondary),
              ),
              Text(
                transactionId,
                style: TextStyle(fontSize: AppSizes.fontXs, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          Text(
            title,
            style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600, color: context.appColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppAvatar(imageUrl: actorAvatarUrl, label: actorName, radius: AppSizes.sm + AppSizes.xs),
                  const SizedBox(width: AppSizes.xs + AppSizes.xs / 2),
                  Text(
                    actorName,
                    style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w500, color: context.appColors.textSecondary),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge(text: category, shape: StatusBadgeShape.square, compact: true),
                  const SizedBox(width: AppSizes.xs + AppSizes.xs / 2),
                  StatusBadge(text: _statusLabel, type: _statusType, compact: true),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}