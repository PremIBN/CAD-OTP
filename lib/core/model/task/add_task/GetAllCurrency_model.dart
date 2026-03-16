// ignore_for_file: file_names

class GetAllCurrencyModel {
  GetAllCurrencyModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.stdCode,
    required this.codeValue,
    required this.codeId,
    required this.codeName,
    required this.codeGroup,
    required this.validationErrors,
  });

  final dynamic success;
  final dynamic statusCode;
  final String? message;
  final dynamic stdCode;
  final dynamic codeValue;
  final dynamic codeId;
  final String? codeName;
  final String? codeGroup;
  final List<dynamic> validationErrors;

  factory GetAllCurrencyModel.fromJson(Map<String, dynamic> json){
    return GetAllCurrencyModel(
      success: json["Success"],
      statusCode: json["StatusCode"],
      message: json["Message"],
      stdCode: json["STDCode"],
      codeValue: json["CodeValue"],
      codeId: json["CodeID"],
      codeName: json["CodeName"],
      codeGroup: json["CodeGroup"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}
