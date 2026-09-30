// import 'package:flutter/material.dart';
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/constants/app_strings.dart';
//
// /// ⚠️ Not wired to DropdownField — its exact constructor wasn't available.
// /// Built as a minimal DropdownButton composition styled to match the
// /// bordered-box look. Swap to DropdownField once its source is shared.
// class SalesAgentSelector extends StatelessWidget {
//   final String selectedAgent;
//   final List<String> agents;
//   final ValueChanged<String> onChanged;
//
//   const SalesAgentSelector({
//     super.key,
//     required this.selectedAgent,
//     required this.agents,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           AppStrings.salesAgentLabel,
//           style: const TextStyle(
//             color: AppColors.textSecondary,
//             fontSize: AppSizes.fontXs,
//             fontWeight: FontWeight.w700,
//             letterSpacing: 0.4,
//           ),
//         ),
//         const SizedBox(height: AppSizes.xs),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(
//             horizontal: AppSizes.md,
//             vertical: AppSizes.xs,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(color: AppColors.border),
//             borderRadius: BorderRadius.circular(AppSizes.radiusSm),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: selectedAgent.isEmpty ? null : selectedAgent,
//               isExpanded: true,
//               icon: const Icon(
//                 Icons.keyboard_arrow_down_rounded,
//                 color: AppColors.textSecondary,
//               ),
//               style: const TextStyle(
//                 color: AppColors.textPrimary,
//                 fontSize: AppSizes.fontSm,
//               ),
//               items: agents
//                   .map(
//                     (agent) =>
//                         DropdownMenuItem(value: agent, child: Text(agent)),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 if (value != null) onChanged(value);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
