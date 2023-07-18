import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/timeline/feedback_form.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_icon_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({Key? key}) : super(key: key);
  static const String pageRoute = "timeline";
  static const ValueKey pageKey = ValueKey(pageRoute);
  static const IconData icon = Icons.timeline_sharp;

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
              DynamicIconButton(
                onPressed: () => DynamicAlertDialog.showDynamicDialog(
                    context: context,
                    icon: Icon(
                      (PlatformService.instance.isIos)
                          ? CupertinoIcons.question
                          : Icons.question_mark,
                      color: IscteTheme.iscteColor,
                    ),
                    title: Text(AppLocalizations.of(context)!.explanation),
                    content: Text(AppLocalizations.of(context)!
                        .timelineExplanationAlertDialogContent)),
                child: Icon(
                  (PlatformService.instance.isIos)
                      ? CupertinoIcons.question
                      : Icons.question_mark,
                  color: IscteTheme.iscteColor,
                ),
              ),
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
          ),
        ),
      ),
      endDrawer: Drawer(
        width: width > 400
            ? width > 500
                ? width > 600
                    ? width * 0.4
                    : width * 0.7
                : width * 0.8
            : width,
        child: const TimelineFilterPage(),
      ),
      body: const TimeLineBodyBuilder(
        isFilterTimeline: false,
      ),
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
      persistentFooterButtons: [
        if (MediaQuery.of(context).size.height < 700 &&
            PlatformService.instance.isWeb)
          Image.asset(
            "Resources/Img/Logo/rgb_iscte_pt_horizontal.png",
            height: kToolbarHeight + 25,
          )
      ],
    );
  }
}
