import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/content.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';

class TimeLineDetailsPage extends StatelessWidget {
  static const pageRoute = "/timeline/detail";

  const TimeLineDetailsPage({
    required this.data,
    Key? key,
  }) : super(key: key);
  final double textweight = 2;
  final Content data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: AppLocalizations.of(context)!.timelineDetailsScreen,
        leading: DynamicBackIconButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  data.contentIcon,
                  Text(
                    data.getDateString(),
                    textScaleFactor: textweight,
                  ),
                  data.contentIcon
                ],
              ),
              data.scopeIcon,
              data.description != null
                  ? Text(
                      "Description: " + data.description!,
                      textScaleFactor: textweight,
                    )
                  : Container(),
              data.id != null
                  ? Text("id: " + data.id!.toString(),
                      textScaleFactor: textweight)
                  : Container(),
              data.eventId != null
                  ? Text("eventID: " + data.eventId!.toString(),
                      textScaleFactor: textweight)
                  : Container(),
              data.link != null
                  ? Text("link: " + data.link!.toString(),
                      textScaleFactor: textweight)
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
