import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../routes/route_names.dart';
import '../widgets/not_found_content.dart';


class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: const NotFoundMobileView(),
        tablet: const NotFoundTabView(),
      ),
    );
  }
}




class NotFoundMobileView extends StatelessWidget {
  const NotFoundMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.xxl),
      child: NotFoundContent(
        onBackToHome: () => context.go(RouteNames.home),
      ),
    );
  }
}



/// Same content as [NotFoundMobileView], centered in a fixed-width
/// column for wider (tablet/web) viewports.
class NotFoundTabView extends StatelessWidget {
  const NotFoundTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: NotFoundContent(
            onBackToHome: () => context.go(RouteNames.home),
          ),
        ),
      ),
    );
  }
}