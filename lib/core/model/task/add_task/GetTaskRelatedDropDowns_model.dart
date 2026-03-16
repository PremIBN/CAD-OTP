// ignore_for_file: file_names

class GetTaskRelatedDropDownsModel {
  GetTaskRelatedDropDownsModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.employeeList,
    required this.serviceList,
    required this.taskStatusList,
    required this.clientList,
    required this.validationErrors,
  });

  final int? success;
  final int? statusCode;
  final String? message;
  final List<ClientListElement> employeeList;
  final List<ClientListElement> serviceList;
  final List<TaskStatusList> taskStatusList;
  final List<ClientListElement> clientList;
  final List<dynamic> validationErrors;

  factory GetTaskRelatedDropDownsModel.fromJson(Map<String, dynamic> json){
    return GetTaskRelatedDropDownsModel(
      success: json["Success"],
      statusCode: json["StatusCode"],
      message: json["Message"],
      employeeList: json["EmployeeList"] == null ? [] : List<ClientListElement>.from(json["EmployeeList"]!.map((x) => ClientListElement.fromJson(x))),
      serviceList: json["ServiceList"] == null ? [] : List<ClientListElement>.from(json["ServiceList"]!.map((x) => ClientListElement.fromJson(x))),
      taskStatusList: json["TaskStatusList"] == null ? [] : List<TaskStatusList>.from(json["TaskStatusList"]!.map((x) => TaskStatusList.fromJson(x))),
      clientList: json["ClientList"] == null ? [] : List<ClientListElement>.from(json["ClientList"]!.map((x) => ClientListElement.fromJson(x))),
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}

class ClientListElement {
  ClientListElement({
    required this.displayName,
    required this.displayValue,
    required this.codeValue,
    required this.validationErrors,
  });

  final String? displayName;
  final dynamic displayValue;
  final dynamic codeValue;
  final List<dynamic> validationErrors;

  factory ClientListElement.fromJson(Map<String, dynamic> json){
    return ClientListElement(
      displayName: json["DisplayName"],
      displayValue: json["DisplayValue"],
      codeValue: json["CodeValue"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}

class TaskStatusList {
  TaskStatusList({
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

  factory TaskStatusList.fromJson(Map<String, dynamic> json){
    return TaskStatusList(
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
