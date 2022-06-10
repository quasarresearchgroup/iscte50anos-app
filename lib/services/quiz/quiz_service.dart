import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:iscte_spots/models/auth/registration_form_result.dart';
import 'package:iscte_spots/pages/auth/register/registration_error.dart';
import 'package:iscte_spots/services/auth/auth_service.dart';
import 'package:iscte_spots/widgets/util/constants.dart';
import 'package:logger/logger.dart';

import '../../pages/leaderboard/leaderboard_screen.dart';

class QuizService {
  static final Logger _logger = Logger();

  static Future<List<dynamic>> getQuizList() async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");

      HttpClient client = HttpClient();
      client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

      final request = await client.postUrl(Uri.parse(
          '${BackEndConstants.API_ADDRESS}/api/quizzes'));

      request.headers.set('content-type', 'application/json');
      request.headers.add("Authorization", "Token $apiToken");
      final response = await request.close();

      if (response.statusCode == 200) {
        return jsonDecode(await response.transform(utf8.decoder).join());
      }
    } catch (e) {
      print(e);
    }
    throw Exception('Failed to load quiz list');
  }

  static Future<Map> startTrial(int quiz) async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");

      HttpClient client = HttpClient();
      client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

      final request = await client.postUrl(Uri.parse(
          '${BackEndConstants.API_ADDRESS}/api/quizzes/1'));

      request.headers.add("Authorization", "Token $apiToken");
      request.headers.set('content-type', 'application/json');
      final response = await request.close();

      if (response.statusCode == 201) {
        return jsonDecode(await response.transform(utf8.decoder).join());
      }
    } catch (e) {
      print(e);
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
          '${BackEndConstants.API_ADDRESS}/api/quizzes/$quiz/trials/$trial/next_question'));

      request.headers.add("Authorization", "Token $apiToken");
      request.headers.set('content-type', 'application/json');
      final response = await request.close();

      if (response.statusCode == 201) {
        return jsonDecode(await response.transform(utf8.decoder).join());
      }
    } catch (e) {
      print(e);
    }
    throw Exception('Failed to obtain next question');
  }

  static Future<Map> answerQuestion(int quiz, int trial, int question) async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");

      HttpClient client = HttpClient();
      client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

      final request = await client.postUrl(Uri.parse(
          '${BackEndConstants.API_ADDRESS}/api/quizzes/$quiz/trials/$trial/questions/$question'));

      request.headers.add("Authorization", "Token $apiToken");
      request.headers.set('content-type', 'application/json');
      final response = await request.close();

      if (response.statusCode == 201) {
        return jsonDecode(await response.transform(utf8.decoder).join());
      }
    } catch (e) {
      print(e);
    }
    throw Exception('Failed to obtain next question');
  }









}


