import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';
import '../../constants/app_strings.dart';

/// A tap-to-open, search-filterable single-select field.
///
/// Use this instead of a [Wrap] of `ChoiceChip`s whenever a filter/select
/// list can realistically grow past ~8–10 items (master-data lookups,
/// categories, product pickers, etc.). Keeps the trigger to one compact
/// field height regardless of how many options exist; the search + list
/// live in a bottom sheet instead of inline in the page.
///
/// Generic over [T] so it works with any id type (int, String…).
class SearchableDropdownField<T extends Object> extends StatelessWidget {
  final String label;
  final String? hintText;
  final T? selectedId;
  final List<(T id, String label)> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  const SearchableDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.selectedId,
    required this.onChanged,
    this.hintText,
    this.enabled = true,
  });

  String? get _selectedLabel {
    for (final item in items) {
      if (item.$1 == selectedId) return item.$2;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = _selectedLabel != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w700,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: !enabled || items.isEmpty
              ? null
              : () => _openSheet(context),
          child: Container(
            height: AppSizes.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            decoration: BoxDecoration(
              border: Border.all(color: context.appColors.border),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              color: enabled ? context.appColors.surface : context.appColors.surface.withValues(alpha: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedLabel ?? (items.isEmpty ? AppStrings.noOptionsAvailable : (hintText ?? AppStrings.selectOption)),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                      color: hasValue ? context.appColors.textPrimary : context.appColors.textHint,
                    ),
                  ),
                ),
                if (hasValue)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: Icon(Icons.close_rounded, size: AppSizes.iconSm, color: context.appColors.textHint),
                  ),
                if (hasValue) const SizedBox(width: AppSizes.xs),
                Icon(Icons.keyboard_arrow_down_rounded, size: AppSizes.iconMd, color: context.appColors.textHint),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SearchableDropdownSheet<T>(
        title: label,
        items: items,
        selectedId: selectedId,
        onSelected: (id) {
          onChanged(id);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }
}

class _SearchableDropdownSheet<T extends Object> extends StatefulWidget {
  final String title;
  final List<(T id, String label)> items;
  final T? selectedId;
  final ValueChanged<T?> onSelected;

  const _SearchableDropdownSheet({
    required this.title,
    required this.items,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<_SearchableDropdownSheet<T>> createState() => _SearchableDropdownSheetState<T>();
}

class _SearchableDropdownSheetState<T extends Object> extends State<_SearchableDropdownSheet<T>> {
  final _searchController = TextEditingController();
  late List<(T id, String label)> _filtered = widget.items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filtered = query.trim().isEmpty
          ? widget.items
          : widget.items.where((item) => item.$2.toLowerCase().contains(query.trim().toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        // Material (not a plain Container/DecoratedBox) so ListTile below
        // finds this as its nearest Material ancestor — otherwise its
        // background/ink-splash effects get hidden by the sheet's own
        // background color, which throws the
        // "ListTile background color or ink splashes may be invisible" assertion.
        return Material(
          color: context.appColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AppSizes.sm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: context.appColors.border, borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.title, style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary)),
                      if (widget.selectedId != null)
                        TextButton(
                          onPressed: () => widget.onSelected(null),
                          child: Text(AppStrings.clear, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: AppStrings.searchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      isDense: true,
                      filled: true,
                      fillColor: context.appColors.background,
                      contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                    child: Text(AppStrings.noResultsFound, style: TextStyle(color: context.appColors.textHint)),
                  )
                      : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final (id, label) = _filtered[index];
                      final isSelected = id == widget.selectedId;
                      return ListTile(
                        title: Text(
                          label,
                          style: TextStyle(
                            fontSize: AppSizes.fontSm,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected ? AppColors.primary : context.appColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                        onTap: () => widget.onSelected(id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}