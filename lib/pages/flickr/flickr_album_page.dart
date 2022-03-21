import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/flickr/flickr_photo.dart';
import 'package:iscte_spots/models/flickr/flickr_photoset.dart';
import 'package:iscte_spots/services/flickr_photoset_service.dart';

class FlickAlbumPage extends StatefulWidget {
  FlickAlbumPage({Key? key, required this.album}) : super(key: key);

  final FlickrPhotoset album;

  @override
  State<FlickAlbumPage> createState() => _FlickAlbumPageState();
}

class _FlickAlbumPageState extends State<FlickAlbumPage> {
  final FLickrPhotosetService fLickrPhotosetService = FLickrPhotosetService();

  List<FlickrPhoto> fetchedPhotos = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fLickrPhotosetService.stream.listen((FlickrPhoto event) {
      setState(() {
        fetchedPhotos.add(event);
      });
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
            itemCount: fetchedPhotos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(fetchedPhotos[index].url),
              );
            }));
  }
}
