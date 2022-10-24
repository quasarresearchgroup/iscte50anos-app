import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/pages/timeline/timeline_filter_page.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:logger/logger.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({Key? key}) : super(key: key);
  final Logger _logger = Logger();
  static const String pageRoute = "timeline";
  static const ValueKey pageKey = ValueKey(pageRoute);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final Future<List<int>> yearsList = TimelineEventService.fetchYearsList();

  void handleFilterNavigation() {
    Navigator.of(context).pushNamed(TimelineFilterPage.pageRoute);
  }

  late ValueNotifier<bool> isDialOpen;

  @override
  void initState() {
    super.initState();
    isDialOpen = ValueNotifier<bool>(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: AppLocalizations.of(context)!.timelineScreen,
        trailing: (!PlatformService.instance.isIos)
            ? IconButton(
                onPressed: handleFilterNavigation,
                icon: const Icon(Icons.search),
              )
            : CupertinoButton(
                onPressed: handleFilterNavigation,
                child: const Icon(
                  CupertinoIcons.search,
                  color: CupertinoColors.white,
                ),
              ),
      ),
      /*floatingActionButton: TimelineDial(
              isDialOpen: isDialOpen,
              deleteTimelineData: deleteTimelineData,
              refreshTimelineData: deleteGetAllEvents,
            ),*/
      body: TimeLineBody(
        yearsList: yearsList,
      ),
    );
  }
}
