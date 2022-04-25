import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/models/flickr/flickr_photoset.dart';
import 'package:iscte_spots/services/flickr/flickr_service.dart';

class FlickrIscteAlbumService extends FlickrService {
  final StreamController<FlickrPhotoset> _controller =
      StreamController<FlickrPhotoset>();

  @override
  Stream<FlickrPhotoset> get stream => _controller.stream;
  //List<FlickrPhotoset> photosetsInstanceList = [];
  int currentPage = 1;
  final int perPage = 25;

  Future<void> fetch() async {
    assert(!fetching);
    if (fetching) {
      logger.e(
          "Already fetching. Wait for current fetch to finish before making another request!");
    } else {
      try {
        http.Response response = await http
            .get(Uri.parse(
                'https://www.flickr.com/services/rest/?method=flickr.photosets.getList&api_key=${FlickrService.key}&user_id=${FlickrService.userID}&page=$currentPage&per_page=$perPage&format=json&nojsoncallback=1'))
            .timeout(const Duration(minutes: 2));
        if (response.statusCode == 200) {
          logger.d("Started fetching image urls");
          startFetch();
          final jsonResponse = jsonDecode(response.body);
          var photosets = jsonResponse["photosets"]["photoset"];

          int counter = 0;
          for (var photosetEntry in photosets) {
            FlickrPhotoset flickrPhotoset = FlickrPhotoset(
              title: photosetEntry["title"]["_content"],
              description: photosetEntry["description"]["_content"],
              id: photosetEntry["id"],
              farm: photosetEntry["farm"],
              server: photosetEntry["server"],
              photoN: photosetEntry["photos"],
              primaryphotoID: photosetEntry["primary"],
              primaryphotoURL:
                  "https://farm${photosetEntry["farm"]}.staticflickr.com/${photosetEntry["server"]}/${photosetEntry["primary"]}\_${photosetEntry["secret"]}.jpg",
            );
            logger.d(flickrPhotoset);
            _controller.sink.add(flickrPhotoset);
          }
          currentPage++;
          if (counter < perPage) {
            _controller.sink.addError(FlickrService.noDataError);
          }
          stopFetch();
        } else {
          logger.d("Error ${response.statusCode}");
          stopFetch();
          //return [];
        }
      } on Exception catch (e) {
        throw SocketException(e.toString());
        //_controller.close();
      }
    }
  }
}
