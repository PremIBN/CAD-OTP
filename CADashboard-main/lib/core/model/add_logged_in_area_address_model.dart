class AddLoggedInAreaAddress {
  AddLoggedInAreaAddress({
    required this.success,
    required this.message,
  });

  final int? success;
  final String? message;

  factory AddLoggedInAreaAddress.fromJson(Map<String, dynamic> json){
    return AddLoggedInAreaAddress(
      success: json["Success"],
      message: json["Message"],
    );
  }

  Map<String, dynamic> toJson() => {
    "Success": success,
    "Message": message,
  };

}
