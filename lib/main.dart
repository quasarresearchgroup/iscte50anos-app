import 'package:ISCTE_50_Anos/pages/menu.dart';
import 'package:ISCTE_50_Anos/pages/pages.dart';
import 'package:ISCTE_50_Anos/pages/qr_scan_page.dart';
import 'package:ISCTE_50_Anos/pages/timeline_page.dart';
import 'package:ISCTE_50_Anos/widgets/my_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String appTitle = "";
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/timeline': (context) => TimelinePage(),
        '/pages': (context) => const VisitedPagesPage(),
      },
    );
  }
}

class Home extends StatefulWidget {
  Home({
    Key? key,
  }) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  late List _appScreens;

  @override
  void initState() {
    super.initState();
    _appScreens = [
      MyMenu(
        updateIndex: updateIndex,
        changeScreen: changeScreen,
      ),
      QRScanPage(),
    ];
  }

  void changeScreen(Widget newPage, Scaffold scaffold) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => newPage));
  }

  void updateIndex(int value) {
    setState(() {
      _currentIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Title(
              color: Colors.black,
              child: Text(AppLocalizations.of(context)!.appName)),
        ),
        body: _appScreens[_currentIndex],
        bottomNavigationBar: MyBottomBar(
          updateIndex: updateIndex,
        ),
      );
}
