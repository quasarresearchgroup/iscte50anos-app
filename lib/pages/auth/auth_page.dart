import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/pages/auth/login/login_openday_page.dart';
import 'package:iscte_spots/pages/auth/register/register_openday_page.dart';
import 'package:iscte_spots/pages/home/home_page.dart';
import 'package:iscte_spots/services/auth/openday_login_service.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

class AuthPage extends StatefulWidget {
  static const pageRoute = "/auth";

  final Logger _logger = Logger();

  AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  bool _isLoggedIn = true;
  bool _isLoading = true;
  late List<StatefulWidget> _pages;
  final int _loginIndex = 0;
  final int _registerIndex = 1;
  late TabController _tabController;
  late final AnimationController _lottieController;
  final animatedSwitcherDuration = const Duration(seconds: 1);

  @override
  void dispose() {
    _tabController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      LoginOpendayPage(
        changeToSignUp: changeToSignUp,
        loggingComplete: loggingComplete,
        animatedSwitcherDuration: animatedSwitcherDuration,
      ),
      RegisterOpenDayPage(
        changeToLogIn: changeToLogIn,
        loggingComplete: loggingComplete,
        animatedSwitcherDuration: animatedSwitcherDuration,
      ),
    ];
    _tabController = TabController(length: _pages.length, vsync: this);
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _lottieController.addStatusListener(
      (status) {
        widget._logger.d("listenning to complete login animation $status");
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 500)).then(
              (value) => Navigator.popAndPushNamed(context, HomePage.pageRoute));
        }
      },
    );

    initFunc();
  }

  void initFunc() async {
    bool _loggedIn;
    try {
      _loggedIn = await OpenDayLoginService.isLoggedIn();
    } on SocketException {
      _loggedIn = false;
    }
    setState(() {
      _isLoggedIn = _loggedIn;
      _isLoading = false;
    });
    if (_isLoggedIn) {
      loggingComplete();
    }
  }

  void loggingComplete() async {
    setState(() => _isLoggedIn = true);
  }

  void changeToSignUp() {
    _tabController.animateTo(_registerIndex);
  }

  void changeToLogIn() {
    _tabController.animateTo(_loginIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedSwitcher(
        duration: animatedSwitcherDuration,
        child: _isLoading
            ? const LoadingWidget()
            : _isLoggedIn
                ? lottieCompleteLoginBuilder()
                : TabBarView(
                    controller: _tabController,
                    physics: NeverScrollableScrollPhysics(),
                    children: _pages,
                  ),
      ),
    );
  }

  Widget lottieCompleteLoginBuilder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.network(
            "https://assets6.lottiefiles.com/packages/lf20_Vwcw5D.json",
            //width: MediaQuery.of(context).size.width * 0.5,
            //height: MediaQuery.of(context).size.height * 0.5,
            //fit: BoxFit.contain,
            controller: _lottieController,
            onLoaded: (LottieComposition composition) {
              TickerFuture forward = _lottieController.forward();
            },
          )
        ],
      );
}
