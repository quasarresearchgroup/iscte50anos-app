import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/services/auth/auth_storage_service.dart';
import 'package:iscte_spots/services/auth/exceptions.dart';
import 'package:iscte_spots/services/auth/login_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class SpotsRequestService {
  static Future<void> fetchAllSpots(BuildContext context) async {
    LoggerService.instance
        .debug("started getAllSpots request at ${DateTime.now()}\t");

    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    String? apiToken =
        await secureStorage.read(key: LoginStorageService.backendApiKeyStorageLocation);
    if (apiToken == null) {
      LoggerService.instance.error("No apitoken stored");
      await LoginService.logOut(context);
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
        await LoginService.logOut(context);
        throw LoginException();
      } else if (response.statusCode == 200) {
        var responseDecoded =
            jsonDecode(await response.transform(utf8.decoder).join());

        LoggerService.instance.debug(responseDecoded);
        List<Spot> spotsList = [];
        for (var item in responseDecoded) {
          spotsList.add(
              Spot(id: item["id"], photoLink: item["location_photo_link"]));
        }
        await DatabaseSpotTable.addBatch(spotsList);
        return;
      } else {
        throw Exception("General error on request");
      }
    } catch (e) {
      LoggerService.instance.error(e);
      rethrow;
    }
  }
}
