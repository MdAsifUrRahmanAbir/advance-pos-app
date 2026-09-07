class EditProfileModel {
  final String? id;

  EditProfileModel({this.id});

  factory EditProfileModel.fromJson(Map<String, dynamic> json) {
    return EditProfileModel(
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
  };
}
