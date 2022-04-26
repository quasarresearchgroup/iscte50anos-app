import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/models/auth/login_form_result.dart';
import 'package:iscte_spots/widgets/util/constants.dart';
import 'package:logger/logger.dart';

class OpenDayLogin {
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
    if (response.statusCode == 200) {
      String? responseApiToken = decodedResponse["api_token"];
      if (responseApiToken != null) {
        final storage = FlutterSecureStorage();
        storage.write(
          key: BackEndConstants.backendApiKeySharedPrefsString,
          value: responseApiToken,
        );
        _logger.d("Stored token: $responseApiToken in Secure Storage");
      }
    } else {
      _logger.e(
          "statusCode: ${response.statusCode} on login response: $decodedResponse");
    }
    return response.statusCode;
  }
}
