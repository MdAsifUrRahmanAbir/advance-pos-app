// import 'package:flutter/material.dart';

// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/constants/app_strings.dart';
// import '../../../../core/theme/app_color_scheme.dart';
// import '../../../../core/widgets/common/custom_card.dart';
// import '../../../../core/widgets/common/square_icon_tile.dart';
// import '../../data/models/dashboard_model.dart';
// import '../states/dashboard_format.dart';
//
// /// 2×2 grid of key figures: net balance (red when negative), received,
// /// expense and sales returns.
// class DashboardKpiGrid extends StatelessWidget {
//   final Balance balance;
//   final SalesReturnClass salesReturn;
//
//   const DashboardKpiGrid({
//     super.key,
//     required this.balance,
//     required this.salesReturn,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final net = balance.balance;
//     final netColor = net < 0 ? AppColors.error : AppColors.success;
//
//     return Column(
//       children: [
//         _row(
//           _KpiTile(
//             icon: Icons.account_balance_wallet_outlined,
//             color: netColor,
//             label: AppStrings.dashNetBalance,
//             value: DashboardFormat.money(net),
//             valueColor: netColor,
//           ),
//           _KpiTile(
//             icon: Icons.south_west_rounded,
//             color: AppColors.info,
//             label: AppStrings.dashReceived,
//             value: DashboardFormat.money(balance.totalReceive),
//           ),
//         ),
//         const SizedBox(height: AppSizes.sm),
//         _row(
//           _KpiTile(
//             icon: Icons.north_east_rounded,
//             color: AppColors.error,
//             label: AppStrings.expense,
//             value: DashboardFormat.money(balance.totalExpense),
//           ),
//           _KpiTile(
//             icon: Icons.assignment_return_outlined,
//             color: AppColors.warning,
//             label: AppStrings.salesReturnTitle,
//             value: DashboardFormat.money(salesReturn.amount),
//             caption: AppStrings.dashReturnMeta(
//               salesReturn.count,
//               salesReturn.quantity,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _row(Widget left, Widget right) {
//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Expanded(child: left),
//           const SizedBox(width: AppSizes.sm),
//           Expanded(child: right),
//         ],
//       ),
//     );
//   }
// }
//
// class _KpiTile extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String label;
//   final String value;
//   final Color? valueColor;
//   final String? caption;
//
//   const _KpiTile({
//     required this.icon,
//     required this.color,
//     required this.label,
//     required this.value,
//     this.valueColor,
//     this.caption,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.appColors;
//     return CustomCard(
//       padding: const EdgeInsets.all(AppSizes.md),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SquareIconTile(
//             icon: icon,
//             color: color,
//             iconSize: AppSizes.iconSm,
//             padding: AppSizes.sm,
//             radius: AppSizes.radiusSm,
//           ),
//           const SizedBox(height: AppSizes.sm + AppSizes.xs),
//           Text(
//             label,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontXs),
//           ),
//           const SizedBox(height: AppSizes.xs / 2),
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             alignment: Alignment.centerLeft,
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: valueColor ?? colors.textPrimary,
//                 fontSize: AppSizes.fontLg,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           if (caption != null) ...[
//             const SizedBox(height: AppSizes.xs / 2),
//             Text(
//               caption!,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(color: colors.textHint, fontSize: AppSizes.fontXs),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }