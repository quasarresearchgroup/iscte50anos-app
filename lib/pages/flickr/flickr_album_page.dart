import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/flickr/flickr_photo.dart';
import 'package:iscte_spots/models/flickr/flickr_photoset.dart';
import 'package:iscte_spots/services/flickr/flickr_photoset_service.dart';
import 'package:iscte_spots/services/flickr/flickr_service.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class FlickAlbumPage extends StatefulWidget {
  FlickAlbumPage({Key? key, required this.album}) : super(key: key);
  final Logger _logger = Logger();
  final FlickrPhotoset album;
  final FLickrPhotosetService fLickrPhotosetService = FLickrPhotosetService();
  final ScrollController listViewController = ScrollController();
  final int fetchThreshHold = 1000;

  @override
  State<FlickAlbumPage> createState() => _FlickAlbumPageState();
}

class _FlickAlbumPageState extends State<FlickAlbumPage> {
  late StreamSubscription<FlickrPhoto> _streamSubscription;
  List<FlickrPhoto> fetchedPhotos = [];
  bool noMoreData = false;
  int lastFetch = 0;
  bool fetching = false;

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        widget.fLickrPhotosetService.stream.listen((FlickrPhoto event) {
      setState(() {
        if (!fetchedPhotos.contains(event)) {
          fetchedPhotos.add(event);
        } else {
          widget._logger.d("duplicated photo entry: $event");
        }
      });
    }, onError: (error) {
      widget._logger.d(error);
      noMoreData = error == FlickrService.noDataError;
    });
    widget.listViewController.addListener(() {
      //widget._logger.d(
      //    "current: ${listViewController.offset}; max:${listViewController.position.maxScrollExtent};");
      if (widget.listViewController.position.maxScrollExtent * 0.9 <=
          widget.listViewController.offset) {
        fetchMorePhotos();
      }
    });

    fetchMorePhotos();
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  void fetchMorePhotos() async {
    int millisecondsSinceEpoch2 = DateTime.now().millisecondsSinceEpoch;
    if (millisecondsSinceEpoch2 - lastFetch >= widget.fetchThreshHold) {
      setState(() {
        fetching = true;
      });
      widget._logger.d("fetching more data");
      lastFetch = millisecondsSinceEpoch2;
      await widget.fLickrPhotosetService
          .fetch(albumID: widget.album.id, farm: widget.album.farm);
      setState(() {
        fetching = false;
      });
    } else {
      widget._logger.d("wait a bit before fetching againg");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          title: widget.album.title,
          trailing: fetching
              ? const LoadingWidget()
              : PlatformService.instance.isIos
                  ? const Icon(CupertinoIcons.check_mark)
                  : const Icon(Icons.check),
          leading: const DynamicBackIconButton(),
        ),
        body: ListView.builder(
            itemCount: fetchedPhotos.length + 1,
            controller: widget.listViewController,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: index < fetchedPhotos.length
                    ? InteractiveViewer(
                        child: CachedNetworkImage(
                            imageUrl: fetchedPhotos[index].url,
                            fadeOutDuration: const Duration(seconds: 1),
                            fadeInDuration: const Duration(seconds: 3),
                            progressIndicatorBuilder: (BuildContext context,
                                    String url, DownloadProgress progress) =>
                                LoadingWidget()),
                      )
                    : noMoreData
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.noMoreDataError),
                          )
                        : Container(),
              );
            }));
  }
}
