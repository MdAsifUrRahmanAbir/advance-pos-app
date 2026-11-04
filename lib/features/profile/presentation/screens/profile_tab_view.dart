import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../widgets/profile_employee_card.dart';
import '../widgets/profile_hero_header.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_reports_section.dart';
import '../widgets/profile_settings_sections.dart';
import 'profile_logout_action.dart';
import 'profile_session_info.dart';

/// Same content as [ProfileMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports; the hero is a rounded card.
class ProfileTabView extends ConsumerWidget {
  const ProfileTabView({super.key});

  /// Centered content width (within the 480–960 range) — flagged.
  static const double _maxWidth = 640;

  /// How far the employee card overlaps the hero.
  static const double _cardOverlap = AppSizes.xl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = watchProfileSessionInfo(ref);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.xl,
              AppSizes.lg,
              AppSizes.xl,
              AppSizes.xl,
            ),
            child: Column(
              children: [
                ProfileHeroHeader(
                  title: info.headerTitle,
                  companyName: info.company?.name,
                  product: info.company?.product,
                  logoUrl: info.logoUrl,
                  companyCode: info.company?.compCode,
                  extraBottomSpace: _cardOverlap,
                  fullBleed: false,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Transform.translate(
                    offset: const Offset(0, -_cardOverlap),
                    child: ProfileEmployeeCard(
                      name: info.employee?.userName,
                      employeeId: info.employeeId,
                      employeeNo: info.employee?.employeeNo,
                    ),
                  ),
                ),
                ProfileReportsSection(
                  onCustomerTap: () => context.push(RouteNames.customers),
                  onStockReportTap: () => context.push(RouteNames.error),
                  onSalesReturnTap: () => context.push(RouteNames.salesReturn),
                  onExpenseTap: () => context.push(RouteNames.expense),
                  onSalesReplacementTap: () =>
                      context.push(RouteNames.salesReplacement),
                ),
                const SizedBox(height: AppSizes.xl),
                ProfileSettingsSections(
                  showAccountSection: false,
                  onPersonalInfoTap: () => context.go(RouteNames.editProfile),
                  onSettingsTap: () => context.push(RouteNames.settings),
                ),
                const SizedBox(height: AppSizes.xl),
                ProfileLogoutButton(
                  onTap: () => confirmAndLogout(context, ref),
                ),
                const SizedBox(height: AppSizes.bottomNavBarHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}