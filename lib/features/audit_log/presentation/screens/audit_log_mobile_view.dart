import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../widgets/audit_log_entry_card.dart';

class AuditLogMobileView extends ConsumerWidget {
  const AuditLogMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AppHeaderBar(
          title: AppStrings.auditLogTitle,
          trailingIcon: Icons.search_rounded,
        backStyle: HeaderBackStyle.chevron,
          onTrailingTap: () {
            // TODO: open audit-log search once that flow exists
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                // TODO: replace hardcoded entries with
                // auditLogControllerProvider once
                // features/audit_log/data/repositories is implemented.
                const AuditLogEntryCard(
                  timestamp: '2026-02-23 09:41:02',
                  transactionId: 'TXN-9021',
                  title: 'Secure cluster database backup',
                  actorName: 'Alex Carter',
                  category: 'Infrastructure',
                  status: AuditLogStatus.success,
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                const AuditLogEntryCard(
                  timestamp: '2026-02-23 08:30:15',
                  transactionId: 'TXN-8451',
                  title: 'Unauthorized terminal access attempt',
                  actorName: 'Unknown IP',
                  category: 'Security',
                  status: AuditLogStatus.failed,
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                const AuditLogEntryCard(
                  timestamp: '2026-02-23 07:15:00',
                  transactionId: 'TXN-8319',
                  title: 'Sync dispatched to main server',
                  actorName: 'System Agent',
                  category: 'Sync',
                  status: AuditLogStatus.pending,
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                const AuditLogEntryCard(
                  timestamp: '2026-02-23 06:05:42',
                  transactionId: 'TXN-7941',
                  title: 'New node user registration',
                  actorName: 'John Smith',
                  category: 'Auth',
                  status: AuditLogStatus.success,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}