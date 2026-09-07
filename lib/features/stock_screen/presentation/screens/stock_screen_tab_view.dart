import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/utility/empty_state.dart';

/// Same content as [StockMobileView], centered in a fixed-width column
/// for wider (tablet/web) viewports.
class StockScreenTabView extends StatelessWidget {
  const StockScreenTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeaderBar(title: AppStrings.stockTitle),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: EdgeInsets.all(AppSizes.xl),
                child: EmptyState(
                  title: AppStrings.stockTitle,
                  message: AppStrings.stockEmptyMessage,
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}