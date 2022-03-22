import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/flickr/flickr_photo.dart';
import 'package:iscte_spots/models/flickr/flickr_photoset.dart';
import 'package:iscte_spots/services/flickr_photoset_service.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class FlickAlbumPage extends StatefulWidget {
  FlickAlbumPage({Key? key, required this.album}) : super(key: key);
  final Logger _logger = Logger();
  final FlickrPhotoset album;

  @override
  State<FlickAlbumPage> createState() => _FlickAlbumPageState();
}

class _FlickAlbumPageState extends State<FlickAlbumPage> {
  final FLickrPhotosetService fLickrPhotosetService = FLickrPhotosetService();

  final ScrollController listViewController = ScrollController();
  List<FlickrPhoto> fetchedPhotos = [];
  bool noMoreData = false;
  @override
  void initState() {
    super.initState();
    fLickrPhotosetService.stream.listen((FlickrPhoto event) {
      setState(() {
        if (!fetchedPhotos.contains(event)) {
          fetchedPhotos.add(event);
        }
      });
    }, onError: (error) {
      widget._logger.d(error);
      noMoreData = error == FLickrPhotosetService.NODATAERROR;
    });
    listViewController.addListener(() {
      if (listViewController.position.maxScrollExtent ==
          listViewController.offset) {
        fLickrPhotosetService.fetch(
            albumID: widget.album.id, farm: widget.album.farm);
      }
    });

    fLickrPhotosetService.fetch(
        albumID: widget.album.id, farm: widget.album.farm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.album.title),
        ),
        body: ListView.builder(
            itemCount: fetchedPhotos.length + 1,
            controller: listViewController,
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
