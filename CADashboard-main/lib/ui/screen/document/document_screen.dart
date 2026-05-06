import 'dart:convert';
import 'dart:async';
import 'dart:io' show File, Platform;
import 'dart:typed_data';

import 'package:cadashboard/core/View_Model/document/document_vm.dart';
import 'package:cadashboard/core/common/common_loader.dart';
import 'package:cadashboard/core/common/empty_data.dart';
import 'package:cadashboard/core/model/document/document_file_model.dart';
import 'package:cadashboard/core/model/document/document_folder_model.dart';
import 'package:cadashboard/core/model/task/add_task/GetTaskRelatedDropDowns_model.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/ui/screen/webview_screen.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';
import 'package:cadashboard/main.dart' show navigatorKey;
import 'package:cadashboard/core/repository/menu_repository.dart';
import 'package:screenshot_guard/screenshot_guard.dart';

/// Supported file extensions for document upload (device file manager). Case-insensitive.
const Set<String> _supportedDocumentExtensions = {
  'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
  'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp',
  'txt', 'csv', 'rtf', 'odt', 'ods', 'odp',
};

/// Human-readable list for user messages.
const String _supportedFormatsMessage = 'PDF, Word, Excel, PowerPoint, images, TXT, CSV';

/// Returns true if [fileName] has a supported extension.
bool _isSupportedDocumentFile(String fileName) {
  final ext = fileName.split('.').lastOrNull?.toLowerCase() ?? '';
  return ext.isNotEmpty && _supportedDocumentExtensions.contains(ext);
}

/// Theme for top-level Documents screen (black folder icons)
class _DocTheme {
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color folderIcon = Colors.black;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
}

/// Yellow for folder icons when viewing inside a folder
const Color _innerIconYellow = Color(0xFFE8A317);

/// Black for folder navigation and action icons (chevron, options menu)
const Color _folderActionIconColor = Colors.black;

/// Full-screen image viewer using [Image.memory]. Ensures images load and are visible (no WebView).
class _DocumentImageViewer extends StatelessWidget {
  const _DocumentImageViewer({required this.title, required this.bytes});

  final String title;
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    if (bytes.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text(title), backgroundColor: Colors.black87, foregroundColor: Colors.white),
        body: const Center(
          child: Text(
            'No image data',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Could not display image',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatelessBaseView<DocumentVM>(
      model: DocumentVM(),
      onInitState: (model) {
        model.loadFolders(context);
        // Pre-load client & financial year filter data so FY list is ready when user opens filters.
        model.loadDocumentFilterOptions(context);
      },
      builder: (buildContext, model, child) {
        return ValueListenableBuilder<ViewState>(
          valueListenable: model.viewLoader,
          builder: (context, state, _) {
            if (state == ViewState.loading) {
              return Scaffold(
                backgroundColor: _DocTheme.background,
                appBar: AppBar(
                  title: Text(ApiTextLocalizer.localize('Documents', locale: Localizations.localeOf(buildContext))),
                  backgroundColor: _DocTheme.surface,
                  foregroundColor: _DocTheme.textPrimary,
                ),
                body: Center(child: CommonLoader()),
              );
            }
            if (state == ViewState.failed) {
              return Scaffold(
                backgroundColor: _DocTheme.background,
                appBar: AppBar(
                  title: Text(ApiTextLocalizer.localize('Documents', locale: Localizations.localeOf(buildContext))),
                  backgroundColor: _DocTheme.surface,
                  foregroundColor: _DocTheme.textPrimary,
                ),
                body: EmptyData(emptyData: ApiTextLocalizer.localize('Unable to load documents.', locale: Localizations.localeOf(buildContext))),
              );
            }
            final isRootLevel = !model.canGoBack;
            final currentFolderName =
                model.currentFolder?.folderName.toLowerCase().trim() ?? '';
            final isSharedFolder = currentFolderName == 'shared by me' ||
                currentFolderName == 'shared to me';
            final scaffold = Scaffold(
              backgroundColor: isRootLevel ? _DocTheme.background : null,
              appBar: AppBar(
                title: Text(
                  model.canGoBack && model.currentTitle.isNotEmpty
                      ? model.currentTitle
                      : ApiTextLocalizer.localize(
                          'Documents',
                          locale: Localizations.localeOf(buildContext),
                        ),
                ),
                backgroundColor: isRootLevel ? _DocTheme.surface : null,
                foregroundColor: isRootLevel ? _DocTheme.textPrimary : null,
                leading: model.canGoBack
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => model.popFolder(),
                      )
                    : null,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: model.hasActiveDocumentFilters
                          ? Theme.of(buildContext).colorScheme.primary
                          : null,
                    ),
                    onPressed: () {
                      if (isRootLevel) {
                        // Root: full filter options (Client + Financial Year).
                        _showDocumentFilterOptions(
                          context: buildContext,
                          model: model,
                        );
                      } else {
                        // Inside sub-folder: open only Financial Year filter.
                        _showDocumentFyFilterSheet(
                          context: buildContext,
                          model: model,
                        );
                      }
                    },
                  ),
                  _ViewSizeButton(model: model, isRootLevel: isRootLevel),
                ],
              ),
              body: Stack(
                alignment: Alignment.topCenter,
                children: [
                  _DocumentBody(
                    model: model,
                    buildContext: buildContext,
                    isRootLevel: isRootLevel,
                    onRefresh: () async {
                      try {
                        await model.loadFolders(
                          buildContext,
                          restoreFolderId: model.currentFolder?.docFolderId,
                          silent: true,
                        );
                      } catch (_) {
                        // Error already shown by VM
                      }
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: model.isMoveInProgress,
                    builder: (_, inProgress, __) => inProgress
                        ? const LinearProgressIndicator()
                        : const SizedBox.shrink(),
                  ),
                  ValueListenableBuilder<double?>(
                    valueListenable: model.downloadProgress,
                    builder: (_, progress, __) {
                      if (progress == null) return const SizedBox.shrink();
                      final label = model.downloadProgressLabel.value;
                      return Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Material(
                          elevation: 8,
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (label != null && label.isNotEmpty)
                                    Text(label, style: Theme.of(buildContext).textTheme.bodyMedium),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: progress == 0 ? null : progress,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              floatingActionButton: isSharedFolder
                  ? null
                  : FloatingActionButton(
                      onPressed: () => _showDocumentActionSheet(
                        context: buildContext,
                        model: model,
                        isRootLevel: isRootLevel,
                      ),
                      tooltip: 'Add',
                      child: const Icon(Icons.add),
                    ),
            );

            // Wrap Document UI with screenshot protection based on backend-driven
            // Download permission (MenuActionName == \"Download\").
            return _DocumentSecureWrapper(
              canDownload: MenuRepository.canDownloadDocument,
              child: scaffold,
            );
          },
        );
      },
    );
  }

  /// Returns client org ID string for GetFolderList: '0' for Internal, else normalized integer from selection.
  static String _clientOrgIdFromSelection(ClientListElement c) {
    if (c.displayName == 'Internal' || c.displayValue == null) return '0';
    if (c.displayValue == 0) return '0';
    final s = c.displayValue.toString().trim();
    if (s.isEmpty) return '0';
    final parsed = int.tryParse(s.split('.').first);
    return (parsed != null && parsed >= 0) ? parsed.toString() : '0';
  }

  /// Shows filter options dialog (Client, Financial Year, Clear). Document list updates from selection.
  static void _showDocumentFilterOptions({
    required BuildContext context,
    required DocumentVM model,
  }) {
    model.loadDocumentFilterOptions(context);
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(ApiTextLocalizer.localize('Filter documents', locale: Localizations.localeOf(context))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(ApiTextLocalizer.localize('Client', locale: Localizations.localeOf(context))),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showDocumentClientFilterSheet(context: context, model: model);
                  },
                ),
                ListTile(
                  title: Text(ApiTextLocalizer.localize('Financial Year', locale: Localizations.localeOf(context))),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showDocumentFyFilterSheet(context: context, model: model);
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(ApiTextLocalizer.localize('Clear filters', locale: Localizations.localeOf(context))),
                  onTap: () {
                    model.clearDocumentFilters();
                    model.loadFolders(context);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showDocumentClientFilterSheet({
    required BuildContext context,
    required DocumentVM model,
  }) {
    String searchQuery = '';
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredList = searchQuery.trim().isEmpty
                ? model.documentFilterClientList
                : model.documentFilterClientList
                    .where(
                      (c) =>
                          (c.displayName ?? '')
                              .toLowerCase()
                              .contains(searchQuery.trim().toLowerCase()),
                    )
                    .toList();
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              maxChildSize: 0.85,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                          ApiTextLocalizer.localize('Select Client', locale: Localizations.localeOf(context)),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: ApiTextLocalizer.localize('Search client name...', locale: Localizations.localeOf(context)),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) => setState(() => searchQuery = value),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: model.documentFilterClientList.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : filteredList.isEmpty
                                ? Center(
                                    child: Text(
                                      searchQuery.trim().isEmpty
                                          ? 'No clients'
                                          : 'No matching clients',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).hintColor,
                                          ),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: scrollController,
                                    itemCount: filteredList.length,
                                    itemBuilder: (context, index) {
                                      final c = filteredList[index];
                                      return ListTile(
                                        title: Text(c.displayName ?? ''),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          model.filterClientOrgId = _clientOrgIdFromSelection(c);
                                          model.notifyListeners();
                                          model.loadFolders(context);
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static void _showDocumentFyFilterSheet({
    required BuildContext context,
    required DocumentVM model,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      enableDrag: true,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Text(
                      'Select Financial Year',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Choose a year range to filter documents',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  Flexible(
                    child: model.documentFilterFyList.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: model.documentFilterFyList.length,
                            itemBuilder: (context, index) {
                              final fy = model.documentFilterFyList[index];
                              final yearRange = fy.displayName ?? fy.codeDescription ?? '—';
                              final isSelected =
                                  fy.displayValue?.toString() == model.filterFinancialYearId;
                              return ListTile(
                                title: Text(
                                  yearRange,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: Theme.of(context).colorScheme.primary,
                                      )
                                    : null,
                                selected: isSelected,
                                onTap: () {
                                  model.filterFinancialYearId =
                                      fy.displayValue?.toString();
                                  model.notifyListeners();
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Shows a bottom sheet to pick a document, then shows share sub-options (Share via apps / Copy link).
  /// "Share via apps" opens the system share sheet (WhatsApp, Gmail, Google Drive, etc.).
  static void _showShareDocumentSheet({
    required BuildContext context,
    required DocumentVM model,
  }) {
    final folder = model.currentFolder;
    if (folder == null) return;
    final files = model.displayFiles;
    if (files.isEmpty) {
      CommonFunction.showSnackBar(
        context: context,
        isError: false,
        message: 'No documents in this folder to share.',
      );
      return;
    }
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Choose a document to share',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return ListTile(
                    leading: Icon(Icons.insert_drive_file, color: theme.colorScheme.primary),
                    title: Text(
                      file.documentName.isNotEmpty ? file.documentName : 'File',
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (!context.mounted) return;
                      CommonFunction.showSnackBar(
                        context: context,
                        isError: false,
                        message: 'Preparing share…',
                      );
                      _showShareFileOptionsSheet(
                        context: context,
                        model: model,
                        file: file,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows sub-options to share a document: actual file via apps, or copy link.
  /// For file share we load bytes first; for link share we resolve the view URL.
  static void _showShareFileOptionsSheet({
    required BuildContext context,
    required DocumentVM model,
    required DocumentFileModel file,
  }) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  ApiTextLocalizer.localize('Share document', locale: Localizations.localeOf(context)),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: Icon(Icons.share, color: theme.colorScheme.primary),
                title: Text(ApiTextLocalizer.localize('Share file via apps', locale: Localizations.localeOf(context))),
                subtitle: Text(ApiTextLocalizer.localize('Send the actual document (WhatsApp, Gmail, Drive…)', locale: Localizations.localeOf(context))),
                onTap: () async {
                  Navigator.pop(ctx);
                  if (!context.mounted) return;
                  model.getDocumentBytes(
                    context,
                    documentId: file.documentId,
                    onSuccess: (bytes) async {
                      if (!context.mounted) return;
                      if (bytes.isEmpty) {
                        CommonFunction.showSnackBar(
                          context: context,
                          isError: true,
                          message: 'Could not load document for sharing.',
                        );
                        return;
                      }
                      final name = file.documentName.isNotEmpty
                          ? file.documentName
                          : 'Document';
                      try {
                        final xfile = XFile.fromData(bytes, name: name);
                        await Share.shareXFiles([xfile], text: name);
                      } catch (e) {
                        if (context.mounted) {
                          CommonFunction.showSnackBar(
                            context: context,
                            isError: true,
                            message: 'Could not open share menu. Use Copy link instead.',
                          );
                        }
                      }
                    },
                    onFailed: (msg) {
                      if (!context.mounted) return;
                      CommonFunction.showSnackBar(
                        context: context,
                        isError: true,
                        message: msg,
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.link, color: theme.colorScheme.primary),
                title: Text(ApiTextLocalizer.localize('Copy link', locale: Localizations.localeOf(context))),
                subtitle: Text(ApiTextLocalizer.localize('Paste the link anywhere to share', locale: Localizations.localeOf(context))),
                onTap: () {
                  Navigator.pop(ctx);
                  if (!context.mounted) return;
                  model.getDocumentURL(
                    context,
                    documentId: file.documentId,
                    onSuccess: (url, [token]) {
                      Clipboard.setData(ClipboardData(text: url));
                      if (context.mounted) {
                        CommonFunction.showSnackBar(
                          context: context,
                          isError: false,
                          message: 'Link copied. Paste to share.',
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showDocumentActionSheet({
    required BuildContext context,
    required DocumentVM model,
    required bool isRootLevel,
  }) {
    final theme = Theme.of(context);
    final canAdd = MenuRepository.canAddDocument;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.create_new_folder, color: theme.colorScheme.primary),
                title: Text(
                  ApiTextLocalizer.localize(
                    isRootLevel ? 'New folder' : 'New subfolder',
                    locale: Localizations.localeOf(context),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showNewFolderDialog(context: context, model: model, isSubfolder: !isRootLevel);
                },
              ),
              if (canAdd) ...[
                ListTile(
                  leading: Icon(Icons.upload_file, color: theme.colorScheme.primary),
                  title: Text(ApiTextLocalizer.localize('Upload files', locale: Localizations.localeOf(context))),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (isRootLevel) {
                      _showSelectFolderForUpload(context, model);
                    } else {
                      _pickAndUploadFiles(context, model, model.currentFolder!.docFolderId);
                    }
                  },
                ),
                if (!isRootLevel) ...[
                  ListTile(
                    leading: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
                    title: Text(ApiTextLocalizer.localize('Take Photo', locale: Localizations.localeOf(context))),
                    onTap: () {
                      Navigator.pop(ctx);
                      _captureImageAndUpload(
                        context: context,
                        model: model,
                        folderId: model.currentFolder!.docFolderId,
                        isScan: false,
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.document_scanner, color: theme.colorScheme.primary),
                    title: Text(ApiTextLocalizer.localize('Scan Document', locale: Localizations.localeOf(context))),
                    onTap: () {
                      Navigator.pop(ctx);
                      _captureImageAndUpload(
                        context: context,
                        model: model,
                        folderId: model.currentFolder!.docFolderId,
                        isScan: true,
                      );
                    },
                  ),
                ],
              ],
              if (!isRootLevel) ...[
                if (MenuRepository.canShareDocument)
                  ListTile(
                    leading: Icon(Icons.share, color: theme.colorScheme.primary),
                    title: Text(ApiTextLocalizer.localize('Share', locale: Localizations.localeOf(context))),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showShareDocumentSheet(context: context, model: model);
                    },
                  ),
              ],
              if (isRootLevel && MenuRepository.canShareDocument)
                ListTile(
                  leading: Icon(Icons.share, color: theme.colorScheme.primary),
                  title: Text(ApiTextLocalizer.localize('Share', locale: Localizations.localeOf(context))),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (context.mounted) {
                      CommonFunction.showSnackBar(
                        context: context,
                        isError: false,
                        message: 'Open a folder to choose a document to share.',
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Requests camera permission gracefully. Returns true only when granted.
  /// Handles denied and permanently denied with user guidance (dialogs + Open Settings).
  static Future<bool> _requestCameraPermission(BuildContext context) async {
    var status = await Permission.camera.status;

    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      await _showCameraPermissionDeniedDialog(
        context,
        isPermanentlyDenied: true,
      );
      return false;
    }

    // First-time or denied: request permission (shows system dialog).
    status = await Permission.camera.request();
    if (status.isGranted || status.isLimited) return true;

    if (!context.mounted) return false;
    await _showCameraPermissionDeniedDialog(
      context,
      isPermanentlyDenied: status.isPermanentlyDenied,
    );
    return false;
  }

  /// Shows a dialog guiding the user to grant camera access (Open Settings / Cancel).
  static Future<void> _showCameraPermissionDeniedDialog(
    BuildContext context, {
    required bool isPermanentlyDenied,
  }) async {
    if (!context.mounted) return;
    final theme = Theme.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera access needed'),
        content: Text(
          isPermanentlyDenied
              ? 'Camera access was denied. Tap "Open Settings" → open "Permissions" (or "App permissions") → turn on "Camera". Then return to this app and try again.\n\nIf Camera does not appear in the Permissions list, uninstall the app and reinstall it, then try again.'
              : 'Camera access is required for Take Photo and Scan Document. Tap "Open Settings" → open "Permissions" → turn on "Camera", or tap Take Photo / Scan Document again to see the permission prompt.\n\nIf Camera does not appear under Permissions, uninstall and reinstall the app, then try again.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Requests storage permission for file picker (Android only, API < 33).
  /// Returns true if granted or not needed (web, iOS, Android 13+); false if denied.
  static Future<bool> _requestStoragePermissionForFilePick(BuildContext context) async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid) return true;
    int sdkInt = 0;
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      sdkInt = androidInfo.version.sdkInt;
    } catch (_) {}
    if (sdkInt >= 33) return true;

    var status = await Permission.storage.status;
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      await _showStoragePermissionDeniedDialog(context, isPermanentlyDenied: true);
      return false;
    }

    status = await Permission.storage.request();
    if (status.isGranted || status.isLimited) return true;

    if (!context.mounted) return false;
    await _showStoragePermissionDeniedDialog(context, isPermanentlyDenied: status.isPermanentlyDenied);
    return false;
  }

  static Future<void> _showStoragePermissionDeniedDialog(
    BuildContext context, {
    required bool isPermanentlyDenied,
  }) async {
    if (!context.mounted) return;
    final theme = Theme.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Storage access needed'),
        content: Text(
          isPermanentlyDenied
              ? 'Storage access was denied. Tap "Open Settings" → Permissions → turn on "Files and media" (or "Storage"). Then try Upload files again.'
              : 'Storage access is required to select files from your device. Tap "Open Settings" → Permissions → turn on "Files and media", or try Upload files again to see the permission prompt.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Captures image from camera (photo or scan) and uploads to [folderId]. Refreshes list on success.
  /// Requests camera permission first; opens camera only after permission is granted.
  static Future<void> _captureImageAndUpload({
    required BuildContext context,
    required DocumentVM model,
    required int folderId,
    required bool isScan,
  }) async {
    if (!kIsWeb) {
      final granted = await _requestCameraPermission(context);
      if (!granted || !context.mounted) return;
    } else {
      CommonFunction.showSnackBar(
        context: context,
        isError: false,
        message: 'Opening camera…',
      );
    }

    if (!context.mounted) return;
    final picker = ImagePicker();
    final prefix = isScan ? 'scan' : 'photo';
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
    );

    if (image == null || !context.mounted) return;

    try {
      final bytes = await image.readAsBytes();
      if (!context.mounted) return;
      if (bytes.isEmpty) {
        CommonFunction.showSnackBar(
          context: context,
          isError: true,
          message: 'Could not read image. Try again.',
        );
        return;
      }
      model.uploadFiles(
        context,
        folderId: folderId,
        files: [MapEntry(fileName, bytes)],
      );
    } catch (e) {
      if (!context.mounted) return;
      CommonFunction.showSnackBar(
        context: context,
        isError: true,
        message: 'Could not use image. Please try again.',
      );
    }
  }

  /// Opens device file manager to select documents, validates supported formats,
  /// uploads selected files to [folderId], and refreshes the Document folder UI.
  /// Requests storage permission (Android < 33) before opening picker; validates before initiating upload.
  static Future<void> _pickAndUploadFiles(
    BuildContext context,
    DocumentVM model,
    int folderId,
  ) async {
    if (!kIsWeb) {
      final granted = await _requestStoragePermissionForFilePick(context);
      if (!granted || !context.mounted) return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: _supportedDocumentExtensions.toList(),
    );
    if (result == null || result.files.isEmpty) return;

    final files = <MapEntry<String, Uint8List>>[];
    int skippedUnsupported = 0;
    int skippedNoData = 0;

    for (final pf in result.files) {
      if (pf.name.isEmpty) continue;
      if (!_isSupportedDocumentFile(pf.name)) {
        skippedUnsupported++;
        continue;
      }
      final bytes = pf.bytes;
      if (bytes == null || bytes.isEmpty) {
        skippedNoData++;
        continue;
      }
      files.add(MapEntry(pf.name, bytes));
    }

    if (files.isEmpty) {
      if (!context.mounted) return;
      if (skippedUnsupported > 0) {
        CommonFunction.showSnackBar(
          context: context,
          isError: true,
          message: 'No supported files selected. Supported: $_supportedFormatsMessage',
        );
      } else if (skippedNoData > 0) {
        CommonFunction.showSnackBar(
          context: context,
          isError: true,
          message: 'Could not read file data. Try again.',
        );
      } else {
        CommonFunction.showSnackBar(
          context: context,
          isError: true,
          message: 'Could not read file data. Try again.',
        );
      }
      return;
    }

    if (!context.mounted) return;
    if (skippedUnsupported > 0 && context.mounted) {
      CommonFunction.showSnackBar(
        context: context,
        isError: false,
        message: '$skippedUnsupported file(s) skipped (unsupported). Supported: $_supportedFormatsMessage',
      );
    }
    model.uploadFiles(context, folderId: folderId, files: files);
  }

  static void _showSelectFolderForUpload(BuildContext context, DocumentVM model) {
    final folders = model.allFoldersForMove;
    if (folders.isEmpty) {
      CommonFunction.showSnackBar(
        context: context,
        isError: false,
        message: 'Create a folder first, then upload files into it.',
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final maxH = MediaQuery.of(ctx).size.height * 0.5;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                      child: Text(
                        ApiTextLocalizer.localize('Select folder to upload to', locale: Localizations.localeOf(context)),
                        style: Theme.of(ctx).textTheme.titleMedium,
                      ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: folders.length,
                  itemBuilder: (ctx, i) {
                    final f = folders[i];
                    return ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(
                        f.folderName.isNotEmpty ? f.folderName : 'Folder',
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickAndUploadFiles(context, model, f.docFolderId);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void _showNewFolderDialog({
    required BuildContext context,
    required DocumentVM model,
    required bool isSubfolder,
  }) {
    final nameController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isSubfolder ? 'New subfolder' : 'New folder'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Folder name',
            hintText: 'Enter name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              Navigator.pop(ctx);
              if (name.isEmpty) {
                CommonFunction.showSnackBar(
                  context: context,
                  isError: true,
                  message: 'Enter a folder name',
                );
                return;
              }
              final parentFolderId = isSubfolder && model.currentFolder != null
                  ? model.currentFolder!.docFolderId
                  : 0;
              model.createFolder(context, parentFolderId: parentFolderId, folderName: name);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _ViewSizeButton extends StatelessWidget {
  const _ViewSizeButton({required this.model, required this.isRootLevel});

  final DocumentVM model;
  final bool isRootLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<DocumentViewSize>(
      icon: Icon(
        Icons.view_module,
        color: isRootLevel ? _DocTheme.textPrimary : theme.iconTheme.color,
      ),
      tooltip: 'View size',
      color: isRootLevel ? _DocTheme.surface : theme.colorScheme.surface,
      onSelected: model.setViewSize,
      itemBuilder: (context) => [
        PopupMenuItem<DocumentViewSize>(
          value: DocumentViewSize.large,
          child: Text('Large', style: TextStyle(color: theme.colorScheme.onSurface)),
        ),
        PopupMenuItem<DocumentViewSize>(
          value: DocumentViewSize.medium,
          child: Text('Medium', style: TextStyle(color: theme.colorScheme.onSurface)),
        ),
        PopupMenuItem<DocumentViewSize>(
          value: DocumentViewSize.small,
          child: Text('Small', style: TextStyle(color: theme.colorScheme.onSurface)),
        ),
      ],
    );
  }
}

class _DocumentBody extends StatelessWidget {
  const _DocumentBody({
    required this.model,
    required this.buildContext,
    required this.isRootLevel,
    required this.onRefresh,
  });

  final DocumentVM model;
  final BuildContext buildContext;
  final bool isRootLevel;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final folders = model.displaySubfolders;
    final files = model.displayFiles;

    // Show whatever the backend reports for this folder:
    // folders (if any), files (if any), or both. If neither exist, show empty state.
    if (folders.isEmpty && files.isEmpty) {
      final emptyMessage = isRootLevel
          ? 'No Data Found'
          : 'No folders or files here.';
      final localizedEmptyMessage = ApiTextLocalizer.localize(
        emptyMessage,
        locale: Localizations.localeOf(context),
      );
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Text(
                localizedEmptyMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: isRootLevel ? _DocTheme.textSecondary : theme.hintColor,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final size = model.viewSize;
    final tileHeight = _tileHeight(size);
    final iconSize = _iconSize(size);
    final fontSize = _fontSize(size);
    final dividerColor = isRootLevel ? _DocTheme.divider : theme.dividerColor;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: folders.length + files.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: dividerColor),
        itemBuilder: (context, index) {
          if (index < folders.length) {
            final f = folders[index];
            return _FolderListTile(
              folder: f,
              tileHeight: tileHeight,
              iconSize: iconSize,
              fontSize: fontSize,
              isRootLevel: isRootLevel,
              model: model,
              buildContext: buildContext,
              onTap: () => model.pushFolder(f),
            );
          }
          final f = files[index - folders.length];
          return _FileListTile(
            file: f,
            tileHeight: tileHeight,
            iconSize: iconSize,
            fontSize: fontSize,
            isRootLevel: isRootLevel,
            model: model,
            buildContext: buildContext,
            onPreview: () => _openPreview(buildContext, model, f),
            onDownload: () => _openDownload(buildContext, model, f),
          );
        },
      ),
    );
  }

  static double _tileHeight(DocumentViewSize s) {
    switch (s) {
      case DocumentViewSize.large:
        return 56;
      case DocumentViewSize.medium:
        return 48;
      case DocumentViewSize.small:
        return 40;
    }
  }

  static double _iconSize(DocumentViewSize s) {
    switch (s) {
      case DocumentViewSize.large:
        return 40;
      case DocumentViewSize.medium:
        return 32;
      case DocumentViewSize.small:
        return 24;
    }
  }

  static double _fontSize(DocumentViewSize s) {
    switch (s) {
      case DocumentViewSize.large:
        return 16;
      case DocumentViewSize.medium:
        return 14;
      case DocumentViewSize.small:
        return 12;
    }
  }

  /// Max size (bytes) to preview via data URL; larger files use view URL to avoid OOM.
  static const int _maxDataUrlPreviewBytes = 8 * 1024 * 1024;
  /// Minimum size for local image bytes; smaller files may be corrupt or placeholder and show blank.
  static const int _minImageBytes = 64;

  static String _mimeFromFileName(String fileName) {
    final ext = fileName.split('.').lastOrNull?.toLowerCase() ?? '';
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'application/octet-stream';
    }
  }

  static bool _bytesMatchMime(Uint8List bytes, String mime) {
    if (bytes.length < 4) return false;
    if (mime == 'application/pdf') {
      return bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46;
    }
    if (mime == 'image/jpeg') {
      return bytes[0] == 0xFF && bytes[1] == 0xD8;
    }
    if (mime == 'image/png') {
      return bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47;
    }
    if (mime == 'image/gif') {
      return bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46;
    }
    if (mime == 'image/webp') {
      return bytes.length >= 12 &&
          bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
          bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50;
    }
    if (mime == 'image/bmp') {
      return bytes[0] == 0x42 && bytes[1] == 0x4D;
    }
    return true;
  }

  /// True when [bytes] have image magic (JPEG, PNG, GIF, WebP, BMP). Use to show image viewer even when filename has no/wrong extension.
  static bool _isImageBytes(Uint8List bytes) {
    if (bytes.length < 2) return false;
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
    if (bytes.length >= 3 && bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
        bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) return true;
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) return true;
    return false;
  }

  /// Opens a document/image for preview. When the user is outside the assigned geo-fenced
  /// zone, document access is blocked by location-based access control (API returns error);
  /// this results in blank or blocked views. Resolution: correct device location or backend
  /// location validation—not viewer changes. Locally saved files open from disk without API.
  Future<void> _openPreview(BuildContext context, DocumentVM model, DocumentFileModel file) async {
    final fileName = file.documentName.trim().isEmpty ? 'document' : file.documentName;
    if (!kIsWeb) {
      final localPath = await model.getLocalPathIfExists(fileName);
      if (localPath != null && context.mounted) {
        final bytes = await _readLocalFileBytes(localPath);
        if (context.mounted && bytes != null && bytes.isNotEmpty) {
          final opened = await _openExistingLocalFile(context, file, fileName, bytes);
          if (context.mounted && opened) return;
        }
        if (context.mounted) {
          final opened = await _openLocalFile(context, localPath);
          if (opened) return;
        }
      }
    }
    if (!context.mounted) return;
    CommonFunction.showSnackBar(context: context, isError: false, message: 'Opening document…');

    void openWithViewUrl(String url, [String? token]) {
      try {
        final trimmed = url.trim();
        if (trimmed.isEmpty) {
          _showDocumentError('Could not get document URL');
          return;
        }
        if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
          _showDocumentError('Invalid document URL');
          return;
        }
        final uri = Uri.tryParse(trimmed);
        if (uri == null) {
          _showDocumentError('Invalid document URL');
          return;
        }
        void openInBrowserThenMaybeInApp() async {
          try {
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!context.mounted) return;
              CommonFunction.showSnackBar(context: context, isError: false, message: 'Opened in browser');
              return;
            }
          } catch (_) {}
          if (!context.mounted) return;
          final nav = navigatorKey.currentState;
          final page = cusNavigate(WebviewScreen(title: file.documentName, url: trimmed, token: token));
          if (nav != null) {
            nav.push(page);
          } else {
            Navigator.push(context, page);
          }
        }
        openInBrowserThenMaybeInApp();
      } catch (_) {
        _showDocumentError('Could not open document');
      }
    }

    model.getDocumentBytes(
      context,
      documentId: file.documentId,
      onSuccess: (bytes) {
        try {
          if (!context.mounted || bytes.isEmpty) {
            model.getDocumentURL(context, documentId: file.documentId, onSuccess: openWithViewUrl);
            return;
          }
          if (bytes.length > _maxDataUrlPreviewBytes) {
            model.getDocumentURL(context, documentId: file.documentId, onSuccess: openWithViewUrl);
            return;
          }
          final mime = _mimeFromFileName(fileName);
          if (!_bytesMatchMime(bytes, mime)) {
            model.getDocumentURL(context, documentId: file.documentId, onSuccess: openWithViewUrl);
            return;
          }
          final nav = navigatorKey.currentState;
          final useImageViewer = mime.startsWith('image/') || _isImageBytes(bytes);
          if (useImageViewer) {
            final page = cusNavigate(_DocumentImageViewer(title: file.documentName, bytes: bytes));
            if (nav != null) {
              nav.push(page);
            } else if (context.mounted) {
              Navigator.push(context, page);
            }
            return;
          }
          if (!kIsWeb) {
            void tryOpenWithSystemViewer() async {
              try {
                final opened = await _saveBytesToTempAndOpen(bytes, fileName);
                if (!context.mounted) return;
                if (opened) return;
                final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
                final page = cusNavigate(WebviewScreen(title: file.documentName, url: dataUrl));
                final keyState = navigatorKey.currentState;
                if (keyState != null) {
                  keyState.push(page);
                } else if (context.mounted) {
                  Navigator.push(context, page);
                }
              } catch (_) {
                if (context.mounted) _showDocumentError('Could not open document');
              }
            }
            tryOpenWithSystemViewer();
            return;
          }
          final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
          final page = cusNavigate(WebviewScreen(title: file.documentName, url: dataUrl));
          if (nav != null) {
            nav.push(page);
          } else if (context.mounted) {
            Navigator.push(context, page);
          }
        } catch (_) {
          if (context.mounted) {
            _showDocumentError('Could not open document');
            model.getDocumentURL(context, documentId: file.documentId, onSuccess: openWithViewUrl);
          }
        }
      },
      onFailed: (_) {
        model.getDocumentURL(context, documentId: file.documentId, onSuccess: openWithViewUrl);
      },
    );
  }

  static void _showDocumentError(String message) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      CommonFunction.showSnackBar(context: ctx, isError: true, message: message);
    }
  }

  Future<void> _openDownload(
      BuildContext context, DocumentVM model, DocumentFileModel file) async {
    if (!MenuRepository.canDownloadDocument) {
      if (context.mounted) {
        CommonFunction.showSnackBar(
          context: context,
          isError: false,
          message: 'You do not have permission to download documents.',
        );
      }
      return;
    }
    final fileName = file.documentName.trim().isEmpty ? 'document' : file.documentName;
    if (kIsWeb) {
      model.getDocumentURL(context, documentId: file.documentId, onSuccess: (url, [token]) {
        void openUrl() async {
          final uri = Uri.tryParse(url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else if (context.mounted) {
            CommonFunction.showSnackBar(context: context, isError: true, message: 'Could not open link');
          }
        }
        openUrl();
      });
    } else {
      final localPath = await model.getLocalPathIfExists(fileName);
      if (localPath != null && context.mounted) {
        final opened = await _openLocalFile(context, localPath);
        if (context.mounted) return; // Opened or file already on device; no saved-path message
      }
      model.downloadDocument(context, documentId: file.documentId, fileName: fileName);
    }
  }

  /// Reads bytes from a local file path. Returns null on error or if file is empty.
  static Future<Uint8List?> _readLocalFileBytes(String localPath) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      return bytes.isEmpty ? null : bytes;
    } catch (_) {
      return null;
    }
  }

  /// Opens an existing local file by rendering its [bytes] in-app (image viewer or temp-file open). Ensures previously stored files display correctly.
  static Future<bool> _openExistingLocalFile(
    BuildContext context,
    DocumentFileModel file,
    String fileName,
    Uint8List bytes,
  ) async {
    if (bytes.length > _maxDataUrlPreviewBytes) {
      return false;
    }
    final mime = _mimeFromFileName(fileName);
    if (!_bytesMatchMime(bytes, mime)) return false;
    final useImageViewer = mime.startsWith('image/') || _isImageBytes(bytes);
    if (useImageViewer && bytes.length < _minImageBytes) {
      return false;
    }
    final nav = navigatorKey.currentState;
    if (useImageViewer) {
      final page = cusNavigate(_DocumentImageViewer(title: file.documentName, bytes: bytes));
      if (nav != null) {
        nav.push(page);
      } else if (context.mounted) {
        Navigator.push(context, page);
      }
      return true;
    }
    final opened = await _saveBytesToTempAndOpen(bytes, fileName);
    if (opened) return true;
    final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
    final page = cusNavigate(WebviewScreen(title: file.documentName, url: dataUrl));
    if (nav != null) {
      nav.push(page);
    } else if (context.mounted) {
      Navigator.push(context, page);
    }
    return true;
  }

  /// Opens a local file using the system default app. On Android uses [OpenFile] (content URI) to avoid FileUriExposedException.
  /// If you see MissingPluginException after adding open_file, run: flutter clean, flutter pub get, then rebuild the app.
  /// Returns false on any error so caller can fall back to WebView.
  /// Saves [bytes] to a temp file and opens with system app. Returns true if opened successfully.
  static Future<bool> _saveBytesToTempAndOpen(Uint8List bytes, String fileName) async {
    if (bytes.isEmpty) return false;
    try {
      final dir = await getTemporaryDirectory();
      final safeName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
      final name = safeName.isEmpty ? 'document' : safeName;
      final file = File('${dir.path}/cad_preview_${DateTime.now().millisecondsSinceEpoch}_$name');
      await file.writeAsBytes(bytes);
      final path = file.path;
      if (Platform.isAndroid || Platform.isIOS) {
        final result = await OpenFile.open(path);
        if (result.type == ResultType.done) return true;
      }
      final uri = Uri.file(path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> _openLocalFile(BuildContext context, String localPath) async {
    try {
      if (Platform.isAndroid) {
        final result = await OpenFile.open(localPath);
        return result.type == ResultType.done;
      }
      final uri = Uri.file(localPath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (_) {
      // MissingPluginException, file not found, or no app to open - fall back to WebView
    }
    return false;
  }

  /// Shares a single document file via apps (WhatsApp, Gmail, Drive, etc.).
  /// Downloads bytes first so we share the actual file, not just a link.
  static Future<void> _shareFile(
    BuildContext context,
    DocumentVM model,
    DocumentFileModel file,
  ) async {
    final completer = Completer<Uint8List?>();
    model.getDocumentBytes(
      context,
      documentId: file.documentId,
      onSuccess: (bytes) => completer.complete(bytes),
      onFailed: (_) => completer.complete(null),
    );
    final bytes = await completer.future;
    if (!context.mounted) return;
    if (bytes == null || bytes.isEmpty) {
      CommonFunction.showSnackBar(
        context: context,
        isError: true,
        message: 'Could not load document for sharing.',
      );
      return;
    }
    final name =
        file.documentName.isNotEmpty ? file.documentName : 'Document';
    try {
      final xfile = XFile.fromData(bytes, name: name);
      await Share.shareXFiles([xfile], text: name);
    } catch (e) {
      if (context.mounted) {
        CommonFunction.showSnackBar(
          context: context,
          isError: true,
          message: 'Could not open share options.',
        );
      }
    }
  }

  /// Shares all files contained in [folder] as multiple attachments via system share sheet.
  static Future<void> _shareFolder(
    BuildContext context,
    DocumentVM model,
    DocumentFolderModel folder,
  ) async {
    final files = folder.folderDocuments;
    if (files.isEmpty) {
      CommonFunction.showSnackBar(
        context: context,
        isError: false,
        message: 'No documents in this folder to share.',
      );
      return;
    }
    CommonFunction.showSnackBar(
      context: context,
      isError: false,
      message: 'Preparing documents to share…',
    );
    final List<XFile> xFiles = [];
    for (final f in files) {
      final completer = Completer<Uint8List?>();
      model.getDocumentBytes(
        context,
        documentId: f.documentId,
        onSuccess: (bytes) => completer.complete(bytes),
        onFailed: (_) => completer.complete(null),
      );
      final bytes = await completer.future;
      if (!context.mounted) return;
      if (bytes == null || bytes.isEmpty) continue;
      final name =
          f.documentName.trim().isNotEmpty ? f.documentName : 'Document_${f.documentId}';
      xFiles.add(XFile.fromData(bytes, name: name));
    }
    if (xFiles.isEmpty) {
      CommonFunction.showSnackBar(
        context: context,
        isError: true,
        message: 'Could not load any documents to share.',
      );
      return;
    }
    try {
      await Share.shareXFiles(
        xFiles,
        text: folder.folderName.isNotEmpty ? folder.folderName : 'Documents',
      );
    } catch (e) {
      if (context.mounted) {
        CommonFunction.showSnackBar(
          context: context,
          isError: true,
          message: 'Could not open share options.',
        );
      }
    }
  }

  static void _showRenameFolderDialog(
    BuildContext context,
    DocumentVM model,
    DocumentFolderModel folder,
  ) {
    final nameController = TextEditingController(text: folder.folderName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ApiTextLocalizer.localize('Rename folder', locale: Localizations.localeOf(context))),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: ApiTextLocalizer.localize('Folder name', locale: Localizations.localeOf(context)),
            hintText: ApiTextLocalizer.localize('Enter name', locale: Localizations.localeOf(context)),
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ApiTextLocalizer.localize('Cancel', locale: Localizations.localeOf(context))),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              Navigator.pop(ctx);
              if (name.isEmpty) {
                CommonFunction.showSnackBar(
                  context: context,
                  isError: true,
                  message: 'Enter a folder name',
                );
                return;
              }
              model.renameFolder(
                context,
                folderId: folder.docFolderId,
                newName: name,
                parentFolderId: folder.parentFolderId,
              );
            },
            child: Text(ApiTextLocalizer.localize('Save', locale: Localizations.localeOf(context))),
          ),
        ],
      ),
    );
  }

  static void _showMoveToFolderSheet(
    BuildContext context,
    DocumentVM model, {
    required String itemLabel,
    int? documentId,
    int? folderId,
    String? folderName,
  }) {
    var folders = model.allFoldersForMove;
    if (folderId != null) {
      final excluded = model.getFolderIdsExcludedFromMoveTarget(folderId);
      folders = folders.where((f) => !excluded.contains(f.docFolderId)).toList();
    }
    if (folders.isEmpty) {
      CommonFunction.showSnackBar(context: context, isError: false, message: 'No other folders available.');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final maxH = MediaQuery.of(ctx).size.height * 0.5;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${ApiTextLocalizer.localize('Move', locale: Localizations.localeOf(context))} '
                  '"$itemLabel" '
                  '${ApiTextLocalizer.localize('to', locale: Localizations.localeOf(context))}',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: folders.length,
                  itemBuilder: (ctx, i) {
                    final f = folders[i];
                    return ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(
                        f.folderName.isNotEmpty ? f.folderName : 'Folder',
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (documentId != null) {
                          model.moveDocument(context, documentId: documentId, targetFolderId: f.docFolderId);
                        } else if (folderId != null && folderName != null) {
                          model.moveFolder(context, folderId: folderId, folderName: folderName, targetFolderId: f.docFolderId);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DocumentSecureWrapper extends StatefulWidget {
  const _DocumentSecureWrapper({
    required this.canDownload,
    required this.child,
  });

  final bool canDownload;
  final Widget child;

  @override
  State<_DocumentSecureWrapper> createState() => _DocumentSecureWrapperState();
}

class _DocumentSecureWrapperState extends State<_DocumentSecureWrapper> {
  final ScreenshotGuard _screenshotGuard = ScreenshotGuard();

  @override
  void initState() {
    super.initState();
    _updateSecureFlag();
  }

  @override
  void didUpdateWidget(covariant _DocumentSecureWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.canDownload != widget.canDownload) {
      _updateSecureFlag();
    }
  }

  Future<void> _updateSecureFlag() async {
    if (kIsWeb) return;
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isWindows)) return;
    await _screenshotGuard.enableSecureFlag(enable: !widget.canDownload);
  }

  @override
  void dispose() {
    // Clear secure flag when leaving Document screen so screenshots work elsewhere.
    _screenshotGuard.enableSecureFlag(enable: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _FolderListTile extends StatelessWidget {
  const _FolderListTile({
    required this.folder,
    required this.tileHeight,
    required this.iconSize,
    required this.fontSize,
    required this.isRootLevel,
    required this.model,
    required this.buildContext,
    required this.onTap,
  });

  final DocumentFolderModel folder;
  final double tileHeight;
  final double iconSize;
  final double fontSize;
  final bool isRootLevel;
  final DocumentVM model;
  final BuildContext buildContext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = isRootLevel ? _DocTheme.surface : theme.cardColor;
    final folderColor = isRootLevel ? _DocTheme.folderIcon : _innerIconYellow;
    final textColor = isRootLevel ? _DocTheme.textPrimary : theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;

    return Material(
      color: surfaceColor,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: tileHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(Icons.folder, size: iconSize, color: folderColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    folder.folderName.isNotEmpty ? folder.folderName : 'Folder',
                    style: TextStyle(fontSize: fontSize, color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right, size: 22, color: _folderActionIconColor),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert, size: 22, color: _folderActionIconColor),
                  tooltip: 'Folder options',
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        onTap();
                        break;
                      case 'rename':
                        _DocumentBody._showRenameFolderDialog(buildContext, model, folder);
                        break;
                      // case 'move':
                      //   _DocumentBody._showMoveToFolderSheet(
                      //     buildContext,
                      //     model,
                      //     itemLabel: folder.folderName.isNotEmpty ? folder.folderName : 'Folder',
                      //     folderId: folder.docFolderId,
                      //     folderName: folder.folderName,
                      //   );
                      //   break;
                      case 'share':
                        if (!MenuRepository.canShareDocument) {
                          CommonFunction.showSnackBar(
                            context: buildContext,
                            isError: false,
                            message: 'You do not have permission to share documents.',
                          );
                          return;
                        }
                        _DocumentBody._shareFolder(buildContext, model, folder);
                        break;
                      case 'download':
                        if (!MenuRepository.canDownloadDocument) {
                          CommonFunction.showSnackBar(
                            context: buildContext,
                            isError: false,
                            message: 'You do not have permission to download documents.',
                          );
                          return;
                        }
                        model.downloadFolder(buildContext, folder);
                        break;
                    }
                  },
                  itemBuilder: (ctx) {
                    final items = <PopupMenuItem<String>>[
                      PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility, color: _folderActionIconColor),
                          title: Text(ApiTextLocalizer.localize('View', locale: Localizations.localeOf(buildContext))),
                          dense: true,
                        ),
                      ),
                      // PopupMenuItem(
                      //   value: 'move',
                      //   child: ListTile(
                      //     leading: Icon(Icons.drive_file_move, color: _folderActionIconColor),
                      //     title: const Text('Move Folder'),
                      //     dense: true,
                      //   ),
                      // ),
                      if (MenuRepository.canDownloadDocument)
                        PopupMenuItem(
                          value: 'download',
                          child: ListTile(
                            leading: Icon(Icons.download, color: _folderActionIconColor),
                            title: Text(ApiTextLocalizer.localize('Download folder', locale: Localizations.localeOf(buildContext))),
                            dense: true,
                          ),
                        ),
                      if (MenuRepository.canShareDocument)
                        PopupMenuItem(
                          value: 'share',
                          child: ListTile(
                            leading: Icon(Icons.share, color: _folderActionIconColor),
                            title: Text(ApiTextLocalizer.localize('Share', locale: Localizations.localeOf(buildContext))),
                            dense: true,
                          ),
                        ),
                    ];
                    if (!isRootLevel) {
                      items.insert(
                        1,
                        PopupMenuItem(
                          value: 'rename',
                          child: ListTile(
                            leading: Icon(Icons.edit, color: _folderActionIconColor),
                            title: Text(ApiTextLocalizer.localize('Rename', locale: Localizations.localeOf(buildContext))),
                            dense: true,
                          ),
                        ),
                      );
                    }
                    return items;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FileListTile extends StatelessWidget {
  const _FileListTile({
    required this.file,
    required this.tileHeight,
    required this.iconSize,
    required this.fontSize,
    required this.isRootLevel,
    required this.model,
    required this.buildContext,
    required this.onPreview,
    required this.onDownload,
  });

  final DocumentFileModel file;
  final double tileHeight;
  final double iconSize;
  final double fontSize;
  final bool isRootLevel;
  final DocumentVM model;
  final BuildContext buildContext;
  final VoidCallback onPreview;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = isRootLevel ? _DocTheme.surface : theme.cardColor;
    final iconColor = isRootLevel ? _DocTheme.textSecondary : (theme.iconTheme.color ?? theme.colorScheme.onSurface);
    final textColor = isRootLevel ? _DocTheme.textPrimary : theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final fileIconColor = _fileIconColorFor(file.documentName);

    return Material(
      color: surfaceColor,
      child: InkWell(
        onTap: onPreview,
        child: SizedBox(
          height: tileHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(
                  _iconFor(file.documentName),
                  size: iconSize,
                  color: fileIconColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    file.documentName.isNotEmpty ? file.documentName : 'File',
                    style: TextStyle(fontSize: fontSize, color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert, size: 22, color: iconColor),
                  tooltip: 'Options',
                  onSelected: (value) {
                    switch (value) {
                      case 'preview':
                        onPreview();
                        break;
                      case 'share':
                        if (!MenuRepository.canShareDocument) {
                          CommonFunction.showSnackBar(
                            context: buildContext,
                            isError: false,
                            message: 'You do not have permission to share documents.',
                          );
                          return;
                        }
                        _DocumentBody._shareFile(buildContext, model, file);
                        break;
                      // case 'move':
                      //   _DocumentBody._showMoveToFolderSheet(
                      //     buildContext,
                      //     model,
                      //     itemLabel: file.documentName.isNotEmpty ? file.documentName : 'File',
                      //     documentId: file.documentId,
                      //   );
                      //   break;
                      case 'download':
                        if (!MenuRepository.canDownloadDocument) {
                          CommonFunction.showSnackBar(
                            context: buildContext,
                            isError: false,
                            message: 'You do not have permission to download documents.',
                          );
                          return;
                        }
                        onDownload();
                        break;
                      case 'lock':
                        model.lockDocument(context, documentId: file.documentId);
                        break;
                      case 'unlock':
                        model.unlockDocument(context, documentId: file.documentId);
                        break;
                      case 'unshare':
                        if (!MenuRepository.canShareDocument) {
                          CommonFunction.showSnackBar(
                            context: buildContext,
                            isError: false,
                            message: 'You do not have permission to share documents.',
                          );
                          return;
                        }
                        model.unshareDocument(context, documentId: file.documentId);
                        break;
                    }
                  },
                  itemBuilder: (ctx) {
                    final isLocked = file.isLocked == 1;
                    final loc = Localizations.localeOf(ctx);
                    return [
                      PopupMenuItem(
                        value: 'preview',
                        child: ListTile(
                          leading: const Icon(Icons.visibility),
                          title: Text(ApiTextLocalizer.localize('View / Preview', locale: loc)),
                          dense: true,
                        ),
                      ),
                      if (MenuRepository.canShareDocument)
                        PopupMenuItem(
                          value: 'share',
                          child: ListTile(
                            leading: const Icon(Icons.share),
                            title: Text(ApiTextLocalizer.localize('Share Document', locale: loc)),
                            dense: true,
                          ),
                        ),
                      if (MenuRepository.canShareDocument)
                        PopupMenuItem(
                          value: 'unshare',
                          child: ListTile(
                            leading: const Icon(Icons.link_off),
                            title: Text(ApiTextLocalizer.localize('Un-share Document', locale: loc)),
                            dense: true,
                          ),
                        ),
                      // PopupMenuItem(
                      //   value: 'move',
                      //   enabled: !isLocked,
                      //   child: ListTile(
                      //     leading: Icon(Icons.drive_file_move, color: isLocked ? Colors.grey : null),
                      //     title: Text('Move Document', style: TextStyle(color: isLocked ? Colors.grey : null)),
                      //     dense: true,
                      //   ),
                      // ),
                      if (MenuRepository.canDownloadDocument)
                        PopupMenuItem(
                          value: 'download',
                          child: ListTile(
                            leading: const Icon(Icons.download),
                            title: Text(ApiTextLocalizer.localize('Download', locale: loc)),
                            dense: true,
                          ),
                        ),
                      PopupMenuItem(
                        value: isLocked ? 'unlock' : 'lock',
                        child: ListTile(
                          leading: Icon(isLocked ? Icons.lock_open : Icons.lock),
                          title: Text(
                            ApiTextLocalizer.localize(
                              isLocked ? 'Unlock Document' : 'Lock Document',
                              locale: loc,
                            ),
                          ),
                          dense: true,
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) return Icons.description;
    if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) return Icons.table_chart;
    if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') || lower.endsWith('.webp')) return Icons.image;
    if (lower.endsWith('.txt')) return Icons.text_snippet;
    return Icons.insert_drive_file;
  }

  /// Green Excel, blue photos, dark blue txt, black others.
  static Color _fileIconColorFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) return Colors.green;
    if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') || lower.endsWith('.webp')) return Colors.blue;
    if (lower.endsWith('.txt')) return const Color(0xFF0D47A1); // dark blue
    return Colors.black;
  }
}
