import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/helper/helper_methods.dart';
import 'package:iscte_spots/models/flickr/flickr_photo.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/services/flickr/flickr_url_converter_service.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class TimeLineDetailsPage extends StatefulWidget {
  const TimeLineDetailsPage({
    required this.eventId,
    Key? key,
  }) : super(key: key);
  final int eventId;
  static const String pageRoute = "event";
  static const ValueKey pageKey = ValueKey(pageRoute);

  @override
  State<TimeLineDetailsPage> createState() => _TimeLineDetailsPageState();
}

class _TimeLineDetailsPageState extends State<TimeLineDetailsPage> {
  final double textweight = 2;
  final Logger _logger = Logger();
  late final Future<Event> event;
  late final Future<String> eventTitle;
  final List<YoutubePlayerController> _videoControllers = [];
  late Future<List<Topic>> allTopicFromEvent;
  late Future<List<Content>> allContentFromEvent;

  @override
  void initState() {
    super.initState();
    event = TimelineEventService.fetchEvent(id: widget.eventId);
    eventTitle = event.then((value) => value.title);
    event.then((value) {
      allContentFromEvent = value.getContentList;
      allTopicFromEvent = value.getTopicsList;
    });
  }

  void addVideoController(YoutubePlayerController controller) {
    _videoControllers.add(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        middle: FutureBuilder<String>(
            future: eventTitle,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  "Details: ${snapshot.data!}",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: IscteTheme.iscteColor),
                );
              } else {
                return Text(
                  "Details",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: IscteTheme.iscteColor),
                );
              }
            }),
        leading: const DynamicBackIconButton(),
      ),
      body: FutureBuilder<Event>(
          future: event,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Event snapshotEvent = snapshot.data!;
              return FutureBuilder<List<Content>>(
                  future: allContentFromEvent,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      snapshot.data!.sort((Content a, Content b) {
                        if (a.type != null && b.type != null) {
                          return b.type!.index - a.type!.index;
                        } else {
                          return b.id - a.id;
                        }
                      });

                      List<Content> gridContents = [];
                      List<Content> listContents = [];
                      for (Content content in snapshot.data!) {
                        if (content.link.contains("flickr") ||
                            content.link.contains("youtube")) {
                          gridContents.add(content);
                        } else {
                          listContents.add(content);
                        }
                      }

                      _logger.d(
                          "event: $snapshotEvent\ndata:${snapshot.data!}\nlistContents: $listContents\ngridContents: $gridContents");
                      double mediaQuerryWidth =
                          MediaQuery.of(context).size.width;
                      int gridViewCrossAxisCountMediaQuery =
                          mediaQuerryWidth > 1000
                              ? mediaQuerryWidth > 3000
                                  ? 4
                                  : 2
                              : 1;
                      return CustomScrollView(
                        scrollDirection: Axis.vertical,
                        slivers: [
                          if (listContents.isNotEmpty)
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return TimelineDetailListContent(
                                    content: listContents[index],
                                    isEven: index % 2 == 0,
                                  );
                                },
                                childCount: (listContents.length),
                              ),
                            ),
                          if (listContents.isNotEmpty)
                            const SliverToBoxAdapter(
                              child: Divider(),
                            ),
                          if (gridContents.isNotEmpty)
                            SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return TimelineDetailGridContent(
                                    content: gridContents[index],
                                    isEven: index % 2 == 0,
                                    addVideoControllerCallback:
                                        addVideoController,
                                  );
                                },
                                addAutomaticKeepAlives: true,
                                childCount: (gridContents.length),
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: (gridContents.length) <
                                        gridViewCrossAxisCountMediaQuery
                                    ? gridContents.length
                                    : gridViewCrossAxisCountMediaQuery,
                                childAspectRatio: 16 / 9,
                              ),
                            )
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return NetworkError(onRefresh: () {
                        setState(() {
                          allContentFromEvent = snapshotEvent.getContentList;
                        });
                      });
                    } else {
                      return const LoadingWidget();
                    }
                  });
            } else {
              return const LoadingWidget();
            }
          }),
    );
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

class TimelineDetailListContent extends StatelessWidget {
  TimelineDetailListContent({
    Key? key,
    required this.isEven,
    required this.content,
  }) : super(key: key);

  final bool isEven;
  final Content content;
  final Logger _logger = Logger();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        _logger.d("Tapped $content");
        if (content.link.isNotEmpty) {
          HelperMethods.launchURL(content.link);
        }
      },
      hoverColor: IscteTheme.iscteColorSmooth,
      tileColor: !isEven ? IscteTheme.greyColor : Colors.transparent,
      leading: content.contentIcon,
      trailing: content.validated != null && content.validated!
          ? Icon(Icons.check_box)
          : null,
      title: Text(
          content.title != null
              ? content.title!.isNotEmpty
                  ? content.title!
                  : content.link
              : content.link,
          maxLines: 2,
          overflow: TextOverflow.ellipsis),
    );
  }
}

class TimelineDetailGridContent extends StatefulWidget {
  TimelineDetailGridContent({
    Key? key,
    required this.content,
    required this.isEven,
    required this.addVideoControllerCallback,
  }) : super(key: key);

  final Content content;
  final bool isEven;
  final void Function(YoutubePlayerController controller)
      addVideoControllerCallback;

  @override
  State<TimelineDetailGridContent> createState() =>
      _TimelineDetailGridContentState();
}

class _TimelineDetailGridContentState extends State<TimelineDetailGridContent> {
  final Logger _logger = Logger();
  Widget? child;
  late YoutubePlayerController controller;
  @override
  void initState() {
    super.initState();

    if (widget.content.link.contains("youtube")) {
      controller = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          mute: false,
          showFullscreenButton: true,
          loop: false,
        ),
      )..onInit = () {
          controller.loadVideo(widget.content.link);
        };
      widget.addVideoControllerCallback(controller);

      child = YoutubePlayer(
        controller: controller,
      );
    } else if (widget.content.link.contains("www.flickr.com/photos")) {
      child = FutureBuilder<FlickrPhoto>(
          future: FlickrUrlConverterService.getPhotofromFlickrURL(
              widget.content.link),
          builder: (BuildContext context, AsyncSnapshot<FlickrPhoto> snapshot) {
            if (snapshot.hasData) {
              FlickrPhoto photo = snapshot.data!;

              return CachedNetworkImage(
                imageUrl: photo.url,
                fadeOutDuration: const Duration(seconds: 1),
                fadeInDuration: const Duration(seconds: 3),
                progressIndicatorBuilder: (BuildContext context, String url,
                        DownloadProgress progress) =>
                    const LoadingWidget(),
              );
            } else if (snapshot.hasError) {
              return NetworkError(onRefresh: () {});
            } else {
              return const LoadingWidget();
            }
          });
    } else {
      child = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: IscteTheme.greyColor,
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            onTap: widget.content.link.isNotEmpty
                ? () {
                    _logger.d("Tapped ${widget.content}");
                    HelperMethods.launchURL(widget.content.link);
                  }
                : null,
            title: Text(
              widget.content.title != null
                  ? (widget.content.title!.isEmpty
                      ? widget.content.link
                      : widget.content.title!)
                  : widget.content.title!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: widget.content.contentIcon,
            trailing:
                widget.content.validated != null && widget.content.validated!
                    ? Icon(Icons.check_box)
                    : null,
          ),
          if (child != null) Expanded(child: child!),
        ],
      ),
    );
  }
}
