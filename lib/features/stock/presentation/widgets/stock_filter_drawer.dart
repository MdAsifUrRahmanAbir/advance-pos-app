import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../states/stock_filter.dart';

/// Right-side drawer opened from the Stock screen's header filter icon.
/// Lets the user narrow the list by Group / Category / Subcategory /
/// Brand (Model), sourced live from [masterDataControllerProvider] (the
/// once-per-day cached master data). Subcategories are narrowed to the
/// ones belonging to the selected category, if any is chosen.
///
/// No supplier selector yet — the API/state supports `supplierId`, but
/// there's no supplier master-data source wired in to populate a list.
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
                  _section(
                    title: 'Group',
                    selectedId: _draft.groupId,
                    items: masterData.groups.map((g) => (g.id, g.groupName)).toList(),
                    onSelected: (id) => setState(() => _draft = _draft.copyWith(groupId: id)),
                    onClear: () => setState(() => _draft = _draft.clearing(groupId: true)),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _section(
                    title: 'Category',
                    selectedId: _draft.categoryId,
                    items: categories.map((c) => (c.id, c.categoryName)).toList(),
                    onSelected: (id) => setState(() {
                      // Changing category invalidates a previously
                      // selected subcategory that may no longer belong to it.
                      _draft = _draft.copyWith(categoryId: id).clearing(subCategoryId: true);
                    }),
                    onClear: () => setState(() => _draft = _draft.clearing(categoryId: true, subCategoryId: true)),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _section(
                    title: 'Subcategory',
                    selectedId: _draft.subCategoryId,
                    items: subcategories.map((s) => (s.id, s.subCategoryName)).toList(),
                    onSelected: (id) => setState(() => _draft = _draft.copyWith(subCategoryId: id)),
                    onClear: () => setState(() => _draft = _draft.clearing(subCategoryId: true)),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _section(
                    title: 'Brand / Model',
                    selectedId: _draft.brandId,
                    items: masterData.brands.map((b) => (b.id, b.modelName)).toList(),
                    onSelected: (id) => setState(() => _draft = _draft.copyWith(brandId: id)),
                    onClear: () => setState(() => _draft = _draft.clearing(brandId: true)),
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

  Widget _section({
    required String title,
    required int? selectedId,
    required List<(int, String)> items,
    required ValueChanged<int?> onSelected,
    required VoidCallback onClear,
  }) {
    return Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700, color: context.appColors.textSecondary)),
              if (selectedId != null)
                GestureDetector(
                  onTap: onClear,
                  child: const Text('Clear', style: TextStyle(fontSize: AppSizes.fontXs, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          if (items.isEmpty)
            Text('No options available', style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textHint))
          else
            Wrap(
              spacing: AppSizes.xs,
              runSpacing: AppSizes.xs,
              children: [
                for (final (id, label) in items)
                  ChoiceChip(
                    label: Text(label),
                    selected: selectedId == id,
                    onSelected: (isSelected) => onSelected(isSelected ? id : null),
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(fontSize: AppSizes.fontXs, color: selectedId == id ? AppColors.primary : context.appColors.textSecondary),
                    side: BorderSide(color: context.appColors.border),
                  ),
              ],
            ),
        ],
      );
    });
  }
}