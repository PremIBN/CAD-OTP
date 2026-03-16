// ignore_for_file: file_names

class GetAllOrgTasksModel {
  GetAllOrgTasksModel({
    required this.taskEfforts,
    required this.taskReminderList,
    required this.taskNotes,
    required this.taskLogs,
    required this.assignedByEmpIDs,
    required this.displayEndDate,
    required this.displayStartDate,
    required this.link,
    required this.complianceName,
    required this.startDateMob,
    required this.endDateMob,
    required this.acknowledgename,
    required this.parentStartDate,
    required this.parentEndDate,
    required this.loginOrgId,
    required this.branchId,
    required this.departmentId,
    required this.branchName,
    required this.departmentName,
    required this.isShared,
    required this.assignMainTaskEmployeesToSubTasks,
    required this.assignMainTaskDatesToSubTasks,
    required this.isSharedClient,
    required this.currencyId,
    required this.isAssignedUser,
    required this.isSms,
    required this.isEmail,
    required this.alertId,
    required this.completionDate,
    required this.actualStartDate,
    required this.actualEndDate,
    required this.clientGroupId,
    required this.employeeEstimationCount,
    required this.oldStatusId,
    required this.isTaskOwner,
    required this.sequenceNo,
    required this.parentTaskNo,
    required this.taskIDs,
    required this.carryForwardFromFy,
    required this.copiedFromFy,
    required this.copiedFromFyName,
    required this.actualEffort,
    required this.estimatedEffort,
    required this.isDocumentAvailable,
    required this.invoiceDate,
    required this.srNo,
    required this.proformaInvoiceDate,
    required this.proformaInvoiceId,
    required this.proformaInvoiceNumber,
    required this.subTaskList,
    required this.employeeutilization,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.loginDetailId,
    required this.locationRequestStatus,
    required this.browserName,
    required this.udin,
    required this.ackNo,
    required this.mandateNo,
    required this.reviewerId,
    required this.orgGroupName,
    required this.employeeId,
    required this.monthId,
    required this.reviewerName,
    required this.reviewerIDs,
    required this.loginMode,
    required this.postponeDatesCount,
    required this.symbol,
    required this.compiledactualeffort,
    required this.compiledestimatedeffort,
    required this.encrpytedTaskId,
    required this.fullName,
    required this.complianceId,
    required this.type,
    required this.taskId,
    required this.parentTaskId,
    required this.taskNumber,
    required this.parentTaskNumber,
    required this.taskName,
    required this.serviceId,
    required this.serviceName,
    required this.clientOrgId,
    required this.clientName,
    required this.taskStatusId,
    required this.calculatedStatusId,
    required this.assignementTypeId,
    required this.estimatedEffortHrs,
    required this.estimatedEffortMin,
    required this.startDate,
    required this.endDate,
    required this.complianceDate,
    required this.isBillable,
    required this.billingAmount,
    required this.isInvoiced,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.templateTaskId,
    required this.assignedByEmpId,
    required this.assignedByEmpName,
    required this.orgId,
    required this.reminderBeforeDays,
    required this.completionPercent,
    required this.priorityId,
    required this.isComplianceTask,
    required this.financialYearId,
    required this.addedBy,
    required this.addedDate,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.tokenId,
    required this.startLimit,
    required this.endLimit,
    required this.assignedToEmpId,
    required this.assignedToEmpIDs,
    required this.calculatedStatus,
    required this.orgName,
    required this.taskStatus,
    required this.priority,
    required this.subTaskCount,
    required this.assignedToEmpName,
    required this.taskDocuments,
    required this.taskStatusList,
    required this.statusGroup,
    required this.taskTemplateId,
    required this.subTask,
    required this.inwardId,
    required this.loggedInByFullName,
    required this.financialYear,
    required this.financialYearForTask,
    required this.notes,
    required this.colorCode,
    required this.taskRecentNote,
    required this.isAccessible,
    required this.currency,
    required this.validationErrors,
  });

  final List<dynamic> taskEfforts;
  final List<dynamic> taskReminderList;
  final List<dynamic> taskNotes;
  final List<dynamic> taskLogs;
  final dynamic assignedByEmpIDs;
  final dynamic displayEndDate;
  final dynamic displayStartDate;
  final dynamic link;
  final dynamic complianceName;
  final dynamic startDateMob;
  final dynamic endDateMob;
  final dynamic acknowledgename;
  final dynamic parentStartDate;
  final dynamic parentEndDate;
  final dynamic loginOrgId;
  final dynamic branchId;
  final dynamic departmentId;
  final String? branchName;
  final String? departmentName;
  final dynamic isShared;
  final dynamic assignMainTaskEmployeesToSubTasks;
  final dynamic assignMainTaskDatesToSubTasks;
  final dynamic isSharedClient;
  final dynamic currencyId;
  final dynamic isAssignedUser;
  final dynamic isSms;
  final dynamic isEmail;
  final dynamic alertId;
  final dynamic completionDate;
  final dynamic actualStartDate;
  final dynamic actualEndDate;
  final dynamic clientGroupId;
  final dynamic employeeEstimationCount;
  final dynamic oldStatusId;
  final dynamic isTaskOwner;
  final dynamic sequenceNo;
  final dynamic parentTaskNo;
  final dynamic taskIDs;
  final String? carryForwardFromFy;
  final String? copiedFromFy;
  final String? copiedFromFyName;
  final String? actualEffort;
  final String? estimatedEffort;
  final String? isDocumentAvailable;
  final String? invoiceDate;
  final dynamic srNo;
  final String? proformaInvoiceDate;
  final dynamic proformaInvoiceId;
  final String? proformaInvoiceNumber;
  final dynamic subTaskList;
  final dynamic employeeutilization;
  final dynamic address;
  final dynamic latitude;
  final dynamic longitude;
  final dynamic loginDetailId;
  final dynamic locationRequestStatus;
  final dynamic browserName;
  final String? udin;
  final String? ackNo;
  final String? mandateNo;
  final dynamic reviewerId;
  final String? orgGroupName;
  final dynamic employeeId;
  final dynamic monthId;
  final String? reviewerName;
  final dynamic reviewerIDs;
  final dynamic loginMode;
  final dynamic postponeDatesCount;
  final String? symbol;
  final dynamic compiledactualeffort;
  final dynamic compiledestimatedeffort;
  final String? encrpytedTaskId;
  final String? fullName;
  final dynamic complianceId;
  final dynamic type;
  final dynamic taskId;
  final dynamic parentTaskId;
  final String? taskNumber;
  final String? parentTaskNumber;
  final String? taskName;
  final dynamic serviceId;
  final String? serviceName;
  final dynamic clientOrgId;
  final String? clientName;
  final dynamic taskStatusId;
  final dynamic calculatedStatusId;
  final dynamic assignementTypeId;
  final dynamic estimatedEffortHrs;
  final dynamic estimatedEffortMin;
  final DateTime? startDate;
  final DateTime? endDate;
  final dynamic complianceDate;
  final dynamic isBillable;
  final dynamic billingAmount;
  final dynamic isInvoiced;
  final dynamic invoiceId;
  final String? invoiceNumber;
  final dynamic templateTaskId;
  final dynamic assignedByEmpId;
  final String? assignedByEmpName;
  final dynamic orgId;
  final dynamic reminderBeforeDays;
  final dynamic completionPercent;
  final dynamic priorityId;
  final dynamic isComplianceTask;
  final dynamic financialYearId;
  final String? addedBy;
  final DateTime? addedDate;
  final String? modifiedBy;
  final DateTime? modifiedDate;
  final String? tokenId;
  final dynamic startLimit;
  final dynamic endLimit;
  final String? assignedToEmpId;
  final String? assignedToEmpIDs;
  final String? calculatedStatus;
  final String? orgName;
  final String? taskStatus;
  final String? priority;
  final dynamic subTaskCount;
  final String? assignedToEmpName;
  final dynamic taskDocuments;
  final List<dynamic> taskStatusList;
  final String? statusGroup;
  final dynamic taskTemplateId;
  final String? subTask;
  final dynamic inwardId;
  final String? loggedInByFullName;
  final String? financialYear;
  final String? financialYearForTask;
  final String? notes;
  final String? colorCode;
  final String? taskRecentNote;
  final String? isAccessible;
  final String? currency;
  final List<dynamic> validationErrors;

  factory GetAllOrgTasksModel.fromJson(Map<String, dynamic> json){
    return GetAllOrgTasksModel(
      taskEfforts: json["taskEfforts"] == null ? [] : List<dynamic>.from(json["taskEfforts"]!.map((x) => x)),
      taskReminderList: json["taskReminderList"] == null ? [] : List<dynamic>.from(json["taskReminderList"]!.map((x) => x)),
      taskNotes: json["taskNotes"] == null ? [] : List<dynamic>.from(json["taskNotes"]!.map((x) => x)),
      taskLogs: json["taskLogs"] == null ? [] : List<dynamic>.from(json["taskLogs"]!.map((x) => x)),
      assignedByEmpIDs: json["AssignedByEmpIDs"],
      displayEndDate: json["DisplayEndDate"],
      displayStartDate: json["DisplayStartDate"],
      link: json["Link"],
      complianceName: json["ComplianceName"],
      startDateMob: json["StartDate_Mob"],
      endDateMob: json["EndDate_Mob"],
      acknowledgename: json["Acknowledgename"],
      parentStartDate: json["ParentStartDate"],
      parentEndDate: json["ParentEndDate"],
      loginOrgId: json["LoginOrgID"],
      branchId: json["BranchID"],
      departmentId: json["DepartmentID"],
      branchName: json["BranchName"],
      departmentName: json["DepartmentName"],
      isShared: json["IsShared"],
      assignMainTaskEmployeesToSubTasks: json["AssignMainTaskEmployeesToSubTasks"],
      assignMainTaskDatesToSubTasks: json["AssignMainTaskDatesToSubTasks"],
      isSharedClient: json["IsSharedClient"],
      currencyId: json["CurrencyID"],
      isAssignedUser: json["IsAssignedUser"],
      isSms: json["IsSms"],
      isEmail: json["IsEmail"],
      alertId: json["AlertID"],
      completionDate: json["CompletionDate"],
      actualStartDate: json["ActualStartDate"],
      actualEndDate: json["ActualEndDate"],
      clientGroupId: json["ClientGroupId"],
      employeeEstimationCount: json["EmployeeEstimationCount"],
      oldStatusId: json["OldStatusID"],
      isTaskOwner: json["IsTaskOwner"],
      sequenceNo: json["SequenceNo"],
      parentTaskNo: json["ParentTaskNo"],
      taskIDs: json["TaskIDs"],
      carryForwardFromFy: json["CarryForwardFromFY"],
      copiedFromFy: json["CopiedFromFY"],
      copiedFromFyName: json["CopiedFromFYName"],
      actualEffort: json["Actual_Effort"],
      estimatedEffort: json["Estimated_Effort"],
      isDocumentAvailable: json["IsDocumentAvailable"],
      invoiceDate: json["InvoiceDate"],
      srNo: json["SRNo"],
      proformaInvoiceDate: json["ProformaInvoiceDate"],
      proformaInvoiceId: json["ProformaInvoiceID"],
      proformaInvoiceNumber: json["ProformaInvoiceNumber"],
      subTaskList: json["SubTaskList"],
      employeeutilization: json["employeeutilization"],
      address: json["Address"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      loginDetailId: json["LoginDetailID"],
      locationRequestStatus: json["LocationRequestStatus"],
      browserName: json["BrowserName"],
      udin: json["UDIN"],
      ackNo: json["ACKNo"],
      mandateNo: json["MandateNo"],
      reviewerId: json["ReviewerID"],
      orgGroupName: json["OrgGroupName"],
      employeeId: json["EmployeeID"],
      monthId: json["MonthID"],
      reviewerName: json["ReviewerName"],
      reviewerIDs: json["ReviewerIDs"],
      loginMode: json["LoginMode"],
      postponeDatesCount: json["PostponeDatesCount"],
      symbol: json["Symbol"],
      compiledactualeffort: json["compiledactualeffort"],
      compiledestimatedeffort: json["compiledestimatedeffort"],
      encrpytedTaskId: json["EncrpytedTaskID"],
      fullName: json["FullName"],
      complianceId: json["ComplianceID"],
      type: json["Type"],
      taskId: json["TaskID"],
      parentTaskId: json["ParentTaskId"],
      taskNumber: json["TaskNumber"],
      parentTaskNumber: json["ParentTaskNumber"],
      taskName: json["TaskName"],
      serviceId: json["ServiceID"],
      serviceName: json["ServiceName"],
      clientOrgId: json["ClientOrgID"],
      clientName: json["ClientName"],
      taskStatusId: json["TaskStatusID"],
      calculatedStatusId: json["CalculatedStatusID"],
      assignementTypeId: json["AssignementTypeID"],
      estimatedEffortHrs: json["EstimatedEffortHrs"],
      estimatedEffortMin: json["EstimatedEffortMin"],
      startDate: DateTime.tryParse(json["StartDate"] ?? ""),
      endDate: DateTime.tryParse(json["EndDate"] ?? ""),
      complianceDate: json["ComplianceDate"],
      isBillable: json["IsBillable"],
      billingAmount: json["BillingAmount"],
      isInvoiced: json["IsInvoiced"],
      invoiceId: json["InvoiceId"],
      invoiceNumber: json["InvoiceNumber"],
      templateTaskId: json["TemplateTaskID"],
      assignedByEmpId: json["AssignedByEmpID"],
      assignedByEmpName: json["AssignedByEmpName"],
      orgId: json["OrgID"],
      reminderBeforeDays: json["ReminderBeforeDays"],
      completionPercent: json["CompletionPercent"],
      priorityId: json["PriorityId"],
      isComplianceTask: json["IsComplianceTask"],
      financialYearId: json["FinancialYearID"],
      addedBy: json["AddedBy"],
      addedDate: DateTime.tryParse(json["AddedDate"] ?? ""),
      modifiedBy: json["ModifiedBy"],
      modifiedDate: DateTime.tryParse(json["ModifiedDate"] ?? ""),
      tokenId: json["TokenID"],
      startLimit: json["StartLimit"],
      endLimit: json["EndLimit"],
      assignedToEmpId: json["AssignedToEmpID"],
      assignedToEmpIDs: json["AssignedToEmpIDs"],
      calculatedStatus: json["CalculatedStatus"],
      orgName: json["OrgName"],
      taskStatus: json["TaskStatus"],
      priority: json["Priority"],
      subTaskCount: json["SubTaskCount"],
      assignedToEmpName: json["AssignedToEmpName"],
      taskDocuments: json["TaskDocuments"],
      taskStatusList: json["TaskStatusList"] == null ? [] : List<dynamic>.from(json["TaskStatusList"]!.map((x) => x)),
      statusGroup: json["StatusGroup"],
      taskTemplateId: json["TaskTemplateID"],
      subTask: json["SubTask"],
      inwardId: json["InwardID"],
      loggedInByFullName: json["LoggedInByFullName"],
      financialYear: json["FinancialYear"],
      financialYearForTask: json["FinancialYearForTask"],
      notes: json["Notes"],
      colorCode: json["ColorCode"],
      taskRecentNote: json["TaskRecentNote"],
      isAccessible: json["IsAccessible"],
      currency: json["Currency"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}
