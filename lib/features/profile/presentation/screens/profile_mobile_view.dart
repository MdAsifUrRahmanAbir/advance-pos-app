import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../widgets/profile_company_section.dart';
import '../widgets/profile_employee_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_logout_button.dart';
// import '../widgets/profile_stats_row.dart';
import '../widgets/profile_reports_section.dart';
import '../widgets/profile_settings_sections.dart';
import 'profile_logout_action.dart';
import 'profile_session_info.dart';

class ProfileMobileView extends ConsumerWidget {
  const ProfileMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = watchProfileSessionInfo(ref);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, AppSizes.xl),
        child: Column(
          children: [
            ProfileHeader(name: info.employee?.userName ?? ''),
            const SizedBox(height: AppSizes.lg),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                0,
                AppSizes.md,
                0,
              ),
              child: Column(
                children: [
                  // const ProfileStatsRow(
                  //   projects: '24',
                  //   tasks: '156',
                  //   rating: '4.8',
                  // ),
                  // const SizedBox(height: AppSizes.lg),
                  ProfileEmployeeSection(
                    name: info.employee?.userName,
                    employeeId: info.employeeId,
                    employeeNo: info.employee?.employeeNo,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  ProfileCompanySection(
                    companyName: info.company?.name,
                    product: info.company?.product,
                    logoUrl: info.company?.logo,
                    companyCode: info.company?.compCode,
                    branchId: info.branchId,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  ProfileReportsSection(
                    onCustomerTap: () => context.push(RouteNames.customers),
                    onStockReportTap: () => context.push(RouteNames.error),
                    onSalesReturnTap: () =>
                        context.push(RouteNames.salesReturn),
                    onExpenseTap: () => context.push(RouteNames.expense),
                    onSalesReplacementTap: () =>
                        context.push(RouteNames.salesReplacement),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  ProfileSettingsSections(
                    showAccountSection: false,
                    onPersonalInfoTap: () =>
                        context.push(RouteNames.editProfile),
                    onSettingsTap: () => context.push(RouteNames.settings),
                    onPrivacyTap: () => context.push(RouteNames.termsPrivacy),
                    onHelpCenterTap: () => context.push(RouteNames.helpSupport),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  ProfileLogoutButton(
                    onTap: () => confirmAndLogout(context, ref),
                  ),

                  const SizedBox(height: AppSizes.bottomNavBarHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
