import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/auth/registration_form_result.dart';
import 'package:iscte_spots/pages/auth/register/registration_error.dart';
import 'package:iscte_spots/services/auth/auth_service.dart';
import 'package:logger/logger.dart';

class RegistrationService {
  static const String AfiliationsFile = 'Resources/openday_affiliations.json';
  static final Logger _logger = Logger();

  static Future<Map<String, dynamic>> getSchoolAffiliations() async {
    await Future.delayed(Duration(seconds: 1));

    try {
      final String file = await rootBundle.loadString(AfiliationsFile);
      var jsonText =
          await rootBundle.loadString('Resources/openday_affiliations.json');
      Map<String, dynamic> affiliationMap =
          json.decode(utf8.decode(jsonText.codeUnits));
      return affiliationMap;
      /*final Map<String, List<String>> result = {};

      result["-"] = <String>["-"];
      file.split("\n").forEach((line) {
        List<String> lineSplit = line.split(",");
        String district = lineSplit[1];
        String school = lineSplit[0];
        if (result[district] == null) {
          result[district] = <String>["-", school];
        } else {
          result[district]!.add(school);
        }
      });
      return result;
        */
    } catch (e) {
      _logger.e(e);
      rethrow;
    }
  }

  static Future<RegistrationError> registerNewUser(
      RegistrationFormResult registrationFormResult) async {
    _logger.d("registering new User:\n$registrationFormResult");

    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    final HttpClientRequest request = await client
        .postUrl(Uri.parse('${BackEndConstants.API_ADDRESS}/api/auth/signup'));

    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(registrationFormResult.toMap())));

    HttpClientResponse response = await request.close();
    _logger.d("response: $response");
    _logger.d("statusCode: ${response.statusCode}");
    var decodedResponse =
        await jsonDecode(await response.transform(utf8.decoder).join());
    _logger.d("response: $decodedResponse");

    RegistrationError responseRegistrationError;
    if (decodedResponse["code"] != null) {
      int responseErrorCode = decodedResponse["code"];
      responseRegistrationError =
          RegistrationErrorExtension.registrationErrorConstructor(
              responseErrorCode);
    } else {
      String responseApiToken = decodedResponse["api_token"];
      _logger.d("Created new user with token: $responseApiToken");

      AuthService.storeLogInCredenials(
        username: registrationFormResult.username,
        password: registrationFormResult.password,
        apiKey: responseApiToken,
      );
      responseRegistrationError = RegistrationError.noError;
    }
    client.close();

    _logger.d(
        "response error code: $responseRegistrationError ; code: ${responseRegistrationError.code}");
    return responseRegistrationError;
  }
}
