import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_code_reader/models/page.dart';

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
            title: Text(AppLocalizations.of(context)!.timelineScreen),
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
                        return Center(
                            child: ListTile(
                          title: Text(page.content),
                          onLongPress: () {
                            setState(() {
                              DatabaseHelper.instance.remove(page.id!);
                            });
                          },
                        ));
                      }).toList());
              }
            },
          ));
    });
  }
}
