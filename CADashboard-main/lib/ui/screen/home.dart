import 'dart:async';
import 'dart:io';
import 'package:cadashboard/core/View_Model/home_vm.dart';
import 'package:cadashboard/core/repository/menu_repository.dart';
import 'package:cadashboard/core/common/app_version_service.dart';
import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/common/common_loader.dart';
import 'package:cadashboard/core/common/empty_data.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/utils/images.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/screen/about_screen.dart';
import 'package:cadashboard/ui/screen/account/account_receivable.dart';
import 'package:cadashboard/ui/screen/app_permissions_settings_screen.dart';
import 'package:cadashboard/ui/screen/change_password_screen.dart';
import 'package:cadashboard/ui/screen/login_screen.dart';
import 'package:cadashboard/ui/screen/notification_screen.dart';
import 'package:cadashboard/ui/screen/document/document_screen.dart';
import 'package:cadashboard/ui/screen/client/view_client.dart';
import 'package:cadashboard/ui/screen/task/view_task.dart';
import 'package:cadashboard/ui/screen/webview_screen.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:cadashboard/core/model/attendance/attendance_history_row.dart';
import 'package:cadashboard/ui/widget/greeting_widget.dart';
import 'package:cadashboard/ui/widget/language_selection_sheet.dart';
import 'package:cadashboard/ui/widget/screen_loader.dart';
import 'package:cadashboard/ui/widget/upgrade_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:cadashboard/l10n/app_localizations.dart';
import 'package:cadashboard/core/services/api_text_localizer.dart';

import '../../core/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  /// Optional tokenID from the latest login response.
  /// When provided, Home will use this tokenID for initial menu fetch
  /// instead of any previously stored token.
  final String? tokenId;

  const HomeScreen({super.key, this.tokenId});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

  HomeVM homeVM = HomeVM();
  TextStyle recentTextStyle = const TextStyle(fontSize: 18,fontWeight: FontWeight.w600);
  double greetingTextSize = 14.0;
  double height = 80;
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<DateTime> _now = ValueNotifier(DateTime.now());
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    // If Home is opened right after login, use the freshly issued tokenID
    // for the first menu/API calls instead of any older stored token.
    homeVM.setSessionToken(widget.tokenId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocationService().startMonitoring(context);
    });
    timer();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now.value = DateTime.now();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _now.dispose();
    super.dispose();
  }

  timer() async {
    Timer.periodic(const Duration(seconds: 10), (timer1) {
      timer1.cancel();
      Timer.periodic(const Duration(milliseconds: 200,), (timer2) {
        if(height == 0){
          timer2.cancel();
        } else {
          setState(() {
            height -= 10;
          });
        }
      });
    });
  }

  requestLocationPermission() async {
    LocationPermission permission;
    // Check if location services are enabled

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (Platform.isIOS) {
      if (!serviceEnabled) {
        isLoading.value = false;
        final ctx = navigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          locationDialog(
            context: ctx,
            onTapGotIt: () => Navigator.pop(ctx),
          );
        }
        return false;
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      isLoading.value = false;
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        isLoading.value = false;
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      isLoading.value = false;
      return false;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      isLoading.value = false;
      final ctx = navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        homeVM.dialog(ctx, 'Logout ?', 'Are you sure you want logout?', latitude: position.latitude.toString(), longitude: position.longitude.toString());
      }
    } catch (e) {
      isLoading.value = false;
    }

    return true ;
  }

  @override
  Widget build(BuildContext homeContext) {
    var size = MediaQuery.of(homeContext).size;
    return StatelessBaseView(
      model: homeVM,
      onInitState: (p0) {
        p0.checkToken(homeContext);
      },
      builder: (buildContext, model, child) {
        final locale = Localizations.localeOf(homeContext);
        return ValueListenableBuilder(
          valueListenable: isLoading,
          builder: (context, loading, child) {
            return ScreenLoader(
              loading: loading,
              child: UpgradeApp(
                child: Scaffold(
                  appBar: AppBar(
                    title: Image.asset(AppImages.logoText),
                    actions: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications),
                            onPressed: () {
                              Navigator.push(homeContext, cusNavigate(const NotificationScreen())).then((value){
                                model.viewLoader.value = ViewState.loading;
                                model.checkToken(homeContext);
                              });
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: model.notification,
                            builder: (context, value, child) {
                              if (value == 0) {
                                return const SizedBox();
                              } else {
                                return Positioned(
                                  right: 10,top: 5,
                                  child: CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.red,
                                    child: Text(model.notification.value.toString(),style: const TextStyle(color: Colors.white,fontSize: 8 )),
                                  ),
                                );
                              }
                            },
                          )
                        ],
                      ),
                      IconButton(
                        icon: Image.asset(
                          'assets/images/language.png',
                          width: 22,
                          height: 22,
                        ),
                        onPressed: () {
                          LanguageSelectionSheet.show(homeContext);
                        },
                      ),
                      SizedBox(width: size.width * 0.01,)
                    ],
                  ),
                  body: ValueListenableBuilder(
                    valueListenable: model.viewLoader,
                    builder: (context, value, child) {
                      if(value == ViewState.loading){
                        return CommonLoader();
                      } else if (value == ViewState.success) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            try {
                              await model.refresh(buildContext);
                            } catch (_) {
                              // Error already shown by VM
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.008,),
                                if(height != 0)AnimatedContainer(
                                  height: height,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${ApiTextLocalizer.localize('Hello', locale: locale)}, ',
                                              style: TextStyle(fontSize: greetingTextSize),
                                            ),
                                            GreetingWidget(size: greetingTextSize,)
                                          ],
                                        ),
                                        Text(model.userName,style: TextStyle(fontSize: greetingTextSize)),
                                        const Divider(height: 20,),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _AttendanceCard(
                                  now: _now,
                                  model: model,
                                ),
                                SizedBox(height: size.height * 0.01,),
                                _HomeMenuGrid(
                                  size: size,
                                  menuItems: model.menuItems,
                                  onNavigate: () {
                                    model.viewLoader.value = ViewState.loading;
                                    model.updateUI();
                                    model.checkToken(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        );
                      } else {
                        return EmptyData(emptyData: model.errorMessage);
                      }
                    },
                  ),
                  drawer: SafeArea(
                    child: ValueListenableBuilder(
                      valueListenable: model.viewLoader,
                      builder: (context, value, child) {
                        if(value == ViewState.loading){
                          return CommonLoader();
                        } else if (value == ViewState.success) {
                          return Drawer(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15).copyWith(bottom: 25),
                                  decoration: const BoxDecoration(
                                      color: AppColor.background,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15)
                                      ),
                                      boxShadow: [BoxShadow(color: Colors.black,blurStyle: BlurStyle.outer,blurRadius: 1)]
                                  ),
                                  child: Column(
                                    children: [
                                      Image.asset(AppImages.logoText,color: Colors.white),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const CircleAvatar(
                                            radius: 30,
                                            child: Icon(Icons.person),
                                          ),
                                          SizedBox(width: size.width * 0.03,),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(model.userName,style: const TextStyle(fontWeight: FontWeight.w700,fontSize: 18,color: Colors.white),),
                                                Text(model.userEmail,style: const TextStyle(fontWeight: FontWeight.w700,fontSize: 14,color: Colors.white),)
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                ListTile(
                                  leading: const Icon(Icons.settings_suggest_outlined),
                                  title: const Text('App settings'),
                                  subtitle: const Text('Notifications & microphone'),
                                  onTap: () {
                                    Navigator.pop(homeContext);
                                    Navigator.push(homeContext, cusNavigate(const AppPermissionsSettingsScreen()));
                                  },
                                ),

                                ListTile(
                                  leading: const Icon(Icons.lock_outline),
                                  title: Text(ApiTextLocalizer.localize('Change Password', locale: locale)),
                                  onTap: () {
                                    Navigator.pop(homeContext);
                                    Navigator.push(homeContext, cusNavigate(const ChangePasswordScreen()));
                                  },
                                ),

                                ListTile(
                                  leading: const Icon(Icons.info_outline_rounded),
                                  title: Text(ApiTextLocalizer.localize('About us', locale: locale)),
                                  onTap: () {
                                    Navigator.pop(homeContext);
                                    Navigator.push(homeContext, cusNavigate(const AboutUsScreen()));
                                  },
                                ),

                                ListTile(
                                  leading: Image.asset(AppImages.privacyPolicy,width: 27),
                                  title: Text(ApiTextLocalizer.localize('Privacy Policy', locale: locale)),
                                  onTap: () {
                                    Navigator.pop(homeContext);
                                    final title = ApiTextLocalizer.localize('Privacy Policy', locale: locale);
                                    Navigator.push(homeContext, cusNavigate(WebviewScreen(title: title, url: Urls.privacy_policy)));
                                  },
                                ),

                                ListTile(
                                  contentPadding: const EdgeInsets.only(left: 22),
                                  leading: Image.asset(AppImages.termsCondition,width: 23),
                                  title: Text(ApiTextLocalizer.localize('Terms & Condition', locale: locale)),
                                  onTap: () {
                                    Navigator.pop(homeContext);
                                    final title = ApiTextLocalizer.localize('Terms & Condition', locale: locale);
                                    Navigator.push(homeContext, cusNavigate(WebviewScreen(title: title, url: Urls.termsAndCondition)));
                                  },
                                ),

                                Divider(height: size.height * 0.03,),
                                ListTile(
                                  leading: const Icon(Icons.logout,color: Colors.red),
                                  title: Text(ApiTextLocalizer.localize('Logout', locale: locale),style: const TextStyle(color: Colors.red)),
                                  onTap: () {
                                    isLoading.value = true;
                                    Navigator.pop(homeContext);
                                    requestLocationPermission();
                                  },
                                ),

                                ListTile(
                                  leading: const Icon(Icons.delete_outline,color: Colors.red),
                                  title: Text(ApiTextLocalizer.localize('Delete My Account', locale: locale),style: const TextStyle(color: Colors.red)),
                                  onTap: () {
                                    Navigator.pop(homeContext);
                                    model.dialog(homeContext,'Delete My Account ?','Could you please confirm that you want to permanently delete your account?');
                                  },
                                ),

                                Center(child: Text("Version: ${AppVersionService.fullVersion}"))
                              ],
                            ),
                          );
                        } else {
                          return EmptyData(emptyData: model.errorMessage);
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

}

class _AttendanceCard extends StatelessWidget {
  final ValueNotifier<DateTime> now;
  final HomeVM model;

  const _AttendanceCard({required this.now, required this.model});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final dateFmt = DateFormat('dd MMM yyyy');
    final dayFmt = DateFormat('EEEE');
    final timeFmt = DateFormat('hh:mm a');
    const actionButtonWidth = 108.0;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ApiTextLocalizer.localize('Attendance', locale: locale),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await model.loadAttendanceHistory(DateTime.now());
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      cusNavigate(
                        AttendanceSwipesScreen(
                          model: model,
                          locale: locale,
                          timeFmt: timeFmt,
                          dateFmt: dateFmt,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    ApiTextLocalizer.localize('View Swipes', locale: locale),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ValueListenableBuilder<DateTime>(
              valueListenable: now,
              builder: (context, n, _) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _kv(
                        ApiTextLocalizer.localize("Today's Date", locale: locale),
                        dateFmt.format(n),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _kv(
                        ApiTextLocalizer.localize("Today's Day", locale: locale),
                        dayFmt.format(n),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _kv(
                        ApiTextLocalizer.localize('Current Time', locale: locale),
                        timeFmt.format(n),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<bool>(
              valueListenable: model.attendanceLoading,
              builder: (context, loading, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: model.attendanceSignedIn,
                  builder: (context, signedIn, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<DateTime?>(
                            valueListenable: model.attendanceSignInAt,
                            builder: (context, inAt, _) {
                              final txt = inAt == null ? '-' : timeFmt.format(inAt);
                              return _kv(ApiTextLocalizer.localize('First Sign In', locale: locale), txt);
                            },
                          ),
                        ),
                        Expanded(
                          child: ValueListenableBuilder<DateTime?>(
                            valueListenable: model.attendanceSignOutAt,
                            builder: (context, outAt, _) {
                              final txt = outAt == null ? '-' : timeFmt.format(outAt);
                              return _kv(ApiTextLocalizer.localize('Last Sign Out', locale: locale), txt);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: actionButtonWidth,
                          height: 40,
                          child: loading
                              ? const Center(
                                  child: SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              // LastActivity == 1 => show Sign Out button
                              // LastActivity == 0 => show Sign In button
                              : (signedIn
                                  ? FilledButton(
                                      onPressed: () async {
                                        await model.attendanceSignOut(context);
                                      },
                                      child: Text(
                                        ApiTextLocalizer.localize('Sign Out', locale: locale),
                                        maxLines: 1,
                                        overflow: TextOverflow.visible,
                                        softWrap: false,
                                      ),
                                    )
                                  : FilledButton(
                                      onPressed: () async {
                                        await model.attendanceSignIn(context);
                                      },
                                      child: Text(
                                        ApiTextLocalizer.localize('Sign In', locale: locale),
                                        maxLines: 1,
                                        overflow: TextOverflow.visible,
                                        softWrap: false,
                                      ),
                                    )),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(
          v,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

}

class AttendanceSwipesScreen extends StatelessWidget {
  final HomeVM model;
  final Locale locale;
  final DateFormat timeFmt;
  final DateFormat dateFmt;

  const AttendanceSwipesScreen({
    super.key,
    required this.model,
    required this.locale,
    required this.timeFmt,
    required this.dateFmt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Swipes'),
      ),
      body: _AttendanceSwipesSheet(
        model: model,
        locale: locale,
        timeFmt: timeFmt,
        dateFmt: dateFmt,
      ),
    );
  }
}

class _AttendanceSwipesSheet extends StatefulWidget {
  final HomeVM model;
  final Locale locale;
  final DateFormat timeFmt;
  final DateFormat dateFmt;

  const _AttendanceSwipesSheet({
    required this.model,
    required this.locale,
    required this.timeFmt,
    required this.dateFmt,
  });

  @override
  State<_AttendanceSwipesSheet> createState() => _AttendanceSwipesSheetState();
}

class _AttendanceSwipesSheetState extends State<_AttendanceSwipesSheet> {
  int _recordsPerPage = 50;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: ValueListenableBuilder<List<AttendanceHistoryRow>>(
          valueListenable: widget.model.attendanceHistory,
          builder: (context, historyRows, _) {
            final pagedRows = historyRows.take(_recordsPerPage).toList();
            return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Today\'s Swipes ( ${widget.dateFmt.format(DateTime.now())} )',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC57B33),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _recordsPerPage,
                                  isDense: true,
                                  items: const [10, 20, 30, 40, 50]
                                      .map(
                                        (count) => DropdownMenuItem<int>(
                                          value: count,
                                          child: Text('$count pages'),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _recordsPerPage = value);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 700),
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      const Color(0xFFE8EEF6),
                                    ),
                                    columnSpacing: 36,
                                    columns: [
                                      DataColumn(label: Text('Sr No')),
                                      DataColumn(label: Text('Time')),
                                      DataColumn(
                                        label: Text(
                                          'Sign In /\nSign Out',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      DataColumn(label: Text('Login Mode')),
                                      DataColumn(label: Text('Address')),
                                    ],
                                    rows: pagedRows.isEmpty
                                        ? [
                                            DataRow(
                                              cells: [
                                                const DataCell(SizedBox.shrink()),
                                                DataCell(Text('No Records Found.')),
                                                const DataCell(SizedBox.shrink()),
                                                const DataCell(SizedBox.shrink()),
                                                const DataCell(SizedBox.shrink()),
                                              ],
                                            ),
                                          ]
                                        : pagedRows
                                            .map(
                                              (row) => DataRow(
                                                cells: [
                                                  DataCell(Text(row.srNo.toString())),
                                                  DataCell(Text(row.time)),
                                                  DataCell(Text(row.signInOrSignOut)),
                                                  DataCell(Text(row.loginMode)),
                                                  DataCell(_addressCell(row.address)),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
          },
        ),
      ),
    );
  }

  Widget _addressCell(String address) {
    final trimmed = address.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return const Text('-');
    }

    const previewLen = 28;
    final isLong = trimmed.length > previewLen;
    final preview = isLong ? '${trimmed.substring(0, previewLen)}...' : trimmed;

    if (!isLong) {
      return Text(preview);
    }

    return SizedBox(
      width: 220,
      child: Row(
        children: [
          Expanded(
            child: Text(
              preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => _showAddressDialog(trimmed),
            child: const Text(
              'Read more',
              style: TextStyle(
                color: AppColor.background,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressDialog(String address) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Address'),
          content: SingleChildScrollView(
            child: Text(address),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

/// Renders only menus returned by the menu API (called after login with tokenID).
/// No hardcoded menus. "No Module Assigned" only when API returned empty or null (never before response).
class _HomeMenuGrid extends StatelessWidget {
  final Size size;
  final List<MenuItem> menuItems;
  final VoidCallback onNavigate;

  const _HomeMenuGrid({
    required this.size,
    required this.menuItems,
    required this.onNavigate,
  });

  /// Order: Task, Client, Account Receivable, Document, then others.
  static List<MenuItem> _orderMenuItems(List<MenuItem> list) {
    int orderOf(MenuItem m) {
      final u = m.url.toLowerCase();
      if (u.contains('task')) return 0;
      if (u.contains('client') || u.contains('organisation') || u.contains('org')) return 1;
      if (u.contains('account') || u.contains('receivable') || u.contains('ar')) return 2;
      if (u.contains('document') || u.contains('doc')) return 3;
      return 4;
    }
    final copy = List<MenuItem>.from(list);
    copy.sort((a, b) => orderOf(a).compareTo(orderOf(b)));
    return copy;
  }

  static bool _isFullWidthItem(MenuItem m) {
    final u = m.url.toLowerCase();
    return u.contains('account') || u.contains('receivable') || u.contains('ar') ||
        u.contains('document') || u.contains('doc');
  }

  @override
  Widget build(BuildContext context) {
    if (menuItems.isEmpty) {
      final locale = Localizations.localeOf(context);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            ApiTextLocalizer.localize('No Module Assigned', locale: locale),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final items = _orderMenuItems(menuItems);
    final rows = <Widget>[];
    var i = 0;
    while (i < items.length) {
      final item = items[i];
      if (_isFullWidthItem(item)) {
        rows.add(Row(
          children: [
            Expanded(child: _menuTile(context, item, onNavigate)),
          ],
        ));
        i += 1;
      } else {
        final rowItems = <MenuItem>[item];
        if (i + 1 < items.length && !_isFullWidthItem(items[i + 1])) {
          rowItems.add(items[i + 1]);
          i += 2;
        } else {
          i += 1;
        }
        final rowChildren = <Widget>[];
        for (var j = 0; j < rowItems.length; j++) {
          if (j > 0) rowChildren.add(SizedBox(width: size.width * 0.02));
          // _menuTile already returns a widget with its own layout (HomeGird),
          // which wraps its content in Expanded. Do not wrap it again or
          // you'll get nested Expanded/ParentDataWidget errors.
          rowChildren.add(_menuTile(context, rowItems[j], onNavigate));
        }
        rows.add(Row(children: rowChildren));
      }
      if (i < items.length) {
        rows.add(SizedBox(height: size.height * 0.01));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _menuTile(BuildContext context, MenuItem item, VoidCallback onNavigate) {
    final url = item.url.toLowerCase();
    final locale = Localizations.localeOf(context);
    final name = () {
      if (url.contains('task')) return ApiTextLocalizer.localize('Task', locale: locale);
      if (url.contains('client') || url.contains('organisation') || url.contains('org')) {
        return ApiTextLocalizer.localize('Client', locale: locale);
      }
      if (url.contains('account') || url.contains('receivable') || url.contains('ar')) {
        return ApiTextLocalizer.localize('Account Receivable', locale: locale);
      }
      if (url.contains('document') || url.contains('doc')) return ApiTextLocalizer.localize('Document', locale: locale);
      // Unknown module from backend: show transliteration instead of raw English
      // when user selected a non-English app language.
      return ApiTextLocalizer.localize(item.name, locale: locale);
    }();

    if (url.contains('task')) {
      return HomeGird(
        name: name,
        image: AppImages.task,
        onTap: () {
          Navigator.push(context, cusNavigate(const ViewTasks())).then((_) {
            onNavigate();
          });
        },
      );
    }
    if (url.contains('client') || url.contains('organisation') || url.contains('org')) {
      return HomeGird(
        name: name,
        icon: CupertinoIcons.person,
        onTap: () {
          Navigator.push(context, cusNavigate(const ViewClient())).then((_) {
            onNavigate();
          });
        },
      );
    }
    if (url.contains('account') || url.contains('receivable') || url.contains('ar')) {
      return HomeGird(
        name: name,
        image: AppImages.AccountReceivable,
        onTap: () {
          Navigator.push(context, cusNavigate(const AccountReceivableScreen())).then((_) {
            onNavigate();
          });
        },
      );
    }
    if (url.contains('document') || url.contains('doc')) {
      return HomeGird(
        name: name,
        image: AppImages.document,
        onTap: () {
          Navigator.push(context, cusNavigate(const DocumentScreen()));
        },
      );
    }
    return HomeGird(
      name: name,
      icon: Icons.dashboard,
      onTap: () {
        if (item.url.startsWith('http')) {
          Navigator.push(context, cusNavigate(WebviewScreen(title: name, url: item.url)));
        }
      },
    );
  }
}

locationDialog({
  required BuildContext context,
  required VoidCallback onTapGotIt,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            width: 300,
            padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Enable Location Service",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                (Platform.isIOS)
                    ? const Text("Enable location service on your device inside Setting -> Privacy -> Location Service.", textAlign: TextAlign.center,)
                    : const Text("Enable location service on your device Setting.", textAlign: TextAlign.center,),
                const SizedBox(height: 15),
                CusBtn(
                  btnName: "OK, GOT IT!",
                  onTap: onTapGotIt,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ignore: non_constant_identifier_names
Widget HomeGird({VoidCallback? onTap, IconData? icon, String? image, required String name}){
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Card(
        surfaceTintColor: Colors.white,
        color: Colors.white,
        elevation: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  (icon != null)
                      ? Icon(icon, color: AppColor.background)
                      : Image.asset(
                          image!,
                          width: 25,
                          color: AppColor.background,
                        ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColor.background,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
