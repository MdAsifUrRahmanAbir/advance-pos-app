class AuditLogModel {
  final String? id;

  AuditLogModel({this.id});

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
  };
}
