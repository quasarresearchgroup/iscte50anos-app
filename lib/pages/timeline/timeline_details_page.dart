import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/helper/helper_methods.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class TimeLineDetailsPage extends StatefulWidget {
  static const pageRoute = "/timeline/detail";

  TimeLineDetailsPage({
    required this.event,
    Key? key,
  }) : super(key: key);
  final Event event;

  @override
  State<TimeLineDetailsPage> createState() => _TimeLineDetailsPageState();
}

class _TimeLineDetailsPageState extends State<TimeLineDetailsPage> {
  final double textweight = 2;

  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    Future<List<Content>> allFromEvent = widget.event.getContentList;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.timelineDetailsScreen),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: FutureBuilder<List<Content>>(
              future: allFromEvent,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _logger.d("event: ${widget.event} , data:${snapshot.data!} ");
                  return ListView.builder(
                    addAutomaticKeepAlives: true,
                    itemCount: (snapshot.data?.length)! + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          leading: widget.event.scopeIcon,
                          title: Text(widget.event.title ?? ""),
                          subtitle: Text("id: " + widget.event.id.toString()),
                          trailing: Text(
                            widget.event.getDateString(),
                          ),
                        );
                      } else if (index == 1) {
                        return const Divider(
                          color: Colors.white,
                        );
                      } else {
                        return buildContent(snapshot.data![index - 2]);
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return NetworkError(onRefresh: () {
                    setState(() {
                      allFromEvent = widget.event.getContentList;
                    });
                  });
                } else {
                  return const LoadingWidget();
                }
              }),
        ),
      ),
    );
  }

  Widget buildContent(Content content) {
    return ListTile(
      leading: content.contentIcon,
      title: Text(content.description ?? ""),
      subtitle: Text(content.link ?? ""),
      onTap: () {
        if (content.link != null) {
          HelperMethods.launchURL(content.link!);
        }
      },
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
