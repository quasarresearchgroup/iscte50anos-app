
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboadingService {
  static const String _onboardKey = "onboard";
  

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isOnboarded = prefs.getBool(OnboadingService._onboardKey);
    LoggerService.instance.debug("isOnboarded : $isOnboarded");
    return isOnboarded ?? false;
  }

  static Future<bool> storeOnboard() async {
    final prefs = await SharedPreferences.getInstance();
    bool boola = await prefs.setBool(OnboadingService._onboardKey, true);
    LoggerService.instance.debug("storeOnboard : $boola");
    return boola;
  }

  static Future<bool> removeOnboard() async {
    final prefs = await SharedPreferences.getInstance();
    bool boola = await prefs.setBool(OnboadingService._onboardKey, false);
    LoggerService.instance.debug("removedOnboard : $boola");
    return boola;
  }
}
