import 'dart:convert';
import 'dart:io';

import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

import '../../pages/leaderboard/leaderboard_screen.dart';
import '../flickr/flickr_service.dart';

const API_ADDRESS = BackEndConstants.API_ADDRESS;
const API_ADDRESS_TEST = "http://192.168.1.66";
const FLICKR_API_KEY = "c16f27dcc1c8674dd6daa3a26bd24520";

class QuizService {
  static final Logger _logger = Logger();

  static Future<List<dynamic>> getQuizList() async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");
      //String? apiToken = "8eb7f1e61ef68a526cf5a1fb6ddb0903bc0678c1";

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final request =
          await client.getUrl(Uri.parse('$API_ADDRESS/api/quizzes'));

      request.headers.set('content-type', 'application/json');
      request.headers.add("Authorization", "Token $apiToken");
      final response = await request.close();

      if (response.statusCode == 200) {
        var quizzes = jsonDecode(await response.transform(utf8.decoder).join());
        _logger.d(quizzes);
        return quizzes;
      }
    } catch (e) {
      _logger.d(e);
      rethrow;
    }
    throw Exception('Failed to load quiz list');
  }

  static Future<Map> startTrial(int quiz) async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");
      //String? apiToken = "8eb7f1e61ef68a526cf5a1fb6ddb0903bc0678c1";

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      //final request = await client.postUrl(
      //  Uri.parse('${BackEndConstants.API_ADDRESS}/api/quizzes/$quiz'));
      final request = await client
          .postUrl(Uri.parse('$API_ADDRESS/api/quizzes/$quiz/trials'));

      request.headers.add("Authorization", "Token $apiToken");
      request.headers.set('content-type', 'application/json');
      final response = await request.close();
      _logger.d(response);

      if (response.statusCode == 201) {
        return jsonDecode(await response.transform(utf8.decoder).join());
      }
    } catch (e) {
      _logger.d(e);
      rethrow;
    }
    throw Exception('Failed to start trial');
  }

  static Future<Map> getNextQuestion(int quiz, int trial) async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final request = await client.postUrl(Uri.parse(
          '$API_ADDRESS/api/quizzes/$quiz/trials/$trial/next_question'));

      request.headers.add("Authorization", "Token $apiToken");
      request.headers.set('content-type', 'application/json');
      final response = await request.close();

      if (response.statusCode == 201) {
        return jsonDecode(await response.transform(utf8.decoder).join());
      }
    } catch (e) {
      _logger.d(e);
    }
    throw Exception('Failed to obtain next question');
  }

  static Future<bool> answerQuestion(
      int quiz, int trial, int question, Map answer) async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final request = await client.postUrl(Uri.parse(
          '$API_ADDRESS/api/quizzes/$quiz/trials/$trial/questions/$question/answer'));

      request.headers.add("Authorization", "Token $apiToken");
      request.headers.add('Content-Type', 'application/json; charset=utf-8');
      request.add(utf8.encode(json.encode(answer)));
      final response = await request.close();

      /*var response = await http.post(
          Uri.parse(
              '$API_ADDRESS/api/quizzes/$quiz/trials/$trial/questions/$question/answer'),
          headers: {
            "Authorization": "Token $apiToken",
            "Content-Type": 'application/json; charset=utf-8'
          },
          body: jsonEncode(answer));*/

      return response.statusCode == 201;
      //return jsonDecode(await response.transform(utf8.decoder).join());
      return true;
    } catch (e) {
      _logger.d(e);
      rethrow;
    }
  }

  static Future<String> getPhotoURLfromQuizFlickrURL(String url) async {
    try {

      if(url == ""){
        return "https://www.iscte-iul.pt/assets/files/2021/12/07/1638876926013_logo_50_anos_main.png";
      }

      var photoId = url.split("/")[5];
      var photoData = await http.get(Uri.parse(
          'https://www.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=$FLICKR_API_KEY&photo_id=$photoId&format=json&nojsoncallback=1'));
      if (photoData.statusCode == 200) {
        final jsonPhotoData = jsonDecode(photoData.body)["photo"];
        _logger.d(jsonPhotoData);

        var farm = jsonPhotoData["farm"];
        var server = jsonPhotoData["server"];
        var photoid = jsonPhotoData["id"];
        var photoSecret = jsonPhotoData["secret"];
        var imagesrc =
            "https://farm$farm.staticflickr.com/$server/$photoid\_$photoSecret\_z.jpg";

        return imagesrc;
      }else{
        throw Exception();
      }
    } catch (e) {
      _logger.d(e);
      rethrow;
    }
  }
}
