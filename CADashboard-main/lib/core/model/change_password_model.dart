class ChangePasswordModel {
  ChangePasswordModel({
    required this.message,
    required this.success,
    required this.newPassword,
    required this.oldPassword,
    required this.tokenId,
    required this.fullName,
    required this.userName,
    required this.orgName,
    required this.validationErrors,
  });

  final int? success;
  final String? message;
  final String? newPassword;
  final String? oldPassword;
  final String? tokenId;
  final String? fullName;
  final String? userName;
  final String? orgName;
  final List<dynamic> validationErrors;

  factory ChangePasswordModel.fromJson(Map<String, dynamic> json){
    return ChangePasswordModel(
      success: json["Success"],
      message: json["Message"],
      newPassword: json["NewPassword"],
      oldPassword: json["OldPassword"],
      tokenId: json["TokenID"],
      fullName: json["FullName"],
      userName: json["UserName"],
      orgName: json["OrgName"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}
