class SpecificClientModel {
  SpecificClientModel({
    required this.sortData,
    required this.searchText,
    required this.loggedOrgId,
    required this.oldOrgName,
    required this.effortmailtoclient,
    required this.branch,
    required this.clientTypeId,
    required this.cc,
    required this.primaryMobile,
    required this.clientManagerEmailForDoc,
    required this.clientOrgIDs,
    required this.isDisabled,
    required this.gstNo,
    required this.groupName,
    required this.orgGroupId,
    required this.creatorOrgId,
    required this.isLogin,
    required this.orgId,
    required this.orgName,
    required this.orgTypeId,
    required this.orgLogoMetadata,
    required this.isSetupComplete,
    required this.currencyId,
    required this.timeZoneId,
    required this.languageId,
    required this.isActive,
    required this.isDeleted,
    required this.addedBy,
    required this.addedDate,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.tokenId,
    required this.fileNumber,
    required this.relationTypeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userRoleId,
    required this.alternateEmail,
    required this.genderId,
    required this.dateOfBirth,
    required this.mobile,
    required this.notes,
    required this.userName,
    required this.password,
    required this.optInEmail,
    required this.optInMobile,
    required this.startLimit,
    required this.endLimit,
    required this.employeeId,
    required this.fullName,
    required this.totalAmount,
    required this.amountReceived,
    required this.totalInvoice,
    required this.clientManager,
    required this.totalTask,
    required this.invoicePaid,
    required this.taskCompleted,
    required this.firmTypeId,
    required this.industryTypeId,
    required this.clientOrgId,
    required this.sort,
    required this.countryId,
    required this.stateId,
    required this.cityId,
    required this.referredBy,
    required this.link,
    required this.emailBody,
    required this.lastLoginTime,
    required this.orgCode,
    required this.acknowledgename,
    required this.broadCastDocuments,
    required this.message,
    required this.panNumber,
    required this.orgAttributeId,
    required this.validationErrors,
    this.clientSupplyType,
    this.clientJoiningDate,
    this.stdCode,
  });

  final dynamic sortData;
  final dynamic searchText;
  final int? loggedOrgId;
  final dynamic oldOrgName;
  final int? effortmailtoclient;
  final int? branch;
  final int? clientTypeId;
  final dynamic cc;
  final String? primaryMobile;
  final String? clientManagerEmailForDoc;
  final dynamic clientOrgIDs;
  final int? isDisabled;
  final dynamic gstNo;
  final String? groupName;
  final int? orgGroupId;
  final int? creatorOrgId;
  final int? isLogin;
  final int? orgId;
  final String? orgName;
  final int? orgTypeId;
  final String? orgLogoMetadata;
  final int? isSetupComplete;
  final int? currencyId;
  final int? timeZoneId;
  final int? languageId;
  final int? isActive;
  final int? isDeleted;
  final String? addedBy;
  final DateTime? addedDate;
  final String? modifiedBy;
  final DateTime? modifiedDate;
  final String? tokenId;
  final String? fileNumber;
  final int? relationTypeId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final int? userRoleId;
  final String? alternateEmail;
  final int? genderId;
  final DateTime? dateOfBirth;
  final String? mobile;
  final String? notes;
  final String? userName;
  final String? password;
  final int? optInEmail;
  final int? optInMobile;
  final int? startLimit;
  final int? endLimit;
  final int? employeeId;
  final String? fullName;
  final int? totalAmount;
  final int? amountReceived;
  final int? totalInvoice;
  final String? clientManager;
  final int? totalTask;
  final int? invoicePaid;
  final int? taskCompleted;
  final int? firmTypeId;
  final int? industryTypeId;
  final int? clientOrgId;
  final String? sort;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final String? referredBy;
  final String? link;
  final String? emailBody;
  final String? lastLoginTime;
  final int? orgCode;
  final String? acknowledgename;
  final dynamic broadCastDocuments;
  final String? message;
  final String? panNumber;
  final int? orgAttributeId;
  final List<dynamic> validationErrors;
  final int? clientSupplyType;
  final DateTime? clientJoiningDate;
  final String? stdCode;

  factory SpecificClientModel.fromJson(Map<String, dynamic> json){
    return SpecificClientModel(
      sortData: json["SortData"],
      searchText: json["SearchText"],
      loggedOrgId: json["LoggedOrgID"],
      oldOrgName: json["OldOrgName"],
      effortmailtoclient: json["effortmailtoclient"],
      branch: json["Branch"],
      clientTypeId: json["ClientTypeID"],
      cc: json["CC"],
      primaryMobile: json["PrimaryMobile"],
      clientManagerEmailForDoc: json["ClientManagerEmailForDoc"],
      clientOrgIDs: json["ClientOrgIDs"],
      isDisabled: json["IsDisabled"],
      gstNo: json["GSTNo"],
      groupName: json["GroupName"],
      orgGroupId: json["OrgGroupID"],
      creatorOrgId: json["CreatorOrgID"],
      isLogin: json["IsLogin"],
      orgId: json["OrgID"],
      orgName: json["OrgName"],
      orgTypeId: json["OrgTypeID"],
      orgLogoMetadata: json["OrgLogoMetadata"],
      isSetupComplete: json["IsSetupComplete"],
      currencyId: json["CurrencyID"],
      timeZoneId: json["TimeZoneID"],
      languageId: json["LanguageID"],
      isActive: json["IsActive"],
      isDeleted: json["IsDeleted"],
      addedBy: json["AddedBy"],
      addedDate: DateTime.tryParse(json["AddedDate"] ?? ""),
      modifiedBy: json["ModifiedBy"],
      modifiedDate: DateTime.tryParse(json["ModifiedDate"] ?? ""),
      tokenId: json["TokenID"],
      fileNumber: json["FileNumber"],
      relationTypeId: json["RelationTypeID"],
      firstName: json["FirstName"],
      lastName: json["LastName"],
      email: json["Email"],
      userRoleId: json["UserRoleID"],
      alternateEmail: json["AlternateEmail"],
      genderId: json["GenderID"],
      dateOfBirth: DateTime.tryParse(json["DateOfBirth"] ?? ""),
      mobile: json["Mobile"],
      notes: json["Notes"],
      userName: json["UserName"],
      password: json["Password"],
      optInEmail: json["OptInEmail"],
      optInMobile: json["OptInMobile"],
      startLimit: json["StartLimit"],
      endLimit: json["EndLimit"],
      employeeId: json["EmployeeID"],
      fullName: json["FullName"],
      totalAmount: json["TotalAmount"],
      amountReceived: json["AmountReceived"],
      totalInvoice: json["TotalInvoice"],
      clientManager: json["ClientManager"],
      totalTask: json["TotalTask"],
      invoicePaid: json["InvoicePaid"],
      taskCompleted: json["TaskCompleted"],
      firmTypeId: json["FirmTypeID"],
      industryTypeId: json["IndustryTypeID"],
      clientOrgId: json["ClientOrgID"],
      sort: json["Sort"],
      countryId: json["CountryID"],
      stateId: json["StateID"],
      cityId: json["CityID"],
      referredBy: json["ReferredBy"],
      link: json["Link"],
      emailBody: json["EmailBody"],
      lastLoginTime: json["LastLoginTime"],
      orgCode: json["OrgCode"],
      acknowledgename: json["Acknowledgename"],
      broadCastDocuments: json["BroadCastDocuments"],
      message: json["Message"],
      panNumber: json["PanNumber"],
      orgAttributeId: json["OrgAttributeID"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
      clientJoiningDate: DateTime.tryParse(json["ClientJoiningDate"] ?? ""),
      clientSupplyType: json["ClientSupplyType"],
      stdCode: json["STDCode"],
    );
  }
}
