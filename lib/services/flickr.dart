import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class FlickrService {
  final Logger _logger = Logger();
  static const String tags = "iscte";
  static const String photosetID = "72157719497252192";
  static const String userID = "45216724@N07";
  String? key;
  StreamSubscription<http.Response>? streamSubscription;
  bool fetching = false;

  FlickrService() {
    key = dotenv.env["FLICKR_KEY"];
    if (key == null) {
      throw Exception("No API key");
    }
  }

  http.Response fetch() async {
    http.Response response;
    if (fetching) {
      streamSubscription?.cancel();
    }
    fetching = true;
    streamSubscription = await http
        .get(Uri.parse(
            'https://www.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=$key&photoset_id=$photosetID&user_id=$userID&format=json&nojsoncallback=1'))
        .asStream()
        .listen((http.Response event) {
      response = event;
      fetching = false;
      return response;
    });
  }

  Future<List<String>> getImageURLS() async {
    http.Response response;
    if (fetching) {
      streamSubscription?.cancel();
    }
    fetching = true;
    streamSubscription = await http
        .get(Uri.parse(
            'https://www.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=$key&photoset_id=$photosetID&user_id=$userID&format=json&nojsoncallback=1'))
        .asStream()
        .listen((http.Response event) {
      response = event;
      fetching = false;
    });
//'https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=$key&tags=$tags&format=json&nojsoncallback=1'));
//'https://www.flickr.com/services/feeds/photos_public.gne?tags=$tags&format=json&nojsoncallback=1'));
    final List<String> photoLinks = [];
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

//_logger.d(jsonResponse);
      var photos = jsonResponse["photoset"]["photo"];

      for (var photo in photos) {
        var photo_id = photo["id"];
//_logger.d("photo_ID=$photo_id\n$photo");
        final http.Response photoData = await http.get(Uri.parse(
            'https://www.flickr.com/services/rest/?method=flickr.photos.getContext&api_key=$key&photo_id=$photo_id&format=json&nojsoncallback=1'));
        if (photoData.statusCode == 200) {
          final jsonPhotoData = jsonDecode(photoData.body)["prevphoto"];
//_logger.d(jsonPhotoData);

          var server = jsonPhotoData["server"];
          var photoid = jsonPhotoData["id"];
          var farm = jsonPhotoData["farm"];
          var photoSecret = jsonPhotoData["secret"];
          var imagesrc =
              "https://farm$farm.staticflickr.com/$server/$photoid\_$photoSecret.jpg";
          _logger.d(imagesrc);
          photoLinks.add(imagesrc);
        }
      }
    }
    _logger.d(photoLinks);
    return photoLinks;
  }
}
