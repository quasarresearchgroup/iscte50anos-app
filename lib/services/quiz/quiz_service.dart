import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/quiz/quiz.dart';
import 'package:iscte_spots/models/quiz/trial.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/services/auth/auth_storage_service.dart';
import 'package:iscte_spots/services/auth/exceptions.dart';
import 'package:iscte_spots/services/auth/login_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/quiz/quiz_exceptions.dart';

const API_ADDRESS = BackEndConstants.API_ADDRESS;
const API_ADDRESS_TEST = "http://192.168.1.66";
const FLICKR_API_KEY = "c16f27dcc1c8674dd6daa3a26bd24520";
const ISCTE_DEFAULT_QUESTION_IMAGE_URL =
    "https://www.iscte-iul.pt/assets/files/2021/12/07/1638876926013_logo_50_anos_main.png";

class QuizService {
  static Future<List<Quiz>> getQuizList(BuildContext context) async {
    try {
      String apiToken = await LoginStorageService.getBackendApiKey();

      //String? apiToken = "8eb7f1e61ef68a526cf5a1fb6ddb0903bc0678c1";

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final request =
          await client.getUrl(Uri.parse('$API_ADDRESS/api/quizzes'));

      request.headers.set('content-type', 'application/json');
      request.headers.add("Authorization", "Token $apiToken");
      final response = await request.close();

      var decodedJson =
          jsonDecode(await response.transform(utf8.decoder).join());
      LoggerService.instance.debug(decodedJson);
      if (response.statusCode == 403) {
        LoginService.logOut(context);
        throw LoginException();
      } else if (response.statusCode == 200) {
        List<Quiz> quizzes = [];
        for (var item in decodedJson) {
          quizzes.add(Quiz.fromJson(item));
        }
        return quizzes;
      }
    } catch (e) {
      LoggerService.instance.error(e);
      rethrow;
    }
    throw Exception('Failed to load quiz list');
  }

  static Future<Trial> startTrial(int quiz) async {
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
      LoggerService.instance.debug(response);

      if (response.statusCode == 201) {
        var json = jsonDecode(await response.transform(utf8.decoder).join());
        LoggerService.instance.debug(json);
        return Trial.fromJson(json);
      }
    } catch (e) {
      LoggerService.instance.error(e);
      rethrow;
    }
    throw Exception('Failed to start trial');
  }

  static Future<Trial> getTrial(int quizNumber, int trialNumber) async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");
      //String? apiToken = "8eb7f1e61ef68a526cf5a1fb6ddb0903bc0678c1";

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      //final request = await client.postUrl(
      //  Uri.parse('${BackEndConstants.API_ADDRESS}/api/quizzes/$quiz'));
      final request = await client.getUrl(Uri.parse(
          '$API_ADDRESS/api/quizzes/$quizNumber/trials/$trialNumber'));

      request.headers.add("Authorization", "Token $apiToken");
      request.headers.set('content-type', 'application/json');
      final response = await request.close();
      LoggerService.instance.debug("statusCode ${response.statusCode}");
      var json = jsonDecode(await response.transform(utf8.decoder).join());
      LoggerService.instance.debug(json);
      return Trial.fromJson(json);
    } catch (e) {
      LoggerService.instance.debug(e);
      rethrow;
    }
    throw TrialFailedContinue();
  }

  static Future<int> answerTrial(
      int quizId, int trialId, Map answersMap) async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      LoggerService.instance.debug(
          "Submitting answers of trial to server: ${jsonEncode(answersMap)}");

      http.Response response = await http.post(
        Uri.parse('$API_ADDRESS/api/quizzes/$quizId/trials/$trialId/answer'),
        headers: <String, String>{
          "Authorization": "Token $apiToken",
          'content-type': 'application/json; charset=utf-8',
        },
        body: jsonEncode(answersMap),
      );

      var decodedJson = await jsonDecode(utf8.decode(response.bodyBytes));

      LoggerService.instance.debug(decodedJson);
      switch (response.statusCode) {
        case 201:
          int score = decodedJson["trial_score"];
          LoggerService.instance
              .debug("Success in submitting answer, score:$score");
          return score;
        case 400:
          LoggerService.instance.error(decodedJson);

          if (decodedJson["status"] ==
              TrialAlreadyAnsweredException().errorMessage) {
            throw TrialAlreadyAnsweredException();
          } else if (decodedJson["status"] ==
              TrialInvalidAnswerException().errorMessage) {
            throw TrialInvalidAnswerException();
          }
          throw TrialFailedSubmitAnswer();
        case 404:
          throw TrialQuizNotExistException();
        default:
          throw TrialFailedSubmitAnswer();
      }
    } catch (e) {
      LoggerService.instance.error(e);
      rethrow;
    }
  }

  static Future<String> getPhotoURLfromQuizFlickrURL(String url) async {
    try {
      if (url == "") {
        return ISCTE_DEFAULT_QUESTION_IMAGE_URL;
      }

      var photoId = url.split("/")[5];
      var photoData = await http.get(Uri.parse(
          'https://www.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=$FLICKR_API_KEY&photo_id=$photoId&format=json&nojsoncallback=1'));
      if (photoData.statusCode == 200) {
        final jsonPhotoData = jsonDecode(photoData.body)["photo"];
        LoggerService.instance.verbose(jsonPhotoData);

        var farm = jsonPhotoData["farm"];
        var server = jsonPhotoData["server"];
        var photoid = jsonPhotoData["id"];
        var photoSecret = jsonPhotoData["secret"];
        var imagesrc =
            "https://farm$farm.staticflickr.com/$server/$photoid\_$photoSecret\_z.jpg";

        return imagesrc;
      } else {
        throw Exception();
      }
    } catch (e) {
      LoggerService.instance.error("$url\n${e.toString()}");
      rethrow;
    }
  }
}
