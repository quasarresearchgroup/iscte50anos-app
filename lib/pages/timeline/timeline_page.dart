import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/timeline/feedback_form.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_icon_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({Key? key}) : super(key: key);
  static const String pageRoute = "timeline";
  static const ValueKey pageKey = ValueKey(pageRoute);
  static const IconData icon = Icons.timeline;

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
        leading:
            PlatformService.instance.isWeb ? const FeedbackFormButon() : null,
        trailing: Builder(
            builder: (context) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!PlatformService.instance.isWeb)
                      const FeedbackFormButon(),
                    DynamicIconButton(
                      onPressed: Scaffold.of(context).openEndDrawer,
                      child: Icon(
                        (PlatformService.instance.isIos)
                            ? CupertinoIcons.search
                            : Icons.search,
                        color: IscteTheme.iscteColor,
                      ),
                    ),
                  ],
                )),
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
      body: const TimeLineBodyBuilder(
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
