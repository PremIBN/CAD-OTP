class TaskNoteModel {
  TaskNoteModel({
    required this.addedByUserId,
    required this.financialYearId,
    required this.taskId,
    required this.notes,
    required this.taskNotesId,
    required this.addedBy,
    required this.addedDate,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.tokenId,
    required this.validationErrors,
  });

  final int? addedByUserId;
  final int? financialYearId;
  final int? taskId;
  final String? notes;
  final int? taskNotesId;
  final String? addedBy;
  final dynamic addedDate;
  final String? modifiedBy;
  final dynamic modifiedDate;
  final String? tokenId;
  final List<dynamic> validationErrors;

  factory TaskNoteModel.fromJson(Map<String, dynamic> json){
    return TaskNoteModel(
      addedByUserId: json["AddedByUserID"],
      financialYearId: json["FinancialYearID"],
      taskId: json["TaskID"],
      notes: json["Notes"],
      taskNotesId: json["TaskNotesID"],
      addedBy: json["AddedBy"],
      addedDate: json["AddedDate"],
      modifiedBy: json["ModifiedBy"],
      modifiedDate: json["ModifiedDate"],
      tokenId: json["TokenID"],
      validationErrors: json["ValidationErrors"] == null ? [] : List<dynamic>.from(json["ValidationErrors"]!.map((x) => x)),
    );
  }

}
