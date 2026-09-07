class CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final Duration? ttl;

  const CacheEntry({required this.data, required this.cachedAt, this.ttl});

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(cachedAt) > ttl!;
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) => {
    'data': toJsonT(data),
    'cachedAt': cachedAt.toIso8601String(),
    'ttlSeconds': ttl?.inSeconds,
  };

  static CacheEntry<T> fromJson<T>(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return CacheEntry<T>(
      data: fromJsonT(json['data'] as Map<String, dynamic>),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      ttl: json['ttlSeconds'] == null
          ? null
          : Duration(seconds: json['ttlSeconds'] as int),
    );
  }
}