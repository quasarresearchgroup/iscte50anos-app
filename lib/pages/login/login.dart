/// -----------------------------------
///          External Packages
/// -----------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/pages/login/profile.dart';

import '../../services/login_service.dart';
import 'iscte_login_widget.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

/// -----------------------------------
///                 App
/// -----------------------------------

void main() {
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
    final apiToken = await secureStorage.read(key: 'api_token');

    if (storedRefreshToken == null && apiToken == null) return;

    setState(() {
      isBusy = true;
    });

    try {
      final response = await appAuth.token(TokenRequest(
        IscteLoginService.IDP_CLIENT_ID,
        IscteLoginService.IDP_REDIRECT_URI,
        issuer: IscteLoginService.IDP_ISSUER,
        refreshToken: storedRefreshToken,
      ));

      final idToken = IscteLoginService.parseIdToken(response?.idToken ?? "");
      final profile =
          await IscteLoginService.getUserDetails(response?.accessToken ?? "");

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

  Future<void> loginAction() async {
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
      final Map<String, dynamic> idToken = await IscteLoginService.login();
      setState(() {
        isBusy = false;
        isLoggedIn = true;
        name = idToken['name'];
        //picture = profile['picture'];
      });
    } catch (e, s) {
      //print('login error: $e - stack: $s');
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
                  : IscteLogin(loginAction, errorMessage),
        ),
      ),
    );
  }
}
