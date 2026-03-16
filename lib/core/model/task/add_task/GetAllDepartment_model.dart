// ignore_for_file: file_names

class GetAllDepartmentsModel {
  GetAllDepartmentsModel({
    required this.departmentId,
    required this.orgId,
    required this.departmentName,
    required this.description,
    required this.addedBy,
    required this.addedDate,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.tokenId,
    required this.branchId,
    required this.displayValue,
    required this.displayName,
    required this.validationErrors,
  });

  final dynamic departmentId;
  final dynamic orgId;
  final String? departmentName;
  final String? description;
  final String? addedBy;
  final dynamic addedDate;
  final String? modifiedBy;
  final dynamic modifiedDate;
  final String? tokenId;
  final dynamic branchId;
  final dynamic displayValue;
  final String? displayName;
  final List<dynamic> validationErrors;

  factory GetAllDepartmentsModel.fromJson(Map<String, dynamic> json){
    return GetAllDepartmentsModel(
      departmentId: json["DepartmentID"],
      orgId: json["OrgID"],
      departmentName: json["DepartmentName"],
      description: json["Description"],
      addedBy: json["AddedBy"],
      addedDate: json["AddedDate"],
      modifiedBy: json["ModifiedBy"],
      modifiedDate: json["ModifiedDate"],
      tokenId: json["TokenID"],
      branchId: json["BranchId"],
      displayValue: json["DisplayValue"],
      displayName: json["DisplayName"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}
