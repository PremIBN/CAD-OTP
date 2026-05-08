import 'package:cadashboard/core/services/fcm_token_sync.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/ui/widget/language_selection_sheet.dart';
import 'dart:io' show Platform;
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

  Future<void> _showEnableInPhoneSettingsDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _onNotificationToggle(bool wantOn) async {
    final prefs = await SharedPreferences.getInstance();
    if (wantOn) {
      // Do not trigger the system permission prompt from the in-app Settings toggle.
      // If OS permission is already granted, we can enable the in-app flag.
      // Otherwise, guide the user to enable it from Phone Settings.
      final status = await Permission.notification.status;
      if (!mounted) return;
      if (_osAllowsNotif(status)) {
        await prefs.setBool(PreferenceHelper.appNotificationsUserEnabled, true);
        await registerFcmTokenAndRequestPlatformPermission();
        await _load();
        return;
      }

      await _showEnableInPhoneSettingsDialog(
        title: 'Enable Notifications',
        message: Platform.isIOS
            ? 'To enable notifications, go to iPhone Settings → Notifications → CADashboard → turn ON “Allow Notifications”.'
            : 'To enable notifications, go to Phone Settings → Apps → CADashboard → Notifications → Allow.',
      );
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
      // Do not trigger the system permission prompt from the in-app Settings toggle.
      // If OS permission is already granted, we can enable the in-app flag.
      // Otherwise, guide the user to enable it from Phone Settings.
      final status = await Permission.microphone.status;
      if (!mounted) return;
      if (status.isGranted) {
        await prefs.setBool(PreferenceHelper.appMicrophoneUserEnabled, true);
        await _load();
        return;
      }

      await _showEnableInPhoneSettingsDialog(
        title: 'Enable Microphone',
        message: Platform.isIOS
            ? 'To enable microphone, go to iPhone Settings → Privacy → Microphone → turn ON “CADashboard”.'
            : 'To enable microphone, go to Phone Settings → Apps → CADashboard → Permissions → Microphone.',
      );
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
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: const Text('Change app language'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await LanguageSelectionSheet.show(context, dismissible: true);
                  },
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
