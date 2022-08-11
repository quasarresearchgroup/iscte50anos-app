import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/helper/helper_methods.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TimeLineDetailsPage extends StatefulWidget {
  static const String pageRoute = "${TimelinePage.pageRoute}/detail";

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

  List<YoutubePlayerController> _youtubeControllers = [];

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    Future<List<Content>> allContentFromEvent = widget.event.getContentList;
    Future<List<Topic>> allTopicFromEvent = widget.event.getTopicsList;
    String subtitleText = "id: " + widget.event.id.toString();
    allTopicFromEvent.then((value) {
      subtitleText += "; topics: " + value.map((e) => e.title ?? "").join(", ");
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.timelineDetailsScreen),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: FutureBuilder<List<Content>>(
              future: allContentFromEvent,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _logger.d("event: ${widget.event} , data:${snapshot.data!} ");
                  return ListView.builder(
                    addAutomaticKeepAlives: true,
                    itemCount: (snapshot.data?.length)! + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          //leading: widget.event.scopeIcon,
                          title: Text(widget.event.title ?? ""),
                          subtitle: Text(subtitleText),
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
                      allContentFromEvent = widget.event.getContentList;
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
    if (content.link.contains("youtube")) {
      YoutubePlayerController _controller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(content.link)!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          loop: false,
          hideControls: false,
          isLive: false,
          forceHD: false,
        ),
      );
      return Wrap(
        children: [
          YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
              ),
              builder: (context, player) => player),
        ],
      );
    } else {
      return ListTile(
        leading: content.contentIcon,
        title: Text(content.description ?? ""),
        subtitle: Text(content.link),
        onTap: () {
          _logger.d(content);
          if (content.link.isNotEmpty) {
            HelperMethods.launchURL(content.link);
          }
        },
      );
    }
  }

  void launchLink(String link) async {
    var url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void deactivate() {
    for (YoutubePlayerController controller in _youtubeControllers) {
      controller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    for (YoutubePlayerController controller in _youtubeControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
