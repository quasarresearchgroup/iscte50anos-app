import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/helper/helper_methods.dart';
import 'package:iscte_spots/models/database/tables/database_page_table.dart';
import 'package:iscte_spots/models/visited_url.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

class VisitedPagesPage extends StatefulWidget {
  const VisitedPagesPage({Key? key}) : super(key: key);
  static const pageRoute = "/pages";

  @override
  _VisitedPagesPageState createState() => _VisitedPagesPageState();
}

class _VisitedPagesPageState extends State<VisitedPagesPage> {
  @override
  Widget build(BuildContext context) {
    TextStyle messagesStyle =
        TextStyle(color: Theme.of(context).selectedRowColor, fontSize: 25);
    return Builder(builder: (context) {
      return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.visitedPagesScreen),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                DatabasePageTable.removeALL();
              });
            },
          ),
          body: RefreshIndicator(
            onRefresh: () {
              return DatabasePageTable.getAll();
            },
            child: FutureBuilder<List<VisitedURL>>(
              future: DatabasePageTable.getAll(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<VisitedURL>> snapshot) {
                if (!snapshot.hasData) {
                  return LoadingWidget(messagesStyle: messagesStyle);
                } else {
                  List<VisitedURL> list = snapshot.data!;
                  if (snapshot.data!.isEmpty) {
                    return NoPagesVisited(messagesStyle: messagesStyle);
                  } else {
                    list.sort((VisitedURL a, VisitedURL b) =>
                        b.dateTime - a.dateTime);
                    return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: list.map((page) {
                          return ListTile(
                            title: Text(page.content),
                            subtitle: Text(page.parsedTime),
                            onLongPress: () {
                              setState(() {
                                DatabasePageTable.remove(page.id!);
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
            ),
          ));
    });
  }
}

class NoPagesVisited extends StatelessWidget {
  const NoPagesVisited({
    Key? key,
    required this.messagesStyle,
  }) : super(key: key);

  final TextStyle messagesStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.do_disturb_alt_outlined,
          size: 60,
        ),
        Text(AppLocalizations.of(context)!.noPages, style: messagesStyle),
      ],
    ));
  }
}
