import 'package:flutter/material.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_color_scheme.dart';
import '../utility/custom_loader.dart';
import '../utility/empty_state.dart';
import '../utility/error_state.dart';
import 'search_field.dart';

/// One selectable row of [PaginatedPickerSheet].
class PickerItem {
  final String id;
  final String label;
  final String? subtitle;

  const PickerItem({required this.id, required this.label, this.subtitle});
}

/// Bottom-sheet content for a searchable, infinitely-scrolling single
/// select. It is a dumb view: the caller owns the data and rebuilds it
/// (open the sheet with a Riverpod `Consumer` inside the builder).
///
/// - [onSearch] set → the server searches; the caller debounces and
///   reloads [items]. [onSearch] null → the loaded [items] are filtered
///   locally, and more pages keep loading while nothing matches.
/// - Reaching the end of the list calls [onLoadMore] while [hasMore].
class PaginatedPickerSheet extends StatefulWidget {
  final String title;
  final String searchHint;
  final String emptyTitle;
  final List<PickerItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final ValueChanged<String>? onSearch;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final ValueChanged<PickerItem> onSelected;

  const PaginatedPickerSheet({
    super.key,
    required this.title,
    required this.searchHint,
    required this.emptyTitle,
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
    required this.onLoadMore,
    required this.onRetry,
    required this.onSelected,
    this.onSearch,
  });

  @override
  State<PaginatedPickerSheet> createState() => _PaginatedPickerSheetState();
}

class _PaginatedPickerSheetState extends State<PaginatedPickerSheet> {
  static const double _heightFactor = 0.75;
  static const double _loadMoreThreshold = 160;

  final _search = TextEditingController();
  final _scroll = ScrollController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  bool get _localFilter => widget.onSearch == null;

  List<PickerItem> get _visible {
    if (!_localFilter || _query.isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((i) => i.label.toLowerCase().contains(q)).toList();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    if (p.pixels >= p.maxScrollExtent - _loadMoreThreshold) _loadMoreIfNeeded();
  }

  void _loadMoreIfNeeded() {
    if (widget.hasMore && !widget.isLoadingMore && !widget.isLoading) {
      widget.onLoadMore();
    }
  }

  void _onChanged(String value) {
    final text = value.trim();
    if (_localFilter) {
      setState(() => _query = text);
    } else {
      widget.onSearch!(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final visible = _visible;

    // Local filter with no match yet: keep paging until one turns up.
    if (_localFilter && _query.isNotEmpty && visible.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadMoreIfNeeded();
      });
    }

    final Widget body;
    if (widget.isLoading && widget.items.isEmpty) {
      body = const CustomLoader();
    } else if (widget.errorMessage != null && widget.items.isEmpty) {
      body = ErrorState(message: widget.errorMessage!, onRetry: widget.onRetry);
    } else if (visible.isEmpty && !widget.hasMore) {
      body = EmptyState(
        title: widget.emptyTitle,
        message: AppStrings.tryDifferentSearchMessage,
        icon: Icons.search_off_rounded,
      );
    } else {
      body = ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        itemCount: visible.length + (widget.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => Divider(height: 1, color: colors.divider),
        itemBuilder: (context, index) {
          if (index >= visible.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSizes.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = visible[index];
          return ListTile(
            title: Text(
              item.label,
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            subtitle: item.subtitle == null || item.subtitle!.isEmpty
                ? null
                : Text(
              item.subtitle!,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                color: colors.textSecondary,
              ),
            ),
            onTap: () => widget.onSelected(item),
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * _heightFactor,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLg),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  AppSizes.md,
                  AppSizes.md,
                  AppSizes.sm,
                ),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: SearchField(
                  controller: _search,
                  hintText: widget.searchHint,
                  onChanged: _onChanged,
                  onClear: () => _onChanged(''),
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}