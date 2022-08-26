import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/models/flickr/flickr_photo.dart';
import 'package:iscte_spots/services/flickr/flickr_service.dart';
import 'package:logger/logger.dart';

class FlickrUrlConverterService {
  static final Logger _logger = Logger();

  static Future<FlickrPhoto> getPhotofromFlickrURL(String url) async {
    assert(url.isNotEmpty);
    try {
      var photoId = url.split("/")[5];
      var photoData = await http.get(Uri.parse(
          'https://www.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=${FlickrService.key}&photo_id=$photoId&format=json&nojsoncallback=1'));
      if (photoData.statusCode == 200) {
        final jsonPhotoData = jsonDecode(photoData.body)["photo"];
        _logger.d(jsonPhotoData);

        var farm = jsonPhotoData["farm"];
        var server = jsonPhotoData["server"];
        var photoid = jsonPhotoData["id"];
        var photoSecret = jsonPhotoData["secret"];
        var photoTitle = jsonPhotoData["title"]["_content"];

        return FlickrPhoto(
          farm: farm,
          server: server,
          id: photoid,
          secret: photoSecret,
          title: photoTitle,
        );
      } else {
        throw Exception(photoData.statusCode);
      }
    } catch (e) {
      _logger.d(e);
      rethrow;
    }
  }
}
