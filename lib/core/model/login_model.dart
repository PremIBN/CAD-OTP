class LoginModel {
  LoginModel({
    required this.serviceProviderOrgId,
    required this.serviceProviderOrgName,
    required this.ipAddress,
    required this.totalLoginLastMonth,
    required this.isInvoiceAssigned,
    required this.isPerformaInvoiceAssigned,
    required this.daysSinceRegistered,
    required this.employeeCount,
    required this.clientCount,
    required this.loginDetailId,
    required this.isOrgAdminUser,
    required this.isBackDatedActualEffortsRestricted,
    required this.restrictTillDays,
    required this.countryId,
    required this.showtaskotherdetails,
    required this.isMandateNoCompulsory,
    required this.success,
    required this.roleName,
    required this.redirectOldPath,
    required this.financialYearId,
    required this.designationId,
    required this.isDefaultRole,
    required this.orgLogoPath,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.profileImage,
    required this.password,
    required this.loginMode,
    required this.deviceId,
    required this.deviceName,
    required this.ip,
    required this.tokenId,
    required this.hintQuestion,
    required this.hintAns,
    required this.email,
    required this.alternateEmail,
    required this.mobile,
    required this.optInEmail,
    required this.optInMobile,
    required this.lastLoginFailedTIme,
    required this.lastLoginTime,
    required this.loginAttempt,
    required this.lastPwdChangeDate,
    required this.exchangeCode,
    required this.isActive,
    required this.isDeleted,
    required this.addedBy,
    required this.addedDate,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.orgId,
    required this.orgName,
    required this.orgTypeId,
    required this.orgLogoMetadata,
    required this.isSetupComplete,
    required this.currencyId,
    required this.timeZoneId,
    required this.languageId,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.userRoleId,
    required this.sessionDuration,
    required this.isOldCadUser,
    required this.setupStatus,
    required this.genderId,
    required this.playerId,
    required this.actualEndDate,
    required this.packageAmount,
    required this.orgCode,
    required this.validationErrors,
  });

  final dynamic serviceProviderOrgId;
  final String? serviceProviderOrgName;
  final String? ipAddress;
  final String? totalLoginLastMonth;
  final String? isInvoiceAssigned;
  final String? isPerformaInvoiceAssigned;
  final String? daysSinceRegistered;
  final dynamic employeeCount;
  final dynamic clientCount;
  final int? loginDetailId;
  final dynamic isOrgAdminUser;
  final dynamic isBackDatedActualEffortsRestricted;
  final dynamic restrictTillDays;
  final dynamic countryId;
  final dynamic showtaskotherdetails;
  final dynamic isMandateNoCompulsory;
  final dynamic success;
  final String? roleName;
  final String? redirectOldPath;
  final dynamic financialYearId;
  final dynamic designationId;
  final dynamic isDefaultRole;
  final String? orgLogoPath;
  final dynamic userId;
  final String? userName;
  final String? userImage;
  final dynamic profileImage;
  final String? password;
  final dynamic loginMode;
  final String? deviceId;
  final String? deviceName;
  final String? ip;
  final String? tokenId;
  final String? hintQuestion;
  final String? hintAns;
  final String? email;
  final String? alternateEmail;
  final String? mobile;
  final dynamic optInEmail;
  final dynamic optInMobile;
  final dynamic lastLoginFailedTIme;
  final DateTime? lastLoginTime;
  final dynamic loginAttempt;
  final dynamic lastPwdChangeDate;
  final String? exchangeCode;
  final dynamic isActive;
  final dynamic isDeleted;
  final dynamic addedBy;
  final dynamic addedDate;
  final dynamic modifiedBy;
  final dynamic modifiedDate;
  final dynamic orgId;
  final String? orgName;
  final dynamic orgTypeId;
  final String? orgLogoMetadata;
  final dynamic isSetupComplete;
  final dynamic currencyId;
  final dynamic timeZoneId;
  final dynamic languageId;
  final dynamic employeeId;
  final String? firstName;
  final String? lastName;
  final dynamic userRoleId;
  final dynamic sessionDuration;
  final dynamic isOldCadUser;
  final dynamic setupStatus;
  final dynamic genderId;
  final String? playerId;
  final DateTime? actualEndDate;
  final dynamic packageAmount;
  final String? orgCode;
  final List<dynamic> validationErrors;

  factory LoginModel.fromJson(Map<String, dynamic> json){
    return LoginModel(
      serviceProviderOrgId: json["ServiceProviderOrgID"],
      serviceProviderOrgName: json["ServiceProviderOrgName"],
      ipAddress: json["IPAddress"],
      totalLoginLastMonth: json["TotalLoginLastMonth"],
      isInvoiceAssigned: json["IsInvoiceAssigned"],
      isPerformaInvoiceAssigned: json["IsPerformaInvoiceAssigned"],
      daysSinceRegistered: json["DaysSinceRegistered"],
      employeeCount: json["EmployeeCount"],
      clientCount: json["ClientCount"],
      loginDetailId: json["LoginDetailID"],
      isOrgAdminUser: json["IsOrgAdminUser"],
      isBackDatedActualEffortsRestricted: json["IsBackDatedActualEffortsRestricted"],
      restrictTillDays: json["RestrictTillDays"],
      countryId: json["CountryID"],
      showtaskotherdetails: json["showtaskotherdetails"],
      isMandateNoCompulsory: json["IsMandateNoCompulsory"],
      success: json["Success"],
      roleName: json["RoleName"],
      redirectOldPath: json["RedirectOldPath"],
      financialYearId: json["FinancialYearID"],
      designationId: json["DesignationID"],
      isDefaultRole: json["IsDefaultRole"],
      orgLogoPath: json["OrgLogoPath"],
      userId: json["UserID"],
      userName: json["UserName"],
      userImage: json["UserImage"],
      profileImage: json["ProfileImage"],
      password: json["Password"],
      loginMode: json["LoginMode"],
      deviceId: json["DeviceID"],
      deviceName: json["DeviceName"],
      ip: json["IP"],
      tokenId: json["TokenID"],
      hintQuestion: json["HintQuestion"],
      hintAns: json["HintAns"],
      email: json["Email"],
      alternateEmail: json["AlternateEmail"],
      mobile: json["Mobile"],
      optInEmail: json["OptInEmail"],
      optInMobile: json["OptInMobile"],
      lastLoginFailedTIme: json["LastLoginFailedTIme"],
      lastLoginTime: DateTime.tryParse(json["LastLoginTime"] ?? ""),
      loginAttempt: json["LoginAttempt"],
      lastPwdChangeDate: json["LastPwdChangeDate"],
      exchangeCode: json["ExchangeCode"],
      isActive: json["IsActive"],
      isDeleted: json["IsDeleted"],
      addedBy: json["AddedBy"],
      addedDate: json["AddedDate"],
      modifiedBy: json["ModifiedBy"],
      modifiedDate: json["ModifiedDate"],
      orgId: json["OrgID"],
      orgName: json["OrgName"],
      orgTypeId: json["OrgTypeID"],
      orgLogoMetadata: json["OrgLogoMetadata"],
      isSetupComplete: json["IsSetupComplete"],
      currencyId: json["CurrencyID"],
      timeZoneId: json["TimeZoneID"],
      languageId: json["LanguageID"],
      employeeId: json["EmployeeID"],
      firstName: json["FirstName"],
      lastName: json["LastName"],
      userRoleId: json["UserRoleID"],
      sessionDuration: json["SessionDuration"],
      isOldCadUser: json["IsOldCADUser"],
      setupStatus: json["SetupStatus"],
      genderId: json["GenderID"],
      playerId: json["PlayerID"],
      actualEndDate: DateTime.tryParse(json["ActualEndDate"] ?? ""),
      packageAmount: json["PackageAmount"],
      orgCode: json["OrgCode"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }
}
