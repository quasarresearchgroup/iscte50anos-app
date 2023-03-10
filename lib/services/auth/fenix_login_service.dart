import 'dart:convert';
import 'dart:io';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:iscte_spots/services/logging/LoggerService.dart';

import 'auth_storage_service.dart';

class IscteLoginService {
  /// -----------------------------------
  ///           Auth0 Variables
  /// -----------------------------------
  static const IDP_DOMAIN = 'login.iscte-iul.pt';
  static const IDP_CLIENT_ID = '0oa2y4zd1pm9krr2o417';
  static const IDP_REDIRECT_URI = 'pt.iscteiul.vultos:/callback';
  static const IDP_ISSUER = 'https://$IDP_DOMAIN/oauth2/ausyeqjx8GS8Nj1Y9416';
  static const API_ADDRESS = "https://194.210.120.193";
  static const FlutterAppAuth appAuth = FlutterAppAuth();

  static Map<String, dynamic> parseIdToken(String idToken) {
    final parts = idToken.split(r'.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

  static Future<Map> getUserDetails(String accessToken) async {
    //print(accessToken);
    const url =
        'https://login.iscte-iul.pt/oauth2/ausyeqjx8GS8Nj1Y9416/v1/userinfo';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  static Future<bool> login() async {
    // GET ACCESS TOKEN AND ID TOKEN FROM OKTA

    final AuthorizationTokenResponse? result =
        await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        IDP_CLIENT_ID,
        IDP_REDIRECT_URI,
        issuer: IDP_ISSUER,
        //scopes: ['upn', 'openid', 'profile'],
        scopes: ['upn', 'openid', 'profile', 'offline_access'],
        //promptValues: ['login']
      ),
    );
    String? refreshToken = result?.refreshToken;

    final Map<String, dynamic> idToken =
        IscteLoginService.parseIdToken(result?.idToken ?? "");
    final profile = await getUserDetails(result?.accessToken ?? "");
    print("IDTOKEN: $idToken");
    print("----------------------------------------------------");

    print("PROFILE INFO: $profile");

    //await secureStorage.write(
    //    key: 'refresh_token', value: result?.refreshToken,);

    // Exchange OKTA access token to API Token
    /*Response tokenExchange = await http.post(
        Uri.parse('$API_ADDRESS/api/auth/'),
        body: {"access_token": result?.accessToken});*/

    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    final request = await client.postUrl(Uri.parse('$API_ADDRESS/api/auth/'));

    request.headers.set('content-type', 'application/json');
    var tokenRequestBody =
        utf8.encode(json.encode({"access_token": result?.accessToken}));
    request.headers.set('Content-Length', tokenRequestBody.length);
    request.add(tokenRequestBody);
    final response = await request.close();

    LoggerService.instance
        .debug("Obtained api token. Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      dynamic apiToken = await jsonDecode(await response.transform(utf8.decoder).join());
      LoggerService.instance.debug("API Token: $apiToken");
      //secureStorage.write(key: 'api_token', value: apiToken["access_token"]);
      IscteLoginStorageService.storeFenixLogInCredenials(
        refreshToken: refreshToken,
        apiKey: apiToken["api_token"].toString(),
      );
      return true;
    }

    return false;

    // final Map apiToken = json.decode(utf8.decode(tokenExchange.body.codeUnits));
  }
}
