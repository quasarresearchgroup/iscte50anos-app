import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/pages/onboarding/bottom_onboard.dart';
import 'package:iscte_spots/pages/onboarding/onboard_tile.dart';
import 'package:iscte_spots/pages/onboarding/skip_onboard_button.dart';
import 'package:logger/logger.dart';

class OnboardingPage extends StatefulWidget {
  static const pageRoute = "/onboard";

  OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final Logger _logger = Logger();
  final PageController _pageController = PageController(initialPage: 0);
  late final int _numPages;
  int _currentPage = 0;
  int _lastPage = 0;
  final double bottomSheetHeight = 100.0;
  late final AnimationController _controller;
  late final Tween<Offset> _offsetTween;
  final Duration animDuration = const Duration(milliseconds: 500);
  late final List<Widget> pageViewChildren;

  @override
  void initState() {
    pageViewChildren = [
      OnboardTile(
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.blue,
      ),
      OnboardTile(
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.yellow,
      ),
      OnboardTile(
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.green,
      ),
      OnboardTile(
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.purple,
      ),
      OnboardTile(
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
      _lastPage = _currentPage;
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      color: Theme.of(context).selectedRowColor,
      fontSize: 22.0,
    );

    return Scaffold(
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
          bottomSheetHeight: bottomSheetHeight,
          animDuration: animDuration,
          numPages: _numPages,
          pageController: _pageController,
          currentPage: _currentPage,
          changePage: changePage,
          textStyle: textStyle),
    );
  }
}
