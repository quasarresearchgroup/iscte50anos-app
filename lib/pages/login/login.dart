/// -----------------------------------
///          External Packages
/// -----------------------------------

import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

/// -----------------------------------
///           Auth0 Variables
/// -----------------------------------

const IDP_DOMAIN = 'login.iscte-iul.pt';
const IDP_CLIENT_ID = '0oa2y4zd1pm9krr2o417';

const IDP_REDIRECT_URI = 'pt.iscteiul.vultos:/callback';
const IDP_ISSUER = 'https://$IDP_DOMAIN';

/// -----------------------------------
///           Profile Widget
/// -----------------------------------

class Profile extends StatelessWidget {
  final logoutAction;
  final String name;
  final String picture;

  Profile(this.logoutAction, this.name, this.picture);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 4.0),
            shape: BoxShape.circle,

          ),
        ),
        SizedBox(height: 24.0),
        Text('Name: $name'),
        SizedBox(height: 48.0),
        ElevatedButton(
          onPressed: () {
            logoutAction();
          },
          child: Text('Logout'),
        ),
      ],
    );
  }
}

/// -----------------------------------
///            Login Widget
/// -----------------------------------

class Login extends StatelessWidget {
  final loginAction;
  final String loginError;

  const Login(this.loginAction, this.loginError);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            loginAction();
          },
          child: const Text('Login using Iscte Login'),
        ),
        Text(loginError ?? ''),
      ],
    );
  }
}

/// -----------------------------------
///                 App
/// -----------------------------------

void main(){
  //secureStorage.deleteAll();
  runApp(LoginPage());
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

/// -----------------------------------
///              App State
/// -----------------------------------

class _LoginPageState extends State<LoginPage> {
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage = "";
  String name = "";

  String picture = "";

  @override
  void initState() {
    initAction();
    super.initState();
  }

  void initAction() async {

    // Get refresh token from storage
    final storedRefreshToken = await secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken == null) return;

    setState(() {
      isBusy = true;
    });

    try {

      final response = await appAuth.token(TokenRequest(
        IDP_CLIENT_ID,
        IDP_REDIRECT_URI,
        issuer: IDP_ISSUER,
        refreshToken: storedRefreshToken,
      ));

      final idToken = parseIdToken(response?.idToken ?? "");
      final profile = await getUserDetails(response?.accessToken ?? "");

      secureStorage.write(key: 'refresh_token', value: response?.refreshToken);

      setState(() {
        isBusy = false;
        isLoggedIn = true;
        name = idToken['name'];
        picture = profile['picture'];
      });

    } catch (e, s) {
      print('error on refresh token: $e - stack: $s');
      logoutAction();
    }
  }

  Map<String, dynamic> parseIdToken(String idToken) {
    final parts = idToken.split(r'.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

  Future<Map> getUserDetails(String accessToken) async {
    print(accessToken);
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

  Future<void> loginAction() async {
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
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

      final idToken = parseIdToken(result?.idToken ?? "");
      final profile = await getUserDetails(result?.accessToken ?? "");
      print(idToken);
      print(profile);

      await secureStorage.write(
          key: 'refresh_token', value: result?.refreshToken);

      setState(() {
        isBusy = false;
        isLoggedIn = true;
        name = idToken['name'];
        //picture = profile['picture'];
      });
    } catch (e, s) {
      print('login error: $e - stack: $s');

      setState(() {
        isBusy = false;
        isLoggedIn = false;
        errorMessage = e.toString();
      });
    }
  }

  void logoutAction() async {
    /*
    await secureStorage.delete(key: 'refresh_token');

    const url = 'https://$IDP_DOMAIN/oauth2/v1/logout';
    final response = await http.get(
      Uri.parse(url),
    );
    */


    setState(() {
      isLoggedIn = false;
      isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      home: Scaffold(

        appBar: AppBar(
          title: const Text('Login'),
        ),

        body: Center(
          child: isBusy
          ? const CircularProgressIndicator.adaptive()
            : isLoggedIn
        ? Profile(logoutAction, name, picture)
        : Login(loginAction, errorMessage),
    ),
      ),
    );
  }
}