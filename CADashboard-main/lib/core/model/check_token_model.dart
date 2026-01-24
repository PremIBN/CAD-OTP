class CheckTokenModel {
  CheckTokenModel({
    required this.message,
    required this.success,
    required this.statusCode,
    required this.validationErrors,
  });

  final String? message;
  final int? success;
  final int? statusCode;
  final List<dynamic> validationErrors;

  factory CheckTokenModel.fromJson(Map<String, dynamic> json){
    return CheckTokenModel(
      message: json["Message"],
      success: json["Success"],
      statusCode: json["StatusCode"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Success": success,
    "ValidationErrors": validationErrors.map((x) => x).toList(),
  };

}
