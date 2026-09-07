class TermsPrivacyModel {
  final String? id;

  TermsPrivacyModel({this.id});

  factory TermsPrivacyModel.fromJson(Map<String, dynamic> json) {
    return TermsPrivacyModel(
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
  };
}
