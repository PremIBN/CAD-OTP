import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/model/document/document_file_model.dart';
import 'package:cadashboard/core/model/document/document_folder_model.dart';
import 'package:cadashboard/core/model/task/add_task/FinancialYear_model.dart';
import 'package:cadashboard/core/model/task/add_task/GetTaskRelatedDropDowns_model.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/main.dart' show navigatorKey;
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/core/utils/document_file_saver.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart' show Permission, PermissionActions, PermissionStatusGetters, openAppSettings;
import 'package:shared_preferences/shared_preferences.dart';

enum DocumentViewSize { large, medium, small }

class DocumentVM extends BaseModel {
  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);

  DocumentViewSize viewSize = DocumentViewSize.medium;

  void setViewSize(DocumentViewSize size) {
    if (viewSize == size) return;
    viewSize = size;
    notifyListeners();
  }

  /// Root-level folders only (parentFolderId==0 from API). Never flattened—exact backend structure.
  List<DocumentFolderModel> rootFolders = [];

  /// Navigation stack; empty = at root. One folder per level—no merged content.
  final List<DocumentFolderModel> _stack = [];

  DocumentFolderModel? get currentFolder =>
      _stack.isEmpty ? null : _stack.last;

  /// Sub-folders: at root = main folders only (as on website); inside a folder = that folder's FolderList from API only.
  List<DocumentFolderModel> get currentSubfolders =>
      _stack.isEmpty ? rootFolders : (currentFolder?.folderList ?? []);

  /// Files: only from API (FolderDocuments for current folder). Root has none. Matches website—no extra files or folder data.
  List<DocumentFileModel> get currentFiles =>
      _stack.isEmpty ? [] : (currentFolder?.folderDocuments ?? []);

  /// IDs of items currently being moved (optimistic UI: hide from list until sync completes).
  final Set<int> _optimisticallyMovedDocumentIds = {};
  final Set<int> _optimisticallyMovedFolderIds = {};

  /// True while a move request is in progress (for loading indicator).
  final ValueNotifier<bool> isMoveInProgress = ValueNotifier(false);

  /// Download progress 0.0–1.0 when downloading folder; null when idle. UI can show progress bar.
  final ValueNotifier<double?> downloadProgress = ValueNotifier<double?>(null);
  /// Human-readable label e.g. "Downloading 3/10 files" while folder download is in progress.
  final ValueNotifier<String?> downloadProgressLabel = ValueNotifier<String?>(null);

  /// Document list filter: client org ID (selected client only; '0' = default/all). Normalized to integer string for API.
  String filterClientOrgId = '0';
  /// Document list filter: financial year ID (null = no filter).
  String? filterFinancialYearId;
  /// Client list for filter dropdown (loaded on demand).
  List<ClientListElement> documentFilterClientList = [];
  /// Financial year list for filter dropdown (loaded on demand).
  List<FinancialYearModel> documentFilterFyList = [];

  /// Subfolders to display: exact backend structure only. Root = main folders (parentFolderId==0). Inside folder = direct children only (parentFolderId match). No extra or merged folders.
  List<DocumentFolderModel> get displaySubfolders {
    var list = currentSubfolders
        .where((f) => !_optimisticallyMovedFolderIds.contains(f.docFolderId));
    if (_stack.isNotEmpty && currentFolder != null) {
      final parentId = currentFolder!.docFolderId;
      list = list.where((f) => f.parentFolderId == parentId);
    }
    return list.toList();
  }

  /// Files to display: backend FolderDocuments for the current folder,
  /// filtered by selected/default financial year (like Task module). If no FY
  /// filter is set, all files for this folder are shown.
  List<DocumentFileModel> get displayFiles {
    var list = currentFiles
        .where((f) => !_optimisticallyMovedDocumentIds.contains(f.documentId));
    if (filterFinancialYearId != null && filterFinancialYearId!.isNotEmpty) {
      final fyId = int.tryParse(filterFinancialYearId!);
      if (fyId != null) {
        list = list.where((f) => f.financialYearId == fyId);
      }
    }
    return list.toList();
  }

  /// All folders (root + descendants) for move-target picker.
  List<DocumentFolderModel> get allFoldersForMove {
    final List<DocumentFolderModel> out = [];
    for (final f in rootFolders) {
      out.add(f);
      out.addAll(f.allSubfolders);
    }
    return out;
  }

  /// When moving folder [folderId], exclude it and its descendants from valid targets.
  Set<int> getFolderIdsExcludedFromMoveTarget(int? folderId) {
    if (folderId == null) return {};
    final folder = _findFolderById(rootFolders, folderId);
    if (folder == null) return {folderId};
    final ids = <int>{folder.docFolderId};
    for (final f in folder.allSubfolders) {
      ids.add(f.docFolderId);
    }
    return ids;
  }

  static DocumentFolderModel? _findFolderById(
    List<DocumentFolderModel> list,
    int folderId,
  ) {
    for (final f in list) {
      if (f.docFolderId == folderId) return f;
      final inChild = _findFolderById(f.folderList, folderId);
      if (inChild != null) return inChild;
    }
    return null;
  }

  bool get canGoBack => _stack.isNotEmpty;

  String get currentTitle =>
      currentFolder?.folderName ?? '';

  /// [restoreFolderId] if set, after loading re-opens that folder so user stays in place.
  /// [silent] when true skips full-screen loading (e.g. after move sync).
  /// Returns a Future that completes when the folder list has been loaded or failed.
  Future<void> loadFolders(BuildContext context, {int? restoreFolderId, bool silent = false}) async {
    final completer = Completer<void>();
    if (!silent) {
      viewLoader.value = ViewState.loading;
      notifyListeners();
    }

    // Ensure default financial year (same as Task module) is applied by default.
    await _ensureDefaultFinancialYear();

    final clientOrgIdForApi = _normalizeClientOrgIdForApi(filterClientOrgId);
    documentRepo.getFolderList(
      clientOrgID: clientOrgIdForApi,
      financialYearID: filterFinancialYearId,
      success: (list) {
        // Only main (root-level) folders at start—same as website. Subfolders shown when user opens a folder.
        rootFolders = list.where((f) => f.parentFolderId == 0).toList();
        _stack.clear();
        if (restoreFolderId != null && restoreFolderId != 0) {
          final path = _findFolderPath(rootFolders, restoreFolderId);
          if (path.isNotEmpty) _stack.addAll(path);
        }
        _optimisticallyMovedDocumentIds.clear();
        _optimisticallyMovedFolderIds.clear();
        viewLoader.value = ViewState.success;
        notifyListeners();
        if (!completer.isCompleted) completer.complete();
      },
      failed: (message) {
        if (!silent && context.mounted) {
          CommonFunction.showSnackBar(
              context: context, isError: true, message: message);
        }
        viewLoader.value = ViewState.failed;
        notifyListeners();
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  /// Loads client and financial year lists for the filter dialog. "Select Client" sheet shows "Internal" first, then individual clients.
  void loadDocumentFilterOptions(BuildContext context) {
    // If we've already loaded both client and FY lists, avoid re-fetching to
    // prevent repeated spinners and make the filter UI feel instant.
    if (documentFilterClientList.isNotEmpty &&
        documentFilterFyList.isNotEmpty) {
      return;
    }
    dropDownRepo.dropdown(
      successResponse: (response) {
        documentFilterClientList = [
          ClientListElement(
            displayName: 'Internal',
            displayValue: 0,
            codeValue: 2,
            validationErrors: [],
          ),
          ...response.clientList,
        ];
        financialYearRepo.getFinancialYear(
          success: (fyResponse) {
            documentFilterFyList = fyResponse;
            notifyListeners();
          },
          failed: (message) {
            documentFilterFyList = [];
            notifyListeners();
          },
        );
      },
      failedResponse: (message, code) {
        if (context.mounted) {
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
        }
        documentFilterClientList = [];
        documentFilterFyList = [];
        notifyListeners();
      },
    );
  }

  /// Reads the default FinancialYearID from preferences (set at login) and applies it
  /// as the document FY filter the first time we load, mirroring the Task module.
  Future<void> _ensureDefaultFinancialYear() async {
    if (filterFinancialYearId != null && filterFinancialYearId!.isNotEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final fy = prefs.getString(PreferenceHelper.financialYearID);
      if (fy != null && fy.isNotEmpty) {
        filterFinancialYearId = fy;
      }
    } catch (_) {
      // Ignore errors; document filtering will behave as before if prefs are unavailable.
    }
  }

  /// Clears Client and Financial Year filters and notifies listeners.
  void clearDocumentFilters() {
    filterClientOrgId = '0';
    filterFinancialYearId = null;
    notifyListeners();
  }

  /// True if any document list filter is applied (client other than default, or FY).
  bool get hasActiveDocumentFilters =>
      filterClientOrgId != '0' ||
      (filterFinancialYearId != null && filterFinancialYearId!.isNotEmpty);

  /// Returns client org ID as integer string for GetFolderList API ('0' or e.g. '5'). Avoids '5.0' which some backends ignore.
  static String _normalizeClientOrgIdForApi(String value) {
    if (value.isEmpty || value == '0') return '0';
    final parsed = int.tryParse(value.split('.').first.trim());
    return parsed == null || parsed < 0 ? '0' : parsed.toString();
  }

  /// Path from root to folder with [folderId] (including the folder). Empty if not found.
  static List<DocumentFolderModel> _findFolderPath(
    List<DocumentFolderModel> roots,
    int folderId,
  ) {
    for (final f in roots) {
      if (f.docFolderId == folderId) return [f];
      final inChild = _findFolderPath(f.folderList, folderId);
      if (inChild.isNotEmpty) return [f, ...inChild];
    }
    return [];
  }

  void pushFolder(DocumentFolderModel folder) {
    _stack.add(folder);
    notifyListeners();
  }

  void popFolder() {
    if (_stack.isNotEmpty) {
      _stack.removeLast();
      notifyListeners();
    }
  }

  Future<void> getDocumentURL(
    BuildContext context, {
    required int documentId,
    required void Function(String url, [String? token]) onSuccess,
  }) async {
    documentRepo.getDocumentURL(
      documentId: documentId,
      success: onSuccess,
      failed: (message) {
        final ctx = context.mounted ? context : navigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          CommonFunction.showSnackBar(context: ctx, isError: true, message: message);
        }
      },
    );
  }

  /// Recursively collect (documentId, relativePath) for all files under [folder] with [pathPrefix].
  static List<({int documentId, String relativePath})> _collectFolderFiles(
    DocumentFolderModel folder,
    String pathPrefix,
  ) {
    final prefix = pathPrefix.isEmpty
        ? _sanitizePathSegment(folder.folderName.isEmpty ? 'Folder' : folder.folderName)
        : '$pathPrefix/${_sanitizePathSegment(folder.folderName.isEmpty ? 'Folder' : folder.folderName)}';
    final List<({int documentId, String relativePath})> out = [];
    for (final file in folder.folderDocuments) {
      final name = file.documentName.trim().isEmpty ? 'document_${file.documentId}' : file.documentName;
      out.add((documentId: file.documentId, relativePath: '$prefix/${_sanitizePathSegment(name)}'));
    }
    for (final sub in folder.folderList) {
      out.addAll(_collectFolderFiles(sub, prefix));
    }
    return out;
  }

  static String _sanitizePathSegment(String s) {
    return s.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Requests storage permission on Android when applicable (API < 33). Never blocks download:
  /// files are always saved to app-accessible storage. On Android 13+ (API 33+) storage
  /// permission is deprecated; download proceeds without requesting. Shows clear guidance if denied.
  Future<void> _requestStoragePermissionAndGuide(BuildContext context) async {
    if (!Platform.isAndroid) return;
    int sdkInt = 0;
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      sdkInt = androidInfo.version.sdkInt;
    } catch (_) {}
    // Android 13+ (API 33): Permission.storage is deprecated and always denied. App saves to
    // app storage only, so no runtime permission needed. Skip request to avoid confusing the user.
    if (sdkInt >= 33) return;
    final status = await Permission.storage.status;
    if (status.isGranted || status.isLimited) return;
    final result = await Permission.storage.request();
    if (result.isGranted || result.isLimited) return;
    if (!context.mounted) return;
    if (result.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.orange.shade800,
          content: const Text(
            'Storage permission was denied. Files are saved to app storage. To allow saving to Downloads, enable Storage in Settings.',
            style: TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'Open Settings',
            textColor: Colors.white,
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    } else {
      CommonFunction.showSnackBar(
        context: context,
        isError: false,
        message: 'Storage permission denied. Files will be saved to app storage.',
      );
    }
  }

  /// Loads folder and all subfolders' contents from API so download has full file list. Falls back to in-memory tree and still recurses into subfolders.
  Future<DocumentFolderModel> _loadFolderTreeForDownload(DocumentFolderModel folder) async {
    final completer = Completer<DocumentFolderModel>();
    documentRepo.getFolderContents(
      folderID: folder.docFolderId,
      clientOrgID: _normalizeClientOrgIdForApi(filterClientOrgId),
      financialYearID: filterFinancialYearId,
      success: (loaded) async {
        final loadedSubs = <DocumentFolderModel>[];
        for (final sub in loaded.folderList) {
          loadedSubs.add(await _loadFolderTreeForDownload(sub));
        }
        if (!completer.isCompleted) {
          completer.complete(DocumentFolderModel(
            docFolderId: loaded.docFolderId,
            folderName: loaded.folderName.isNotEmpty ? loaded.folderName : folder.folderName,
            parentFolderId: loaded.parentFolderId,
            folderPath: loaded.folderPath,
            folderDocuments: loaded.folderDocuments,
            folderList: loadedSubs,
            defaultFolderType: loaded.defaultFolderType,
          ));
        }
      },
      failed: (_) async {
        if (completer.isCompleted) return;
        final loadedSubs = <DocumentFolderModel>[];
        for (final sub in folder.folderList) {
          loadedSubs.add(await _loadFolderTreeForDownload(sub));
        }
        if (!completer.isCompleted) {
          completer.complete(DocumentFolderModel(
            docFolderId: folder.docFolderId,
            folderName: folder.folderName,
            parentFolderId: folder.parentFolderId,
            folderPath: folder.folderPath,
            folderDocuments: folder.folderDocuments,
            folderList: loadedSubs,
            defaultFolderType: folder.defaultFolderType,
          ));
        }
      },
    );
    return completer.future;
  }

  /// Download entire folder to device (mobile/desktop only). Maintains folder structure; shows progress.
  /// Recursively loads folder contents from API so all files and subfolders are downloaded.
  Future<void> downloadFolder(
    BuildContext context,
    DocumentFolderModel folder,
  ) async {
    if (kIsWeb) {
      CommonFunction.showSnackBar(context: context, isError: true, message: 'Folder download is not available on web.');
      return;
    }
    await _requestStoragePermissionAndGuide(context);
    if (!context.mounted) return;
    downloadProgressLabel.value = 'Loading folder…';
    notifyListeners();
    final loadedFolder = await _loadFolderTreeForDownload(folder);
    final files = _collectFolderFiles(loadedFolder, '');
    downloadProgressLabel.value = null;
    notifyListeners();
    if (files.isEmpty) {
      CommonFunction.showSnackBar(context: context, isError: false, message: 'Folder is empty.');
      return;
    }
    downloadProgress.value = 0;
    downloadProgressLabel.value = 'Downloading 0/${files.length} files';
    notifyListeners();
    var done = 0;
    var failed = 0;
    for (final entry in files) {
      if (!context.mounted) break;
      downloadProgressLabel.value = 'Downloading ${done + failed + 1}/${files.length} files';
      notifyListeners();
      final completer = Completer<Uint8List?>();
      documentRepo.downloadDocument(
        documentId: entry.documentId,
        success: (bytes) => completer.complete(bytes),
        failed: (_) => completer.complete(null),
      );
      final bytes = await completer.future;
      if (bytes != null && bytes.isNotEmpty) {
        final path = await saveDocumentBytesToPath(bytes, entry.relativePath);
        if (path != null && path.isNotEmpty) {
          done++;
        } else {
          failed++;
        }
      } else {
        failed++;
      }
      downloadProgress.value = (done + failed) / files.length;
      notifyListeners();
    }
    downloadProgress.value = null;
    downloadProgressLabel.value = null;
    notifyListeners();
    if (!context.mounted) return;
    if (failed == files.length) {
      CommonFunction.showSnackBar(context: context, isError: true, message: 'Download failed');
    } else if (failed > 0) {
      CommonFunction.showSnackBar(
        context: context,
        isError: false,
        message: 'Downloaded $done of ${files.length} files',
      );
    } else {
      final basePath = await getDocumentsBasePath();
      CommonFunction.showSnackBar(
        context: context,
        isError: false,
        message: basePath.isNotEmpty
            ? 'Downloaded to: $basePath'
            : 'Downloaded to CADashboard folder',
      );
    }
  }

  /// Relative path from download root to current folder (e.g. "FolderA" or "FolderA/FolderB"). Empty when at root. Matches paths used by folder download.
  String get currentFolderRelativePath {
    if (_stack.isEmpty) return '';
    return _stack
        .map((f) => _sanitizePathSegment(f.folderName.isEmpty ? 'Folder' : f.folderName))
        .join('/');
  }

  /// Returns the local file path if a document with [fileName] is already on device; null otherwise. Uses current folder path so files saved during folder download are found.
  Future<String?> getLocalPathIfExists(String fileName) async =>
      getLocalDocumentPathIfExists(fileName, relativePathPrefix: currentFolderRelativePath.isEmpty ? null : currentFolderRelativePath);

  /// Fetches document bytes for in-app preview (same auth as download). Use for data-URL display when view URL returns blank.
  void getDocumentBytes(
    BuildContext context, {
    required int documentId,
    required void Function(Uint8List bytes) onSuccess,
    required void Function(String message) onFailed,
  }) {
    documentRepo.downloadDocument(
      documentId: documentId,
      success: onSuccess,
      failed: onFailed,
    );
  }

  /// Download file to device (mobile/desktop) or open URL (web). Preserves [fileName] and format; shows progress and success.
  Future<void> downloadDocument(
    BuildContext context, {
    required int documentId,
    required String fileName,
  }) async {
    if (kIsWeb) {
      getDocumentURL(context, documentId: documentId, onSuccess: (_, [__]) {
        // Caller should launch URL for web; VM only fetches URL here
      });
      return;
    }
    await _requestStoragePermissionAndGuide(context);
    final displayName = fileName.trim().isEmpty ? 'document' : fileName;
    downloadProgress.value = 0;
    downloadProgressLabel.value = 'Downloading $displayName…';
    notifyListeners();

    documentRepo.downloadDocument(
      documentId: documentId,
      success: (bytes) async {
        final path = await saveDocumentBytes(bytes, fileName);
        downloadProgress.value = path != null && path.isNotEmpty ? 1 : null;
        downloadProgressLabel.value = path != null && path.isNotEmpty ? 'Downloaded' : null;
        notifyListeners();
        if (!context.mounted) return;
        if (path != null && path.isNotEmpty) {
          CommonFunction.showSnackBar(
            context: context,
            isError: false,
            message: 'Saved: $displayName\n$path',
          );
        } else {
          CommonFunction.showSnackBar(
            context: context,
            isError: true,
            message: 'Could not save file',
          );
        }
        downloadProgress.value = null;
        downloadProgressLabel.value = null;
        notifyListeners();
      },
      failed: (message) {
        downloadProgress.value = null;
        downloadProgressLabel.value = null;
        notifyListeners();
        if (context.mounted) {
          CommonFunction.showSnackBar(
            context: context,
            isError: true,
            message: message,
          );
        }
      },
    );
  }

  /// Lock document so it cannot be edited, moved, or deleted (permissions-based). Refreshes list on success.
  Future<void> lockDocument(
    BuildContext context, {
    required int documentId,
  }) async {
    documentRepo.lockDocument(
      documentId: documentId,
      success: () {
        if (context.mounted) {
          CommonFunction.showSnackBar(
            context: context,
            isError: false,
            message: 'Document locked',
          );
          final restoreId = currentFolder?.docFolderId;
          loadFolders(
            context,
            restoreFolderId: restoreId != null && restoreId != 0 ? restoreId : null,
            silent: true,
          );
        }
      },
      failed: (message) {
        if (context.mounted) {
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
        }
      },
    );
  }

  /// Unlock document to allow editing, moving, or deletion again. Refreshes list on success.
  Future<void> unlockDocument(
    BuildContext context, {
    required int documentId,
  }) async {
    documentRepo.unlockDocument(
      documentId: documentId,
      success: () {
        if (context.mounted) {
          CommonFunction.showSnackBar(
            context: context,
            isError: false,
            message: 'Document unlocked',
          );
          final restoreId = currentFolder?.docFolderId;
          loadFolders(
            context,
            restoreFolderId: restoreId != null && restoreId != 0 ? restoreId : null,
            silent: true,
          );
        }
      },
      failed: (message) {
        if (context.mounted) {
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
        }
      },
    );
  }

  /// Un-share document to revoke client access. Refreshes list on success.
  Future<void> unshareDocument(
    BuildContext context, {
    required int documentId,
  }) async {
    documentRepo.unshareDocument(
      documentId: documentId,
      success: () {
        if (context.mounted) {
          CommonFunction.showSnackBar(
            context: context,
            isError: false,
            message: 'Client access revoked',
          );
          final restoreId = currentFolder?.docFolderId;
          loadFolders(
            context,
            restoreFolderId: restoreId != null && restoreId != 0 ? restoreId : null,
            silent: true,
          );
        }
      },
      failed: (message) {
        if (context.mounted) {
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
        }
      },
    );
  }

  /// Create a new folder under [parentFolderId]. Use 0 for root. Refreshes list on success.
  Future<void> createFolder(
    BuildContext context, {
    required int parentFolderId,
    required String folderName,
  }) async {
    final name = folderName.trim();
    if (name.isEmpty) {
      CommonFunction.showSnackBar(context: context, isError: true, message: 'Enter a folder name');
      return;
    }
    documentRepo.checkFolderNameExists(
      folderName: name,
      parentFolderId: parentFolderId,
      success: (existing) {
        if (existing.isNotEmpty) {
          CommonFunction.showSnackBar(
            context: context,
            isError: true,
            message: 'A folder with this name already exists',
          );
          return;
        }
        documentRepo.addFolder(
          docFolderId: 0,
          folderName: name,
          parentFolderId: parentFolderId,
          success: () {
            CommonFunction.showSnackBar(
              context: context,
              isError: false,
              message: 'Created',
            );
            loadFolders(context, restoreFolderId: parentFolderId != 0 ? parentFolderId : null);
          },
          failed: (message) {
            CommonFunction.showSnackBar(context: context, isError: true, message: message);
          },
        );
      },
      failed: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
      },
    );
  }

  /// Rename folder [folderId] to [newName] under same [parentFolderId]. Refreshes list on success.
  Future<void> renameFolder(
    BuildContext context, {
    required int folderId,
    required String newName,
    required int parentFolderId,
  }) async {
    final name = newName.trim();
    if (name.isEmpty) {
      CommonFunction.showSnackBar(context: context, isError: true, message: 'Enter a folder name');
      return;
    }
    documentRepo.checkFolderNameExists(
      folderName: name,
      parentFolderId: parentFolderId,
      success: (existing) {
        final otherWithSameName = existing.any((f) => f.docFolderId != folderId);
        if (otherWithSameName) {
          CommonFunction.showSnackBar(
            context: context,
            isError: true,
            message: 'A folder with this name already exists',
          );
          return;
        }
        documentRepo.addFolder(
          docFolderId: folderId,
          folderName: name,
          parentFolderId: parentFolderId,
          success: () {
            CommonFunction.showSnackBar(
              context: context,
              isError: false,
              message: 'Renamed',
            );
            loadFolders(context, restoreFolderId: folderId);
          },
          failed: (message) {
            CommonFunction.showSnackBar(context: context, isError: true, message: message);
          },
        );
      },
      failed: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
      },
    );
  }

  /// Move a document (file) to [targetFolderId]. Updates UI immediately (optimistic), then syncs with backend.
  Future<void> moveDocument(
    BuildContext context, {
    required int documentId,
    required int targetFolderId,
  }) async {
    _optimisticallyMovedDocumentIds.add(documentId);
    isMoveInProgress.value = true;
    notifyListeners();

    if (context.mounted) {
      CommonFunction.showSnackBar(
        context: context,
        isError: false,
        message: 'Moving…',
      );
    }

    documentRepo.moveDocument(
      documentId: documentId,
      targetFolderId: targetFolderId,
      success: () {
        _optimisticallyMovedDocumentIds.remove(documentId);
        isMoveInProgress.value = false;
        notifyListeners();
        if (context.mounted) {
          CommonFunction.showSnackBar(
            context: context,
            isError: false,
            message: 'Moved',
          );
          final restoreId = currentFolder?.docFolderId;
          loadFolders(
            context,
            restoreFolderId: restoreId != null && restoreId != 0 ? restoreId : null,
            silent: true,
          );
        }
      },
      failed: (message) {
        _optimisticallyMovedDocumentIds.remove(documentId);
        isMoveInProgress.value = false;
        notifyListeners();
        if (context.mounted) {
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
          final restoreId = currentFolder?.docFolderId;
          loadFolders(
            context,
            restoreFolderId: restoreId != null && restoreId != 0 ? restoreId : null,
            silent: true,
          );
        }
      },
    );
  }

  /// Move a folder to [targetFolderId] (new parent). Updates UI immediately (optimistic), then syncs with backend.
  Future<void> moveFolder(
    BuildContext context, {
    required int folderId,
    required String folderName,
    required int targetFolderId,
  }) async {
    _optimisticallyMovedFolderIds.add(folderId);
    isMoveInProgress.value = true;
    notifyListeners();

    if (context.mounted) {
      CommonFunction.showSnackBar(
        context: context,
        isError: false,
        message: 'Moving…',
      );
    }

    documentRepo.moveFolder(
      folderId: folderId,
      folderName: folderName,
      targetFolderId: targetFolderId,
      success: () {
        _optimisticallyMovedFolderIds.remove(folderId);
        isMoveInProgress.value = false;
        notifyListeners();
        if (context.mounted) {
          CommonFunction.showSnackBar(
            context: context,
            isError: false,
            message: 'Moved',
          );
          final restoreId = currentFolder?.docFolderId;
          loadFolders(
            context,
            restoreFolderId: restoreId != null && restoreId != 0 ? restoreId : null,
            silent: true,
          );
        }
      },
      failed: (message) {
        _optimisticallyMovedFolderIds.remove(folderId);
        isMoveInProgress.value = false;
        notifyListeners();
        if (context.mounted) {
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
          final restoreId = currentFolder?.docFolderId;
          loadFolders(
            context,
            restoreFolderId: restoreId != null && restoreId != 0 ? restoreId : null,
            silent: true,
          );
        }
      },
    );
  }

  /// Checks whether the server has a document upload endpoint available.
  /// See BACKEND_DOCUMENT_UPLOAD_SPEC.md for what the server must implement.
  Future<bool> checkDocumentUploadAvailable() async =>
      documentRepo.checkDocumentUploadAvailable();

  /// Upload files to [folderId]. Each entry is (fileName, bytes). Refreshes list on success.
  Future<void> uploadFiles(
    BuildContext context, {
    required int folderId,
    required List<MapEntry<String, Uint8List>> files,
  }) async {
    if (files.isEmpty) return;
    if (context.mounted) {
      CommonFunction.showSnackBar(
        context: context,

        isError: false,
        message: 'Uploading…',
      );
    }
    var done = 0;
    var failedCount = 0;
    String? lastError;
    for (final entry in files) {
      final name = entry.key;
      final bytes = entry.value;
      final clientIdForApi = _normalizeClientOrgIdForApi(filterClientOrgId);
      final fyId = filterFinancialYearId;
      documentRepo.UploadDocument(
        docFolderId: folderId,
        clientOrgId: clientIdForApi,
        financialYearId: fyId,
        fileName: name,
        fileBytes: bytes,
        success: () {
          done++;
          if (done + failedCount == files.length && context.mounted) {
            if (failedCount > 0) {
              CommonFunction.showSnackBar(
                context: context,
                isError: true,
                message: lastError ?? 'Some files failed to upload',
              );
            } else {
              final msg = files.length == 1 ? 'Uploaded successfully' : 'Uploaded ${files.length} files';
              CommonFunction.showSnackBar(
                context: context,
                isError: false,
                message: msg,
              );
            }
            final restoreId = currentFolder?.docFolderId;
            loadFolders(
              context,
              restoreFolderId: restoreId != null && restoreId != 0 ? restoreId : null,
              silent: true,
            );
          }
        },
        failed: (message) {
          lastError = message;
          failedCount++;
          if (done + failedCount == files.length && context.mounted) {
            CommonFunction.showSnackBar(
              context: context,
              isError: true,
              message: lastError ?? 'Upload failed',
            );
            final restoreId = currentFolder?.docFolderId;
            loadFolders(
              context,
              restoreFolderId: restoreId != null && restoreId != 0 ? restoreId : null,
              silent: true,
            );
          }
        },
      );
    }
  }
}
