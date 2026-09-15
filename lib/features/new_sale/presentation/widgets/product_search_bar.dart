import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/search_field.dart';

/// ⚠️ Assumes SearchField({hintText, onChanged, controller}).
class ProductSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ProductSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SearchField(
      hintText: AppStrings.searchProductHint,
      onChanged: onChanged,
    );
  }
}
