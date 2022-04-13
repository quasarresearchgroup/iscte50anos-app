import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IscteTheme {
  static Color iscteColor = const Color.fromRGBO(14, 41, 194, 1);

  static AppBarTheme get appBarTheme {
    return AppBarTheme(
      //backgroundColor: Color.fromRGBO(14, 41, 194, 1),
      elevation: 0,
      // This removes the shadow from all App Bars.
      centerTitle: true,
      toolbarHeight: 55,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      backgroundColor: iscteColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: iscteColor,
        statusBarIconBrightness: Brightness.light, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
    );
  }

  static ThemeData get lightThemeData {
    return ThemeData.light().copyWith(
      primaryColor: iscteColor,
      errorColor: Colors.deepOrangeAccent,
      appBarTheme: appBarTheme,
    );
  }

  static ThemeData get darkThemeData {
    return ThemeData.dark().copyWith(
      primaryColor: iscteColor,
      errorColor: Colors.deepOrangeAccent,
      appBarTheme: appBarTheme,
    );
  }
}
