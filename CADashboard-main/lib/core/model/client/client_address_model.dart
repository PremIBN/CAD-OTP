class ClientAddressModel {
  ClientAddressModel({
    required this.addressTypeId,
    required this.addressType,
    required this.addressId,
    required this.addressLine1,
    required this.addressLine2,
    required this.cityId,
    required this.stateId,
    required this.countryId,
    required this.zip,
    required this.location,
    required this.landLineNo1,
    required this.landLineNo2,
    required this.faxNo1,
    required this.mobileNo1,
    required this.mobileNo2,
    required this.isActive,
    required this.isDeleted,
    required this.addedBy,
    required this.countryName,
    required this.cityName,
    required this.stateName,
    required this.addedDate,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.tokenId,
    required this.employeeId,
    required this.employeeAddressId,
    required this.orgId,
    required this.orgAddressId,
    required this.validationErrors,
  });

  final int? addressTypeId;
  final String? addressType;
  final int? addressId;
  final String? addressLine1;
  final String? addressLine2;
  final int? cityId;
  final int? stateId;
  final int? countryId;
  final String? zip;
  final String? location;
  final String? landLineNo1;
  final String? landLineNo2;
  final String? faxNo1;
  final String? mobileNo1;
  final String? mobileNo2;
  final int? isActive;
  final int? isDeleted;
  final int? addedBy;
  final String? countryName;
  final String? cityName;
  final String? stateName;
  final dynamic addedDate;
  final int? modifiedBy;
  final dynamic modifiedDate;
  final String? tokenId;
  final int? employeeId;
  final int? employeeAddressId;
  final int? orgId;
  final int? orgAddressId;
  final List<dynamic> validationErrors;

  factory ClientAddressModel.fromJson(Map<String, dynamic> json){
    return ClientAddressModel(
      addressTypeId: json["AddressTypeID"],
      addressType: json["AddressType"],
      addressId: json["AddressID"],
      addressLine1: json["AddressLine1"],
      addressLine2: json["AddressLine2"],
      cityId: json["CityID"],
      stateId: json["StateID"],
      countryId: json["CountryID"],
      zip: json["Zip"],
      location: json["Location"],
      landLineNo1: json["LandLineNo1"],
      landLineNo2: json["LandLineNo2"],
      faxNo1: json["FaxNo1"],
      mobileNo1: json["MobileNo1"],
      mobileNo2: json["MobileNo2"],
      isActive: json["IsActive"],
      isDeleted: json["IsDeleted"],
      addedBy: json["AddedBy"],
      countryName: json["CountryName"],
      cityName: json["CityName"],
      stateName: json["StateName"],
      addedDate: json["AddedDate"],
      modifiedBy: json["ModifiedBy"],
      modifiedDate: json["ModifiedDate"],
      tokenId: json["TokenID"],
      employeeId: json["EmployeeID"],
      employeeAddressId: json["EmployeeAddressID"],
      orgId: json["OrgID"],
      orgAddressId: json["OrgAddressID"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }
}
