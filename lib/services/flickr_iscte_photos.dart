import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/services/flickr_service.dart';

class FlickrIsctePhotoService extends FlickrService {
  static const String tags = "iscte";
  static const String photosetID = "72157719497252192";
  static const String userID = "45216724@N07";

  Future<http.Response?> getRequest() async {
    return await http
        .get(Uri.parse(
            'https://www.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=$key&photoset_id=$photosetID&user_id=$userID&format=json&nojsoncallback=1'))
        .timeout(const Duration(minutes: 2));
  }

  Future<List<String>> fetch() async {
    http.Response? response = await getRequest();
//'https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=$key&tags=$tags&format=json&nojsoncallback=1'));
//'https://www.flickr.com/services/feeds/photos_public.gne?tags=$tags&format=json&nojsoncallback=1'));
    final List<String> photoLinks = [];
    if (!fetching) {
      if (response != null && response.statusCode == 200) {
        logger.d("Started fetching image urls");
        startFetch();

        final jsonResponse = jsonDecode(response.body);
        var photos = jsonResponse["photoset"]["photo"];

        for (var photo in photos) {
          var photoId = photo["id"];
          final http.Response photoData = await http.get(Uri.parse(
              'https://www.flickr.com/services/rest/?method=flickr.photos.getContext&api_key=$key&photo_id=$photoId&format=json&nojsoncallback=1'));
          if (photoData.statusCode == 200) {
            final jsonPhotoData = jsonDecode(photoData.body)["prevphoto"];

            var server = jsonPhotoData["server"];
            var photoid = jsonPhotoData["id"];
            var farm = jsonPhotoData["farm"];
            var photoSecret = jsonPhotoData["secret"];
            var imagesrc =
                "https://farm$farm.staticflickr.com/$server/$photoid\_$photoSecret.jpg";
            logger.d(imagesrc);
            photoLinks.add(imagesrc);
          }
        }
        stopFetch();
        logger.d(photoLinks);
        return photoLinks;
      } else {
        fetching = false;
        throw Exception(response?.statusCode);
      }
    } else {
      logger.d("Fetching already in progress, no effect was taken");
    }
    return photoLinks;
  }
}
