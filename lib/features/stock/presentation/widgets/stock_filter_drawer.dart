import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import '../../../../core/widgets/common/searchable_dropdown_field.dart';
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../states/stock_filter.dart';

class StockFilterDrawer extends ConsumerStatefulWidget {
  final StockFilter initialFilter;
  final ValueChanged<StockFilter> onApply;

  const StockFilterDrawer({super.key, required this.initialFilter, required this.onApply});

  @override
  ConsumerState<StockFilterDrawer> createState() => _StockFilterDrawerState();
}

class _StockFilterDrawerState extends ConsumerState<StockFilterDrawer> {
  late StockFilter _draft = widget.initialFilter;

  @override
  Widget build(BuildContext context) {
    final masterData = ref.watch(masterDataControllerProvider);
    final categories = masterData.categoryData?.categories ?? const [];
    final subcategories = _draft.categoryId == null
        ? masterData.subcategories
        : masterData.subcategories.where((s) => s.prodCatId.contains(_draft.categoryId)).toList();

    return Drawer(
      backgroundColor: context.appColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter Stock', style: TextStyle(fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700, color: context.appColors.textPrimary)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Expanded(
              child: masterData.isLoading && !masterData.isReady
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                children: [
                  SearchableDropdownField<int>(
                    label: 'Group',
                    items: masterData.groups.map((g) => (g.id, g.groupName)).toList(),
                    selectedId: _draft.groupId,
                    onChanged: (id) => setState(() => _draft = id == null ? _draft.clearing(groupId: true) : _draft.copyWith(groupId: id)),
                  ),
                  const SizedBox(height: AppSizes.md),
                  SearchableDropdownField<int>(
                    label: 'Category',
                    items: categories.map((c) => (c.id, c.categoryName)).toList(),
                    selectedId: _draft.categoryId,
                    onChanged: (id) => setState(() {
                      // Changing category invalidates a previously
                      // selected subcategory that may no longer belong to it.
                      _draft = id == null
                          ? _draft.clearing(categoryId: true, subCategoryId: true)
                          : _draft.copyWith(categoryId: id).clearing(subCategoryId: true);
                    }),
                  ),
                  const SizedBox(height: AppSizes.md),
                  SearchableDropdownField<int>(
                    label: 'Subcategory',
                    items: subcategories.map((s) => (s.id, s.subCategoryName)).toList(),
                    selectedId: _draft.subCategoryId,
                    onChanged: (id) => setState(() => _draft = id == null ? _draft.clearing(subCategoryId: true) : _draft.copyWith(subCategoryId: id)),
                  ),
                  const SizedBox(height: AppSizes.md),
                  SearchableDropdownField<int>(
                    label: 'Brand / Model',
                    items: masterData.brands.map((b) => (b.id, b.modelName)).toList(),
                    selectedId: _draft.brandId,
                    onChanged: (id) => setState(() => _draft = id == null ? _draft.clearing(brandId: true) : _draft.copyWith(brandId: id)),
                  ),
                  const SizedBox(height: AppSizes.lg),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Reset',
                      onPressed: () {
                        setState(() => _draft = StockFilter.empty);
                        widget.onApply(StockFilter.empty);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Apply',
                      onPressed: () {
                        widget.onApply(_draft);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}