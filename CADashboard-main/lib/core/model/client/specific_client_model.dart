int? _readJsonInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return int.tryParse(s);
}

String? _readJsonString(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

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
    final validationRaw = json["ValidationErrors"];
    final validationList = validationRaw == null
        ? <dynamic>[]
        : validationRaw is List
            ? List<dynamic>.from(validationRaw)
            : <dynamic>[];

    return SpecificClientModel(
      sortData: json["SortData"],
      searchText: json["SearchText"],
      loggedOrgId: _readJsonInt(json["LoggedOrgID"]),
      oldOrgName: json["OldOrgName"],
      effortmailtoclient: _readJsonInt(json["effortmailtoclient"]),
      branch: _readJsonInt(json["Branch"]),
      clientTypeId: _readJsonInt(json["ClientTypeID"]),
      cc: json["CC"],
      primaryMobile: _readJsonString(json["PrimaryMobile"]),
      clientManagerEmailForDoc: _readJsonString(json["ClientManagerEmailForDoc"]),
      clientOrgIDs: json["ClientOrgIDs"],
      isDisabled: _readJsonInt(json["IsDisabled"]),
      gstNo: json["GSTNo"],
      groupName: _readJsonString(json["GroupName"]),
      orgGroupId: _readJsonInt(json["OrgGroupID"]),
      creatorOrgId: _readJsonInt(json["CreatorOrgID"]),
      isLogin: _readJsonInt(json["IsLogin"]),
      orgId: _readJsonInt(json["OrgID"]),
      orgName: _readJsonString(json["OrgName"]),
      orgTypeId: _readJsonInt(json["OrgTypeID"]),
      orgLogoMetadata: _readJsonString(json["OrgLogoMetadata"]),
      isSetupComplete: _readJsonInt(json["IsSetupComplete"]),
      currencyId: _readJsonInt(json["CurrencyID"]),
      timeZoneId: _readJsonInt(json["TimeZoneID"]),
      languageId: _readJsonInt(json["LanguageID"]),
      isActive: _readJsonInt(json["IsActive"]),
      isDeleted: _readJsonInt(json["IsDeleted"]),
      addedBy: _readJsonString(json["AddedBy"]),
      addedDate: DateTime.tryParse('${json["AddedDate"] ?? ""}'),
      modifiedBy: _readJsonString(json["ModifiedBy"]),
      modifiedDate: DateTime.tryParse('${json["ModifiedDate"] ?? ""}'),
      tokenId: _readJsonString(json["TokenID"]),
      fileNumber: _readJsonString(json["FileNumber"]),
      relationTypeId: _readJsonInt(json["RelationTypeID"]),
      firstName: _readJsonString(json["FirstName"]),
      lastName: _readJsonString(json["LastName"]),
      email: _readJsonString(json["Email"]),
      userRoleId: _readJsonInt(json["UserRoleID"]),
      alternateEmail: _readJsonString(json["AlternateEmail"]),
      genderId: _readJsonInt(json["GenderID"]),
      dateOfBirth: DateTime.tryParse('${json["DateOfBirth"] ?? ""}'),
      mobile: _readJsonString(json["Mobile"]),
      notes: _readJsonString(json["Notes"]),
      userName: _readJsonString(json["UserName"]),
      password: _readJsonString(json["Password"]),
      optInEmail: _readJsonInt(json["OptInEmail"]),
      optInMobile: _readJsonInt(json["OptInMobile"]),
      startLimit: _readJsonInt(json["StartLimit"]),
      endLimit: _readJsonInt(json["EndLimit"]),
      employeeId: _readJsonInt(json["EmployeeID"]),
      fullName: _readJsonString(json["FullName"]),
      totalAmount: _readJsonInt(json["TotalAmount"]),
      amountReceived: _readJsonInt(json["AmountReceived"]),
      totalInvoice: _readJsonInt(json["TotalInvoice"]),
      clientManager: _readJsonString(json["ClientManager"]),
      totalTask: _readJsonInt(json["TotalTask"]),
      invoicePaid: _readJsonInt(json["InvoicePaid"]),
      taskCompleted: _readJsonInt(json["TaskCompleted"]),
      firmTypeId: _readJsonInt(json["FirmTypeID"]),
      industryTypeId: _readJsonInt(json["IndustryTypeID"]),
      clientOrgId: _readJsonInt(json["ClientOrgID"]),
      sort: _readJsonString(json["Sort"]),
      countryId: _readJsonInt(json["CountryID"]),
      stateId: _readJsonInt(json["StateID"]),
      cityId: _readJsonInt(json["CityID"]),
      referredBy: _readJsonString(json["ReferredBy"]),
      link: _readJsonString(json["Link"]),
      emailBody: _readJsonString(json["EmailBody"]),
      lastLoginTime: _readJsonString(json["LastLoginTime"]),
      orgCode: _readJsonInt(json["OrgCode"]),
      acknowledgename: _readJsonString(json["Acknowledgename"]),
      broadCastDocuments: json["BroadCastDocuments"],
      message: _readJsonString(json["Message"]),
      panNumber: _readJsonString(json["PanNumber"]),
      orgAttributeId: _readJsonInt(json["OrgAttributeID"]),
      validationErrors: validationList,
      clientJoiningDate: DateTime.tryParse('${json["ClientJoiningDate"] ?? ""}'),
      clientSupplyType: _readJsonInt(json["ClientSupplyType"]),
      stdCode: _readJsonString(json["STDCode"]),
    );
  }
}
