import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(LeaderBoardPage());
}

class LeaderBoardPage extends StatefulWidget {
  static const pageRoute = "/leaderboard";
  Logger logger = Logger();

  LeaderBoardPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _LeaderBoardPageState();
  }
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {

  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // ••• ADD THIS: App Bar Theme: •••
          appBarTheme: const AppBarTheme(
            elevation: 0, // This removes the shadow from all App Bars.
            centerTitle: true,
            toolbarHeight: 60,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
          )
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Leaderboard"),//AppLocalizations.of(context)!.quizPageTitle)
        ),
        drawer: const NavigationDrawer(),

        body: Leaderboard(),
      ), //Scaffold
      debugShowCheckedModeBanner: false,
    ); //MaterialApp
  }
}

class Leaderboard extends StatefulWidget {
  const Leaderboard({Key? key}) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {

  late Future<List<dynamic>> futureLeaderboard;

  @override
  void initState() {
    super.initState();
    futureLeaderboard = fetchLeaderboard();
  }

  Future<List<dynamic>> fetchLeaderboard() async {

    final response = await http
        .get(Uri.parse('http://192.168.1.124/api/users/leaderboard'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureLeaderboard,
      builder: (context, snapshot) {
      List<Widget> children;
      if (snapshot.hasData) {
        var items = snapshot.data as List<dynamic>;
        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(
          ),
          scrollDirection: Axis.vertical,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(items[index]["username"], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Pontos: ${items[index]["points"]}"),
              dense:true,
              trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    index == 0 ? Image.asset("Resources/Img/LeaderBoardIcons/gold_medal.png") :
                    index == 1 ? Image.asset("Resources/Img/LeaderBoardIcons/silver_medal.png") :
                    index == 2 ? Image.asset("Resources/Img/LeaderBoardIcons/bronze_medal.png") : Container(),
                    const SizedBox(width:10),
                    Text("#${index+1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ]),
            );
          },
        );
      } else if (snapshot.hasError) {
        children = <Widget>[
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Error: ${snapshot.error}'),
          )
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      );
    },

    );
  }
}

