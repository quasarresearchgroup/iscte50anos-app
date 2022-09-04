import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/auth/login_form_result.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/pages/auth/auth_page.dart';
import 'package:iscte_spots/services/auth/auth_service.dart';
import 'package:iscte_spots/services/onboard_service.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:logger/logger.dart';

class OpenDayLoginService {
  static final Logger _logger = Logger();

  static Future<int> login(LoginFormResult loginFormResult) async {
    _logger.d("Logging in User: $loginFormResult");
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final HttpClientRequest request = await client
          .postUrl(Uri.parse('${BackEndConstants.API_ADDRESS}/api/auth/login'));
      List<int> encodedData = utf8.encode(json.encode(loginFormResult.toMap()));
      request.headers.set('content-type', 'application/json');
      request.headers.add(HttpHeaders.contentLengthHeader, encodedData.length);
      request.add(encodedData);

      HttpClientResponse response = await request.close();
      var decodedResponse =
          await jsonDecode(await response.transform(utf8.decoder).join());
      String? responseApiToken = decodedResponse["api_token"];

      if (response.statusCode == 200 && responseApiToken != null) {
        AuthService.storeLogInCredenials(
          username: loginFormResult.username,
          password: loginFormResult.password,
          apiKey: responseApiToken,
        );
      } else {
        _logger.e(
            "statusCode: ${response.statusCode} with login response: $decodedResponse");
      }
      return response.statusCode;
    } on SocketException {
      rethrow;
    }
  }

  static Future<bool> isLoggedIn() async {
    const storage = FlutterSecureStorage();
    String? username =
        await storage.read(key: AuthService.usernameStorageLocation);
    String? password =
        await storage.read(key: AuthService.passwordStorageLocation);
    _logger.d("username : $username ; password : $password");
    if (username != null && password != null) {
      int loginresult = await login(
        LoginFormResult(
          username: username,
          password: password,
        ),
      );
      if (loginresult == 200) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<void> logOut(BuildContext context) async {
    _logger.d("Logging Out User:");
    /*const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    final HttpClientRequest request = await client
        .postUrl(Uri.parse('${BackEndConstants.API_ADDRESS}/api/auth/logout'));

    String? apiToken = await secureStorage.read(key: "backend_api_key");
    request.headers.add("Authorization", "Token $apiToken");

    request.headers.set('content-type', 'application/json');

    HttpClientResponse response = await request.close();
    var decodedResponse =
        await jsonDecode(await response.transform(utf8.decoder).join());
    if (response.statusCode == 200) {
*/
    await AuthService.deleteUserCredentials();
    await OnboadingService.removeOnboard();
    Navigator.of(context).popUntil(ModalRoute.withName(AuthPage.pageRoute));
    Navigator.of(context).pushNamed(AuthPage.pageRoute);
    /*  } else {
      _logger.e(
          "statusCode: ${response.statusCode} on login response: $decodedResponse");
    }
*/
    //Resetting status of completing all puzzles
    SharedPrefsService.resetCompletedAllPuzzles();

    //Removing placed puzzle pieces
    DatabasePuzzlePieceTable.removeALL();

    return;
  }
}
