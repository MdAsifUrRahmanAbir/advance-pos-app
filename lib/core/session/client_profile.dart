import 'dart:convert';

import '../constants/api_endpoints.dart';

/// The company (client) this device is bound to, from company-code
/// verification. Saved in secure storage and restored at startup; its
/// [apiBaseUrl] is used for every API call.
class ClientProfile {
  final String name;
  final String compCode;
  final String logo;
  final String product;
  final String baseUrl;

  const ClientProfile({
    required this.name,
    required this.compCode,
    required this.logo,
    required this.product,
    required this.baseUrl,
  });

  /// `base_url` ("http://host/.../testing_api/") + "public/api", without a
  /// trailing slash, matching how endpoints are written ("/sales", ...).
  String get apiBaseUrl {
    final root = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return '$root${ApiEndpoints.apiPathSuffix}';
  }

  factory ClientProfile.fromJson(Map<String, dynamic> json) => ClientProfile(
    name: json['name'] as String,
    compCode: json['compCode'] as String,
    logo: json['logo'] as String,
    product: json['product'] as String,
    baseUrl: json['baseUrl'] as String,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'compCode': compCode,
    'logo': logo,
    'product': product,
    'baseUrl': baseUrl,
  };

  String encode() => jsonEncode(toJson());

  /// Null when [raw] is missing, unreadable or has no base URL, so the
  /// caller can send the user back to company verification.
  static ClientProfile? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final profile = ClientProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return profile.baseUrl.isEmpty ? null : profile;
    } catch (_) {
      return null;
    }
  }
}