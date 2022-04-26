import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/pages/auth/login/login_openday_page.dart';
import 'package:iscte_spots/pages/auth/register/register_openday_page.dart';
import 'package:iscte_spots/services/auth/openday_login_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late Widget _chosenWidget;
  bool _isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    _chosenWidget = LoginOpendayPage(changeToSignUp: changeToSignUp);
    initFunc();
  }

  void initFunc() async {
    bool _loggedIn = await OpenDayLoginService.isLoggedIn();
    setState(() {
      _isLoggedIn = _loggedIn;
      if (_isLoggedIn) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  void changeToSignUp() {
    setState(() {
      _chosenWidget = RegisterOpenDayPage(changeToLogIn: changeToLogIn);
    });
  }

  void changeToLogIn() {
    setState(() {
      _chosenWidget = LoginOpendayPage(changeToSignUp: changeToSignUp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoggedIn
          ? Center(
              child: FlutterLogo(
              size: 300,
            ))
          : AnimatedSwitcher(
              duration: Duration(seconds: 1), child: _chosenWidget),
    );
  }
}
