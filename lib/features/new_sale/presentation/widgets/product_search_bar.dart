import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/search_field.dart';

class ProductSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;

  const ProductSearchBar({super.key, this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SearchField(
      controller: controller,
      hintText: AppStrings.searchProductHint,
      onChanged: onChanged,
    );
  }
}