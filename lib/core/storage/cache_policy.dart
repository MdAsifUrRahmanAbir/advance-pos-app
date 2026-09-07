enum CacheSensitivity {
  /// Never persisted to disk. Keep it in memory (Riverpod state) only.
  none,

  /// Non-sensitive, cacheable to the plain (unencrypted) local box.
  standard,

  /// Sensitive but still cacheable — persisted to the encrypted box only.
  sensitive,
}

/// Declares how a piece of data is allowed to be cached. Attach this to
/// repository methods so the caching decision is explicit and reviewable,
/// not implicit in whichever service happens to call storage.
class CachePolicy {
  final CacheSensitivity sensitivity;
  final Duration? ttl; // null = cache forever until explicitly invalidated

  const CachePolicy._(this.sensitivity, this.ttl);

  static const CachePolicy never = CachePolicy._(CacheSensitivity.none, null);

  static CachePolicy standard({Duration ttl = const Duration(hours: 6)}) =>
      CachePolicy._(CacheSensitivity.standard, ttl);

  static CachePolicy sensitive({Duration ttl = const Duration(minutes: 30)}) =>
      CachePolicy._(CacheSensitivity.sensitive, ttl);
}