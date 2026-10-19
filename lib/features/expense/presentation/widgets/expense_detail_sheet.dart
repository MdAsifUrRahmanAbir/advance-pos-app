import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/icon_button.dart';
import '../../../../core/widgets/utility/error_state.dart';
// TODO: adjust path to wherever WidgetSkeletonizer lives.
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../controllers/expense_detail_controller.dart';
import '../controllers/expense_payment_accounts_provider.dart';
import '../states/expense_format.dart';
import '../states/expense_skeleton_data.dart';
import 'expense_detail_summary_card.dart';
import 'expense_heads_card.dart';

/// Opens the expense detail as a modal bottom sheet.
/// TODO: swap showModalBottomSheet for CustomBottomSheet if its API fits.
Future<void> showExpenseDetailSheet({
  required BuildContext context,
  required String expenseNo,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    clipBehavior: Clip.antiAlias,
    constraints: const BoxConstraints(maxWidth: 640),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.lg)),
    ),
    builder: (_) => ExpenseDetailSheet(expenseNo: expenseNo),
  );
}

/// Sheet content. Owns its own load (family controller keyed by expenseNo),
/// so it is a ConsumerWidget rather than a constructor-only widget.
class ExpenseDetailSheet extends ConsumerWidget {
  final String expenseNo;

  const ExpenseDetailSheet({super.key, required this.expenseNo});

  static const double _maxHeightFactor = 0.9;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = expenseDetailControllerProvider(expenseNo);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final accounts = ref.watch(expensePaymentAccountsProvider);

    String accountLabelOf(int systemId, int accountId) =>
        resolvePaymentAccountLabel(
          accounts,
          systemId: systemId,
          accountId: accountId,
        );

    final data = state.detail?.resultData;
    final isSkeleton = data == null && state.isInitialLoading;
    final showError = data == null && !state.isInitialLoading;
    final shown = data ?? ExpenseSkeletonData.detail.resultData;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(
            onShare: data == null
                ? null
                : () => SharePlus.instance.share(
              ShareParams(
                text: ExpenseFormat.shareText(data, accountLabelOf),
                subject: AppStrings.expShareSubject(data.expenseNo),
              ),
            ),
            onClose: () => Navigator.of(context).pop(),
          ),
          Flexible(
            child: showError
                ? ListView(
              shrinkWrap: true,
              children: [
                ErrorState(
                  message: state.errorMessage ??
                      AppStrings.expDetailLoadFailed,
                  onRetry: controller.getExpenseDetail,
                  retryLabel: AppStrings.retry,
                ),
              ],
            )
                : ListView(
              shrinkWrap: true,
              physics: isSkeleton
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.xs,
                AppSizes.md,
                AppSizes.lg + bottomInset,
              ),
              children: [
                ExpenseDetailSummaryCard(data: shown),
                const SizedBox(height: AppSizes.md),
                ExpenseHeadsCard(
                  data: shown,
                  accountLabelOf: accountLabelOf,
                ),
              ],
            ).skeletonizer(enabled: isSkeleton),
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final VoidCallback? onShare;
  final VoidCallback onClose;

  const _SheetHeader({required this.onShare, required this.onClose});

  static const double _handleWidth = 40;
  static const double _handleHeight = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSizes.sm),
        Container(
          width: _handleWidth,
          height: _handleHeight,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md,
            AppSizes.sm,
            AppSizes.sm,
            AppSizes.xs,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  AppStrings.expDetailTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onShare != null)
                AppIconButton(icon: Icons.share_outlined, onPressed: onShare),
              AppIconButton(icon: Icons.close_rounded, onPressed: onClose),
            ],
          ),
        ),
      ],
    );
  }
}