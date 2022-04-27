import 'dart:convert';
import 'dart:io';

import 'package:iscte_spots/pages/profile/profile_screen.dart';
import 'package:iscte_spots/widgets/util/constants.dart';
import 'package:logger/logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class OpenDayQRScanService {
  static final Logger _logger = Logger();
  static final String wrongSpotError = "wrong_spot";
  static final String generalError = "error";
  static final String loginError = "not_logged_in";

  static Future<String> spotRequest({Barcode? barcode}) async {
    String? apiToken = await secureStorage.read(
        key: BackEndConstants.backendApiKeySharedPrefsString);
    if (apiToken == null) {
      return loginError;
    }
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      final HttpClientRequest request;

      if (barcode == null) {
        request = await client.getUrl(
            Uri.parse('${BackEndConstants.API_ADDRESS}/api/spots/permit}'));
      } else {
        request = await client.getUrl(Uri.parse(
            '${BackEndConstants.API_ADDRESS}/api/spots/${barcode.code}'));
      }

      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();

      var responseDecoded =
          jsonDecode(await response.transform(utf8.decoder).join());
      if (response.statusCode == 200) {
        _logger.d(responseDecoded);
        String locationPhotoLink = responseDecoded["location_photo_link"];
        if (locationPhotoLink != null) {
          return locationPhotoLink;
        } else {
          return generalError;
        }
      }
    } catch (e) {
      _logger.e(e);
      return generalError;
    }
    return generalError;
  }
}
