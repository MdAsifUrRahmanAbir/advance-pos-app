import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/avatar.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import 'order_status_badge.dart';

/// Single order summary card — order ID + date, status badge,
/// overlapping item thumbnails, item count + total, and a "View
/// Details" action. Composes entirely from existing core widgets
/// ([CustomCard], [AppAvatar], [SecondaryButton]) plus the
/// feature-local [OrderStatusBadgeWidget].
class OrderCardItem extends StatelessWidget {
  final String orderId;
  final String date;
  final OrderStatus status;
  final List<String> itemImageUrls;
  final int itemCount;
  final String total;
  final VoidCallback? onViewDetails;

  const OrderCardItem({
    super.key,
    required this.orderId,
    required this.date,
    required this.status,
    required this.itemImageUrls,
    required this.itemCount,
    required this.total,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    const avatarDiameter = AppSizes.xl;
    const overlapStep = AppSizes.xl - AppSizes.sm;
    final stackWidth = itemImageUrls.isEmpty
        ? 0.0
        : overlapStep * (itemImageUrls.length - 1) + avatarDiameter;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderId,
                    style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
                  ),
                  const SizedBox(height: AppSizes.xs / 2),
                  Text(
                    date,
                    style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
                  ),
                ],
              ),
              OrderStatusBadgeWidget(status: status),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: stackWidth,
                height: avatarDiameter,
                child: Stack(
                  children: [
                    for (var i = 0; i < itemImageUrls.length; i++)
                      Positioned(
                        left: i * overlapStep,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(BorderSide(color: context.appColors.surface, width: 2)),
                          ),
                          child: AppAvatar(imageUrl: itemImageUrls[i], radius: AppSizes.md),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$itemCount items',
                    style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
                  ),
                  const SizedBox(height: AppSizes.xs / 2),
                  Text(
                    total,
                    style: TextStyle(fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          SecondaryButton(
            label: AppStrings.viewDetails,
            onPressed: onViewDetails,
          ),
        ],
      ),
    );
  }
}