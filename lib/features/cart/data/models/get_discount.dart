class GetDiscountModel {
  final String? status;
  final String? message;
  final DiscountResultData? resultData;

  const GetDiscountModel({this.status, this.message, this.resultData});

  factory GetDiscountModel.fromJson(Map<String, dynamic> json) {
    return GetDiscountModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      resultData: json['resultData'] is Map<String, dynamic>
          ? DiscountResultData.fromJson(
              json['resultData'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'resultData': resultData?.toJson(),
    };
  }
}

class DiscountResultData {
  final bool discountApplied;
  final String? discountType;
  final String? discountScope;
  final String? discountMethod;
  final List<String> discountCodes;
  final Map<String, double> productDiscounts;
  final double? discountRate;
  final double? discountAmount;
  final double? productDiscountAmount;
  final double? billDiscountAmount;

  const DiscountResultData({
    this.discountApplied = false,
    this.discountType,
    this.discountScope,
    this.discountMethod,
    this.discountCodes = const [],
    this.productDiscounts = const {},
    this.discountRate,
    this.discountAmount,
    this.productDiscountAmount,
    this.billDiscountAmount,
  });

  factory DiscountResultData.fromJson(Map<String, dynamic> json) {
    return DiscountResultData(
      discountApplied: json['discountApplied'] is bool
          ? json['discountApplied'] as bool
          : false,
      discountType: json['discountType']?.toString(),
      discountScope: json['discountScope']?.toString(),
      discountMethod: json['discountMethod']?.toString(),
      discountCodes: _parseStringList(json['discountCodes']),
      productDiscounts: _parseProductDiscounts(json['productDiscounts']),
      discountRate: _parseDouble(json['discountRate']),
      discountAmount: _parseDouble(json['discountAmount']),
      productDiscountAmount: _parseDouble(json['productDiscountAmount']),
      billDiscountAmount: _parseDouble(json['billDiscountAmount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'discountApplied': discountApplied,
      'discountType': discountType,
      'discountScope': discountScope,
      'discountMethod': discountMethod,
      'discountCodes': discountCodes,
      'productDiscounts': productDiscounts,
      'discountRate': discountRate,
      'discountAmount': discountAmount,
      'productDiscountAmount': productDiscountAmount,
      'billDiscountAmount': billDiscountAmount,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .where((item) => item != null)
        .map((item) => item.toString())
        .toList();
  }

  static Map<String, double> _parseProductDiscounts(dynamic value) {
    if (value is! Map) return const {};

    return value.map<String, double>((key, value) {
      final parsedValue = _parseDouble(value);

      return MapEntry(key.toString(), parsedValue ?? 0.0);
    });
  }
}
