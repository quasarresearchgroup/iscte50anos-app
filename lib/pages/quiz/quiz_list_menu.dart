import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/widgets/util/constants.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:logger/logger.dart';

//const API_ADDRESS = "http://192.168.1.124";

//const API_ADDRESS_PROD = "https://194.210.120.48";
//const API_ADDRESS_TEST = "http://192.168.1.124";

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

// FOR ISOLATED TESTING
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuizMenu());
}

class QuizMenu extends StatefulWidget {
  static const pageRoute = "/quiz";

  const QuizMenu({Key? key}) : super(key: key);

  @override
  State<QuizMenu> createState() => _QuizMenuState();
}

class _QuizMenuState extends State<QuizMenu>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final Logger logger = Logger();
  late TabController _tabController;
  int _selectedIndex = 0;

  //late Map<String, dynamic> affiliationMap;

  /*Future<String> loadAffiliationData() async {
    var jsonText =
        await rootBundle.loadString('Resources/affiliations_abbr.json');
    setState(
        () => affiliationMap = json.decode(utf8.decode(jsonText.codeUnits)));
    return 'success';
  }*/

  /*
  static const List<Widget> _pages = <Widget>[
    GlobalLeaderboard(),
    AffiliationLeaderboard(),
  ];
  */

  //Page Selection Mechanics
  void _onItemTapped(int index) {
    setState(() {
      _tabController.animateTo(index);
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  void initState() {
    super.initState();
    //loadAffiliationData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    /*AppBarTheme appBarTheme = const AppBarTheme(
      elevation: 0, // This removes the shadow from all App Bars.
      centerTitle: true,
      toolbarHeight: 55,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );

    var darkTheme = ThemeData.dark();

    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: const Color.fromRGBO(14, 41, 194, 1),
        appBarTheme: appBarTheme.copyWith(
          backgroundColor: const Color.fromRGBO(14, 41, 194, 1),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color.fromRGBO(14, 41, 194, 1),
            statusBarIconBrightness:
                Brightness.light, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
          appBarTheme: appBarTheme.copyWith(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: darkTheme.bottomAppBarColor,
          statusBarIconBrightness: Brightness.light, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
      )),
      home:*/
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Quiz"), //AppLocalizations.of(context)!.quizPageTitle)
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: const QuizListPage(),/*TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: _pages,
        ),*/ // _pages[_selectedIndex],

      ),
      /*bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: IscteTheme.appbarRadius,
          topRight: IscteTheme.appbarRadius,
        ),
        child: BottomNavigationBar(
          //type: BottomNavigationBarType.shifting,
          type: BottomNavigationBarType.shifting,
          backgroundColor: Theme.of(context).primaryColor,
          selectedItemColor: Theme.of(context).selectedRowColor,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor,
          elevation: 8,
          enableFeedback: true,
          iconSize: 30,
          selectedFontSize: 13,
          unselectedFontSize: 10,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          //selectedItemColor: Colors.amber[800],
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.globe),
              backgroundColor: Theme.of(context).primaryColor,
              label: 'Global',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.group),
              backgroundColor: Theme.of(context).primaryColor,
              label: 'Afiliação',
            ),
          ],
        ),
      ),*/
    );
  }
}

class QuizListPage extends StatelessWidget {
  const QuizListPage({Key? key}) : super(key: key);

  Future<List<dynamic>> fetchQuizList() async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");

      HttpClient client = HttpClient();
      client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/quizzes'));
      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();

      if (response.statusCode == 200) {
        return jsonDecode(await response.transform(utf8.decoder).join());
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }
    throw Exception('Failed to load quizzes');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          // Container to hold the description
          height: 50,
          child: Center(
            child: Text("Quizzes disponíveis",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        Expanded(child: QuizList(fetchFunction: fetchQuizList)),
      ],
    );
  }
}

class QuizList extends StatefulWidget {
  final Future<List<dynamic>> Function() fetchFunction;

  const QuizList({Key? key, required this.fetchFunction})
      : super(key: key);

  @override
  _QuizListState createState() => _QuizListState();
}

class _QuizListState extends State<QuizList> {
  late Future<List<dynamic>> futureQuizList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureQuizList = widget.fetchFunction();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureQuizList,
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          var items = snapshot.data as List<dynamic>;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                if (!isLoading) {
                  futureQuizList = widget.fetchFunction();
                }
              });
            },
            child: items.isEmpty
                ? const Center(child: Text("Não existem Quizzes disponíveis"))
                : ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {

                return Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Card(
                    child: ListTile(
                      title: Text("Quiz ${items[index]["number"].toString()}",//items[index]["username"].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(
                          "Tentativas: ${items[index]["num_trials"]}\nPontos: ${items[index]["score"]}"),
                      //isThreeLine: true,
                      //dense:true,
                      minVerticalPadding: 10.0,
                    ),
                  ),
                );
              },
            ),
          );
        } else if (snapshot.connectionState != ConnectionState.done) {
          children = const <Widget>[
            SizedBox(
              child: CircularProgressIndicator.adaptive(),
              width: 60,
              height: 60,
            ),
          ];
        } else if (snapshot.hasError) {
          children = <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('Ocorreu um erro a descarregar os dados'),
            ),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'Tocar aqui para recarregar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ];
        } else {
          children = const <Widget>[
            SizedBox(
              child: CircularProgressIndicator.adaptive(),
              width: 60,
              height: 60,
            ),
          ];
        }
        return GestureDetector(
          onTap: () {
            setState(() {
              if (!isLoading) {
                futureQuizList = widget.fetchFunction();
              }
            });
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          ),
        );
      },
    );
  }
}
