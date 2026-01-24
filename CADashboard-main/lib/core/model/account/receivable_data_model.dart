class ReceivableDataModel {
  ReceivableDataModel({
    required this.columns,
    required this.data,
    required this.validationErrors,
  });

  final List<String> columns;
  final List<List<String>> data;
  final List<dynamic> validationErrors;

  factory ReceivableDataModel.fromJson(Map<String, dynamic> json){
    return ReceivableDataModel(
      columns: json["columns"] == null ? [] : List<String>.from(json["columns"]!.map((x) => x)),
      data: json["data"] == null ? [] : List<List<String>>.from(json["data"]!.map((x) => x == null ? [] : List<String>.from(x!.map((x) => x)))),
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}
