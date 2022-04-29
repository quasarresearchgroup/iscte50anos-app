import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/models/auth/login_form_result.dart';
import 'package:iscte_spots/services/auth/auth_service.dart';
import 'package:iscte_spots/widgets/util/constants.dart';
import 'package:logger/logger.dart';

class OpenDayLoginService {
  static final Logger _logger = Logger();

  static Future<int> login(LoginFormResult loginFormResult) async {
    _logger.d("Logging in User:");

    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    final HttpClientRequest request = await client
        .postUrl(Uri.parse('${BackEndConstants.API_ADDRESS}/api/auth/login'));

    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(loginFormResult.toMap())));

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
          "statusCode: ${response.statusCode} on login response: $decodedResponse");
    }
    return response.statusCode;
  }

  static Future<bool> isLoggedIn() async {
    const storage = FlutterSecureStorage();
    String? username =
        await storage.read(key: AuthService.usernameStorageLocation);
    String? password =
        await storage.read(key: AuthService.passwordStorageLocation);
    _logger.d("username : $username ; password : $password");
    if (username != null && password != null) {
      int loginresult =
          await login(LoginFormResult(username: username, password: password));
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
    await AuthService.deleteUserCredentials();
    return;
  }
}
