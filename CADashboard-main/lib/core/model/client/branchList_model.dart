// ignore_for_file: file_names

class BranchTypeModel {
  BranchTypeModel({
    required this.tokenId,
    required this.branchId,
    required this.branchName,
    required this.validationErrors,
  });

  final String? tokenId;
  final int? branchId;
  final String? branchName;
  final List<dynamic> validationErrors;

  factory BranchTypeModel.fromJson(Map<String, dynamic> json){
    return BranchTypeModel(
      tokenId: json["TokenID"],
      branchId: json["BranchID"],
      branchName: json["BranchName"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }
}
