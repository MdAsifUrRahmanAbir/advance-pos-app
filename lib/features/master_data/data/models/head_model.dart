
class HeadModel {
  final List<HeadDatum> headData;

  HeadModel({
    required this.headData,
  });

  factory HeadModel.fromJson(Map<String, dynamic> json) => HeadModel(
    headData: List<HeadDatum>.from(json["headData"].map((x) => HeadDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "headData": List<dynamic>.from(headData.map((x) => x.toJson())),
  };
}

class HeadDatum {
  final int id;
  final String headName;
  final String headCode;
  final int headType;

  HeadDatum({
    required this.id,
    required this.headName,
    required this.headCode,
    required this.headType,
  });

  factory HeadDatum.fromJson(Map<String, dynamic> json) => HeadDatum(
    id: json["id"],
    headName: json["head_name"],
    headCode: json["head_code"],
    headType: json["head_type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "head_name": headName,
    "head_code": headCode,
    "head_type": headType,
  };
}
