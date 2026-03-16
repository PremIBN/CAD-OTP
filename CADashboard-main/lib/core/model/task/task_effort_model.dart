class TaskEffortModel {
  TaskEffortModel({
    required this.effortStatusId,
    required this.flag,
    required this.clientEmail,
    required this.taskName,
    required this.taskNumber,
    required this.tempEffortsAdded,
    required this.tempAddedDate,
    required this.fyName,
    required this.serviceName,
    required this.parentTaskNumber,
    required this.effortmailtoclient,
    required this.clientAlterNateEmail,
    required this.clientName,
    required this.firmName,
    required this.isBillable,
    required this.taskEffortId,
    required this.taskId,
    required this.employeeId,
    required this.actualEffortsHRs,
    required this.actualEffortsMins,
    required this.effortDate,
    required this.notes,
    required this.addedBy,
    required this.addedDate,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.tokenId,
    required this.startLimit,
    required this.endLimit,
    required this.fullName,
    required this.isAccessible,
    required this.isApproved,
    required this.rejectReason,
    required this.loginMode,
    required this.validationErrors,
  });

  final dynamic effortStatusId;
  final dynamic flag;
  final dynamic clientEmail;
  final dynamic taskName;
  final dynamic taskNumber;
  final dynamic tempEffortsAdded;
  final dynamic tempAddedDate;
  final dynamic fyName;
  final dynamic serviceName;
  final dynamic parentTaskNumber;
  final dynamic effortmailtoclient;
  final dynamic clientAlterNateEmail;
  final dynamic clientName;
  final String? firmName;
  final dynamic isBillable;
  final dynamic taskEffortId;
  final dynamic taskId;
  final dynamic employeeId;
  final dynamic actualEffortsHRs;
  final dynamic actualEffortsMins;
  final DateTime? effortDate;
  final String? notes;
  final String? addedBy;
  final dynamic addedDate;
  final String? modifiedBy;
  final dynamic modifiedDate;
  final String? tokenId;
  final dynamic startLimit;
  final dynamic endLimit;
  final String? fullName;
  final dynamic isAccessible;
  final dynamic isApproved;
  final String? rejectReason;
  final dynamic loginMode;
  final List<dynamic> validationErrors;

  factory TaskEffortModel.fromJson(Map<String, dynamic> json){
    return TaskEffortModel(
      effortStatusId: json["EffortStatusID"],
      flag: json["Flag"],
      clientEmail: json["ClientEmail"],
      taskName: json["TaskName"],
      taskNumber: json["TaskNumber"],
      tempEffortsAdded: json["TempEffortsAdded"],
      tempAddedDate: json["TempAddedDate"],
      fyName: json["FYName"],
      serviceName: json["ServiceName"],
      parentTaskNumber: json["ParentTaskNumber"],
      effortmailtoclient: json["effortmailtoclient"],
      clientAlterNateEmail: json["ClientAlterNateEmail"],
      clientName: json["ClientName"],
      firmName: json["FirmName"],
      isBillable: json["IsBillable"],
      taskEffortId: json["TaskEffortID"],
      taskId: json["TaskID"],
      employeeId: json["EmployeeID"],
      actualEffortsHRs: json["ActualEffortsHRs"],
      actualEffortsMins: json["ActualEffortsMins"],
      effortDate: DateTime.tryParse(json["EffortDate"] ?? ""),
      notes: json["Notes"],
      addedBy: json["AddedBy"],
      addedDate: json["AddedDate"],
      modifiedBy: json["ModifiedBy"],
      modifiedDate: json["ModifiedDate"],
      tokenId: json["TokenID"],
      startLimit: json["StartLimit"],
      endLimit: json["EndLimit"],
      fullName: json["FullName"],
      isAccessible: json["IsAccessible"],
      isApproved: json["IsApproved"],
      rejectReason: json["RejectReason"],
      loginMode: json["LoginMode"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}
