import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../data/models/customers_model.dart';
import 'customer_card_item.dart';

/// Shimmer placeholder for the customers list. Built from real
/// [CustomerCardItem]s with dummy data so Skeletonizer produces bones
/// that match the final layout exactly.
class CustomerListSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const CustomerListSkeleton({
    super.key,
    this.itemCount = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSizes.md),
  });

  static final _placeholder = ResultDatum(
    sl: 0,
    customerNo: 'CUS-000000',
    customerName: 'Customer name',
    parRemarks: 'Customer address placeholder',
    customerType: 1,
    isPurchase: null,
    customerMobile: '01700000000',
    customerEmail: '',
    branchName: 'Branch name',
  );

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm + AppSizes.xs),
      itemBuilder: (_, _) => CustomerCardItem(item: _placeholder),
    ).skeletonizer(enabled: true);
  }
}