import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../widgets/terms_privacy_content.dart';

class TermsMobileView extends ConsumerWidget {
  const TermsMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AppHeaderBar(
          title: AppStrings.termsPrivacyTitle,
          subtitle: AppStrings.termsLastUpdated,
          backStyle: HeaderBackStyle.circle,
          onBackTap: (){
            context.pop();
          },
        ),
        const Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.lg),
            child: TermsPrivacyContent(),
          ),
        ),
      ],
    );
  }
}