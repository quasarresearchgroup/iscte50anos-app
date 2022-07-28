import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/services/auth/auth_service.dart';
import 'package:iscte_spots/services/auth/exceptions.dart';
import 'package:iscte_spots/services/auth/openday_login_service.dart';
import 'package:iscte_spots/widgets/util/constants.dart';
import 'package:logger/logger.dart';

class SpotsRequestService {
  static final Logger _logger = Logger();

  static Future<List<String>> getAllSpots(
      {required BuildContext context}) async {
    _logger.d("started getAllSpots request at ${DateTime.now()}\t");

    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    String? apiToken =
        await secureStorage.read(key: AuthService.backendApiKeyStorageLocation);
    if (apiToken == null) {
      throw LoginException();
    }

    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    final HttpClientRequest request;

    request = await client
        .getUrl(Uri.parse('${BackEndConstants.API_ADDRESS}/api/spots/'));
    request.headers.add("Authorization", "Token $apiToken");

    try {
      final response = await request.close();
      if (response.statusCode == 403) {
        OpenDayLoginService.logOut(context);
        throw LoginException();
      } else if (response.statusCode == 200) {
        var responseDecoded =
            jsonDecode(await response.transform(utf8.decoder).join());

        _logger.d(responseDecoded);
        List<String> spotsImages = [];
        for (var item in responseDecoded) {
          spotsImages.add(item["location_photo_link"]);
        }
        return spotsImages;
      } else {
        throw Exception("General error on request");
      }
    } catch (e) {
      _logger.e(e);
      rethrow;
    }
  }
}
