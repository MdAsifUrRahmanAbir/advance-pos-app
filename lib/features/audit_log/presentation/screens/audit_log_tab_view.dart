import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../widgets/audit_log_entry_card.dart';

/// Same content as [AuditLogMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class AuditLogTabView extends ConsumerWidget {
  const AuditLogTabView({super.key});

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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Column(
                  children: [
                    const AuditLogEntryCard(
                      timestamp: '2026-02-23 09:41:02',
                      transactionId: 'TXN-9021',
                      title: 'Secure cluster database backup',
                      actorName: 'Alex Carter',
                      category: 'Infrastructure',
                      status: AuditLogStatus.success,
                    ),
                    const SizedBox(height: AppSizes.md),
                    const AuditLogEntryCard(
                      timestamp: '2026-02-23 08:30:15',
                      transactionId: 'TXN-8451',
                      title: 'Unauthorized terminal access attempt',
                      actorName: 'Unknown IP',
                      category: 'Security',
                      status: AuditLogStatus.failed,
                    ),
                    const SizedBox(height: AppSizes.md),
                    const AuditLogEntryCard(
                      timestamp: '2026-02-23 07:15:00',
                      transactionId: 'TXN-8319',
                      title: 'Sync dispatched to main server',
                      actorName: 'System Agent',
                      category: 'Sync',
                      status: AuditLogStatus.pending,
                    ),
                    const SizedBox(height: AppSizes.md),
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
          ),
        ),
      ],
    );
  }
}