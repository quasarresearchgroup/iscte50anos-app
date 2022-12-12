import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/timeline/feedback_form.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/platform_service.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: MyAppBar(
        title: AppLocalizations.of(context)!.timelineScreen,
        leading: PlatformService.instance.isWeb ? FeedbackFormButon() : null,
        trailing: Builder(builder: (context) {
          return (!PlatformService.instance.isIos)
              ? IconButton(
                  onPressed: Scaffold.of(context).openEndDrawer,
                  icon: const Icon(Icons.search),
                )
              : CupertinoButton(
                  onPressed: Scaffold.of(context).openEndDrawer,
                  child: const Icon(CupertinoIcons.search),
                );
        }),
      ),
      endDrawer: Drawer(
        width: width > 400
            ? width > 500
                ? width > 600
                    ? width * 0.4
                    : width * 0.7
                : width * 0.8
            : width,
        child: TimelineFilterPage(),
      ),
      body: TimeLineBodyBuilder(
        isFilterTimeline: false,
      ),
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
      persistentFooterButtons: [
        if (MediaQuery.of(context).size.height < 700)
          Image.asset(
            "Resources/Img/Logo/rgb_iscte_pt_horizontal.png",
            height: kToolbarHeight + 25,
          )
      ],
    );
  }
}
