import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../states/stock_state.dart';
import 'stock_card_tile.dart';

class StockListSkeleton extends StatelessWidget {
  final int itemCount;
  const StockListSkeleton({super.key, required this.itemCount});

  static const _placeholder = StockItem(
    id: 'skeleton',
    name: 'Sample Product Name',
    sku: 'SKU-0000',
    barcode: '0000000000000',
    quantity: 10,
    category: 'Category',
    sellingPrice: 0.0,
    status: StockStatus.inStock,
  );

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm + AppSizes.xs),
      itemBuilder: (context, index) {
        return StockCardTile(item: _placeholder, onShowInfo: () {});
      },
    ).skeletonizer(enabled: true);
  }
}