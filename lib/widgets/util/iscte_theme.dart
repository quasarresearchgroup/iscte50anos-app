import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IscteTheme {
  static Color iscteColor = const Color.fromRGBO(14, 41, 194, 1);
  //static Color iscteColorLight = iscteColor.withGreen(iscteColor.green + 100);
  //static Color iscteColorDark = iscteColor.withGreen(iscteColor.green - 100);
  static Radius appbarRadius = const Radius.circular(20);

  static AppBarTheme get _appBarTheme {
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: iscteColor,
      ),
      scaffoldBackgroundColor: Colors.white,
      backgroundColor: Colors.white,
      primaryColor: iscteColor,
      errorColor: Colors.deepOrangeAccent,
      bottomAppBarColor: iscteColor,
      primaryIconTheme: IconThemeData(color: Colors.black),
      appBarTheme: _appBarTheme,
    );
  }

  static ThemeData get darkThemeData {
    return ThemeData.dark().copyWith(
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: iscteColor),
        scaffoldBackgroundColor: Colors.black,
        backgroundColor: Colors.black,
        primaryColor: iscteColor,
        errorColor: Colors.deepOrangeAccent,
        bottomAppBarColor: iscteColor,
        appBarTheme: _appBarTheme,
        primaryIconTheme: IconThemeData(color: Colors.white));
  }

  static CupertinoThemeData get cupertinoLightThemeData {
    return CupertinoThemeData(
      barBackgroundColor: CupertinoColors.white,
      scaffoldBackgroundColor: CupertinoColors.white,
      brightness: Brightness.light,
      primaryContrastingColor: CupertinoColors.black,
      primaryColor: IscteTheme.iscteColor,
    );
  }

  static CupertinoThemeData get cupertinoDarkThemeData {
    return CupertinoThemeData(
      barBackgroundColor: CupertinoColors.black,
      scaffoldBackgroundColor: CupertinoColors.black,
      primaryContrastingColor: CupertinoColors.white,
      brightness: Brightness.dark,
      primaryColor: IscteTheme.iscteColor,
    );
  }

  static InputDecoration buildInputDecoration(
      {required String hint, String? errorText, Widget? suffixIcon}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.only(left: 25, right: 25),
      border: UnderlineInputBorder(
          //border: OutlineInputBorder(
          borderRadius: BorderRadius.all(IscteTheme.appbarRadius)),
      hintText: hint,
      errorText: errorText,
      suffixIcon: suffixIcon,
      alignLabelWithHint: true,
    );
  }
}
