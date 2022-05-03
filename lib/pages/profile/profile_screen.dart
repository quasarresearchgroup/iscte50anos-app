import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/device_service.dart';
import 'package:iscte_spots/services/profile/profile_service.dart';
import 'package:logger/logger.dart';

//const API_ADDRESS = "https://194.210.120.48";

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
        title: const Text(
            "Profile"), //AppLocalizations.of(context)!.quizPageTitle)
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
  Map<String, dynamic>? deviceInformation;
  @override
  void initState() {
    super.initState();
    futureProfile = fetchProfileProxy();
    initFunc();
  }

  void initFunc() async {
    deviceInformation = await DeviceService().initPlatformState();
    Logger().d(deviceInformation);
  }

  Future<Map> fetchProfileProxy() async {
    return ProfileService().fetchProfile();
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
            var totalTime = spots > 0
                ? Duration(seconds: profile["total_time"])
                    .toString()
                    .split(".")[0]
                : "-";

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  if (!isLoading) {
                    futureProfile = fetchProfileProxy();
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
                          _profileCircleAvatar(profile),
                          const SizedBox(height: 10),
                          // NAME
                          //"${profile["name"]}\n(${profile["username"]})"
                          Text(profile["name"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 23)),
                          const SizedBox(height: 20),
                          Text(profile["affiliation_name"].toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 20),
                          _buildSpotsRow(profile, totalTime),
                          const Divider(
                            height: 30,
                            thickness: 3,
                            indent: 20,
                            endIndent: 20,
                          ),
                          const Text("Ranking",
                              style: TextStyle(
                                fontSize: 13,
                              )),
                          const SizedBox(height: 10),
                          _buildRankingROw(profile),
                          const Divider(
                            height: 30,
                            thickness: 3,
                            indent: 20,
                            endIndent: 20,
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(deviceInformation != null
                                ? deviceInformation!["model"].toString()
                                : ""),
                          ),
                        ],
                      ),
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
                  futureProfile = fetchProfileProxy();
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
        });
  }

  Row _buildRankingROw(Map<dynamic, dynamic> profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text("Global", style: TextStyle(fontSize: 14)),
            Text("#" + profile["ranking"].toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        Column(
          children: [
            const Text("Afiliação", style: TextStyle(fontSize: 14)),
            Text("#" + profile["affiliation_ranking"].toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        )
      ],
    );
  }

  Row _buildSpotsRow(Map<dynamic, dynamic> profile, String totalTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text("Spots", style: TextStyle(fontSize: 14)),
            Text(profile["num_spots_read"].toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        Column(
          children: [
            const Text("Tempo", style: TextStyle(fontSize: 14)),
            Text(totalTime.toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        )
      ],
    );
  }

  Center _profileCircleAvatar(Map<dynamic, dynamic> profile) {
    return Center(
      child: CircleAvatar(
        radius: 40,
        child: FittedBox(
          fit: BoxFit.fill,
          child: Text(
            profile["initials"],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
          ),
        ),
      ),
    );
  }
}
