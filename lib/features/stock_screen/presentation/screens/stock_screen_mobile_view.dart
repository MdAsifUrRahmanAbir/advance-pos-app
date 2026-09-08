import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/utility/empty_state.dart';

class StockScreenMobileView extends StatelessWidget {
  const StockScreenMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeaderBar(title: AppStrings.stockTitle),
        Expanded(
          child: EmptyState(
            title: AppStrings.stockTitle,
            message: AppStrings.stockEmptyMessage,
            icon: Icons.inventory_2_outlined,
          ),
        ),
        // TODO: wire to a stockControllerProvider + features/stock/data
        // (repository + model) once inventory management is built —
        // this tab is currently a placeholder so the bottom-nav section
        // is fully wired end to end.

        SizedBox(height: AppSizes.bottomNavBarHeight)

      ],
    );
  }
}