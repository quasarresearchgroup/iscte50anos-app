import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/content.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.timelineDetailsScreen),
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
                  ? TextButton(
                      child: Text(
                        "link: " + data.link!,
                        textScaleFactor: textweight,
                      ),
                      onPressed: () {
                        launchLink(data.link!);
                      },
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void launchLink(String link) async {
    var url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
