## Role-based menu visibility (mobile)

This document describes how the Flutter mobile app uses the existing backend
`Authenticate/CreateMenuSubMenu` API to control which modules are visible per user/role.

The backend already applies role-based logic via `CreateMenus(role)`; the app simply
consumes the filtered menu list and renders the Home screen dynamically. No roles are
hardcoded in the app.

---

### 1. Relevant backend APIs

- **Login**  
  `Authenticate/AuthenticateUser`  
  - Returns `TokenID` and user data.
  - The app stores `TokenID` in `SharedPreferences` under `PreferenceHelper.userToken`.

- **Menu / RBAC**  
  `Authenticate/CreateMenuSubMenu?tokenID={TokenID}`  
  - Returns a list of menus/submenus for the current user.
  - Only items allowed for the user’s role are included.

Example response (shape may vary):

```json
{
  "Success": 1,
  "Message": "OK",
  "Data": [
    { "MenuName": "Task", "URL": "Task/ViewTask" },
    { "MenuName": "Client", "URL": "Client/ViewClient" },
    { "MenuName": "Account Receivable", "URL": "Account/Receivable" },
    { "MenuName": "Document", "URL": "Document/Index" }
  ]
}
```

The app does **not** interpret roles; it only reads `MenuName`/`URL` from this API.

---

### 2. URL definitions

`lib/core/url/api_url.dart`:

- `baseUrl` (existing):  
  `static const String baseUrl = 'https://www.cadashboard.com/web/api/';`

- **Menu API constant**:

```dart
static const String Authenticate = '${baseUrl}Authenticate/';
static const String CreateMenuSubMenu = '${Authenticate}CreateMenuSubMenu';
```

---

### 3. Fetching menu items in Flutter

`lib/core/repository/menu_repository.dart`:

```dart
class MenuItem {
  final String name;
  final String url;

  MenuItem({required this.name, required this.url});
}

class MenuRepository extends ApiClient {
  Future<List<MenuItem>> fetchMenu() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(PreferenceHelper.userToken) ?? '';
    if (token.isEmpty || token == 'null') return const [];

    final uri = Uri.parse('${Urls.CreateMenuSubMenu}?tokenID=$token');
    final result = await getMethod(url: uri);

    final items = <MenuItem>[];
    dynamic data = result;

    if (data is String) {
      try { data = jsonDecode(data); } catch (_) {}
    }
    if (data is Map) {
      final inner = data['Data'] ?? data['data'] ?? data['MenuList'] ?? data['menus'];
      if (inner is List) data = inner;
    }

    if (data is List) {
      for (final e in data) {
        if (e is! Map && e is! Map<String, dynamic>) continue;
        final map = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);

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
        if (rawUrl.isEmpty) continue;

        final name = rawName.isNotEmpty ? rawName : rawUrl;
        items.add(MenuItem(name: name, url: rawUrl));
      }
    }

    return items;
  }
}
```

Token usage:

- The same `TokenID` from login is stored in `PreferenceHelper.userToken`.
- `fetchMenu()` reads `PreferenceHelper.userToken` and passes it as `tokenID` to the API.

---

### 4. Integrating menu with Home view model

`lib/core/View_Model/home_vm.dart`:

```dart
class HomeVM extends BaseModel {
  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);
  ValueNotifier<int> notification = ValueNotifier(0);

  final MenuRepository _menuRepository = MenuRepository();
  List<MenuItem> menuItems = [];

  late String userName;
  late String userEmail;

  Future<void> checkToken(BuildContext context) async {
    final preferences = await SharedPreferences.getInstance();
    tokenRepo.checkToken(
      token: preferences.getString(PreferenceHelper.userToken) ?? "",
      successResponse: (success, message, response) async {
        try {
          preferences.setBool(PreferenceHelper.isSignIn, true);
          userName = preferences.getString(PreferenceHelper.fullName) ?? '';
          userEmail = preferences.getString(PreferenceHelper.userEmail) ?? '';

          // Load role-filtered menu from backend:
          try {
            menuItems = await _menuRepository.fetchMenu();
          } catch (_) {
            menuItems = [];
          }

          viewLoader.value = ViewState.success;
          notifyListeners();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) getNotification(context);
          });
        } catch (e, st) {
          appPrint('Token success callback error: $e $st');
          viewLoader.value = ViewState.success;
        }
      },
      failedResponse: (success, message, statusCode) { ... },
    );
  }
}
```

Now `HomeVM.menuItems` contains all menu entries that this role is allowed to see.

---

### 5. Dynamic Home modules (no hardcoded roles)

`lib/ui/screen/home.dart`:

The previous hardcoded grid items (`Task`, `Client`, `Account Receivable`, `Document`) were
replaced with `_DynamicHomeMenu`, which renders Home tiles from `HomeVM.menuItems`.

```dart
SizedBox(height: size.height * 0.01),
_DynamicHomeMenu(model: model, size: size),
```

`_DynamicHomeMenu`:

```dart
class _DynamicHomeMenu extends StatelessWidget {
  const _DynamicHomeMenu({required this.model, required this.size});

  final HomeVM model;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final menus = model.menuItems;
    if (menus.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: size.width * 0.02,
      runSpacing: size.height * 0.01,
      children: menus.map((m) {
        final lowerUrl = m.url.toLowerCase();
        return HomeGird(
          name: m.name,
          image: _imageForMenu(lowerUrl),
          icon: _iconForMenu(lowerUrl),
          onTap: () => _navigateForMenu(context, lowerUrl),
        );
      }).toList(),
    );
  }

  String? _imageForMenu(String lowerUrl) { ... }
  IconData? _iconForMenu(String lowerUrl) { ... }

  void _navigateForMenu(BuildContext context, String lowerUrl) {
    if (lowerUrl.contains('task')) {
      Navigator.push(context, cusNavigate(const ViewTasks()))...;
    } else if (lowerUrl.contains('client')) {
      Navigator.push(context, cusNavigate(const ViewClient()))...;
    } else if (lowerUrl.contains('accountreceivable') ||
               lowerUrl.contains('account_receivable')) {
      Navigator.push(context, cusNavigate(const AccountReceivableScreen()))...;
    } else if (lowerUrl.contains('document')) {
      Navigator.push(context, cusNavigate(const DocumentScreen()));
    }
  }
}
```

**Key points:**

- The **set of visible modules** comes entirely from `CreateMenuSubMenu` (role-based backend).
- The app does **not** hardcode roles; it only inspects each item’s `URL` to choose a screen.
- If backend changes menus or adds/removes modules for a role, the Home screen updates automatically.

---

### 6. Summary

- `TokenID` from login is reused to call `Authenticate/CreateMenuSubMenu`.
- Backend returns a role-filtered menu list.
- Flutter reads this list and **only renders modules present in it**.
- Navigation for each tile is chosen based on the `URL` string from the API.

