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

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  bool _isLoggedIn = true;
  bool _isLoading = true;
  late List<StatefulWidget> _pages;
  final int _loginIndex = 0;
  final int _registerIndex = 1;
  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      LoginOpendayPage(
          changeToSignUp: changeToSignUp, loggingComplete: loggingComplete),
      RegisterOpenDayPage(
          changeToLogIn: changeToLogIn, loggingComplete: loggingComplete),
    ];
    _tabController = TabController(length: _pages.length, vsync: this);
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
    _tabController.animateTo(_registerIndex);
  }

  void changeToLogIn() {
    _tabController.animateTo(_loginIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? const LoadingWidget()
          : _isLoggedIn
              ? const Center(
                  child: FlutterLogo(
                  size: 300,
                ))
              : TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: _pages),
    );
  }
}
