import 'package:flutter/material.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class NavigationService {
  /// Creating the first instance
  static final NavigationService _instance = NavigationService._internal();
  NavigationService._internal();

  /// With this factory setup, any time  NavigationService() is called
  /// within the appication _instance will be returned and not a new instance
  factory NavigationService() => _instance;

  ///This would allow the app monitor the current screen state during navigation.
  ///
  ///This is where the singleton setup we did
  ///would help as the state is internally maintained
  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();


  /// For navigating back to the previous screen
  static dynamic pop([dynamic popValue]) {
    return _instance.navigationKey.currentState?.pop(popValue);
  }

  /// This allows you to naviagte to the next screen by passing the screen widget
  static Future<dynamic> push(Widget page, {arguments}) async =>
      _instance.navigationKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => page,
        ),
      );

  static Future<dynamic> pushNamed(String name, {arguments}) async {
    LoggerService.instance.info("pushing to $name");
    return _instance.navigationKey.currentState
        ?.pushNamed(name, arguments: arguments);
  }

  /// This allows you to naviagte to the next screen and
  /// also replace the current screen by passing the screen widget
  static Future<dynamic> replaceScreen(Widget page, {arguments}) async =>
      _instance.navigationKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => page,
        ),
      );

  /// Allows you to pop to the first screen to when the app first launched.
  /// This is useful when you need to log out a user,
  /// and also remove all the screens on the navigation stack.
  /// I find this very useful
  static void popToFirst() =>
      _instance.navigationKey.currentState?.popUntil((route) => route.isFirst);
}
