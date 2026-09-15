import 'package:flutter/material.dart';

/// Small display-only value classes for the dashboard.
/// These are NOT data/models — they're presentation-layer shapes until
/// the real API is wired via add_api_feature.py, at which point this file
/// should be patched to map from the real DTOs.

class StatCardData {
  final IconData icon;
  final String label;
  final String value;
  final String? trendLabel;
  final bool isPositiveTrend;

  const StatCardData({
    required this.icon,
    required this.label,
    required this.value,
    this.trendLabel,
    this.isPositiveTrend = true,
  });
}

class TopProductData {
  final int rank;
  final String name;
  final int unitsSold;
  final String revenue;

  const TopProductData({
    required this.rank,
    required this.name,
    required this.unitsSold,
    required this.revenue,
  });
}

class RecentSaleData {
  final String saleId;
  final String customerName;
  final int itemCount;
  final String timeAgo;
  final String amount;

  const RecentSaleData({
    required this.saleId,
    required this.customerName,
    required this.itemCount,
    required this.timeAgo,
    required this.amount,
  });
}

class HomeState {
  final bool isLoading;
  final String? errorMessage;
  final bool isOnline;
  final String selectedPeriod; // 'today' | 'weekly' | 'monthly'
  final List<StatCardData> stats;
  final double dailyTargetPercent; // 0.0–1.0
  final String dailyTargetAchieved;
  final String dailyTargetGoal;
  final List<TopProductData> topProducts;
  final List<RecentSaleData> recentSales;

  const HomeState({
    this.isLoading = false,
    this.errorMessage,
    this.isOnline = true,
    this.selectedPeriod = 'today',
    this.stats = const [],
    this.dailyTargetPercent = 0,
    this.dailyTargetAchieved = '',
    this.dailyTargetGoal = '',
    this.topProducts = const [],
    this.recentSales = const [],
  });

  factory HomeState.initial() => const HomeState();

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isOnline,
    String? selectedPeriod,
    List<StatCardData>? stats,
    double? dailyTargetPercent,
    String? dailyTargetAchieved,
    String? dailyTargetGoal,
    List<TopProductData>? topProducts,
    List<RecentSaleData>? recentSales,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isOnline: isOnline ?? this.isOnline,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      stats: stats ?? this.stats,
      dailyTargetPercent: dailyTargetPercent ?? this.dailyTargetPercent,
      dailyTargetAchieved: dailyTargetAchieved ?? this.dailyTargetAchieved,
      dailyTargetGoal: dailyTargetGoal ?? this.dailyTargetGoal,
      topProducts: topProducts ?? this.topProducts,
      recentSales: recentSales ?? this.recentSales,
    );
  }
}
