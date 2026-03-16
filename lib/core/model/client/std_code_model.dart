class StdCodeModel {
  StdCodeModel({
    required this.stdCode,
    required this.codeValue,
    required this.codeId,
    required this.codeName,
    required this.codeGroup,
    required this.validationErrors,
  });

  final String? stdCode;
  final int? codeValue;
  final int? codeId;
  final String? codeName;
  final String? codeGroup;
  final List<dynamic> validationErrors;

  factory StdCodeModel.fromJson(Map<String, dynamic> json){
    return StdCodeModel(
      stdCode: json["STDCode"],
      codeValue: json["CodeValue"],
      codeId: json["CodeID"],
      codeName: json["CodeName"],
      codeGroup: json["CodeGroup"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
    "STDCode": stdCode,
    "CodeValue": codeValue,
    "CodeID": codeId,
    "CodeName": codeName,
    "CodeGroup": codeGroup,
    "ValidationErrors": validationErrors.map((x) => x).toList(),
  };

}
