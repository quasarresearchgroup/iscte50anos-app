import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IscteTheme {
  static const Color iscteColor = Color.fromRGBO(13, 40, 194, 1);
  static const Color iscteColorSmooth = Color.fromRGBO(13, 40, 194, .3);

  //static const Color iscteColorSmooth = Color(0xFF00A4FF);
  static const Color greyColor = Color.fromRGBO(245, 244, 242, 1);

  //static const Color iscteColorLight = iscteColor.withGreen(iscteColor.green + 100);
  //static const Color iscteColorDark = iscteColor.withGreen(iscteColor.green - 100);
  static const Radius appbarRadius = Radius.circular(20);

  static const BorderRadius borderRadious =
      BorderRadius.all(Radius.circular(10));

  static const AppBarTheme _appBarTheme = AppBarTheme(
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
    backgroundColor: Colors.transparent,
    //color: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.black),
    actionsIconTheme: IconThemeData(color: Colors.black),
/*    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: iscteColor,
      systemNavigationBarColor: iscteColor,
      statusBarIconBrightness: Brightness.light, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
    ),*/
  );

  static const NavigationRailThemeData _navigationRailThemeData =
      NavigationRailThemeData(
    backgroundColor: iscteColor,
    selectedIconTheme: IconThemeData(color: Colors.black),
    unselectedIconTheme: IconThemeData(color: Colors.black54),
    useIndicator: false,
  );

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor:
            MaterialStateColor.resolveWith((states) => Colors.white),
        backgroundColor: MaterialStateColor.resolveWith((states) => iscteColor),
      ),
    );
  }

  static ThemeData get lightThemeData {
    return ThemeData.light().copyWith(
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: iscteColor,
      ),
      scaffoldBackgroundColor: Colors.white,
      backgroundColor: Colors.white,
      primaryColor: Colors.white,
      errorColor: Colors.deepOrangeAccent,
      bottomAppBarColor: Colors.white,
      iconTheme: ThemeData.light().iconTheme.copyWith(color: iscteColor),
      appBarTheme: _appBarTheme,
      navigationRailTheme: _navigationRailThemeData,
      textTheme: ThemeData.light().textTheme.apply(
            fontFamily: 'Montserrat',
          ),
      primaryTextTheme: ThemeData.light().textTheme.apply(
            fontFamily: 'Montserrat',
          ),
      buttonTheme: ThemeData.light().buttonTheme.copyWith(
            buttonColor: iscteColor,
          ),
      chipTheme:
          ThemeData.light().chipTheme.copyWith(backgroundColor: greyColor),
      checkboxTheme: ThemeData.light().checkboxTheme.copyWith(
            fillColor: const MaterialStatePropertyAll(iscteColor),
          ),
      textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(iscteColor))),
      elevatedButtonTheme: _elevatedButtonTheme,
    );
  }

/*
  static ThemeData darkThemeData = ThemeData.dark().copyWith(
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(backgroundColor: iscteColor),
    // scaffoldBackgroundColor: Colors.black,
    // backgroundColor: Colors.black,
    primaryColor: iscteColor,
    errorColor: Colors.deepOrangeAccent,
    bottomAppBarColor: iscteColor,
    iconTheme: const IconThemeData(color: Colors.white),
    appBarTheme: _appBarTheme,
    navigationRailTheme: navigationRailThemeData,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateColor.resolveWith((states) => iscteColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor:
            MaterialStateColor.resolveWith((states) => Colors.white),
        backgroundColor: MaterialStateColor.resolveWith((states) => iscteColor),
      ),
    ),
  );
*/
  static CupertinoThemeData cupertinoLightThemeData = const CupertinoThemeData(
    //barBackgroundColor: IscteTheme.iscteColor,
    scaffoldBackgroundColor: CupertinoColors.white,
    brightness: Brightness.light,
    primaryContrastingColor: CupertinoColors.black,
    primaryColor: IscteTheme.iscteColor,
    //primaryColor: CupertinoColors.white,
  );

/*
  static CupertinoThemeData cupertinoDarkThemeData = const CupertinoThemeData(
    //barBackgroundColor: IscteTheme.iscteColor,
    scaffoldBackgroundColor: CupertinoColors.black,
    primaryContrastingColor: CupertinoColors.white,
    brightness: Brightness.dark,
    primaryColor: IscteTheme.iscteColor,
  );
*/
  static InputDecoration buildInputDecoration(
      {required String hint, String? errorText, Widget? suffixIcon}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.only(left: 25, right: 25),
      border: const UnderlineInputBorder(
          //border: OutlineInputBorder(
          borderRadius: BorderRadius.all(IscteTheme.appbarRadius)),
      hintText: hint,
      errorText: errorText,
      suffixIcon: suffixIcon,
      alignLabelWithHint: true,
    );
  }
}
