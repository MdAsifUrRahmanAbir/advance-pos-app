import 'dart:convert';

import 'package:advance_pos_app/core/storage/cache_policy.dart';
import 'package:advance_pos_app/core/storage/local_cache_service.dart';
import 'package:advance_pos_app/features/home/data/models/dashboard_model.dart';

import '../../login/helpers/fake_secure_storage.dart';

/// In-memory stand-in for the Hive cache. Entries are stored as JSON, so
/// the model's toJson/fromJson round trip is exercised too.
class FakeDashboardCache extends LocalCacheService {
  FakeDashboardCache() : super(FakeSecureStorage());

  final Map<String, String> entries = {};

  /// Keys whose entry the real service would find expired.
  final Set<String> expired = {};

  /// Keys whose entry can't be decoded (read throws).
  final Set<String> corrupt = {};

  final List<String> invalidated = [];
  final List<CachePolicy> writePolicies = [];

  void seed(String key, DashboardModel model) =>
      entries[key] = jsonEncode(model.toJson());

  /// Today's sales amount stored under [key], or null.
  double? cachedTodayAmount(String key) {
    final raw = entries[key];
    if (raw == null) return null;
    return DashboardModel.fromJson(jsonDecode(raw) as Map<String, dynamic>)
        .message
        .today
        .sales
        .amount;
  }

  @override
  Future<void> write<T>(
      String key,
      T data,
      CachePolicy policy,
      Map<String, dynamic> Function(T) toJsonT,
      ) async {
    writePolicies.add(policy);
    entries[key] = jsonEncode(toJsonT(data));
    expired.remove(key);
  }

  @override
  T? read<T>(
      String key,
      CacheSensitivity sensitivity,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    if (corrupt.contains(key)) throw const FormatException('bad cache');
    if (expired.contains(key)) {
      entries.remove(key); // the real service deletes expired entries
      return null;
    }
    final raw = entries[key];
    if (raw == null) return null;
    return fromJsonT(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> invalidate(String key, CacheSensitivity sensitivity) async {
    invalidated.add(key);
    entries.remove(key);
    corrupt.remove(key);
  }

  @override
  Future<void> clearOnLogout({bool clearStandard = true}) async =>
      entries.clear();
}