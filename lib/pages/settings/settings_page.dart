import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';

class SettingsPage extends StatefulWidget {
  static const pageRoute = "/settings";

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
          const Center(
            child: Text("version: 1.0.3+12"),
          ),
          ExpansionTile(
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
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
