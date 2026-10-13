import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/bottom_action_bar.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/primary_input_field.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../controllers/expense_form_controller.dart';
import '../controllers/expense_form_payment_accounts_provider.dart';
import '../states/expense_form_state.dart';
import '../widgets/expense_form_entry_card.dart';
import '../widgets/expense_form_header.dart';
import '../widgets/expense_form_lines_section.dart';

class ExpenseFormMobileView extends ConsumerWidget {
  final String? expenseNo;

  const ExpenseFormMobileView({super.key, this.expenseNo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = expenseFormControllerProvider(expenseNo);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final isEdit = expenseNo != null;

    final heads = ref.watch(
      masterDataControllerProvider.select((s) => s.accountHeads),
    );
    final masterLoading = ref.watch(
      masterDataControllerProvider.select((s) => s.isLoading),
    );
    final accounts = ref.watch(expenseFormAccountsProvider);
    final masterReady = heads.isNotEmpty && accounts.isNotEmpty;

    final prefillFailed = isEdit && state.loadError != null;
    final canSave = masterReady && !state.isLoadingDetail && !prefillFailed;

    Future<void> save() async {
      FocusScope.of(context).unfocus();
      final ok = await controller.save();
      if (!context.mounted) return;
      if (ok) {
        CustomSnackbar.show(
          context,
          isEdit ? AppStrings.expFormUpdated : AppStrings.expFormCreated,
        );
        context.pop(true);
        return;
      }
      final s = ref.read(provider);
      // Entry-row problems are already shown inline under the entry card.
      final message =
          s.errorMessage ??
              (s.entryError == null ? AppStrings.expFormSaveFailed : null);
      if (message != null) CustomSnackbar.show(context, message, error: true);
    }

    final Widget body;
    if (prefillFailed) {
      body = ErrorState(
        message: state.loadError!,
        onRetry: controller.loadDetail,
        retryLabel: AppStrings.expFormRetry,
      );
    } else if (!masterReady) {
      body = masterLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : ErrorState(
        message: AppStrings.expFormMasterMissing,
        onRetry: () =>
            ref.read(masterDataControllerProvider.notifier).refresh(),
        retryLabel: AppStrings.expFormRetry,
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          ExpenseFormEntryCard(
            headItems: [for (final h in heads) (h.id, h.headName)],
            accountItems: [for (final o in accounts) (o.accountId, o.label)],
            headId: state.draftHeadId,
            accountId:
            state.draftPaymentAccId ?? controller.defaultPaymentAccId,
            narrationController: controller.localNarrationController,
            amountController: controller.amountController,
            errorText: state.entryError,
            enabled: !state.isSubmitting,
            onHeadChanged: controller.selectHead,
            onAccountChanged: controller.selectPayment,
            onAdd: controller.addLine,
          ),
          const SizedBox(height: AppSizes.md),
          ExpenseFormLinesSection(
            lines: state.isLoadingDetail
                ? ExpenseFormState.skeletonLines
                : state.lines,
            headNames: {for (final h in heads) h.id: h.headName},
            accountOptions: accounts,
            total: state.total,
            onRemove: controller.removeLine,
            enabled: !state.isSubmitting && !state.isLoadingDetail,
          ),
          const SizedBox(height: AppSizes.md),
          PrimaryInputField(
            label: AppStrings.expFormGlobalNarration,
            hint: AppStrings.expFormGlobalNarrationHint,
            controller: controller.globalNarrationController,
            maxLines: 3,
            enabled: !state.isSubmitting,
          ),
        ],
      ).skeletonizer(enabled: state.isLoadingDetail);
    }

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          ExpenseFormHeader(isEdit: isEdit, onBack: () => context.pop()),
          Expanded(child: body),
          BottomActionBar(
            child: PrimaryButton(
              label: isEdit ? AppStrings.expFormUpdate : AppStrings.expFormSave,
              loading: state.isSubmitting,
              onPressed: canSave ? save : null,
            ),
          ),
        ],
      ),
    );
  }
}