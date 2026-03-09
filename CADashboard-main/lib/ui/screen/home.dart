import 'dart:async';
import 'dart:io';
import 'package:cadashboard/core/View_Model/home_vm.dart';
import 'package:cadashboard/core/repository/menu_repository.dart';
import 'package:cadashboard/core/common/app_version_service.dart';
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
import 'package:cadashboard/ui/screen/change_password_screen.dart';
import 'package:cadashboard/ui/screen/login_screen.dart';
import 'package:cadashboard/ui/screen/notification_screen.dart';
import 'package:cadashboard/ui/screen/document/document_screen.dart';
import 'package:cadashboard/ui/screen/client/view_client.dart';
import 'package:cadashboard/ui/screen/task/view_task.dart';
import 'package:cadashboard/ui/screen/webview_screen.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:cadashboard/ui/widget/greeting_widget.dart';
import 'package:cadashboard/ui/widget/screen_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
                                SizedBox(height: size.height * 0.02,),
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
                                            Text('Hello, ',style: TextStyle(fontSize: greetingTextSize)),
                                            GreetingWidget(size: greetingTextSize,)
                                          ],
                                        ),
                                        Text(model.userName,style: TextStyle(fontSize: greetingTextSize)),
                                        const Divider(height: 20,),
                                      ],
                                    ),
                                  ),
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
                                  leading: const Icon(Icons.lock_outline),
                                  title: const Text('Change Password'),
                                  onTap: () {
                                    Navigator.pop(homeContext);
                                    Navigator.push(homeContext, cusNavigate(const ChangePasswordScreen()));
                                  },
                                ),

                                ListTile(
                                  leading: const Icon(Icons.info_outline_rounded),
                                  title: const Text('About us'),
                                  onTap: () {
                                    Navigator.pop(homeContext);
                                    Navigator.push(homeContext, cusNavigate(const AboutUsScreen()));
                                  },
                                ),

                                ListTile(
                                  leading: Image.asset(AppImages.privacyPolicy,width: 27),
                                  title: const Text('Privacy Policy'),
                                  onTap: () {
                                    Navigator.pop(homeContext);
                                    Navigator.push(homeContext, cusNavigate(const WebviewScreen(title: 'Privacy Policy', url: Urls.privacy_policy)));
                                  },
                                ),

                                ListTile(
                                  contentPadding: const EdgeInsets.only(left: 22),
                                  leading: Image.asset(AppImages.termsCondition,width: 23),
                                  title: const Text('Terms & Condition'),
                                  onTap: () {
                                    Navigator.pop(homeContext);
                                    Navigator.push(homeContext, cusNavigate(const WebviewScreen(title: 'Terms & Condition', url: Urls.termsAndCondition)));
                                  },
                                ),

                                Divider(height: size.height * 0.03,),
                                ListTile(
                                  leading: const Icon(Icons.logout,color: Colors.red),
                                  title: const Text('Logout',style: TextStyle(color: Colors.red)),
                                  onTap: () {
                                    isLoading.value = true;
                                    Navigator.pop(homeContext);
                                    requestLocationPermission();
                                  },
                                ),

                                ListTile(
                                  leading: const Icon(Icons.delete_outline,color: Colors.red),
                                  title: const Text('Delete My Account',style: TextStyle(color: Colors.red)),
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No Module Assigned',
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
    final name = item.name;

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
