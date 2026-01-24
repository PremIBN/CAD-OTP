// ignore_for_file: file_names

class FinancialYearModel {
  FinancialYearModel({
    required this.codeDescription,
    required this.displayName,
    required this.lookUpId,
    required this.displayValue,
    required this.tokenId,
    required this.codeValue,
    required this.validationErrors,
  });

  final String? codeDescription;
  final String? displayName;
  final dynamic lookUpId;
  final dynamic displayValue;
  final String? tokenId;
  final dynamic codeValue;
  final List<dynamic> validationErrors;

  factory FinancialYearModel.fromJson(Map<String, dynamic> json){
    return FinancialYearModel(
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
