import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/search_field.dart';
import '../../../../core/widgets/common/icon_button.dart';

/// Search input + a filter/sort icon button beside it.
class ProductSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const ProductSearchBar({super.key, this.onChanged, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchField(
            hintText: AppStrings.searchProductsHint,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(color: context.appColors.border),
          ),
          child: AppIconButton(
            icon: Icons.tune_rounded,
            onPressed: onFilterTap,
          ),
        ),
      ],
    );
  }
}