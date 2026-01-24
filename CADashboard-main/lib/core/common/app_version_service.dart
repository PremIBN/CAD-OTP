import 'package:package_info_plus/package_info_plus.dart';

class AppVersionService {
  static String? _version;
  static String? _buildNumber;
  static String? _appName;
  static String? _packageName;

  /// Initializes and caches app version info.
  static Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    _version = info.version;
    _buildNumber = info.buildNumber;
    _appName = info.appName;
    _packageName = info.packageName;
  }

  static String get version => _version ?? 'Unknown';
  static String get buildNumber => _buildNumber ?? 'Unknown';
  static String get appName => _appName ?? 'Unknown';
  static String get packageName => _packageName ?? 'Unknown';

  /// Returns version in `vX.Y.Z+buildNumber` format
  static String get fullVersion => 'v$version+$buildNumber';
}
