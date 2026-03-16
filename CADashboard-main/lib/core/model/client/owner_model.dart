class OwnerModel {
  OwnerModel({
    required this.contactPersonId,
    required this.clientOrgId,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.mobile2,
    required this.landline1,
    required this.landline2,
    required this.email,
    required this.tokenId,
    required this.description,
    required this.addedBy,
    required this.modifiedBy,
    required this.addedDate,
    required this.modifiedDate,
    required this.validationErrors,
  });

  final int? contactPersonId;
  final int? clientOrgId;
  final String? fullName;
  final dynamic firstName;
  final dynamic lastName;
  final String? mobile;
  final String? mobile2;
  final String? landline1;
  final String? landline2;
  final String? email;
  final dynamic tokenId;
  final String? description;
  final dynamic addedBy;
  final dynamic modifiedBy;
  final dynamic addedDate;
  final dynamic modifiedDate;
  final List<dynamic> validationErrors;

  factory OwnerModel.fromJson(Map<String, dynamic> json){
    return OwnerModel(
      contactPersonId: json["ContactPersonID"],
      clientOrgId: json["ClientOrgID"],
      fullName: json["FullName"],
      firstName: json["FirstName"],
      lastName: json["LastName"],
      mobile: json["Mobile"],
      mobile2: json["Mobile2"],
      landline1: json["Landline1"],
      landline2: json["Landline2"],
      email: json["Email"],
      tokenId: json["TokenID"],
      description: json["Description"],
      addedBy: json["AddedBy"],
      modifiedBy: json["ModifiedBy"],
      addedDate: json["AddedDate"],
      modifiedDate: json["ModifiedDate"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }
}
