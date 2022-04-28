import 'dart:convert';
import 'dart:io';

import 'package:iscte_spots/pages/profile/profile_screen.dart';
import 'package:iscte_spots/services/auth/auth_service.dart';
import 'package:iscte_spots/widgets/util/constants.dart';
import 'package:logger/logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class OpenDayQRScanService {
  static final Logger _logger = Logger();
  static const String wrongSpotError = "Não podes aceder a este Spot ainda";
  static const String generalError = "error";
  static const String loginError = "not_logged_in";
  static const String alreadyVisitedError = "Já visitaste este Spot";
  static const String allVisited = "Parabéns, visitaste todos os Spots!";
  static const String invalidQRError = "QRCode inválido";
  static const String disabledQRError =
      "Não existem QR Codes ativos de momento";

  static Future<String> spotRequest({Barcode? barcode}) async {
    _logger.d("started request at ${DateTime.now()}");
    String? apiToken =
        await secureStorage.read(key: AuthService.backendApiKeyStorageLocation);
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
            Uri.parse('${BackEndConstants.API_ADDRESS}/api/spots/permit'));
      } else {
        request = await client.getUrl(Uri.parse(
            '${BackEndConstants.API_ADDRESS}/api/spots/${barcode.code}'));
      }

      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();

      var responseDecoded =
          jsonDecode(await response.transform(utf8.decoder).join());
      _logger.d(responseDecoded);
      if (responseDecoded["location_photo_link"] != null) {
        _logger.d(
            "${responseDecoded["location_photo_link"]} ${responseDecoded["description"]}");
        return responseDecoded["location_photo_link"];
      } else if (responseDecoded["message"] != null) {
        var responseDecoded2 = responseDecoded["message"] as String;
        return responseDecoded2;
      }
    } catch (e) {
      _logger.e(e);
      return generalError;
    }
    return generalError;
  }
}
