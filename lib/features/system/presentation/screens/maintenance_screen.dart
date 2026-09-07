import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../widgets/maintenance_content.dart';
import '../../../../core/utils/responsive.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: const MaintenanceMobileView(),
        tablet: const MaintenanceTabView(),
      ),
    );
  }
}





class MaintenanceMobileView extends StatelessWidget {
  const MaintenanceMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.xxl),
      child: MaintenanceContent(
        // TODO: replace hardcoded ETA with a real value from a
        // remote-config or system-status provider once that exists.
        etaLabel: 'Back online at 2:00 PM EST',
        onNotifyMe: () {
          // TODO: register for a "maintenance complete" notification
          // once notification opt-in flow/repository exists.
        },
      ),
    );
  }
}



/// Same content as [MaintenanceMobileView], centered in a
/// fixed-width column for wider (tablet/web) viewports.
class MaintenanceTabView extends StatelessWidget {
  const MaintenanceTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: MaintenanceContent(
            etaLabel: 'Back online at 2:00 PM EST',
            onNotifyMe: () {},
          ),
        ),
      ),
    );
  }
}