class OrderListModel {
  final String? id;

  OrderListModel({this.id});

  factory OrderListModel.fromJson(Map<String, dynamic> json) {
    return OrderListModel(
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
  };
}
