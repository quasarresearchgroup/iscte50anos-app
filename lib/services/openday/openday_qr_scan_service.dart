import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/requests/spot_request.dart';
import 'package:iscte_spots/services/auth/auth_service.dart';
import 'package:iscte_spots/services/auth/openday_login_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'openday_notification_service.dart';

class OpenDayQRScanService {
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
        string == alreadyVisitedError;
  }

  static bool isCompleteAll(String string) {
    return string == allVisited;
  }

  static Future<String?> requestRouter(
      BuildContext context, SpotRequest request) async {
    if (request.statusCode == 404) {
      OpenDayNotificationService.showInvalidErrorOverlay(context);
      LoggerService.instance.debug("invalidQRError : $request");
    } else {
      var response = request.locationPhotoLink;
      switch (response) {
        case OpenDayQRScanService.generalError:
          {
            OpenDayNotificationService.showErrorOverlay(context);
            LoggerService.instance.debug("generalError : $response");
          }
          break;
        case OpenDayQRScanService.connectionError:
          {
            OpenDayNotificationService.showConnectionErrorOverlay(context);
            LoggerService.instance.debug("connectionError : $response");
          }
          break;
        case OpenDayQRScanService.loginError:
          {
            OpenDayNotificationService.showLoginErrorOverlay(context);
            LoggerService.instance.debug("loginError : $response");
          }
          break;
        case OpenDayQRScanService.wrongSpotError:
          {
            OpenDayNotificationService.showWrongSpotErrorOverlay(context);
            LoggerService.instance.debug("wrongSpotError : $response");
          }
          break;
        case OpenDayQRScanService.alreadyVisitedError:
          {
            OpenDayNotificationService.showAlreadeyVisitedOverlay(context);
            LoggerService.instance.debug("alreadyVisitedError : $response");
          }
          break;
        case OpenDayQRScanService.invalidQRError:
          {
            OpenDayNotificationService.showInvalidErrorOverlay(context);
            LoggerService.instance.debug("invalidQRError : $response");
          }
          break;
        case OpenDayQRScanService.disabledQRError:
          {
            OpenDayNotificationService.showDisabledErrorOverlay(context);
            LoggerService.instance.debug("disabledQRError : $response");
          }
          break;
        case OpenDayQRScanService.allVisited:
          {
            //OpenDayNotificationService.showAllVisitedOverlay(context);
            LoggerService.instance.debug("allVisited : $response");
            return OpenDayQRScanService.allVisited;
          }
          break;
        default:
          {
            //await OpenDayNotificationService.showNewSpotFoundOverlay(context);
            LoggerService.instance.debug("changed image: $response");
            return response;
          }
      }
    }
  }

  static Future<SpotRequest> spotRequest(
      {required BuildContext context, Barcode? barcode}) async {
    // int now = DateTime.now().millisecondsSinceEpoch;
    //if (now - _lastScan >= _scanCooldown) {

    LoggerService.instance
        .debug("started request at ${DateTime.now()}\t${barcode?.rawValue}");
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    String? apiToken =
        await secureStorage.read(key: AuthService.backendApiKeyStorageLocation);
    if (apiToken == null) {
      return SpotRequest(locationPhotoLink: loginError, statusCode: 403);
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
            '${BackEndConstants.API_ADDRESS}/api/spots/${barcode.rawValue}'));
      }

      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();
      if (response.statusCode == 403) {
        OpenDayLoginService.logOut();
        return SpotRequest(
            locationPhotoLink: loginError, statusCode: response.statusCode);
      } else if (response.statusCode == 404) {
        return SpotRequest(
            locationPhotoLink: invalidQRError, statusCode: response.statusCode);
      } else {
        var responseDecoded =
            jsonDecode(await response.transform(utf8.decoder).join());

        LoggerService.instance.debug(responseDecoded);

        if (responseDecoded["location_photo_link"] != null) {
          LoggerService.instance.debug(
              "${responseDecoded["location_photo_link"]}; ${responseDecoded["description"]}; ${responseDecoded["spot_number"]}");
          SharedPrefsService.resetCompletedAllPuzzles();
          return SpotRequest(
              statusCode: response.statusCode,
              locationPhotoLink: responseDecoded["location_photo_link"],
              spotNumber: responseDecoded["spot_number"]);
          //,responseDecoded["spot_number"];
        } else if (responseDecoded["message"] != null) {
          var responseDecoded2 = responseDecoded["message"] as String;

          LoggerService.instance.debug(responseDecoded2);
          return SpotRequest(
            locationPhotoLink: responseDecoded2,
            statusCode: response.statusCode,
          );
        }
      }
    } on SocketException {
      LoggerService.instance.error("Socket Exception");
      return SpotRequest(locationPhotoLink: connectionError, statusCode: 500);
    } catch (e) {
      LoggerService.instance.error(e);
      return SpotRequest(locationPhotoLink: generalError, statusCode: 500);
    }
    return SpotRequest(locationPhotoLink: generalError, statusCode: 500);
    //}else{

    //}
  }
}
