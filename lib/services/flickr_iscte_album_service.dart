import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/models/flickr/flickr_photoset.dart';
import 'package:iscte_spots/services/flickr_service.dart';

class FlickrIscteAlbumService extends FlickrService {
  final StreamController<FlickrPhotoset> _controller =
      StreamController<FlickrPhotoset>();
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
                'https://www.flickr.com/services/rest/?method=flickr.photosets.getList&api_key=$key&user_id=${FlickrService.userID}&page=$currentPage&per_page=$perPage&format=json&nojsoncallback=1'))
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
            _controller.sink.addError(FlickrService.NODATAERROR);
          }
          stopFetch();
        } else {
          logger.d("Error ${response.statusCode}");
          stopFetch();
          //return [];
        }
      } on Exception catch (e) {
        _controller.sink.addError(e);
        //_controller.close();
      }
    }
  }
}

/*

"""{
   "id":"72157720230772113",
   "owner":"45216724@N07",
   "username":"Iscte - Instituto Universitário de Lisboa",
   "primary":"51744430861",
   "secret":"93bb79ae62",
   "server":"65535",
   "farm":66,
   "count_views":92,
   "count_comments":0,
   "count_photos":77,
   "count_videos":0,
   "title":{
      "_content":"Abertura da Exposição e Colóquio A Resistência Estudantil à Ditadura"
   },
   "description":{
      "_content":"A Abertura da Exposição e Colóquio &quot;A Resistência Estudantil à Ditadura&quot;, teve lugar na sala de exposições e no Grande Auditório do Iscte - Instituto Universitário de Lisboa, a 10 de dezembro de 2021.\n\nA exposição documental ‘A Resistência Estudantil à Ditadura’ é organizada no âmbito do projeto “Free Your Mind (FYM): Youth Activism in Southern Europe in Times of Dictatorship”, financiado pelo Programa Europa para os Cidadãos da União Europeia (Vertente 1: Memória Europeia) e coordenado por Luís Nuno Rodrigues (CEI-Iscte). Uma colaboração entre a Associação Cultural Ephemera e o CEI-Iscte.\n\nProgrma do colóquio:\n11:00 - Ativismo estudantil no período do Estado Novo;\n15:00 - Os ativismos juvenis do século XXI;\n17:30 - Youth Activism in Southern Europe in Times of Dictatorship\n\nFotografia de Hugo Alexandre Cruz."
   },
   "can_comment":0,
   "date_create":"1639414855",
   "date_update":"1647594982",
   "photos":77,
   "videos":0,
   "visibility_can_see_set":1,
   "needs_interstitial":0
}"""
*/
