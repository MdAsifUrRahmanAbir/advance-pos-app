import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import '../../../../core/widgets/common/searchable_dropdown_field.dart';
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../states/invoice_filter.dart';

/// Right-side drawer for Invoices — Group/Category/Subcategory/Brand
/// sourced from master data (mirrors [StockFilterDrawer]), plus a
/// custom date-range picker. Customer/Employee are plain numeric ID
/// inputs, NOT searchable pickers — there's no customer-list/
/// employee-list master-data endpoint to populate a dropdown from yet.
/// Swap those two for [SearchableDropdownField]s once such an endpoint
/// exists.
class InvoiceFilterDrawer extends ConsumerStatefulWidget {
  final InvoiceFilter initialFilter;
  final ValueChanged<InvoiceFilter> onApply;

  const InvoiceFilterDrawer({super.key, required this.initialFilter, required this.onApply});

  @override
  ConsumerState<InvoiceFilterDrawer> createState() => _InvoiceFilterDrawerState();
}

class _InvoiceFilterDrawerState extends ConsumerState<InvoiceFilterDrawer> {
  late InvoiceFilter _draft = widget.initialFilter;
  late final TextEditingController _customerController =
  TextEditingController(text: widget.initialFilter.customerId?.toString() ?? '');
  late final TextEditingController _employeeController =
  TextEditingController(text: widget.initialFilter.employeeId?.toString() ?? '');

  @override
  void dispose() {
    _customerController.dispose();
    _employeeController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: _draft.startDate != null && _draft.endDate != null
          ? DateTimeRange(start: _draft.startDate!, end: _draft.endDate!)
          : null,
    );
    if (picked != null) {
      setState(() => _draft = _draft.copyWith(startDate: picked.start, endDate: picked.end));
    }
  }

  String _dateRangeLabel() {
    if (_draft.startDate == null || _draft.endDate == null) return 'Any date';
    String two(int n) => n.toString().padLeft(2, '0');
    final s = _draft.startDate!;
    final e = _draft.endDate!;
    return '${two(s.day)}/${two(s.month)}/${s.year} – ${two(e.day)}/${two(e.month)}/${e.year}';
  }

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
                  Text('Filter Invoices', style: TextStyle(fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700, color: context.appColors.textPrimary)),
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
                  Text('Date Range', style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700, color: context.appColors.textSecondary)),
                  const SizedBox(height: AppSizes.xs),
                  InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm + AppSizes.xs),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.appColors.border),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_dateRangeLabel(), style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textPrimary)),
                          const Icon(Icons.calendar_today_outlined, size: AppSizes.iconSm),
                        ],
                      ),
                    ),
                  ),
                  if (_draft.startDate != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _draft = _draft.clearing(startDate: true, endDate: true)),
                        child: const Text('Clear dates', style: TextStyle(fontSize: AppSizes.fontXs)),
                      ),
                    ),
                  const SizedBox(height: AppSizes.md),
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
                  const SizedBox(height: AppSizes.md),
                  // TODO: no customer-list / employee-list master-data
                  // endpoint exists yet — plain numeric inputs rather
                  // than searchable pickers. Swap for a
                  // SearchableDropdownField (like above) once one
                  // exists.
                  Text('Customer ID', style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700, color: context.appColors.textSecondary)),
                  const SizedBox(height: AppSizes.xs),
                  TextField(
                    controller: _customerController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 142', isDense: true, border: OutlineInputBorder()),
                    onChanged: (v) => setState(() => _draft = v.trim().isEmpty
                        ? _draft.clearing(customerId: true)
                        : _draft.copyWith(customerId: int.tryParse(v.trim()))),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text('Employee ID', style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700, color: context.appColors.textSecondary)),
                  const SizedBox(height: AppSizes.xs),
                  TextField(
                    controller: _employeeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 7', isDense: true, border: OutlineInputBorder()),
                    onChanged: (v) => setState(() => _draft = v.trim().isEmpty
                        ? _draft.clearing(employeeId: true)
                        : _draft.copyWith(employeeId: int.tryParse(v.trim()))),
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
                        setState(() => _draft = InvoiceFilter.empty);
                        widget.onApply(InvoiceFilter.empty);
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