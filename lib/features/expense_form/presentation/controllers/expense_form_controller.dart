import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../../data/repositories/expense_form_repository.dart';
import '../states/expense_form_format.dart';
import '../states/expense_form_state.dart';
import 'expense_form_payment_accounts_provider.dart';

/// Family arg: expenseNo to edit, or null to add.
final expenseFormControllerProvider = NotifierProvider.autoDispose
    .family<ExpenseFormController, ExpenseFormState, String?>(
  ExpenseFormController.new,
);

class ExpenseFormController extends Notifier<ExpenseFormState> {
  ExpenseFormController(this.expenseNo);

  final String? expenseNo;

  static const int _defaultBranchId = 2; // TODO: take from session / branch picker
  // TODO: confirm with backend that account 1 is the main (Cash) account.
  static const int _mainPaymentAccId = 1;

  // Not `late final`: build() re-runs on invalidate and must be able to
  // assign fresh controllers after onDispose disposed the old ones.
  late TextEditingController localNarrationController;
  late TextEditingController amountController;
  late TextEditingController globalNarrationController;

  /// The edited record's own date (parsed from the detail). Add always
  /// sends "now"; edit keeps this so old expenses aren't moved to today.
  DateTime? _loadedDate;

  bool get isEdit => expenseNo != null;

  ExpenseFormRepository get _repository =>
      ref.read(expenseFormRepositoryProvider);

  /// Account preselected on the entry row (the main account), if present in
  /// master data.
  int? get defaultPaymentAccId {
    for (final o in ref.read(expenseFormAccountsProvider)) {
      if (o.accountId == _mainPaymentAccId) return o.accountId;
    }
    return null;
  }

  @override
  ExpenseFormState build() {
    localNarrationController = TextEditingController();
    amountController = TextEditingController();
    globalNarrationController = TextEditingController();
    _loadedDate = null;
    ref.onDispose(() {
      localNarrationController.dispose();
      amountController.dispose();
      globalNarrationController.dispose();
    });
    if (isEdit) Future.microtask(loadDetail);
    return ExpenseFormState(
      isLoadingDetail: isEdit,
      branchId: _defaultBranchId,
    );
  }

  // ───────────────────────────────────────────────
  // GET (edit prefill)
  // ───────────────────────────────────────────────
  Future<bool> loadDetail() async {
    if (!isEdit) return true;
    state = state.copyWith(isLoadingDetail: true, clearLoadError: true);
    try {
      final detail = await _repository.getExpenseForEdit(expenseNo!);
      if (!ref.mounted) return true;
      final d = detail.resultData;
      globalNarrationController.text = d.globalNarration;
      _loadedDate = ExpenseFormFormat.parseServerDate(d.expenseDate);
      state = state.copyWith(
        isLoadingDetail: false,
        expenseId: d.id,
        branchId: d.branchId,
        lines: [
          for (final x in d.details)
            ExpenseFormLine(
              headId: x.headId,
              headName: x.headName,
              paymentSystemId: x.paymentSystemId,
              paymentAccId: x.paymentAccId,
              localNarration: x.localNarration,
              amount: x.amount,
            ),
        ],
      );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoadingDetail: false,
        loadError: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // Entry row + lines
  // ───────────────────────────────────────────────
  void selectHead(int? id) =>
      state = state.copyWith(draftHeadId: id, clearDraftHead: id == null);

  void selectPayment(int? id) => state = state.copyWith(draftPaymentAccId: id);

  /// Validates the entry row and appends it as a line. Returns false (and
  /// sets [ExpenseFormState.entryError]) when invalid.
  bool addLine() {
    final headId = state.draftHeadId;
    final accountId = state.draftPaymentAccId ?? defaultPaymentAccId;
    final amount = num.tryParse(
      amountController.text.trim().replaceAll(',', ''),
    );

    if (headId == null) return _entryFail(AppStrings.expFormHeadRequired);
    if (accountId == null) return _entryFail(AppStrings.expFormAccountRequired);
    if (amount == null || amount <= 0) {
      return _entryFail(AppStrings.expFormAmountInvalid);
    }

    final line = ExpenseFormLine(
      headId: headId,
      headName: _headName(headId),
      paymentSystemId: _accountSystemId(accountId),
      paymentAccId: accountId,
      localNarration: localNarrationController.text.trim(),
      amount: amount,
    );
    localNarrationController.clear();
    amountController.clear();
    state = state.copyWith(
      lines: [...state.lines, line],
      clearDraftHead: true,
    );
    return true;
  }

  void removeLine(int index) {
    if (index < 0 || index >= state.lines.length) return;
    final next = [...state.lines]..removeAt(index);
    state = state.copyWith(lines: next);
  }

  // ───────────────────────────────────────────────
  // POST (add) / PUT (update)
  // ───────────────────────────────────────────────
  /// A head or amount typed but not yet added is added first, so a
  /// forgotten "Add line" tap doesn't lose it.
  bool get _hasPendingEntry =>
      state.draftHeadId != null || amountController.text.trim().isNotEmpty;

  Future<bool> save() async {
    if (state.isSubmitting || state.isLoadingDetail) return false;
    // Editing needs the internal id from the loaded detail.
    if (isEdit && state.expenseId == null) {
      state = state.copyWith(errorMessage: AppStrings.expFormSaveFailed);
      return false;
    }
    if (_hasPendingEntry && !addLine()) return false;
    if (state.lines.isEmpty) {
      state = state.copyWith(errorMessage: AppStrings.expFormNoLines);
      return false;
    }

    final lines = state.lines;
    final global = globalNarrationController.text.trim();
    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.saveExpense(
        expenseId: state.expenseId,
        expenseNo: expenseNo,
        branchId: state.branchId,
        expenseDate: ExpenseFormFormat.payloadDate(
          _loadedDate ?? DateTime.now(),
        ),
        mainPaymentAccId: _mainPaymentAccId,
        headIds: [for (final l in lines) l.headId],
        paymentAccIds: [for (final l in lines) l.paymentAccId],
        localNarrations: [
          for (final l in lines)
            l.localNarration.isEmpty ? null : l.localNarration,
        ],
        amounts: [
          for (final l in lines)
            l.amount % 1 == 0 ? l.amount.toInt() : l.amount,
        ],
        globalNarration: global.isEmpty ? null : global,
      );
      if (!ref.mounted) return true;
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // Helpers
  // ───────────────────────────────────────────────
  bool _entryFail(String message) {
    state = state.copyWith(entryError: message);
    return false;
  }

  String _headName(int id) {
    for (final h in ref.read(masterDataControllerProvider).accountHeads) {
      if (h.id == id) return h.headName;
    }
    return '';
  }

  int _accountSystemId(int accountId) {
    for (final o in ref.read(expenseFormAccountsProvider)) {
      if (o.accountId == accountId) return o.systemId;
    }
    return 0;
  }
}