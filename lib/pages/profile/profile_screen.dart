import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProfilePage());
}

class ProfilePage extends StatelessWidget {
  static const pageRoute = "/profile";
  Logger logger = Logger();

  ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // APP BAR THEME
    AppBarTheme appBarTheme = const AppBarTheme(
      //backgroundColor: Color.fromRGBO(14, 41, 194, 1),
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
              statusBarIconBrightness: Brightness.light, // For Android (dark icons)
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
          )
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),//AppLocalizations.of(context)!.quizPageTitle)
        ),
        drawer: const NavigationDrawer(),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: const Profile(),
        ),
      ), //Scaffold
      debugShowCheckedModeBanner: false,
    ); //MaterialApp
  }
}

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  late Future<Map> futureProfile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureProfile = fetchProfile();
  }

  Future<Map> fetchProfile() async {
    try {
     // String? apiToken = await secureStorage.read(key: "api_token");
      isLoading = true;
      final response = await http.get(
          Uri.parse('http://192.168.1.124/api/users/profile'),
        //8eb7f1e61ef68a526cf5a1fb6ddb0903bc0678c1
        //555103c2c229fc06bcc7e10e91323c2bc4162bdd
          headers: {'Authorization': 'Token ce0d0c050ab6b249283f24c01dfe84fd01dc2070'},
      );
      if (response.statusCode == 200) {
        print("recebi");
        return jsonDecode(utf8.decode(response.body.codeUnits));
      }
      throw Exception('Failed to load profile');
    }finally{
      isLoading = false;
      //print(isLoading);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureProfile,
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {

          var profile = snapshot.data as Map;
          var spots = profile["num_spots_read"];
          var totalTime = spots > 0 ? Duration(seconds: profile["total_time"]).toString().split(".")[0]
              : "-";

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                if (!isLoading) {
                  futureProfile = fetchProfile();
                }
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Center(
                              child: CircleAvatar(
                                  radius: 40,
                                  child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: Text(profile["initials"], style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 40
                                      ))
                                  )
                              )
                          ),
                          const SizedBox(height: 10),
                          // NAME
                          Text(profile["name"], style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23
                          )),
                          const SizedBox(height: 20),
                          Text(profile["affiliation_name"].toString(),
                              textAlign: TextAlign.center, style: const TextStyle(
                                  fontSize: 13
                              )),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Text("Spots", style:TextStyle(
                                      fontSize: 14
                                  )),
                                  Text(profile["num_spots_read"].toString(), style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                  )),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text("Tempo", style: TextStyle(
                                      fontSize: 14
                                  )),
                                  Text(totalTime.toString(), style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                  )),
                                ],
                              )
                            ],
                          ),
                          const Divider(height: 30,
                            thickness: 3,
                            indent: 20,
                            endIndent: 20,),
                          const Text("Ranking", style: TextStyle(
                            fontSize: 13,
                          )),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Text("Global", style: TextStyle(
                                      fontSize: 14
                                  )),
                                  Text("#"+profile["ranking"].toString(), style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                  )),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text("Afiliação", style: TextStyle(
                                      fontSize: 14
                                  )),
                                  Text("#"+profile["affiliation_ranking"].toString(), style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                  )),
                                ],
                              )
                            ],
                          ),
                          const Divider(height: 30,
                            thickness: 3,
                            indent: 20,
                            endIndent: 20,),
                        ],
                      )
                  ),
                  /*const SizedBox(height: 15),
                  const Text("Estatísticas", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  )),
                  const SizedBox(height: 15),

                  const Text("Número de Spots lidos"),
                  const Text("4", style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 10),

                  const Text("Tempo médio de descoberta de Spots"),
                  const Text("20:35", style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 10),

                  const Text("Estatística Random"),
                  const Text("Torradas Mistas", style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 10),

                  const Text("Outra Estatística Random"),
                  const Text("Tostas Assadas", style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 10),
                                            */
                ],
              ),
            ),
          );
        }else if (snapshot.hasError) {
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
              child: Text('Tocar aqui para recarregar', style: TextStyle(fontWeight: FontWeight.bold),),
            ),

          ];
        } else{
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
              if(!isLoading){
                futureProfile = fetchProfile();
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
      }
    );
  }

 /* @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureProfile,
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          var items = snapshot.data as List<dynamic>;
          return Column(
            children: [
              SizedBox(  // Container to hold the description
                height: 200,
                child: Center(
                  child: Column(
                    children: const [
                      Center(
                        child:CircleAvatar(
                          child: Text("DA")
                        )
                      ),
                      Text("Duarte Almeida")
                    ],
                  )
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async{
                    setState(() {
                      if(!isLoading) {
                        futureProfile = fetchProfile();
                      }
                    });
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left:10.0, right:10.0),
                        child: Card(
                          child: ListTile(
                            title: Text(utf8.decode(utf8.encode(items[index]["name"])),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                )
                            ),
                            subtitle: Text("Pontos: ${items[index]["points"]} \nAfiliação: IGE"),
                            //isThreeLine: true,
                            //dense:true,
                            minVerticalPadding: 10.0,
                            trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  index == 0 ? Image.asset("Resources/Img/LeaderBoardIcons/gold_medal.png") :
                                  index == 1 ? Image.asset("Resources/Img/LeaderBoardIcons/silver_medal.png") :
                                  index == 2 ? Image.asset("Resources/Img/LeaderBoardIcons/bronze_medal.png") :
                                    Container(),
                                  const SizedBox(width:10),
                                  Text( "#${index+1}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
                                      )
                                  ),
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
              child: Text('Tocar aqui para recarregar', style: TextStyle(fontWeight: FontWeight.bold),),
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
              if(!isLoading){
                futureProfile = fetchProfile();
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
  }*/
}

