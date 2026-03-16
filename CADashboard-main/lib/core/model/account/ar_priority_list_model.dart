class ArPriorityListModel {
  ArPriorityListModel({
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

  factory ArPriorityListModel.fromJson(Map<String, dynamic> json){
    return ArPriorityListModel(
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
