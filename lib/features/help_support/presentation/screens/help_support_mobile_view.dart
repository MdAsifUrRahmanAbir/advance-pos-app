import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import '../widgets/faq_item.dart';
import '../widgets/contact_support_tile.dart';

class HelpSupportMobileView extends ConsumerWidget {
  const HelpSupportMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const AppHeaderBar(
          title: AppStrings.helpSupportTitle,
          backStyle: HeaderBackStyle.chevron,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchField(
                  hintText: AppStrings.searchFaqsHint,
                  onChanged: (query) {
                    // TODO: filter FAQ list once helpSupportControllerProvider
                    // and features/help_support/data/repositories exist.
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                 Text(
                  AppStrings.faqSectionTitle,
                  style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                // TODO: replace hardcoded FAQ list with
                // helpSupportControllerProvider once available.
                const FaqItem(
                  initiallyExpanded: true,
                  question: 'How do I reset my API credentials?',
                  answer: "You can reset your API credentials by navigating to Settings > "
                      "Connected Apps > Developer Keys and clicking on 'Regenerate API Key'. "
                      "Make sure to update your production nodes immediately after generation.",
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                const FaqItem(
                  question: 'Where can I download server diagnostic logs?',
                  answer: 'Go to Activity Logs, select a node, and tap the export icon to '
                      'download a full diagnostic bundle.',
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                const FaqItem(
                  question: 'How to setup SSO for my workspace?',
                  answer: 'Navigate to Settings > Security > Two-Factor Auth and follow the '
                      'SSO provider setup wizard.',
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                const FaqItem(
                  question: 'Can I invite external stakeholders to channels?',
                  answer: 'Yes — workspace admins can invite guest members with restricted '
                      'channel-level access from the Members panel.',
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                const FaqItem(
                  question: 'How are database cluster backups scheduled?',
                  answer: 'Backups run daily at 02:00 UTC by default; the schedule can be '
                      'changed under Settings > General.',
                ),
                const SizedBox(height: AppSizes.lg),
                SecondaryButton(
                  label: AppStrings.submitTicket,
                  onPressed: () {
                    // TODO: navigate to a ticket-submission flow once that route exists
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                 Text(
                  AppStrings.contactSupportTitle,
                  style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                ContactSupportTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: AppStrings.liveChat,
                  actionLabel: AppStrings.chatNow,
                  onTap: () {
                    // TODO: launch live chat flow
                  },
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                ContactSupportTile(
                  icon: Icons.mail_outline_rounded,
                  title: AppStrings.emailContact,
                  actionLabel: 'support@enterprise.com',
                  onTap: () {
                    // TODO: launch mail composer via url_launcher
                  },
                ),
                const SizedBox(height: AppSizes.sm + AppSizes.xs),
                ContactSupportTile(
                  icon: Icons.call_outlined,
                  title: AppStrings.callContact,
                  actionLabel: '+1-800-555-0100',
                  onTap: () {
                    // TODO: launch dialer via url_launcher
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}