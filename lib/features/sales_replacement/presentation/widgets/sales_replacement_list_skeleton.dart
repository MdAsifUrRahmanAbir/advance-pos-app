import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/widget_animation_extension.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../data/models/sales_replacement_model.dart' show ResultDatum;
import 'sales_replacement_card_tile.dart';

class SalesReplacementListSkeleton extends StatelessWidget {
  final int itemCount;
  const SalesReplacementListSkeleton({super.key, required this.itemCount});

  static final _placeholder = ResultDatum(
    sl: 1,
    returnDate: '00/00/00',
    returnBillNo: 'SR00000000000',
    salesBillNo: 'SL00000000000',
    totalReturnQuantity: '1',
    totalReturnAmount: '0',
    payableReturnAmount: '0',
    returnDisAmount: '0',
    productNames: ['Sample product name'],
    customerName: 'Customer name',
    returnBy: 'Staff name',
    isActive: 1,
  );

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) =>
      const SizedBox(height: AppSizes.sm + AppSizes.xs),
      itemBuilder: (context, index) {
        return SalesReplacementCardTile(
          item: _placeholder,
          onShowInfo: () {},
        ).fadeSlideIn(delay: (index * 60).ms);
      },
    ).skeletonizer(enabled: true);
  }
}