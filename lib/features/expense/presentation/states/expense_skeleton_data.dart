import '../../data/model/expense_detail_model.dart'
    show Detail, ExpenseDetailModel, ResultData;
import '../../data/model/expense_model.dart' show ResultDatum;

/// Placeholder content for Skeletonizer while the first load is in flight.
/// Never shown as real data.
class ExpenseSkeletonData {
  const ExpenseSkeletonData._();

  static final List<ResultDatum> items = List.generate(
    6,
        (i) => ResultDatum(
      id: i,
      expenseNo: 'EX00000000000',
      expenseDate: '00/00/00',
      totalAmount: 1000,
      branchId: 0,
      branchName: 'Branch name placeholder',
      details: const [],
    ),
  );

  static final ExpenseDetailModel detail = ExpenseDetailModel(
    status: 'success',
    message: '',
    resultData: ResultData(
      id: 0,
      expenseNo: 'EX00000000000',
      expenseDate: '00/00/00',
      totalAmount: 1000,
      branchId: 0,
      branchName: 'Branch name placeholder',
      globalNarration: 'Narration placeholder',
      entryBy: 'Entry user',
      entryDateTime: '00/00/00 00:00 Pm',
      details: [
        Detail(
          headId: 0,
          headName: 'Head name placeholder',
          amount: 1000,
          paymentSystemId: 0,
          paymentAccId: 0,
          localNarration: 'Local narration',
        ),
        Detail(
          headId: 1,
          headName: 'Head name placeholder',
          amount: 1000,
          paymentSystemId: 0,
          paymentAccId: 0,
          localNarration: 'Local narration',
        ),
      ],
    ),
  );
}