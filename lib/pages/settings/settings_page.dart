import 'package:flutter/material.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:yaml/yaml.dart';

class SettingsPage extends StatefulWidget {
  static const pageRoute = "/settings";
  static const IconData icon = Icons.settings;

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
      appBar: MyAppBar(
        title: "Settings", //TODO
        leading: const DynamicBackIconButton(),
      ),
      body: ListView(
        children: [
          IscteAboutListTile(),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context).loadString("pubspec.yaml"),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          Map yaml = loadYaml(snapshot.data!);
          LoggerService.instance.debug([yaml['name'], yaml['version']]);
          return DynamicAboutListTile(yaml: yaml);
        } else {
          return Container();
        }
      },
    );
  }
}

class DynamicAboutListTile extends StatelessWidget {
  const DynamicAboutListTile({
    Key? key,
    required this.yaml,
  }) : super(key: key);

  final Map yaml;

  @override
  Widget build(BuildContext context) {
    var applicationName = yaml['name'];
    var applicationVersion = yaml['version'];

    return ListTile(
      leading: const Icon(Icons.info),
      title: Text("$applicationName"),
      onTap: () {
        DynamicAlertDialog.showDynamicDialog(
            context: context,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("About $applicationName"),
                Text("$applicationVersion"),
              ],
            ),
            // content: Text("legalese"),
            actions: [
              DynamicTextButton(
                child: const Text("View Licenses"), //TODO
                onPressed: () {
                  showLicensePage(
                    context: context,
                    applicationName: applicationName,
                    applicationVersion: applicationVersion,
                    applicationIcon: null,
                    applicationLegalese: null,
                  );
                },
              ),
              DynamicTextButton(
                child: const Text("Close"), //TODO
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]);
      },
    );
    return AboutListTile(
      icon: const Icon(Icons.info),
      applicationName: applicationName,
      applicationVersion: yaml['version'],
      applicationLegalese: "legalese",
    );
  }
}
