import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:iscte_spots/models/auth/registration_form_result.dart';
import 'package:iscte_spots/pages/auth/register/registration_error.dart';
import 'package:iscte_spots/services/auth/auth_service.dart';
import 'package:iscte_spots/widgets/util/constants.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

import '../../pages/leaderboard/leaderboard_screen.dart';

const API_ADDRESS = "https://194.210.120.193";
const API_ADDRESS_TEST = "http://192.168.1.66";

class QuizService {
  static final Logger _logger = Logger();

  static Future<List<dynamic>> getQuizList() async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");
      //String? apiToken = "8eb7f1e61ef68a526cf5a1fb6ddb0903bc0678c1";

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final request = await client
          .getUrl(Uri.parse('$API_ADDRESS/api/quizzes'));

      request.headers.set('content-type', 'application/json');
      request.headers.add("Authorization", "Token $apiToken");
      final response = await request.close();

      if (response.statusCode == 200) {
        return jsonDecode(await response.transform(utf8.decoder).join());
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
}
