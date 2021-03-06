import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/pages/profile/placeholder.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

const FlutterSecureStorage secureStorage = FlutterSecureStorage();
const API_ADDRESS = "http://192.168.1.66";

// FOR ISOLATED TESTING
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),//AppLocalizations.of(context)!.quizPageTitle)
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: const Profile(),
        ),
      );
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
      isLoading = true;
      //String? apiToken = await secureStorage.read(key: "backend_api_key");
      String? apiToken = "8eb7f1e61ef68a526cf5a1fb6ddb0903bc0678c1";

      HttpClient client = HttpClient();
      client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(
          Uri.parse('$API_ADDRESS/api/users/profile'));
      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();

      if (response.statusCode == 200) {
        return jsonDecode(await response.transform(utf8.decoder).join());
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
    }
    throw Exception("Failed to load profile");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureProfile,
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          var profile = snapshot.data as Map;
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
                                      child: Text(profile["initials"],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 40
                                          ))
                                  )
                              )
                          ),
                          const SizedBox(height: 10),
                          // NAME
                          //"${profile["name"]}\n(${profile["username"]})"
                          Text(profile["name"], style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23
                          )),
                          const SizedBox(height: 20),
                          Text(profile["affiliation_name"].toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 13
                              )),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Text("N??vel", style: TextStyle(
                                      fontSize: 14
                                  )),
                                  Text(profile["level"].toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18
                                      )),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text("Pontos", style: TextStyle(
                                      fontSize: 14
                                  )),
                                  Text(profile["points"].toString(),
                                      style: const TextStyle(
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
                            fontSize: 14,
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
                                  Text("#" + profile["ranking"].toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18
                                      )),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text("Afilia????o", style: TextStyle(
                                      fontSize: 14
                                  )),
                                  Text("#" +
                                      profile["affiliation_ranking"].toString(),
                                      style: const TextStyle(
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
                  const Text("Estat??sticas", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  )),
                  const SizedBox(height: 15),

                  const Text("N??mero de Spots lidos"),
                  const Text("4", style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 10),

                  const Text("Tempo m??dio de descoberta de Spots"),
                  const Text("20:35", style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 10),

                  const Text("Estat??stica Random"),
                  const Text("Torradas Mistas", style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 10),

                  const Text("Outra Estat??stica Random"),
                  const Text("Tostas Assadas", style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 10),
                                            */
                ],
              ),
            ),
          );
        }else if(snapshot.connectionState!= ConnectionState.done){
          children = const <Widget>[
            Expanded(
              child: ProfilePlaceholder(),
            )//ProfilePlaceholder(),
          ];
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
            ProfilePlaceholder(),
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
}

