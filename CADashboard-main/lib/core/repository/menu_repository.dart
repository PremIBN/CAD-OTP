import 'dart:convert';
import 'dart:developer';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One menu or submenu item returned by Authenticate/CreateMenuSubMenu.
class MenuItem {
  final String name;
  final String url;

  MenuItem({required this.name, required this.url});
}

/// Fetches menu items for the logged-in user.
/// IMPORTANT: Always pass the freshly issued tokenID from the latest
/// login response; this function does not fall back to stored tokens.
/// Returns only what the backend returns; no hardcoded menus. Empty/null response → empty list.
class MenuRepository extends ApiClient {
  /// Permission flag for Task → "Add Task" submenu/action.
  /// Derived from the latest CreateMenuSubMenu response.
  static bool canAddTask = false;

  /// Permission flag for Task → "Update" action. When false, tapping a task
  /// shows "You don't have permission to update" and does not open the edit screen.
  static bool canUpdateTask = false;

  /// Permission flag for Client → "Add Client" submenu/action.
  /// Derived from the latest CreateMenuSubMenu response.
  static bool canAddClient = false;

  /// Permission flag for Account Receivable → "View" action.
  /// When false, the mobile UI should hide the Account Receivable menu.
  static bool canViewAccountReceivable = true;

  /// Permission flag for Document → "View" action.
  /// When false, the mobile UI should hide the Document menu and related data.
  static bool canViewDocument = true;

  /// Permission flag for Document → "Add" / upload actions.
  /// When false, the mobile UI should hide upload files / camera / scan actions.
  static bool canAddDocument = false;

  /// Permission flag for Document → "Share/Unshare" actions.
  /// When false, the mobile UI should hide share/unshare options.
  static bool canShareDocument = true;

  /// Permission flag for Document → "Download" actions.
  /// When false, the mobile UI should hide download options and enable screenshot protection.
  static bool canDownloadDocument = true;

  /// Permission flag for Client → "Update" submenu/action.
  /// Derived from the latest CreateMenuSubMenu response.
  static bool canUpdateClient = false;

  Future<List<MenuItem>> fetchMenu({required String tokenId}) async {
    final effectiveToken = tokenId.trim();
    if (effectiveToken.isEmpty || effectiveToken.toLowerCase() == 'null') {
      log('MenuRepository: tokenID is null/empty, skipping CreateMenuSubMenu. rawToken=$tokenId');
      return const [];
    }

    // Backend expects POST for CreateMenuSubMenu (same as working Postman call).
    // Use postMethod with tokenID as query parameter and no body.
    final uri = Uri.parse(Urls.CreateMenuSubMenu);
    final urlString = Uri.decodeComponent(
      uri.replace(queryParameters: {'tokenID': effectiveToken}).toString(),
    );
    log('MenuRepository: calling menu API (POST) → $urlString');
    print('MENU TOKENID (CreateMenuSubMenu): $effectiveToken');

    final result = await postMethod(
      url: uri,
      queryParam: {'tokenID': effectiveToken},
      header: null,
      body: null,
      skipLocationCheck: true,
    );

    final items = <MenuItem>[];

    dynamic data = result;
    if (data == null) {
      log('MenuRepository: menu API returned null body');
      return items;
    }
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (e) {
        log('MenuRepository: failed to decode menu API response as JSON: $e');
        return items;
      }
    }

    if (data is Map) {
      // Support multiple backend shapes:
      // 1) { Data: [ ... ] }
      // 2) { Data: { MenuList: [ ... ] } }
      // 3) { MenuList: [ ... ] }
      dynamic inner = data['Data'] ?? data['data'] ?? data['MenuList'] ?? data['menus'];

      // If Data/MenuList is itself a map, try drilling into its MenuList/menus keys.
      if (inner is Map) {
        inner = inner['MenuList'] ??
            inner['menus'] ??
            inner['Data'] ??
            inner['data'];
      }

      if (inner is List) {
        data = inner;
      } else {
        log('MenuRepository: no menu list collection found in response (keys: ${data.keys})');
        return items;
      }
    }

    if (data is List) {
      _parseMenuList(data, items);
      canAddTask = _hasAddTaskPermission(data);
      canUpdateTask = _hasUpdateTaskPermission(data);
      canAddClient = _hasAddClientPermission(data);
      canUpdateClient = _hasUpdateClientPermission(data);
      canViewAccountReceivable = _hasAccountReceivableViewPermission(data);
      canViewDocument = _hasDocumentViewPermission(data);
      canAddDocument = _hasDocumentAddPermission(data);
      canShareDocument = _hasDocumentSharePermission(data);
      canDownloadDocument = _hasDocumentDownloadPermission(data);
      log('MenuRepository: canAddTask=$canAddTask, canUpdateTask=$canUpdateTask, canAddClient=$canAddClient, canUpdateClient=$canUpdateClient, canViewAccountReceivable=$canViewAccountReceivable, canViewDocument=$canViewDocument, canAddDocument=$canAddDocument, canShareDocument=$canShareDocument, canDownloadDocument=$canDownloadDocument');
    } else {
      log('MenuRepository: unexpected menu list type ${data.runtimeType}, result=$data');
    }

    // Show only allowed modules: Task, Client, Account Receivable, Document.
    // Other API entries (Home, Dashboard, etc.) are excluded. If the user's role
    // has only 2 of these 4, only those 2 are shown — no hardcoding.
    final allowed = items.where(_isAllowedModule).toList();
    log('MenuRepository: parsed ${items.length} menu items, showing ${allowed.length} allowed (Task/Client/Account Receivable/Document)');
    return allowed;
  }

  /// True only for the 4 modules we display: Task, Client, Account Receivable, Document.
  static bool _isAllowedModule(MenuItem item) {
    final name = item.name.toLowerCase();
    final url = item.url.toLowerCase();
    final isTask = name.contains('task') || url.contains('task');
    final isClient = name.contains('client') ||
        url.contains('client') ||
        url.contains('organisation') ||
        url.contains('organization') ||
        url.contains('master_organisation') ||
        url.contains('master_organization');
    final isAccountReceivable = (name.contains('account receivable') ||
            name.contains('accounts receivable') ||
            url.contains('account') ||
            url.contains('receivable') ||
            url.contains('accountsreceivable') ||
            url.contains('ar')) &&
        canViewAccountReceivable;
    final isDocument =
        (name.contains('document') || url.contains('document') || url.contains('doc')) &&
            canViewDocument;
    return isTask || isClient || isAccountReceivable || isDocument;
  }

  /// Scans the raw menu JSON for a Task → "Add Task" permission.
  /// Looks at SubMenuName / MenuActionName entries containing "add task".
  static bool _hasAddTaskPermission(dynamic list) {
    if (list is! List) return false;
    bool found = false;

    void scan(List<dynamic> items) {
      for (final e in items) {
        if (found) return;
        if (e is! Map && e is! Map<String, dynamic>) continue;
        final map =
            e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);

        // If this menu/submenu/action is not checked/active, skip it.
        if (!_isMenuEntryChecked(map)) continue;

        final menuName =
            (map['MenuName'] ?? '').toString().toLowerCase();
        final subName =
            (map['SubMenuName'] ?? '').toString().toLowerCase();

        // Submenu called "Add Task" (or similar)
        if (subName.contains('add task')) {
          found = true;
          return;
        }

        // Menu actions like "Add Task" under Task.
        final actions = map['MenuActionList'];
        if (actions is List) {
          for (final a in actions) {
            if (a is! Map && a is! Map<String, dynamic>) continue;
            final am = a is Map<String, dynamic>
                ? a
                : Map<String, dynamic>.from(a as Map);

            // Respect enabled/disabled flag on the action itself.
            if (!_isMenuEntryChecked(am)) continue;

            final actionName =
                (am['MenuActionName'] ?? '').toString().toLowerCase();
            if (actionName.contains('add task') ||
                (actionName == 'add' && menuName.contains('task'))) {
              found = true;
              return;
            }
          }
        }

        final children = map['Children'] ??
            map['children'] ??
            map['SubMenu'] ??
            map['SubMenuList'] ??
            map['InnerSubMenuList'];
        if (children is List) {
          scan(children);
        }
      }
    }

    scan(list);
    return found;
  }

  /// Task "Update" permission — driven by backend API (CreateMenuSubMenu).
  /// When Postman/API shows Update action disabled (not in Task MenuActionList or unchecked),
  /// canUpdateTask is false: task list tap shows "You don't have permission to update"
  /// and the update screen is not shown; details screen shows permission message and pops.
  /// Only the main Task menu (MenuName "Task", URL Manage_Task, or MenuID 7) is considered.
  static bool _hasUpdateTaskPermission(dynamic list) {
    if (list is! List) return false;
    bool found = false;

    void scan(List<dynamic> items) {
      for (final e in items) {
        if (found) return;
        if (e is! Map && e is! Map<String, dynamic>) continue;
        final map =
            e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);
        if (!_isMenuEntryChecked(map)) continue;

        final lowerMenuName =
            (map['MenuName'] ?? '').toString().toLowerCase().trim();
        final lowerUrl = (map['SubMenuURL'] ?? map['Url'] ?? map['URL'] ?? '')
            .toString()
            .toLowerCase();
        final menuId = map['MenuID'];
        // Only the main Task menu: exact "Task" name, or Manage_Task URL, or MenuID 7.
        // Do NOT use .contains('task') — that would match "Add Task" / other submenus.
        final isMainTaskMenu = lowerMenuName == 'task' ||
            lowerUrl.contains('manage_task') ||
            menuId == 7;

        if (isMainTaskMenu) {
          final actions = map['MenuActionList'];
          if (actions is List) {
            for (final a in actions) {
              if (a is! Map && a is! Map<String, dynamic>) continue;
              final am = a is Map<String, dynamic>
                  ? a
                  : Map<String, dynamic>.from(a as Map);
              if (!_isMenuEntryChecked(am)) continue;
              final actionName =
                  (am['MenuActionName'] ?? '').toString().toLowerCase().trim();
              if (actionName == 'update') {
                found = true;
                log('MenuRepository: Task menu (MenuID=$menuId) has enabled "Update" → canUpdateTask=true');
                return;
              }
            }
            log('MenuRepository: Task menu (MenuID=$menuId) has no enabled "Update" → canUpdateTask=false');
          }
        }

        final children = map['Children'] ??
            map['children'] ??
            map['SubMenu'] ??
            map['SubMenuList'] ??
            map['InnerSubMenuList'];
        if (children is List) scan(children);
      }
    }

    scan(list);
    return found;
  }

  /// Scans the raw menu JSON for a Client → "Add Client" permission.
  ///
  /// IMPORTANT: We now tie the mobile Add Client button ONLY to the
  /// Master_Organisation → Client submenu (the one that drives this screen).
  /// Concretely:
  /// - Find a node where SubMenuURL contains "master_organisation" OR
  ///   MenuName/SubMenuName is "client".
  /// - Under that node, look for a MenuActionName that is exactly "Add"
  ///   or contains "Add Client".
  /// If the backend removes or disables that action for this role, this
  /// returns false and the "+" icon is hidden.
  static bool _hasAddClientPermission(dynamic list) {
    if (list is! List) return false;
    bool found = false;

    void scan(List<dynamic> items) {
      for (final e in items) {
        if (found) return;
        if (e is! Map && e is! Map<String, dynamic>) continue;
        final map =
            e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);

        // If this menu/submenu node is not checked/active, skip it.
        if (!_isMenuEntryChecked(map)) continue;

        final lowerMenuName =
            (map['MenuName'] ?? '').toString().toLowerCase().trim();
        final lowerSubName =
            (map['SubMenuName'] ?? '').toString().toLowerCase().trim();
        final lowerUrlContext = (map['SubMenuURL'] ??
                map['Url'] ??
                map['URL'] ??
                map['Route'] ??
                map['Path'] ??
                '')
            .toString()
            .toLowerCase();

        // Only the Master_Organisation → Client node should control mobile Add Client.
        final isClientNode = lowerSubName == 'client' ||
            lowerMenuName == 'client' ||
            lowerUrlContext.contains('master_organisation') ||
            lowerUrlContext.contains('master_organization');

        if (isClientNode) {
          final actions = map['MenuActionList'];
          if (actions is List) {
            for (final a in actions) {
              if (a is! Map && a is! Map<String, dynamic>) continue;
              final am = a is Map<String, dynamic>
                  ? a
                  : Map<String, dynamic>.from(a as Map);

              if (!_isMenuEntryChecked(am)) continue;

              final actionName =
                  (am['MenuActionName'] ?? '').toString().toLowerCase().trim();
              if (actionName == 'add' || actionName.contains('add client')) {
                found = true;
                return;
              }
            }
          }
        }

        final children = map['Children'] ??
            map['children'] ??
            map['SubMenu'] ??
            map['SubMenuList'] ??
            map['InnerSubMenuList'];
        if (children is List) {
          scan(children);
        }
      }
    }

    scan(list);
    return found;
  }

  /// Scans the raw menu JSON for a Client → "Update" permission.
  ///
  /// IMPORTANT: To mirror the Task behavior, we now tie the mobile Client
  /// "Update" permission ONLY to the Master_Organisation → Client submenu.
  /// Concretely:
  /// - Find a node where SubMenuURL contains "master_organisation" OR
  ///   MenuName/SubMenuName is "client".
  /// - Under that node, look for a MenuActionName that contains "update".
  /// If the backend removes or disables that action, this returns false and
  /// tapping a client row will only show the "You do not have permission to edit"
  /// message instead of opening the edit page.
  static bool _hasUpdateClientPermission(dynamic list) {
    if (list is! List) return false;
    bool found = false;

    void scan(List<dynamic> items) {
      for (final e in items) {
        if (found) return;
        if (e is! Map && e is! Map<String, dynamic>) continue;
        final map = e is Map<String, dynamic>
            ? e
            : Map<String, dynamic>.from(e as Map);

        // If this menu/submenu/action is not checked/active, skip it.
        if (!_isMenuEntryChecked(map)) continue;

        final lowerMenuName =
            (map['MenuName'] ?? '').toString().toLowerCase().trim();
        final lowerSubName =
            (map['SubMenuName'] ?? '').toString().toLowerCase().trim();
        final lowerUrlContext = (map['SubMenuURL'] ??
                map['Url'] ??
                map['URL'] ??
                map['Route'] ??
                map['Path'] ??
                '')
            .toString()
            .toLowerCase();

        // Only the Master_Organisation → Client node should control mobile Client Update.
        final isClientNode = lowerSubName == 'client' ||
            lowerMenuName == 'client' ||
            lowerUrlContext.contains('master_organisation') ||
            lowerUrlContext.contains('master_organization');

        if (isClientNode) {
          final actions = map['MenuActionList'];
          if (actions is List) {
            for (final a in actions) {
              if (a is! Map && a is! Map<String, dynamic>) continue;
              final am = a is Map<String, dynamic>
                  ? a
                  : Map<String, dynamic>.from(a as Map);

              if (!_isMenuEntryChecked(am)) continue;

              final actionName =
                  (am['MenuActionName'] ?? '').toString().toLowerCase().trim();
              if (actionName.contains('update')) {
                found = true;
                return;
              }
            }
          }
        }

        final children = map['Children'] ??
            map['children'] ??
            map['SubMenu'] ??
            map['SubMenuList'] ??
            map['InnerSubMenuList'];
        if (children is List) {
          scan(children);
        }
      }
    }

    scan(list);
    return found;
  }

  /// Scans the raw menu JSON for Account Receivable → "View" permission.
  /// Looks at MenuActionName / SubMenuName containing "view" in an Account Receivable context.
  static bool _hasAccountReceivableViewPermission(dynamic list) {
    if (list is! List) return true; // default to visible if structure unexpected
    bool found = false;

    void scan(List<dynamic> items) {
      for (final e in items) {
        if (found) return;
        if (e is! Map && e is! Map<String, dynamic>) continue;
        final map = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);

        // Skip entries that are explicitly unchecked/inactive.
        if (!_isMenuEntryChecked(map)) continue;

        final lowerMenuName = (map['MenuName'] ?? '').toString().toLowerCase();
        final lowerSubName = (map['SubMenuName'] ?? '').toString().toLowerCase();
        final lowerUrl = (map['SubMenuURL'] ??
                map['Url'] ??
                map['URL'] ??
                map['Route'] ??
                map['Path'] ??
                '')
            .toString()
            .toLowerCase();

        // Detect Account Receivable context (menu or submenu or URL).
        final isArContext = lowerMenuName.contains('account receivable') ||
            lowerMenuName.contains('accounts receivable') ||
            lowerSubName.contains('account receivable') ||
            lowerSubName.contains('accounts receivable') ||
            lowerUrl.contains('accountsreceivable') ||
            lowerUrl.contains('account') && lowerUrl.contains('receivable');

        if (isArContext) {
          // If the AR node exists and is enabled, we consider View permitted
          // only when we can see an explicit "View" action or label.
          // First check submenu name.
          if (lowerSubName.contains('view') ||
              lowerMenuName.contains('view')) {
            found = true;
            return;
          }

          // Then check actions like "View" under this AR node.
          final actions = map['MenuActionList'];
          if (actions is List) {
            for (final a in actions) {
              if (a is! Map && a is! Map<String, dynamic>) continue;
              final am = a is Map<String, dynamic> ? a : Map<String, dynamic>.from(a as Map);
              if (!_isMenuEntryChecked(am)) continue;
              final actionName =
                  (am['MenuActionName'] ?? '').toString().toLowerCase();
              if (actionName == 'view' || actionName.contains('view')) {
                found = true;
                return;
              }
            }
          }
        }

        final children = map['Children'] ??
            map['children'] ??
            map['SubMenu'] ??
            map['SubMenuList'] ??
            map['InnerSubMenuList'];
        if (children is List) {
          scan(children);
        }
      }
    }

    scan(list);
    return found;
  }

  /// Scans the raw menu JSON for Document → "View" permission.
  /// Looks at MenuActionName / SubMenuName containing "view" in a Document context.
  static bool _hasDocumentViewPermission(dynamic list) {
    if (list is! List) return true; // default to visible if structure unexpected
    bool found = false;

    void scan(List<dynamic> items) {
      for (final e in items) {
        if (found) return;
        if (e is! Map && e is! Map<String, dynamic>) continue;
        final map = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);

        // Skip entries that are explicitly unchecked/inactive.
        if (!_isMenuEntryChecked(map)) continue;

        final lowerMenuName = (map['MenuName'] ?? '').toString().toLowerCase();
        final lowerSubName = (map['SubMenuName'] ?? '').toString().toLowerCase();
        final lowerUrl = (map['SubMenuURL'] ??
                map['Url'] ??
                map['URL'] ??
                map['Route'] ??
                map['Path'] ??
                '')
            .toString()
            .toLowerCase();

        // Detect Document context.
        final isDocContext = lowerMenuName.contains('document') ||
            lowerSubName.contains('document') ||
            lowerUrl.contains('document') ||
            lowerUrl.contains('doc');

        if (isDocContext) {
          // Submenu or menu labelled with "view" under Document.
          if (lowerSubName.contains('view') || lowerMenuName.contains('view')) {
            found = true;
            return;
          }

          // Or actions like "View" under Document.
          final actions = map['MenuActionList'];
          if (actions is List) {
            for (final a in actions) {
              if (a is! Map && a is! Map<String, dynamic>) continue;
              final am = a is Map<String, dynamic> ? a : Map<String, dynamic>.from(a as Map);
              if (!_isMenuEntryChecked(am)) continue;
              final actionName =
                  (am['MenuActionName'] ?? '').toString().toLowerCase();
              if (actionName == 'view' || actionName.contains('view')) {
                found = true;
                return;
              }
            }
          }
        }

        final children = map['Children'] ??
            map['children'] ??
            map['SubMenu'] ??
            map['SubMenuList'] ??
            map['InnerSubMenuList'];
        if (children is List) {
          scan(children);
        }
      }
    }

    scan(list);
    return found;
  }

  /// Scans the raw menu JSON for Document → "Share/Unshare" permission.
  /// Looks at MenuActionName / SubMenuName containing "share" or "unshare" in a Document context.
  static bool _hasDocumentSharePermission(dynamic list) {
    if (list is! List) return true; // default to enabled if structure unexpected
    bool found = false;

    void scan(List<dynamic> items) {
      for (final e in items) {
        if (found) return;
        if (e is! Map && e is! Map<String, dynamic>) continue;
        final map = e is Map<String, dynamic>
            ? e
            : Map<String, dynamic>.from(e as Map);

        if (!_isMenuEntryChecked(map)) continue;

        final lowerMenuName =
            (map['MenuName'] ?? '').toString().toLowerCase().trim();
        final lowerSubName =
            (map['SubMenuName'] ?? '').toString().toLowerCase().trim();

        // Only the main Document menu (top-level) should control document share/unshare.
        final isDocumentMenu = lowerMenuName == 'document' ||
            lowerMenuName == 'documents' ||
            (lowerMenuName.contains('document') && map['MenuID'] != null);

        if (isDocumentMenu) {
          final actions = map['MenuActionList'];
          if (actions is List) {
            final actionNames = <String>[];
            for (final a in actions) {
              if (a is! Map && a is! Map<String, dynamic>) continue;
              final am = a is Map<String, dynamic>
                  ? a
                  : Map<String, dynamic>.from(a as Map);
              final rawName = (am['MenuActionName'] ?? '').toString();
              actionNames.add(rawName);
              if (!_isMenuEntryChecked(am)) continue;
              final actionName = rawName.toLowerCase().trim();
              if (actionName.contains('share') ||
                  actionName.contains('unshare')) {
                found = true;
                log(
                    'MenuRepository: Document share actions = $actionNames → canShareDocument=$found');
                return;
              }
            }
            if (!found) {
              log(
                  'MenuRepository: Document share actions = $actionNames → canShareDocument=false');
            }
          }

          // Optional nested submenu like "Share/Unshare" directly under Document.
          if (lowerSubName.contains('share') ||
              lowerSubName.contains('unshare')) {
            found = true;
            log(
                'MenuRepository: Document submenu share label \"$lowerSubName\" → canShareDocument=$found');
            return;
          }
        }

        final children = map['Children'] ??
            map['children'] ??
            map['SubMenu'] ??
            map['SubMenuList'] ??
            map['InnerSubMenuList'];
        if (children is List) {
          scan(children);
        }
      }
    }

    scan(list);
    return found;
  }

  /// Scans the raw menu JSON for Document → "Download" permission.
  /// Looks for a "Download" action under the main Document menu. If the backend
  /// omits this action or marks it unchecked, downloading is treated as disabled.
  static bool _hasDocumentDownloadPermission(dynamic list) {
    if (list is! List) return true; // default to enabled if structure unexpected
    bool found = false;

    void scan(List<dynamic> items) {
      for (final e in items) {
        if (found) return;
        if (e is! Map && e is! Map<String, dynamic>) continue;
        final map =
            e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);

        if (!_isMenuEntryChecked(map)) continue;

        final lowerMenuName =
            (map['MenuName'] ?? '').toString().toLowerCase().trim();
        final lowerSubName =
            (map['SubMenuName'] ?? '').toString().toLowerCase().trim();

        // Only the main Document menu (top-level) should control document download.
        final isDocumentMenu = lowerMenuName == 'document' ||
            lowerMenuName == 'documents' ||
            (lowerMenuName.contains('document') && map['MenuID'] != null);

        if (isDocumentMenu) {
          final actions = map['MenuActionList'];
          if (actions is List) {
            for (final a in actions) {
              if (a is! Map && a is! Map<String, dynamic>) continue;
              final am = a is Map<String, dynamic>
                  ? a
                  : Map<String, dynamic>.from(a as Map);
              if (!_isMenuEntryChecked(am)) continue;
              final actionName =
                  (am['MenuActionName'] ?? '').toString().toLowerCase().trim();
              if (actionName == 'download' ||
                  actionName.contains('download document') ||
                  actionName.contains('download file')) {
                found = true;
                return;
              }
            }
          }

          // Optional nested submenu called "Download" under Document (if backend models it that way).
          if (lowerSubName == 'download' ||
              lowerSubName.contains('download document') ||
              lowerSubName.contains('download file')) {
            found = true;
            return;
          }
        }

        final children = map['Children'] ??
            map['children'] ??
            map['SubMenu'] ??
            map['SubMenuList'] ??
            map['InnerSubMenuList'];
        if (children is List) {
          scan(children);
        }
      }
    }

    scan(list);
    return found;
  }

  /// Document upload permission: controlled by the "Add" action in the Document menu.
  /// When the backend removed/disabled "Update" for Document, upload (file upload,
  /// camera, scanner) was aligned with "Add" instead. True when Document menu's
  /// MenuActionList contains an enabled action named "Add" or "Add Document".
  static bool _hasDocumentAddPermission(dynamic list) {
    if (list is! List) return false;
    bool found = false;

    void scan(List<dynamic> items) {
      for (final e in items) {
        if (found) return;
        if (e is! Map && e is! Map<String, dynamic>) continue;
        final map = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);

        if (!_isMenuEntryChecked(map)) continue;

        final lowerMenuName = (map['MenuName'] ?? '').toString().toLowerCase();
        final lowerSubName = (map['SubMenuName'] ?? '').toString().toLowerCase();
        final lowerUrl = (map['SubMenuURL'] ??
                map['Url'] ??
                map['URL'] ??
                map['Route'] ??
                map['Path'] ??
                '')
            .toString()
            .toLowerCase();

        // Only the main Document menu (MenuID 9 / "Document") counts.
        final isDocumentMenu = lowerMenuName == 'document' ||
            lowerMenuName == 'documents' ||
            (lowerMenuName.contains('document') && map['MenuID'] != null);

        if (isDocumentMenu) {
          final actions = map['MenuActionList'];
          if (actions is List) {
            for (final a in actions) {
              if (a is! Map && a is! Map<String, dynamic>) continue;
              final am = a is Map<String, dynamic> ? a : Map<String, dynamic>.from(a as Map);
              if (!_isMenuEntryChecked(am)) continue;
              final actionName = (am['MenuActionName'] ?? '').toString().toLowerCase().trim();
              // Upload (file, camera, scanner) is controlled by Add permission, not Update.
              if (actionName == 'add' || actionName.startsWith('add document')) {
                found = true;
                return;
              }
            }
          }
          // Optional: nested submenu "Add" / "Add Document" under Document.
          if (lowerSubName == 'add' || lowerSubName.startsWith('add document')) {
            found = true;
            return;
          }
        }

        final children = map['Children'] ??
            map['children'] ??
            map['SubMenu'] ??
            map['SubMenuList'] ??
            map['InnerSubMenuList'];
        if (children is List) {
          scan(children);
        }
      }
    }

    scan(list);
    return found;
  }

  /// Best-effort detector for whether a menu/submenu/action is "checked" or active.
  /// Many tree-view APIs expose flags like Checked/IsChecked/Selected/IsSelected/Active/IsActive.
  /// They might be booleans (true/false) or integers (1/0). If none of these flags exist,
  /// we assume it is enabled (to keep backward compatibility).
  static bool _isMenuEntryChecked(Map<String, dynamic> map) {
    // Collect possible boolean/numeric flags.
    final candidates = <dynamic>[
      map['Checked'],
      map['checked'],
      map['IsChecked'],
      map['isChecked'],
      map['Selected'],
      map['selected'],
      map['IsSelected'],
      map['isSelected'],
      map['Active'],
      map['active'],
      map['IsActive'],
      map['isActive'],
    ];

    var sawAnyFlag = false;
    var anyTrue = false;
    for (final c in candidates) {
      if (c is bool) {
        sawAnyFlag = true;
        if (c == false) return false;
        if (c == true) anyTrue = true;
      } else if (c is num) {
        sawAnyFlag = true;
        if (c == 0) return false;
        if (c != 0) anyTrue = true;
      }
    }

    // If we saw at least one flag and none were false/0, treat as checked
    // only if at least one was explicitly true/non-zero.
    if (sawAnyFlag) return anyTrue;

    // No explicit flag → assume enabled.
    return true;
  }

  void _parseMenuList(dynamic list, List<MenuItem> out) {
    if (list is! List) return;
    for (final e in list) {
      if (e is! Map && e is! Map<String, dynamic>) continue;
      final map = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);

      // Top-level menus (MenuID present)
      if (map['MenuID'] != null) {
        final rawName = (map['MenuName'] ??
                map['FormName'] ??
                map['DisplayName'] ??
                map['Text'] ??
                map['Name'] ??
                '')
            .toString()
            .trim();
        final rawUrl =
            (map['URL'] ?? map['Url'] ?? map['FormURL'] ?? map['Route'] ?? map['Path'] ?? '')
                .toString()
                .trim();

        final effectiveName = rawName.isNotEmpty ? rawName : rawUrl;
        final effectiveUrl = rawUrl.isNotEmpty ? rawUrl : effectiveName;

        if (effectiveName.isNotEmpty && effectiveUrl.isNotEmpty) {
          out.add(MenuItem(name: effectiveName, url: effectiveUrl));
        }
      } else {
        // Specific important submenus that should appear as top-level tiles on mobile:
        final subName = (map['SubMenuName'] ?? '').toString().trim();
        final subUrl =
            (map['SubMenuURL'] ?? map['Url'] ?? map['URL'] ?? '').toString().trim();
        final lowerName = subName.toLowerCase();
        final lowerUrl = subUrl.toLowerCase();

        final isAccountReceivable = lowerName.contains('account receivable') ||
            lowerUrl.contains('accountsreceivable');
        final isClientMaster = lowerName.contains('client') &&
            (lowerUrl.contains('master_organisation') || lowerUrl.contains('master_organization'));

        if ((isAccountReceivable || isClientMaster) &&
            subName.isNotEmpty &&
            subUrl.isNotEmpty) {
          out.add(MenuItem(name: subName, url: subUrl));
        }
      }

      // Recursively traverse nested submenu lists.
      final children = map['Children'] ??
          map['children'] ??
          map['SubMenu'] ??
          map['SubMenuList'] ??
          map['InnerSubMenuList'];
      if (children is List) {
        _parseMenuList(children, out);
      }
    }
  }
}

