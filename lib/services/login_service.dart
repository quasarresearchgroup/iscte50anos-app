import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../pages/login/login.dart';

class IscteLoginService {
  /// -----------------------------------
  ///           Auth0 Variables
  /// -----------------------------------

  static const IDP_DOMAIN = 'login.iscte-iul.pt';
  static const IDP_CLIENT_ID = '0oa2y4zd1pm9krr2o417';
  static const IDP_REDIRECT_URI = 'pt.iscteiul.vultos:/callback';
  static const IDP_ISSUER = 'https://$IDP_DOMAIN';
  static const API_ADDRESS = "192.168.1.124";

  static Map<String, dynamic> parseIdToken(String idToken) {
    final parts = idToken.split(r'.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

  static Future<Map> getUserDetails(String accessToken) async {
    //print(accessToken);
    const url = 'https://$IDP_DOMAIN/oauth2/v1/userinfo';
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

  static Future<Map<String, dynamic>> login() async {
    // GET ACCESS TOKEN AND ID TOKEN FROM OKTA
    final AuthorizationTokenResponse? result =
        await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        IDP_CLIENT_ID,
        IDP_REDIRECT_URI,
        issuer: 'https://$IDP_DOMAIN',
        scopes: ['openid', 'profile', 'offline_access'],
        //promptValues: ['login']
      ),
    );

    final Map<String, dynamic> idToken =
        IscteLoginService.parseIdToken(result?.idToken ?? "");
    //final profile = await getUserDetails(result?.accessToken ?? "");
    //print(idToken);
    //print(profile);

    await secureStorage.write(
        key: 'refresh_token', value: result?.refreshToken);

    // Exchange OKTA access token to API Token
    Response tokenExchange = await http.post(
        Uri.parse('http://$API_ADDRESS/api/auth/'),
        body: {"access_token": result?.accessToken});

    final Map apiToken = json.decode(utf8.decode(tokenExchange.body.codeUnits));
    secureStorage.write(key: 'api_token', value: apiToken["access_token"]);
    //print("API Token: ${apiToken["access_token"]}");

    // TODO Route to Profile or Home Page

    return idToken;
  }
}
