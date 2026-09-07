import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/home_state.dart';

final homeControllerProvider =
NotifierProvider.autoDispose<HomeController, HomeState>(HomeController.new);

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState.initial().copyWith(
      isOnline: true,
      stats: _mockStatsFor('today'),
      dailyTargetPercent: 0.75,
      dailyTargetAchieved: '₹45,280',
      dailyTargetGoal: '₹60,000',
      topProducts: _mockTopProducts,
      recentSales: _mockRecentSales,
    );
  }

  void selectPeriod(String period) {
    // TODO: wire to dashboardRepositoryProvider.getDashboardSummary(period)
    // once the home/data/repositories layer is ready. Currently swaps mock data.
    state = state.copyWith(
      selectedPeriod: period,
      stats: _mockStatsFor(period),
    );
  }

  List<StatCardData> _mockStatsFor(String period) {
    // TODO: replace with real values keyed by `period` once API is wired.
    return const [
      StatCardData(
        icon: Icons.bar_chart_rounded,
        label: "Today's Sales",
        value: '₹45,280',
        trendLabel: '+12.5%',
        isPositiveTrend: true,
      ),
      StatCardData(
        icon: Icons.credit_card_rounded,
        label: 'Collection',
        value: '₹38,500',
      ),
      StatCardData(
        icon: Icons.shopping_bag_outlined,
        label: 'Orders',
        value: '124',
        trendLabel: '-3.1%',
        isPositiveTrend: false,
      ),
      StatCardData(
        icon: Icons.person_outline_rounded,
        label: 'Profit',
        value: '₹12,450',
        trendLabel: '+8.3%',
        isPositiveTrend: true,
      ),
    ];
  }

  static const _mockTopProducts = [
    TopProductData(rank: 1, name: 'Fresh Filtered Milk 1L', unitsSold: 48, revenue: '₹2,400'),
    TopProductData(rank: 2, name: 'Whole Wheat Bread', unitsSold: 36, revenue: '₹1,440'),
    TopProductData(rank: 3, name: 'Organic Eggs 12pk', unitsSold: 32, revenue: '₹3,840'),
    TopProductData(rank: 4, name: 'Double Apple Soda', unitsSold: 28, revenue: '₹840'),
    TopProductData(rank: 5, name: 'Crisp Potato Chips', unitsSold: 24, revenue: '₹720'),
  ];

  static const _mockRecentSales = [
    RecentSaleData(saleId: '#SL001', customerName: 'Walk-In Customer', itemCount: 3, timeAgo: '2 mins ago', amount: '₹1,250'),
    RecentSaleData(saleId: '#SL002', customerName: 'Rahul Sharma', itemCount: 5, timeAgo: '15 mins ago', amount: '₹3,420'),
    RecentSaleData(saleId: '#SL003', customerName: 'Amit Patel', itemCount: 1, timeAgo: '1 hour ago', amount: '₹450'),
  ];
}