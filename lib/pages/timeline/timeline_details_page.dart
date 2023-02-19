import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../helper/helper_methods.dart';
import '../../models/flickr/flickr_photo.dart';
import '../../services/flickr/flickr_url_converter_service.dart';
import '../../widgets/util/iscte_theme.dart';

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
  final List<YoutubePlayerController> _videoControllers = [];

  void addVideoController(YoutubePlayerController controller) {
    _videoControllers.add(controller);
  }

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
      appBar: MyAppBar(
        title: AppLocalizations.of(context)!.timelineDetailsScreen,
        leading: DynamicBackIconButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: FutureBuilder<List<Content>>(
              future: allContentFromEvent,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  LoggerService.instance.debug(
                      "event: ${widget.event} , data:${snapshot.data!} ");
                  return ListView.builder(
                    addAutomaticKeepAlives: true,
                    itemCount: (snapshot.data?.length)! + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          //leading: widget.event.scopeIcon,
                          title: Text(widget.event.title),
                          subtitle: Text(subtitleText),
                        );
                      } else if (index == 1) {
                        return const Divider(
                          color: Colors.white,
                        );
                      } else {
                        return TimelineDetailGridContent(
                          content: snapshot.data![index - 2],
                          addVideoControllerCallback: addVideoController,
                        );
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
    for (YoutubePlayerController controller in _videoControllers) {
      controller.pauseVideo();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    for (YoutubePlayerController controller in _videoControllers) {
      controller.close();
    }
    super.dispose();
  }
}

class TimelineDetailGridContent extends StatefulWidget {
  const TimelineDetailGridContent({
    Key? key,
    required this.content,
    required this.addVideoControllerCallback,
  }) : super(key: key);
  final Content content;
  final void Function(YoutubePlayerController controller)
      addVideoControllerCallback;

  @override
  State<TimelineDetailGridContent> createState() =>
      _TimelineDetailGridContentState();
}

class _TimelineDetailGridContentState extends State<TimelineDetailGridContent> {
  late final YoutubePlayerController _controller;
  late final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }

  @override
  void initState() {
    super.initState();

    if (widget.content.link.contains("youtube")) {
      _controller = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          mute: false,
          showFullscreenButton: true,
          loop: false,
        ),
      );
      _controller.loadVideo(widget.content.link);
      widget.addVideoControllerCallback(_controller);
      child = Wrap(
        children: [
          YoutubePlayer(
            controller: _controller,
          ),
        ],
      );
    } else if (widget.content.link.contains("www.flickr.com/photos")) {
      child = FutureBuilder<FlickrPhoto>(
          future: FlickrUrlConverterService.getPhotofromFlickrURL(
              widget.content.link),
          builder: (BuildContext context, AsyncSnapshot<FlickrPhoto> snapshot) {
            if (snapshot.hasData) {
              FlickrPhoto photo = snapshot.data!;
              return Card(
                color: IscteTheme.iscteColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(photo.title),
                      ),
                      InteractiveViewer(
                        child: CachedNetworkImage(
                            imageUrl: photo.url,
                            fadeOutDuration: const Duration(seconds: 1),
                            fadeInDuration: const Duration(seconds: 3),
                            progressIndicatorBuilder: (BuildContext context,
                                    String url, DownloadProgress progress) =>
                                const LoadingWidget()),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return NetworkError(onRefresh: () {});
            } else {
              return const LoadingWidget();
            }
          });
    } else {
      child = ListTile(
        leading: widget.content.contentIcon,
        title: Text(widget.content.description ?? ""),
        subtitle: Text(widget.content.link),
        onTap: () {
          LoggerService.instance.debug(widget.content);
          if (widget.content.link.isNotEmpty) {
            HelperMethods.launchURL(widget.content.link);
          }
        },
      );
    }
  }
}
