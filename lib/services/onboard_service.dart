import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboadingService {
  static const String _onboardKey = "onboard";
  static final Logger _logger = Logger();

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isOnboarded = prefs.getBool(OnboadingService._onboardKey);
    _logger.d("isOnboarded : $isOnboarded");
    return isOnboarded ?? false;
  }

  static Future<bool> storeOnboard() async {
    final prefs = await SharedPreferences.getInstance();
    bool boola = await prefs.setBool(OnboadingService._onboardKey, true);
    _logger.d("storeOnboard : $boola");
    return boola;
  }

  static Future<bool> removeOnboard() async {
    final prefs = await SharedPreferences.getInstance();
    bool boola = await prefs.setBool(OnboadingService._onboardKey, false);
    _logger.d("removedOnboard : $boola");
    return boola;
  }
}
