import 'package:cadashboard/core/services/fcm_token_sync.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/ui/widget/language_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPermissionsSettingsScreen extends StatefulWidget {
  const AppPermissionsSettingsScreen({super.key});

  @override
  State<AppPermissionsSettingsScreen> createState() => _AppPermissionsSettingsScreenState();
}

class _AppPermissionsSettingsScreenState extends State<AppPermissionsSettingsScreen>
    with WidgetsBindingObserver {
  PermissionStatus? _notif;
  PermissionStatus? _mic;
  bool _notifUserOn = true;
  bool _micUserOn = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final notif = await Permission.notification.status;
    final mic = await Permission.microphone.status;
    if (!mounted) return;
    setState(() {
      _notif = notif;
      _mic = mic;
      _notifUserOn = prefs.getBool(PreferenceHelper.appNotificationsUserEnabled) ?? true;
      _micUserOn = prefs.getBool(PreferenceHelper.appMicrophoneUserEnabled) ?? true;
    });
  }

  bool _osAllowsNotif(PermissionStatus? s) =>
      s != null && (s.isGranted || s.isLimited);

  bool _osAllowsMic(PermissionStatus? s) => s != null && s.isGranted;

  String _notifSubtitle() {
    final s = _notif;
    if (s == null) return '';
    if (!_osAllowsNotif(s)) {
      if (s.isPermanentlyDenied) return 'Blocked';
      if (s.isDenied) return 'Not allowed';
      if (s.isRestricted) return 'Restricted';
      return 'Unknown';
    }
    return _notifUserOn ? 'Allowed' : 'Off';
  }

  String _micSubtitle() {
    final s = _mic;
    if (s == null) return '';
    if (!_osAllowsMic(s)) {
      if (s.isPermanentlyDenied) return 'Blocked';
      if (s.isDenied) return 'Not allowed';
      if (s.isRestricted) return 'Restricted';
      return 'Unknown';
    }
    return _micUserOn ? 'Allowed' : 'Off';
  }

  bool get _notifSwitchOn => _osAllowsNotif(_notif) && _notifUserOn;

  bool get _micSwitchOn => _osAllowsMic(_mic) && _micUserOn;

  Future<void> _onNotificationToggle(bool wantOn) async {
    final prefs = await SharedPreferences.getInstance();
    if (wantOn) {
      final result = await Permission.notification.request();
      if (!mounted) return;
      if (result.isPermanentlyDenied) {
        await openAppSettings();
        await _load();
        return;
      }
      if (_osAllowsNotif(result)) {
        await prefs.setBool(PreferenceHelper.appNotificationsUserEnabled, true);
        await registerFcmTokenAndRequestPlatformPermission();
      }
      await _load();
      return;
    }

    await prefs.setBool(PreferenceHelper.appNotificationsUserEnabled, false);
    if (!mounted) return;
    setState(() => _notifUserOn = false);
  }

  Future<void> _onMicrophoneToggle(bool wantOn) async {
    final prefs = await SharedPreferences.getInstance();
    if (wantOn) {
      final result = await Permission.microphone.request();
      if (!mounted) return;
      if (result.isPermanentlyDenied) {
        await openAppSettings();
        await _load();
        return;
      }
      if (result.isGranted) {
        await prefs.setBool(PreferenceHelper.appMicrophoneUserEnabled, true);
      }
      await _load();
      return;
    }

    await prefs.setBool(PreferenceHelper.appMicrophoneUserEnabled, false);
    if (!mounted) return;
    setState(() => _micUserOn = false);
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: const Locale('en'),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(title: const Text('App settings')),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: ListTile(
                  leading: Image.asset('assets/images/language.png', width: 22, height: 22),
                  title: const Text('Language'),
                  subtitle: const Text('Change app language'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => LanguageSelectionSheet.show(context),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  subtitle: Text(_notifSubtitle()),
                  trailing: Switch(
                    value: _notifSwitchOn,
                    onChanged: _onNotificationToggle,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.mic),
                  title: const Text('Microphone'),
                  subtitle: Text(_micSubtitle()),
                  trailing: Switch(
                    value: _micSwitchOn,
                    onChanged: _onMicrophoneToggle,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
