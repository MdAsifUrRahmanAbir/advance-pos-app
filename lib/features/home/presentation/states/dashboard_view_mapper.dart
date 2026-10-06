import '../../data/models/dashboard_model.dart';
import 'home_state.dart';

/// Picks the right slice of [DashboardModel] for the selected period
/// ('today' | 'monthly') or chart range ('7days' | '12months').
extension DashboardViewMapper on DashboardModel {
  bool _isMonthly(String period) => period == 'monthly';

  OverviewData overviewFor(String period) {
    if (_isMonthly(period)) {
      final s = message.thisMonth.sales;
      return OverviewData(amount: s.amount, orders: s.count, items: s.quantity);
    }
    final s = message.today.sales;
    return OverviewData(
      amount: s.amount,
      orders: s.count,
      items: s.quantity,
      discount: s.discount,
      vat: s.vat,
    );
  }

  SalesReturnClass returnFor(String period) => _isMonthly(period)
      ? message.thisMonth.salesReturn
      : message.today.salesReturn;

  Balance balanceFor(String period) =>
      _isMonthly(period) ? message.thisMonth.balance : message.today.balance;

  Collection collectionFor(String period) => _isMonthly(period)
      ? message.thisMonth.collection
      : message.today.collection;

  SalesTrendData trendFor(String range) {
    final is12Months = range == '12months';
    final c = is12Months
        ? message.charts.last12MonthsSales
        : message.charts.last7DaysSales;

    final labels = c.labels.split(',').map((s) => s.trim()).toList();
    final values = c.series
        .split(',')
        .map((s) => double.tryParse(s.trim()) ?? 0)
        .toList();

    var peak = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[peak]) peak = i;
    }

    return SalesTrendData(
      labels: labels,
      values: values,
      maxAmount: c.maxAmount,
      totalAmount: c.amount,
      orderCount: c.count,
      itemCount: c.quantity,
      isMonthlyRange: is12Months,
      peakLabel: peak < labels.length ? labels[peak] : '',
    );
  }
}