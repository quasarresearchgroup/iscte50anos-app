import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/services/flickr/flickr_service.dart';

class FlickrIsctePhotoService extends FlickrService {
  static const String tags = "iscte";
  //static const String photosetID = "72157719497252192";
  static const String photosetID = "72157625777087393";
  static const String userID = "45216724@N07";

  final StreamController<String> _controller = StreamController<String>();
  @override
  Stream<String> get stream => _controller.stream;
  int currentPage = 1;
  final int perPage = 25;

  Future<void> fetch() async {
    if (!fetching) {
      http.Response response = await http
          .get(Uri.parse(
              'https://www.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=${FlickrService.key}&photoset_id=$photosetID&user_id=$userID&page=$currentPage&per_page=$perPage&format=json&nojsoncallback=1'))
          .timeout(const Duration(minutes: 2));

      if (response.statusCode == 200) {
        logger.d("Started fetching image urls");
        startFetch();

        final jsonResponse = jsonDecode(response.body);
        var photos = jsonResponse["photoset"]["photo"];

        for (var photo in photos) {
          var photoId = photo["id"];
          final http.Response photoData = await http.get(Uri.parse(
              'https://www.flickr.com/services/rest/?method=flickr.photos.getContext&api_key=${FlickrService.key}&photo_id=$photoId&format=json&nojsoncallback=1'));
          if (photoData.statusCode == 200) {
            final jsonPhotoData = jsonDecode(photoData.body)["prevphoto"];

            var farm = jsonPhotoData["farm"];
            var server = jsonPhotoData["server"];
            var photoid = jsonPhotoData["id"];
            var photoSecret = jsonPhotoData["secret"];
            var imagesrc =
                "https://farm$farm.staticflickr.com/$server/$photoid\_$photoSecret.jpg";
            logger.d(imagesrc);
            _controller.sink.add(imagesrc);
          }
        }
        stopFetch();
        currentPage++;
      } else {
        stopFetch();
        _controller.sink.addError(response.statusCode);
      }
    } else {
      logger.d("Fetching already in progress, no effect was taken");
    }
  }
}
