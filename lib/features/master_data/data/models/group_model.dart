class GroupModel {
  final String status;
  final String message;
  final int recordsTotal;
  final int recordsShowing;
  final List<GroupItem> resultData;

  GroupModel({
    required this.status,
    required this.message,
    required this.recordsTotal,
    required this.recordsShowing,
    required this.resultData,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
    status: json["status"],
    message: json["message"],
    recordsTotal: json["recordsTotal"],
    recordsShowing: json["recordsShowing"],
    resultData: List<GroupItem>.from(json["resultData"].map((x) => GroupItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "recordsTotal": recordsTotal,
    "recordsShowing": recordsShowing,
    "resultData": List<dynamic>.from(resultData.map((x) => x.toJson())),
  };
}

class GroupItem {
  final int sl;
  final int id;
  final String groupName;
  final String groupCode;

  GroupItem({
    required this.sl,
    required this.id,
    required this.groupName,
    required this.groupCode,
  });

  factory GroupItem.fromJson(Map<String, dynamic> json) => GroupItem(
    sl: json["sl"],
    id: json["id"],
    groupName: json["group_name"],
    groupCode: json["group_code"],
  );

  Map<String, dynamic> toJson() => {
    "sl": sl,
    "id": id,
    "group_name": groupName,
    "group_code": groupCode,
  };
}