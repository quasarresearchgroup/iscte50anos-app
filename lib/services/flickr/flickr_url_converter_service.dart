import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/models/flickr/flickr_photo.dart';
import 'package:iscte_spots/services/flickr/flickr_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';


class FlickrUrlConverterService {

  static Future<FlickrPhoto> getPhotofromFlickrURL(String url) async {
    assert(url.isNotEmpty);
    try {
      var photoId = url.split("/")[5];
      var photoData = await http.get(Uri.parse(
          'https://www.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=${FlickrService.key}&photo_id=$photoId&format=json&nojsoncallback=1'));
      if (photoData.statusCode == 200) {
        final jsonPhotoData = jsonDecode(photoData.body)["photo"];
        LoggerService.instance.debug(jsonPhotoData);

        var farm = jsonPhotoData["farm"];
        var server = jsonPhotoData["server"];
        var photoid = jsonPhotoData["id"];
        var photoSecret = jsonPhotoData["secret"];
        var photoTitle = jsonPhotoData["title"]["_content"];

        FlickrPhoto flickrPhoto = FlickrPhoto(
          farm: farm,
          server: server,
          id: photoid,
          secret: photoSecret,
          title: photoTitle,
        );
        LoggerService.instance.verbose(flickrPhoto);
        return flickrPhoto;
      } else {
        throw Exception(photoData.statusCode);
      }
    } catch (e) {
      LoggerService.instance.error(e);
      rethrow;
    }
  }
}
