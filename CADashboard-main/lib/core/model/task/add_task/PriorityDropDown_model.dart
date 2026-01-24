// ignore_for_file: file_names

class PriorityDropDownModel {
  PriorityDropDownModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.codeDescription,
    required this.displayName,
    required this.lookUpId,
    required this.displayValue,
    required this.tokenId,
    required this.codeValue,
    required this.validationErrors,
  });

  final int? success;
  final int? statusCode;
  final String? message;
  final String? codeDescription;
  final String? displayName;
  final int? lookUpId;
  final int? displayValue;
  final String? tokenId;
  final dynamic codeValue;
  final List<dynamic> validationErrors;

  factory PriorityDropDownModel.fromJson(Map<String, dynamic> json){
    return PriorityDropDownModel(
      success: json["Success"],
      statusCode: json["StatusCode"],
      message: json["Message"],
      codeDescription: json["CodeDescription"],
      displayName: json["DisplayName"],
      lookUpId: json["LookUpID"],
      displayValue: json["DisplayValue"],
      tokenId: json["TokenID"],
      codeValue: json["CodeValue"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}
