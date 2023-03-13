import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';

class TimelineFilterResultsPage extends StatelessWidget {
  const TimelineFilterResultsPage({Key? key}) : super(key: key);

  static const String pageRoute = "results";
  static const ValueKey pageKey = ValueKey(pageRoute);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        LoggerService.instance.info("popped out of timeline filter results");
        return true;
      },
      child: Scaffold(
        appBar: MyAppBar(
          leading: const DynamicBackIconButton(),
          title: AppLocalizations.of(context)!.timelineSearchResults,
        ),
        body: const TimeLineBodyBuilder(
          isFilterTimeline: true,
        ),
      ),
    );
  }
}
