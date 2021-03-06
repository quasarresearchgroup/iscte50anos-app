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
const API_ADDRESS_TEST = "http://192.168.1.66";

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

// FOR ISOLATED TESTING
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home:LeaderBoardPage()));
}

class LeaderBoardPage extends StatefulWidget {
  static const pageRoute = "/leaderboard";

  const LeaderBoardPage({Key? key}) : super(key: key);

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final Logger logger = Logger();
  late TabController _tabController;
  int _selectedIndex = 0;

  late Map<String, dynamic> affiliationMap;

  Future<String> loadAffiliationData() async {
    var jsonText =
        await rootBundle.loadString('Resources/affiliations.json');
    setState(
        () => affiliationMap = json.decode(utf8.decode(jsonText.codeUnits)));
    return 'success';
  }

  static const List<Widget> _pages = <Widget>[
    GlobalLeaderboard(),
    AffiliationLeaderboard(),
  ];

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
    loadAffiliationData();
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
            "Leaderboard"), //AppLocalizations.of(context)!.quizPageTitle)
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: _pages,
        ), // _pages[_selectedIndex],

      ),
      bottomNavigationBar: ClipRRect(
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
              label: 'Afilia????o',
            ),
          ],
        ),
      ),
    );
  }
}

class AffiliationLeaderboard extends StatefulWidget {
  const AffiliationLeaderboard({Key? key}) : super(key: key);

  @override
  _AffiliationLeaderboardState createState() => _AffiliationLeaderboardState();
}

class _AffiliationLeaderboardState extends State<AffiliationLeaderboard>
    with AutomaticKeepAliveClientMixin {
  String selectedType = "-";
  String selectedAffiliation = "-";
  bool firstSearch = false;
  bool canSearch = false;

  late Map<String, dynamic> affiliationMap;
  bool readJson = false;

  Future<List<dynamic>> fetchLeaderboard() async {
    try {
      //String? apiToken = await secureStorage.read(key: "backend_api_key");

      String? apiToken = "8eb7f1e61ef68a526cf5a1fb6ddb0903bc0678c1";

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(Uri.parse(
          '$API_ADDRESS_TEST/api/users/leaderboard?type=${selectedType}&affiliation=$selectedAffiliation'));
      request.headers.add("Authorization", "Token $apiToken");
      final response = await request.close();

      if (response.statusCode == 200) {
        return jsonDecode(await response.transform(utf8.decoder).join());
      }
    } catch (e) {
      print(e);
    }
    throw Exception('Failed to load leaderboard');
  }

  Future<String> loadAffiliationData() async {
    var jsonText =
        await rootBundle.loadString('Resources/affiliations.json');
    readJson = true;
    setState(
        () => affiliationMap = json.decode(utf8.decode(jsonText.codeUnits)));
    return 'success';
  }

  @override
  void initState() {
    super.initState();
    loadAffiliationData();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        const SizedBox(
          // Container to hold the description
          height: 50,
          child: Center(
            child: Text("Top 10 por Afilia????o",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        if (readJson)
          Row(
            children: [
              const SizedBox(width: 15),
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    const Text("Afilia????o"),
                    DropdownButton(
                      isExpanded: true,
                      value: selectedType,
                      items: (affiliationMap.keys.toList())
                          .map(
                            (type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type,
                                    style: const TextStyle(fontSize: 13))),
                          )
                          .toList(),
                      selectedItemBuilder: (BuildContext context) {
                        return affiliationMap.keys.toList().map((type) {
                          return Center(
                            child: SizedBox(
                                width: double.maxFinite,
                                child: Text(type,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13))),
                          );
                        }).toList();
                      },
                      onChanged: (String? newValue) {
                        setState(() {
                          canSearch = false;
                          selectedType = newValue!;
                          selectedAffiliation = "-";
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    const Text("Departamento"),
                    DropdownButton(
                      isExpanded: true,
                      value: selectedAffiliation,
                      items: (affiliationMap[selectedType])
                          .map<DropdownMenuItem<String>>(
                            (aff) => DropdownMenuItem<String>(
                                value: aff,
                                child: Text(aff,
                                    style: const TextStyle(fontSize: 13))),
                          )
                          .toList(),
                      selectedItemBuilder: (BuildContext context) {
                        return (affiliationMap[selectedType] as List<dynamic>)
                            .map((aff) {
                          return Center(
                            child: Text(aff,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13)),
                          );
                        }).toList();
                      },
                      onChanged: (selectedType == "-")
                          ? null
                          : (String? newValue) {
                              if (newValue != "-") {
                                setState(() {
                                  canSearch = true;
                                  firstSearch = true;
                                  selectedAffiliation = newValue!;
                                });
                              }
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        if (canSearch)
          Expanded(
              child: LeaderboardList(
                  key: UniqueKey(), fetchFunction: fetchLeaderboard))
        else if (!firstSearch && readJson)
          const Expanded(
              child: Center(
                  child: Text("Selecione a afilia????o pretendida",
                      style: TextStyle(fontSize: 16)))),
      ],
    );
  }
}

class GlobalLeaderboard extends StatelessWidget {
  const GlobalLeaderboard({Key? key}) : super(key: key);

  Future<List<dynamic>> fetchLeaderboard() async {
    try {
      //String? apiToken = await secureStorage.read(key: "backend_api_key");
      String? apiToken = "8eb7f1e61ef68a526cf5a1fb6ddb0903bc0678c1";

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(
          Uri.parse('$API_ADDRESS_TEST/api/users/leaderboard'));
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
    throw Exception('Failed to load leaderboard');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          // Container to hold the description
          height: 50,
          child: Center(
            child: Text("Top 10 Global",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        Expanded(child: LeaderboardList(fetchFunction: fetchLeaderboard)),
      ],
    );
  }
}

class LeaderboardList extends StatefulWidget {
  final Future<List<dynamic>> Function() fetchFunction;

  const LeaderboardList({Key? key, required this.fetchFunction})
      : super(key: key);

  @override
  _LeaderboardListState createState() => _LeaderboardListState();
}

class _LeaderboardListState extends State<LeaderboardList> {
  late Future<List<dynamic>> futureLeaderboard;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureLeaderboard = widget.fetchFunction();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureLeaderboard,
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          var items = snapshot.data as List<dynamic>;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                if (!isLoading) {
                  futureLeaderboard = widget.fetchFunction();
                }
              });
            },
            child: items.isEmpty
                ? const Center(child: Text("N??o foram encontrados resultados"))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Card(
                          child: ListTile(
                            title: Text(items[index]["username"].toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text("Pontos: ${items[index]["points"]} \nAfilia????o: ${items[index]["affiliation_name"]}"),
                            minVerticalPadding: 10.0,
                            trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  if (index == 0)
                                    Image.asset(
                                        "Resources/Img/LeaderBoardIcons/gold_medal.png")
                                  else if (index == 1)
                                    Image.asset(
                                        "Resources/Img/LeaderBoardIcons/silver_medal.png")
                                  else if (index == 2)
                                    Image.asset(
                                        "Resources/Img/LeaderBoardIcons/bronze_medal.png"),
                                  const SizedBox(width: 10),
                                  Text("#${index + 1}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                ]),
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
                futureLeaderboard = widget.fetchFunction();
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
