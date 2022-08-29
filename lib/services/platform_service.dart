import 'dart:io';

class PlatformService {
  PlatformService._privateConstructor();

  static final PlatformService _instance =
      PlatformService._privateConstructor();

  static PlatformService get instance => _instance;

  bool isIos = true;
//  bool isIos = Platform.isIOS;
  bool isAndroid = Platform.isAndroid;
  bool isFuchsia = Platform.isFuchsia;
  bool isLinux = Platform.isLinux;
  bool isMacOS = Platform.isMacOS;
  bool isWindows = Platform.isWindows;
}
