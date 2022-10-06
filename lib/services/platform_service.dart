import 'dart:io';

import 'package:flutter/foundation.dart';

class PlatformService {
  PlatformService._privateConstructor();

  static final PlatformService _instance =
      PlatformService._privateConstructor();

  static PlatformService get instance => _instance;

  bool isIos = true;
//  bool isIos = Platform.isIOS;
  bool isAndroid = false;
  bool isFuchsia = false;
  bool isLinux = false;
  bool isMacOS = false;
  bool isWindows = false;
  bool isWeb = kIsWeb;
}
