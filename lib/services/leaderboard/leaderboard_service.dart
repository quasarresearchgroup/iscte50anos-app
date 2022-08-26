import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/auth/registration_form_result.dart';
import 'package:iscte_spots/pages/auth/register/registration_error.dart';
import 'package:iscte_spots/services/auth/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

const FlutterSecureStorage secureStorage = FlutterSecureStorage();


class LeaderboardService{
  static final Logger _logger = Logger();

  static Future<List<dynamic>> fetchRelativeLeaderboard() async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");

      HttpClient client = HttpClient();
      client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/users/relative-leaderboard'));
      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();

      _logger.d(response);

      if (response.statusCode == 200) {
        var result = jsonDecode(await response.transform(utf8.decoder).join());
        _logger.d(response);
        return result;
      }else{
        throw Exception("Could not fetch leaderboard");
      }
    } catch (e) {
      _logger.d(e);
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchGlobalLeaderboard() async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");

      HttpClient client = HttpClient();
      client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/users/leaderboard'));
      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();

      _logger.d(response);

      if (response.statusCode == 200) {
        var result = jsonDecode(await response.transform(utf8.decoder).join());
        _logger.d(response);
        return result;
      }else{
        throw Exception("Could not fetch leaderboard");
      }
    } catch (e) {
      _logger.d(e);
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchAffiliationLeaderboard(String type, String affiliation) async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");

      HttpClient client = HttpClient();
      client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/users/leaderboard'
              '?type=$type&affiliation=$affiliation'));
      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();

      _logger.d(response);

      if (response.statusCode == 200) {
        var result = jsonDecode(await response.transform(utf8.decoder).join());
        _logger.d(response);
        return result;
      }else{
        throw Exception("Could not fetch leaderboard");
      }
    } catch (e) {
      _logger.d(e);
      rethrow;
    }
  }

}
