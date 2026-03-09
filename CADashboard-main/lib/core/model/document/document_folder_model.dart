import 'package:cadashboard/core/model/document/document_file_model.dart';

class DocumentFolderModel {
  DocumentFolderModel({
    required this.docFolderId,
    required this.folderName,
    this.parentFolderId = 0,
    this.folderPath,
    this.folderDocuments = const [],
    this.folderList = const [],
    this.defaultFolderType,
  });

  final int docFolderId;
  final String folderName;
  final int parentFolderId;
  final String? folderPath;
  final List<DocumentFileModel> folderDocuments;
  final List<DocumentFolderModel> folderList;
  final int? defaultFolderType;

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory DocumentFolderModel.fromJson(Map<String, dynamic> json) {
    List<DocumentFileModel> docs = [];
    if (json["FolderDocuments"] != null && json["FolderDocuments"] is List) {
      final list = json["FolderDocuments"] as List;
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          docs.add(DocumentFileModel.fromJson(e));
        } else if (e is Map) {
          docs.add(DocumentFileModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    List<DocumentFolderModel> subFolders = [];
    if (json["FolderList"] != null && json["FolderList"] is List) {
      final list = json["FolderList"] as List;
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          subFolders.add(DocumentFolderModel.fromJson(e));
        } else if (e is Map) {
          subFolders.add(DocumentFolderModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return DocumentFolderModel(
      docFolderId: _toInt(json["DocFolderID"] ?? json["DocFolderId"]),
      folderName: (json["FolderName"]?.toString() ?? "").toString(),
      parentFolderId: _toInt(json["ParentFolderId"] ?? json["ParentFolderID"]),
      folderPath: json["FolderPath"]?.toString(),
      folderDocuments: docs,
      folderList: subFolders,
      defaultFolderType: json["DefaultFolderType"] != null ? _toInt(json["DefaultFolderType"]) : null,
    );
  }

  /// Flatten hierarchy for navigation: all descendants (subfolders recursively).
  List<DocumentFolderModel> get allSubfolders {
    List<DocumentFolderModel> out = [];
    for (var f in folderList) {
      out.add(f);
      out.addAll(f.allSubfolders);
    }
    return out;
  }
}
