import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/helper/database_helper.dart';
import 'package:iscte_spots/helper/helper_methods.dart';
import 'package:iscte_spots/models/visited_page.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';

class VisitedPagesPage extends StatefulWidget {
  const VisitedPagesPage({Key? key}) : super(key: key);
  static const pageRoute = "/pages";

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
              drawer: const NavigationDrawer(),
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
                    List<VisitedPage> list = snapshot.data!;
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(AppLocalizations.of(context)!.noPages),
                      );
                    } else {
                      list.sort((VisitedPage a, VisitedPage b) =>
                          b.dateTime - a.dateTime);

                      return ListView(
                          children: list.map((page) {
                        return ListTile(
                          title: Text(page.content),
                          subtitle: Text(page.parsedTime),
                          onLongPress: () {
                            setState(() {
                              DatabaseHelper.instance.remove(page.id!);
                            });
                          },
                          onTap: () {
                            if (page.url != null) {
                              HelperMethods.launchURL(page.url!);
                            }
                          },
                        );
                      }).toList());
                    }
                  }
                },
              )));
    });
  }
}
