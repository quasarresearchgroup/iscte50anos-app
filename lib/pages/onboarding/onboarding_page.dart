import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/onboarding/bottom_onboard.dart';
import 'package:iscte_spots/pages/onboarding/onboard_tile.dart';
import 'package:iscte_spots/pages/onboarding/skip_onboard_button.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatefulWidget {
  static const pageRoute = "/onboard";

  OnboardingPage({Key? key, required this.onLaunch}) : super(key: key);

  bool onLaunch;
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final Logger _logger = Logger();
  final PageController _pageController = PageController(initialPage: 0);
  late final int _numPages;
  int _currentPage = 0;
  final double bottomSheetHeight = 100.0;
  late final AnimationController _controller;
  late final Tween<Offset> _offsetTween;
  final Duration animDuration = const Duration(milliseconds: 500);
  late final List<Widget> pageViewChildren;

  @override
  void initState() {
    pageViewChildren = [
      OnboardTile(
        bottom: const Text("Usa as informações providenciadas"),
        center: Lottie.network(
            //"https://assets8.lottiefiles.com/packages/lf20_97qzkt8d.json"),
            "https://assets1.lottiefiles.com/packages/lf20_z7bpt8g7.json"),
        top: Text(
          AppLocalizations.of(context)!.logOutButton,
          textScaleFactor: 2,
        ),
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.blue,
      ),
      OnboardTile(
        bottom: const Text(""),
        center: Container(),
        top: Text(
          "O jogo",
          textScaleFactor: 2,
        ),
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.blue,
      ),
      OnboardTile(
        bottom: const Text("com"),
        center: Lottie.network(
            "https://assets4.lottiefiles.com/packages/lf20_1LsvAZ.json"),
        top: Text(
          "Completar Puzzle",
          textScaleFactor: 2,
        ),
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.yellow,
      ),
      OnboardTile(
        bottom: const Text(""),
        center: Lottie.network(
            "https://assets9.lottiefiles.com/packages/lf20_smcd09k7.json"),
        top: Text("Encontra o Spot", textScaleFactor: 2),
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.green,
      ),
      OnboardTile(
        bottom: const Text(""),
        center: Lottie.network(
            "https://assets7.lottiefiles.com/packages/lf20_bq55cmov.json"),
        top: Text(
          "Consulta o teu rank",
          textScaleFactor: 2,
        ),
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.purple,
      ),
      OnboardTile(
        bottom: Text(""),
        center: Lottie.network(
            "https://assets1.lottiefiles.com/packages/lf20_0YHgFn.json"),
        top: Text(
          "Repete",
          textScaleFactor: 2,
        ),
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.orange,
      ),
    ];
    _numPages = pageViewChildren.length;
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _offsetTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1, 0),
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void changePage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      color: Theme.of(context).selectedRowColor,
      fontSize: 22.0,
    );

    return WillPopScope(
      onWillPop: () async {
        if (_currentPage == 0) {
          return true;
        } else {
          changePage(_currentPage - 1);
          return false;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              SkipButton(
                  logger: _logger,
                  pageController: _pageController,
                  numPages: _numPages,
                  animDuration: animDuration,
                  textStyle: textStyle)
            ]),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: PageView(
                physics: const ClampingScrollPhysics(),
                controller: _pageController,
                onPageChanged: (int page) {
                  changePage(page);
                },
                children: pageViewChildren,
              ),
            ),
          ],
        ),
        bottomSheet: BottomSheetOnboard(
          onLaunch: widget.onLaunch,
          bottomSheetHeight: bottomSheetHeight,
          animDuration: animDuration,
          numPages: _numPages,
          pageController: _pageController,
          currentPage: _currentPage,
          changePage: changePage,
          textStyle: textStyle,
        ),
      ),
    );
  }
}
