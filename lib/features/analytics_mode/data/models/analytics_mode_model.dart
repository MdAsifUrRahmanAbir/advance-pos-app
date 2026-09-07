class AnalyticsModeModel {
  final String? id;

  AnalyticsModeModel({this.id});

  factory AnalyticsModeModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModeModel(
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
  };
}
