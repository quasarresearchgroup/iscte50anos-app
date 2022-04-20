import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IscteTheme {
  static Color iscteColor = const Color.fromRGBO(14, 41, 194, 1);
  static Radius appbarRadius = Radius.circular(20);

  static AppBarTheme get appBarTheme {
    return AppBarTheme(
      //backgroundColor: Color.fromRGBO(14, 41, 194, 1),
      elevation: 0,
      // This removes the shadow from all App Bars.
      centerTitle: true,
      toolbarHeight: 55,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: IscteTheme.appbarRadius,
        ),
      ),
      backgroundColor: iscteColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: iscteColor,
        systemNavigationBarColor: iscteColor,
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
      scaffoldBackgroundColor: Colors.black,
      backgroundColor: Colors.black,
      primaryColor: iscteColor,
      errorColor: Colors.deepOrangeAccent,
      appBarTheme: appBarTheme,
    );
  }
}
