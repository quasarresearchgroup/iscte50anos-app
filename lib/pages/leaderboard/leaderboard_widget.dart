import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class Leaderboard extends StatefulWidget {
  Leaderboard({Key? key}) : super(key: key);
  final Logger _logger = Logger();
  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  late Future<List<dynamic>> futureLeaderboard;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureLeaderboard = fetchLeaderboard();
  }

  Future<List<dynamic>> fetchGroups() async {
    try {
      isLoading = true;
      //print(isLoading);
      final response =
          await http.get(Uri.parse('http://192.168.1.124/api/users/groups'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to load leaderboard');
    } finally {
      isLoading = false;
      //print(isLoading);
    }
  }

  Future<List<dynamic>> fetchLeaderboard() async {
    try {
      isLoading = true;
      widget._logger.d(isLoading);
      final response = await http
          .get(Uri.parse('http://192.168.1.124/api/users/leaderboard'));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.body.codeUnits));
      }
      throw Exception('Failed to load leaderboard');
    } finally {
      isLoading = false;
      widget._logger.d(isLoading);
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
          return Column(
            children: [
              const SizedBox(
                // Container to hold the description
                height: 50,
                child: Center(
                  child: Text("Top 10 Global",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      if (!isLoading) {
                        futureLeaderboard = fetchLeaderboard();
                      }
                    });
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Card(
                          child: ListTile(
                            title: Text(
                                utf8.decode(utf8.encode(items[index]["name"])),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text(
                                "Pontos: ${items[index]["points"]} \nAfiliação: IGE"),
                            //isThreeLine: true,
                            //dense:true,
                            minVerticalPadding: 10.0,
                            trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  index == 0
                                      ? Image.asset(
                                          "Resources/Img/LeaderBoardIcons/gold_medal.png")
                                      : index == 1
                                          ? Image.asset(
                                              "Resources/Img/LeaderBoardIcons/silver_medal.png")
                                          : index == 2
                                              ? Image.asset(
                                                  "Resources/Img/LeaderBoardIcons/bronze_medal.png")
                                              : Container(),
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
                ),
              ),
            ],
          );
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
                futureLeaderboard = fetchLeaderboard();
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
