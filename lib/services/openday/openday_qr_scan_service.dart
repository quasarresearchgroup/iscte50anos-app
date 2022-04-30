import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/pages/profile/profile_screen.dart';
import 'package:iscte_spots/services/auth/auth_service.dart';
import 'package:iscte_spots/widgets/util/constants.dart';
import 'package:logger/logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'openday_notification_service.dart';

class OpenDayQRScanService {
  static final Logger _logger = Logger();
  static const String generalError = "error";
  static const String connectionError = "wifi_error";
  static const String loginError = "not_logged_in";
  static const String invalidQRError = "QRCode inválido";
  static const String disabledQRError =
      "Não existem QR Codes ativos de momento";
  static const String wrongSpotError = "Não podes aceder a este Spot ainda";
  static const String alreadyVisitedError = "Já visitaste este Spot";
  static const String allVisited = "Parabéns, visitaste todos os Spots!";

  static bool isError(String string) {
    return string == generalError ||
        string == connectionError ||
        string == loginError ||
        string == invalidQRError ||
        string == disabledQRError ||
        string == wrongSpotError ||
        string == alreadyVisitedError ||
        string == allVisited;
  }

  static Future<String?> requestRouter(
      BuildContext context, String response) async {
    switch (response) {
      case OpenDayQRScanService.generalError:
        {
          OpenDayNotificationService.showErrorOverlay(context);
          _logger.d("generalError : $response");
        }
        break;
      case OpenDayQRScanService.connectionError:
        {
          OpenDayNotificationService.showConnectionErrorOverlay(context);
          _logger.d("connectionError : $response");
        }
        break;
      case OpenDayQRScanService.loginError:
        {
          OpenDayNotificationService.showLoginErrorOverlay(context);
          _logger.d("loginError : $response");
        }
        break;
      case OpenDayQRScanService.wrongSpotError:
        {
          OpenDayNotificationService.showWrongSpotErrorOverlay(context);
          _logger.d("wrongSpotError : $response");
        }
        break;
      case OpenDayQRScanService.alreadyVisitedError:
        {
          OpenDayNotificationService.showAlreadeyVisitedOverlay(context);
          _logger.d("alreadyVisitedError : $response");
        }
        break;
      case OpenDayQRScanService.invalidQRError:
        {
          OpenDayNotificationService.showInvalidErrorOverlay(context);
          _logger.d("invalidQRError : $response");
        }
        break;
      case OpenDayQRScanService.disabledQRError:
        {
          OpenDayNotificationService.showDisabledErrorOverlay(context);
          _logger.d("disabledQRError : $response");
        }
        break;
      case OpenDayQRScanService.allVisited:
        {
          //OpenDayNotificationService.showAllVisitedOverlay(context);
          _logger.d("allVisited : $response");
          return OpenDayQRScanService.allVisited;
        }
        break;
      default:
        {
          //await OpenDayNotificationService.showNewSpotFoundOverlay(context);
          _logger.d("changed image: $response");
          return response;
        }
    }
  }

  static Future<String> spotRequest({Barcode? barcode}) async {
    _logger.d("started request at ${DateTime.now()}\t${barcode?.code}");
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
    } on SocketException {
      _logger.e("Soccket Exception");
      return connectionError;
    } catch (e) {
      _logger.e(e);
      return generalError;
    }
    return generalError;
  }
}
