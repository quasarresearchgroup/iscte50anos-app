import 'package:flutter/material.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:logger/logger.dart';
import 'package:yaml/yaml.dart';

class SettingsPage extends StatefulWidget {
  static const pageRoute = "/settings";
  final Logger _logger = Logger();
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _setting = false;

  @override
  void initState() {
    super.initState();
    initFunc();
  }

  void initFunc() async {
    bool completedAll = await SharedPrefsService.getCompletedAllPuzzles();
    setState(() => _setting = completedAll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          IscteAboutListTile(),
          const Center(
            child: Text("version: 1.0.10+12"),
          ),
/*          ExpansionTile(
            title: const Text("Shared Preferences"),
            children: [
              SwitchListTile.adaptive(
                title: const Text("Completed All Puzzles"),
                value: _setting,
                onChanged: (bool newValue) async {
                  if (!newValue) {
                    SharedPrefsService.resetCompletedAllPuzzles();
                    setState(() => _setting = newValue);
                  } else {
                    SharedPrefsService.storeCompletedAllPuzzles();
                    setState(() => _setting = newValue);
                  }
                },
              ),
            ],
          ),*/
        ],
      ),
    );
  }
}

class IscteAboutListTile extends StatelessWidget {
  IscteAboutListTile({Key? key}) : super(key: key);
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context).loadString("pubspec.yaml"),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          Map yaml = loadYaml(snapshot.data!);
          _logger.d([yaml['name'], yaml['version']]);
          return AboutListTile(
            icon: const Icon(Icons.info),
            applicationName: yaml['name'],
            applicationVersion: yaml['version'],
            applicationLegalese: "legalese",
          );
        } else {
          return Container();
        }
      },
    );
  }
}
