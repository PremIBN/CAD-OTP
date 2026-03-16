// ignore_for_file: file_names

class GetTaskStatusCountModel {
  GetTaskStatusCountModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.assignedTaskCount,
    required this.closedTaskCount,
    required this.completedCount,
    required this.dueSoonTaskCount,
    required this.dueTodayTaskCount,
    required this.needApprovalTaskCount,
    required this.notStartedYet,
    required this.pastDueTaskCount,
    required this.workInProgressCount,
    required this.pendingFromClientTaskCount,
    required this.invoicedTaskCount,
    required this.tokenId,
    required this.financialYearId,
    required this.assignedToEmpId,
    required this.clientId,
    required this.assignedTaskId,
    required this.closedTaskId,
    required this.completedId,
    required this.dueSoonTaskId,
    required this.dueTodayTaskId,
    required this.needApprovalTaskId,
    required this.notStartedYetId,
    required this.pastDueTaskId,
    required this.workInProgressId,
    required this.pendingFromClientTaskId,
    required this.invoicedTaskId,
    required this.assignedTaskName,
    required this.closedTaskName,
    required this.completedName,
    required this.dueSoonTaskName,
    required this.dueTodayTaskName,
    required this.needApprovalTaskName,
    required this.notStartedYetName,
    required this.pastDueTaskName,
    required this.workInProgressName,
    required this.pendingFromClientTaskName,
    required this.invoicedTaskName,
    required this.periodFrom,
    required this.periodTo,
    required this.type,
    required this.validationErrors,
  });

  final int? success;
  final int? statusCode;
  final String? message;
  final int? assignedTaskCount;
  final int? closedTaskCount;
  final int? completedCount;
  final int? dueSoonTaskCount;
  final int? dueTodayTaskCount;
  final int? needApprovalTaskCount;
  final int? notStartedYet;
  final int? pastDueTaskCount;
  final int? workInProgressCount;
  final int? pendingFromClientTaskCount;
  final int? invoicedTaskCount;
  final String? tokenId;
  final int? financialYearId;
  final String? assignedToEmpId;
  final int? clientId;
  final int? assignedTaskId;
  final int? closedTaskId;
  final int? completedId;
  final int? dueSoonTaskId;
  final int? dueTodayTaskId;
  final int? needApprovalTaskId;
  final int? notStartedYetId;
  final int? pastDueTaskId;
  final int? workInProgressId;
  final int? pendingFromClientTaskId;
  final int? invoicedTaskId;
  final String? assignedTaskName;
  final String? closedTaskName;
  final String? completedName;
  final String? dueSoonTaskName;
  final String? dueTodayTaskName;
  final String? needApprovalTaskName;
  final String? notStartedYetName;
  final String? pastDueTaskName;
  final String? workInProgressName;
  final String? pendingFromClientTaskName;
  final String? invoicedTaskName;
  final dynamic periodFrom;
  final dynamic periodTo;
  final int? type;
  final List<dynamic> validationErrors;

  factory GetTaskStatusCountModel.fromJson(Map<String, dynamic> json){
    return GetTaskStatusCountModel(
      success: json["Success"],
      statusCode: json["StatusCode"],
      message: json["Message"],
      assignedTaskCount: json["AssignedTaskCount"],
      closedTaskCount: json["ClosedTaskCount"],
      completedCount: json["CompletedCount"],
      dueSoonTaskCount: json["DueSoonTaskCount"],
      dueTodayTaskCount: json["DueTodayTaskCount"],
      needApprovalTaskCount: json["NeedApprovalTaskCount"],
      notStartedYet: json["NotStartedYet"],
      pastDueTaskCount: json["PastDueTaskCount"],
      workInProgressCount: json["WorkInProgressCount"],
      pendingFromClientTaskCount: json["PendingFromClientTaskCount"],
      invoicedTaskCount: json["InvoicedTaskCount"],
      tokenId: json["TokenID"],
      financialYearId: json["FinancialYearID"],
      assignedToEmpId: json["AssignedToEmpID"],
      clientId: json["ClientID"],
      assignedTaskId: json["AssignedTaskID"],
      closedTaskId: json["ClosedTaskID"],
      completedId: json["CompletedID"],
      dueSoonTaskId: json["DueSoonTaskID"],
      dueTodayTaskId: json["DueTodayTaskID"],
      needApprovalTaskId: json["NeedApprovalTaskID"],
      notStartedYetId: json["NotStartedYetID"],
      pastDueTaskId: json["PastDueTaskID"],
      workInProgressId: json["WorkInProgressID"],
      pendingFromClientTaskId: json["PendingFromClientTaskID"],
      invoicedTaskId: json["InvoicedTaskID"],
      assignedTaskName: json["AssignedTaskName"],
      closedTaskName: json["ClosedTaskName"],
      completedName: json["CompletedName"],
      dueSoonTaskName: json["DueSoonTaskName"],
      dueTodayTaskName: json["DueTodayTaskName"],
      needApprovalTaskName: json["NeedApprovalTaskName"],
      notStartedYetName: json["NotStartedYetName"],
      pastDueTaskName: json["PastDueTaskName"],
      workInProgressName: json["WorkInProgressName"],
      pendingFromClientTaskName: json["PendingFromClientTaskName"],
      invoicedTaskName: json["InvoicedTaskName"],
      periodFrom: json["PeriodFrom"],
      periodTo: json["PeriodTo"],
      type: json["Type"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}
