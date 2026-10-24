
class BillsModel {
  final String status;
  final String message;
  final List<Result> result;
  final bool hasMore;

  BillsModel({
    required this.status,
    required this.message,
    required this.result,
    required this.hasMore,
  });

  factory BillsModel.fromJson(Map<String, dynamic> json) => BillsModel(
    status: json["status"],
    message: json["message"],
    result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
    hasMore: json["hasMore"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
    "hasMore": hasMore,
  };
}

class Result {
  final String id;
  final String text;

  Result({
    required this.id,
    required this.text,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    text: json["text"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "text": text,
  };
}
