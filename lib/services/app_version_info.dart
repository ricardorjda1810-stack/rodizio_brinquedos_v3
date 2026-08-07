import 'package:package_info_plus/package_info_plus.dart';

typedef AppVersionInfoLoader = Future<AppVersionInfo> Function();

class AppVersionInfo {
  AppVersionInfo({required String version, required String buildNumber})
      : version = version.trim(),
        buildNumber = buildNumber.trim();

  const AppVersionInfo.empty()
      : version = '',
        buildNumber = '';

  final String version;
  final String buildNumber;
}

Future<AppVersionInfo> loadAppVersionInfoFromPlatform() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return AppVersionInfo(
    version: packageInfo.version,
    buildNumber: packageInfo.buildNumber,
  );
}

Future<AppVersionInfo> loadAppVersionInfoSafely([
  AppVersionInfoLoader? loader,
]) async {
  try {
    final info = await (loader ?? loadAppVersionInfoFromPlatform)();
    return AppVersionInfo(
      version: info.version,
      buildNumber: info.buildNumber,
    );
  } catch (_) {
    return const AppVersionInfo.empty();
  }
}
