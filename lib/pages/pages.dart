import 'package:ISCTE_50_Anos/helper/database_helper.dart';
import 'package:ISCTE_50_Anos/models/page.dart';
import 'package:ISCTE_50_Anos/nav_drawer/navigation_drawer.dart';
import 'package:ISCTE_50_Anos/nav_drawer/page_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VisitedPagesPage extends StatefulWidget {
  const VisitedPagesPage({Key? key}) : super(key: key);
  static const page_route = "/pages";

  @override
  _VisitedPagesPageState createState() => _VisitedPagesPageState();
}

class _VisitedPagesPageState extends State<VisitedPagesPage> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return WillPopScope(
          onWillPop: () async {
            Navigator.pushReplacementNamed(context, PageRoutes.home);
            return true;
          },
          child: Scaffold(
              drawer: NavigationDrawer(),
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.visitedPagesScreen),
              ),
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    DatabaseHelper.instance.removeALL();
                  });
                },
              ),
              body: FutureBuilder<List<VisitedPage>>(
                future: DatabaseHelper.instance.getPages(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<VisitedPage>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text(AppLocalizations.of(context)!.loading),
                    );
                  } else {
                    return snapshot.data!.isEmpty
                        ? Center(
                            child: Text(AppLocalizations.of(context)!.noPages),
                          )
                        : ListView(
                            children: snapshot.data!.map((page) {
                            return ListTile(
                              title: Text(page.content),
                              subtitle: Text(page.dateTimeParsed().toString()),
                              onLongPress: () {
                                setState(() {
                                  DatabaseHelper.instance.remove(page.id!);
                                });
                              },
                            );
                          }).toList());
                  }
                },
              )));
    });
  }
}
