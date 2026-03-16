class DocumentFileModel {
  DocumentFileModel({
    required this.documentId,
    required this.documentName,
    this.filePath,
    this.docFolderId,
    this.fileSize,
    this.modifiedDate,
    this.modifiedByName,
    this.isLocked,
    this.financialYearId,
  });

  final int documentId;
  final String documentName;
  final String? filePath;
  final int? docFolderId;
  final int? fileSize;
  final String? modifiedDate;
  final String? modifiedByName;
  final int? isLocked;
  /// Financial year ID for this document (as provided by backend; used for FY filtering in Document module).
  final int? financialYearId;

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final n = int.tryParse(v.toString());
    return n;
  }

  factory DocumentFileModel.fromJson(Map<String, dynamic> json) {
    return DocumentFileModel(
      documentId: _toInt(json["DocumentID"]),
      documentName: (json["DocumentName"]?.toString() ?? "").toString(),
      filePath: json["FilePath"]?.toString(),
      docFolderId: _toIntOrNull(json["DocFolderID"] ?? json["DocFolderId"]),
      fileSize: _toIntOrNull(json["FileSize"]),
      modifiedDate: json["ModifiedDate"]?.toString(),
      modifiedByName: json["ModifiedByName"]?.toString(),
      isLocked: _toIntOrNull(json["IsLocked"]),
      financialYearId: _toIntOrNull(json["FinancialYearID"]),
    );
  }
}
