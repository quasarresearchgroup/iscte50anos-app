import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/content.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:iscte_spots/widgets/timeline/timeline_search_delegate.dart';
import 'package:logger/logger.dart';

import '../loader/timeline_loader.dart';
import '../models/database/tables/database_content_table.dart';
import '../widgets/timeline/timeline_body.dart';
import '../widgets/util/loading.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({Key? key}) : super(key: key);
  final Logger logger = Logger();

  static const pageRoute = "/timeline";

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late Future<List<Content>> mapdata;

  @override
  void initState() {
    super.initState();
    //mapdata = ContentLoader.getTimeLineEntries();
    mapdata = DatabaseContentTable.getAll();
  }

  void resetMapData() {
    mapdata = DatabaseContentTable.getAll();
  }

  @override
  Widget build(BuildContext context) {
    var isDialOpen = ValueNotifier<bool>(false);

    return WillPopScope(
        onWillPop: () async {
          if (isDialOpen.value) {
            isDialOpen.value = false;
          }
          Navigator.pushReplacementNamed(context, PageRoutes.home);
          return true;
        },
        child: Scaffold(
            drawer: const NavigationDrawer(),
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.timelineScreen),
              actions: [
                IconButton(
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate: TimelineSearchDelegate(mapdata: mapdata));
                    },
                    icon: const FaIcon(FontAwesomeIcons.search))
              ],
            ),
            floatingActionButton: SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close,
              openCloseDial: isDialOpen,
              elevation: 8.0,
              children: [
                SpeedDialChild(
                    child: const FaIcon(FontAwesomeIcons.trash),
                    backgroundColor: Colors.red,
                    label: 'Delete',
                    onTap: () {
                      setState(() {
                        DatabaseContentTable.removeALL();
                        widget.logger.d("Removed all content");
                        Navigator.popAndPushNamed(
                            context, TimelinePage.pageRoute);
                      });
                    }),
                SpeedDialChild(
                    child: const Icon(Icons.refresh),
                    backgroundColor: Colors.green,
                    label: 'Refresh',
                    onTap: () {
                      ContentLoader.insertContentEntriesFromCSV().then((value) {
                        setState(() {
                          widget.logger.d("Inserted from CSV");
                          mapdata = DatabaseContentTable.getAll();
                          mapdata
                              .then((value) => widget.logger.d(value.length));
                          Navigator.popAndPushNamed(
                              context, TimelinePage.pageRoute);
                        });
                      });
                    }),
              ],
            ),
            body: FutureBuilder<List<Content>>(
              future: mapdata,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return TimeLineBody(mapdata: snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(AppLocalizations.of(context)!.generalError));
                } else {
                  return const LoadingWidget();
                }
              },
            )));
  }
}
