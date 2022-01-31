import 'package:ISCTE_50_Anos/helper/database_helper.dart';
import 'package:ISCTE_50_Anos/helper/helper_methods.dart';
import 'package:ISCTE_50_Anos/models/visited_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VisitedPagesPage extends StatefulWidget {
  const VisitedPagesPage({Key? key}) : super(key: key);

  @override
  _VisitedPagesPageState createState() => _VisitedPagesPageState();
}

class _VisitedPagesPageState extends State<VisitedPagesPage> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                DatabaseHelper.instance.removeALL();
              });
            },
          ),
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.visitedPagesScreen),
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
                          subtitle: Text(page.parsed_time),
                          onLongPress: () {
                            setState(() {
                              DatabaseHelper.instance.remove(page.id!);
                            });
                          },
                          onTap: () {
                            HelperMethods.launchURL(page.url);
                          },
                        );
                      }).toList());
              }
            },
          ));
    });
  }
}
