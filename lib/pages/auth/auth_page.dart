import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/pages/auth/login/login_openday_page.dart';
import 'package:iscte_spots/pages/auth/register/register_openday_page.dart';
import 'package:iscte_spots/pages/home/openday_home.dart';
import 'package:iscte_spots/services/auth/openday_login_service.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late Widget _chosenWidget;
  bool _isLoggedIn = true;
  bool _isLoading = true;
  late List<StatefulWidget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      RegisterOpenDayPage(
          changeToLogIn: changeToLogIn, loggingComplete: loggingComplete),
      LoginOpendayPage(
          changeToSignUp: changeToSignUp, loggingComplete: loggingComplete)
    ];
    _chosenWidget = _pages[0];
    initFunc();
  }

  void initFunc() async {
    bool _loggedIn = await OpenDayLoginService.isLoggedIn();
    setState(() {
      _isLoggedIn = _loggedIn;
      _isLoading = false;
    });
    if (_isLoggedIn) {
      loggingComplete();
    }
  }

  void loggingComplete() {
    setState(() {
      _isLoggedIn = true;
    });
    PageRoutes.animateToPage(context, page: HomeOpenDay());
  }

  void changeToSignUp() {
    setState(() {
      _chosenWidget = _pages[0];
    });
  }

  void changeToLogIn() {
    setState(() {
      _chosenWidget = _pages[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          child: _isLoading
              ? const LoadingWidget()
              : _isLoggedIn
                  ? const Center(
                      child: FlutterLogo(
                      size: 300,
                    ))
                  : _chosenWidget),
    );
  }
}
