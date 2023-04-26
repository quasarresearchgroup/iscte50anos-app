import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/services/auth/auth_storage_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

import '../auth/exceptions.dart';
import '../auth/login_service.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

class LeaderboardService {
  static Future<List<dynamic>> fetchRelativeLeaderboard(
      BuildContext context) async {
    try {
      String apiToken = await LoginStorageService.getBackendApiKey();

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(Uri.parse(
          '${BackEndConstants.API_ADDRESS}/api/users/relative-leaderboard'));
      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();

      LoggerService.instance.debug(response);

      var result = jsonDecode(await response.transform(utf8.decoder).join());
      LoggerService.instance.debug(result);

      if (response.statusCode == 403) {
        LoginService.logOut(context);
        throw LoginException();
      } else if (response.statusCode == 200) {
        return result;
      } else {
        throw Exception("Could not fetch leaderboard");
      }
    } catch (e) {
      LoggerService.instance.debug(e);
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchGlobalLeaderboard(
      BuildContext context) async {
    try {
      String apiToken = await LoginStorageService.getBackendApiKey();

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/users/leaderboard'));
      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();

      LoggerService.instance.debug(response);
      var result = jsonDecode(await response.transform(utf8.decoder).join());
      LoggerService.instance.debug(result);

      if (response.statusCode == 403) {
        LoginService.logOut(context);
        throw LoginException();
      } else if (response.statusCode == 200) {
        return result;
      } else {
        throw Exception("Could not fetch leaderboard");
      }
    } catch (e) {
      LoggerService.instance.debug(e);
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchAffiliationLeaderboard(
      String type, String affiliation) async {
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

      LoggerService.instance.debug(response);

      if (response.statusCode == 200) {
        var result = jsonDecode(await response.transform(utf8.decoder).join());
        LoggerService.instance.debug(response);
        return result;
      } else {
        throw Exception("Could not fetch leaderboard");
      }
    } catch (e) {
      LoggerService.instance.debug(e);
      rethrow;
    }
  }
}
