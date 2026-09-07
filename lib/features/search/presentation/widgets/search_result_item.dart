import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchResultItem extends ConsumerWidget {
  const SearchResultItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text('SearchResultItem'),
    );
  }
}
