import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:iscte_spots/pages/home/nav_drawer/page_routes.dart';
import 'package:iscte_spots/pages/home/splashScreen/splash.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

const int puzzlePageIndex = 0;
const int qrPageIndex = 1;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static Future<Widget> _buildPageAsync({required Widget page}) async {
    return Future.microtask(
      () {
        return page;
      },
    );
  }
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformService.instance.isIos) {
      final Brightness platformBrightness =
          WidgetsBinding.instance.window.platformBrightness;
      return CupertinoApp(
        builder: (BuildContext context, Widget? child) => Theme(
          data: (platformBrightness == Brightness.dark)
              ? IscteTheme.darkThemeData
              : IscteTheme.lightThemeData,
          child: IconTheme(
            data: CupertinoIconThemeData(
              color: CupertinoTheme.of(context).primaryContrastingColor,
            ),
            child: child ?? Container(),
          ),
        ),
        debugShowCheckedModeBanner: false,
        title: 'IscteSpots',
        theme: (platformBrightness == Brightness.dark)
            ? IscteTheme.cupertinoDarkThemeData
            : IscteTheme.cupertinoLightThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashScreen(),
        onGenerateRoute: generatedRoutes,
      );
    } else {
      return MaterialApp(
        //showSemanticsDebugger: true,
        debugShowCheckedModeBanner: false,
        title: 'IscteSpots',
        darkTheme: IscteTheme.darkThemeData,
        theme: IscteTheme.lightThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashScreen(),
        onGenerateRoute: generatedRoutes,
      );
    }
  }

  Route? generatedRoutes(RouteSettings routeSettings) {
    Widget widget =
        PageRouter.resolve(routeSettings.name ?? "", routeSettings.arguments);
    //var buildPageAsync = await _buildPageAsync(page: widget);
    return PageRouteBuilder(
      transitionDuration: const Duration(seconds: 1),
      maintainState: true,
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Animatable<Offset> tween =
            Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
          CurveTween(curve: Curves.ease),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
