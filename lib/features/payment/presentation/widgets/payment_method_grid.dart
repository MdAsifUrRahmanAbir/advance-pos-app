// import 'package:flutter/material.dart';
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/constants/app_strings.dart';
// import '../states/payment_state.dart';
//
// /// Single-select icon-card grid for payment method.
// ///
// /// No existing core widget matched this exact shape (icon + label card,
// /// bordered, single-select) — RadioOption reads like a standard radio row,
// /// not this. Feature-local for now; promote to core if this selector
// /// pattern shows up in other flows (e.g. delivery method, shipping tier).
// class PaymentMethodGrid extends StatelessWidget {
//   final PaymentMethod selected;
//   final ValueChanged<PaymentMethod> onSelected;
//
//   const PaymentMethodGrid({
//     super.key,
//     required this.selected,
//     required this.onSelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: PaymentMethod.values.map((method) {
//         final isSelected = method == selected;
//         return Expanded(
//           child: Padding(
//             padding: EdgeInsets.only(
//               right: method != PaymentMethod.values.last ? AppSizes.sm : 0,
//             ),
//             child: _PaymentMethodTile(
//               method: method,
//               isSelected: isSelected,
//               onTap: () => onSelected(method),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
//
// class _PaymentMethodTile extends StatelessWidget {
//   final PaymentMethod method;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const _PaymentMethodTile({
//     required this.method,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   String _label() => switch (method) {
//     PaymentMethod.cash => AppStrings.paymentMethodCash,
//     PaymentMethod.bank => AppStrings.paymentMethodBank,
//     PaymentMethod.card => AppStrings.paymentMethodCard,
//     PaymentMethod.mobile => AppStrings.paymentMethodMobile,
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     final color = isSelected ? AppColors.primary : AppColors.textSecondary;
//
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(AppSizes.radiusSm),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 2),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(
//             color: isSelected ? AppColors.primary : AppColors.border,
//             width: isSelected ? 2 : 1,
//           ),
//           borderRadius: BorderRadius.circular(AppSizes.radiusSm),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(method.icon, size: AppSizes.iconMd - 6, color: color),
//             const SizedBox(height: AppSizes.xs),
//             Text(
//               _label(),
//               style: TextStyle(
//                 color: color,
//                 fontSize: AppSizes.fontXs,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
