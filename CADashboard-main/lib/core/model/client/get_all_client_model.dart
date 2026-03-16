class GetAllClientModel {
  GetAllClientModel({
    required this.records,
    required this.clientList,
    required this.validationErrors,
  });

  final int? records;
  final List<ClientList> clientList;
  final List<dynamic> validationErrors;

  factory GetAllClientModel.fromJson(Map<String, dynamic> json){
    return GetAllClientModel(
      records: json["Records"],
      clientList: json["ClientList"] == null ? [] : List<ClientList>.from(json["ClientList"]!.map((x) => ClientList.fromJson(x))),
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}

class ClientList {
  ClientList({
    required this.orgId,
    required this.type,
    required this.isActive,
    required this.lastLoginTime,
    required this.isLogin,
    required this.orgName,
    required this.clientManager,
    required this.fullName,
    required this.alternateEmail,
    required this.email,
    required this.mobile,
    required this.landline,
    required this.taskCompleted,
    required this.totalTask,
    required this.invoicePaid,
    required this.totalInvoice,
    required this.amountReceived,
    required this.totalAmount,
    required this.panNumber,
    required this.fileNumber,
    required this.groupName,
    required this.companyType,
    required this.branchId,
    required this.branchName,
    required this.clientType,
    required this.primaryMobile,
    required this.isDisabled,
    required this.referAndEarnId,
    required this.displayCategory,
    required this.currency,
    required this.validationErrors,
  });

  final int? orgId;
  final int? type;
  final int? isActive;
  final String? lastLoginTime;
  final int? isLogin;
  final String? orgName;
  final String? clientManager;
  final String? fullName;
  final String? alternateEmail;
  final String? email;
  final String? mobile;
  final String? landline;
  final int? taskCompleted;
  final int? totalTask;
  final int? invoicePaid;
  final int? totalInvoice;
  final int? amountReceived;
  final int? totalAmount;
  final String? panNumber;
  final String? fileNumber;
  final String? groupName;
  final String? companyType;
  final int? branchId;
  final String? branchName;
  final String? clientType;
  final String? primaryMobile;
  final int? isDisabled;
  final int? referAndEarnId;
  final String? displayCategory;
  final String? currency;
  final List<dynamic> validationErrors;

  factory ClientList.fromJson(Map<String, dynamic> json){
    return ClientList(
      orgId: json["OrgID"],
      type: json["Type"],
      isActive: json["IsActive"],
      lastLoginTime: json["LastLoginTime"],
      isLogin: json["IsLogin"],
      orgName: json["OrgName"],
      clientManager: json["ClientManager"],
      fullName: json["FullName"],
      alternateEmail: json["AlternateEmail"],
      email: json["Email"],
      mobile: json["Mobile"],
      landline: json["Landline"],
      taskCompleted: json["TaskCompleted"],
      totalTask: json["TotalTask"],
      invoicePaid: json["InvoicePaid"],
      totalInvoice: json["TotalInvoice"],
      amountReceived: json["AmountReceived"],
      totalAmount: json["TotalAmount"],
      panNumber: json["PanNumber"],
      fileNumber: json["FileNumber"],
      groupName: json["GroupName"],
      companyType: json["CompanyType"],
      branchId: json["BranchID"],
      branchName: json["BranchName"],
      clientType: json["ClientType"],
      primaryMobile: json["PrimaryMobile"],
      isDisabled: json["IsDisabled"],
      referAndEarnId: json["ReferAndEarnID"],
      displayCategory: json["DisplayCategory"],
      currency: json["Currency"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }
}
