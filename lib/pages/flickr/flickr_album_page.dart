import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/flickr/flickr_photo.dart';
import 'package:iscte_spots/models/flickr/flickr_photoset.dart';
import 'package:iscte_spots/services/flickr_photoset_service.dart';
import 'package:iscte_spots/services/flickr_service.dart';
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
      noMoreData = error == FlickrService.NODATAERROR;
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
        appBar: AppBar(
          title: Text(widget.album.title),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: fetching
                    ? const CircularProgressIndicator.adaptive()
                    : const FaIcon(FontAwesomeIcons.check),
              ),
            )
          ],
        ),
        body: ListView.builder(
            itemCount: fetchedPhotos.length + 1,
            controller: widget.listViewController,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: index < fetchedPhotos.length
                    ? Image.network(fetchedPhotos[index].url)
                    : noMoreData
                        ? const Center(child: Text("no more data"))
                        : const LoadingWidget(),
              );
            }));
  }
}
