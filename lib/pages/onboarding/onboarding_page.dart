import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/pages/onboarding/getstarted_onboard_button.dart';
import 'package:iscte_spots/pages/onboarding/next_onboard_button.dart';
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
  late final int _numPages;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  int _lastPage = 0;
  late final AnimationController _controller;
  late final Tween<Offset> _offsetTween;
  final Duration animDuration = const Duration(milliseconds: 500);
  final List<Container> pageViewChildren = [
    Container(
      color: Colors.blue,
    ),
    Container(
      color: Colors.yellow,
    ),
    Container(
      color: Colors.green,
    ),
    Container(
      color: Colors.purple,
    ),
    Container(
      color: Colors.orange,
    ),
  ];

  @override
  void initState() {
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

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).selectedRowColor
            : Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
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
          )),
          SizedBox(
            height: 100,
            child: AnimatedSwitcher(
                duration: animDuration,
                reverseDuration: animDuration,
                switchInCurve: Curves.fastLinearToSlowEaseIn,
                switchOutCurve: Curves.fastOutSlowIn,
                //height: 40.0,
                //width: double.infinity,
                //color: Theme.of(context).primaryColor,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  Animation<Offset> finalAnimation;
                  if (child is GetStartedOnboard) {
                    finalAnimation = Tween<Offset>(
                            begin: const Offset(1, 0.0), end: Offset.zero)
                        .animate(animation);
                  } else {
                    finalAnimation = Tween<Offset>(
                            begin: const Offset(-1, 0.0), end: Offset.zero)
                        .animate(animation);
                  }
                  return SlideTransition(
                    position: finalAnimation,
                    child: child,
                  );
                },
                child: _currentPage != _numPages - 1
                    ? NextOnboardButton(
                        //key: ValueKey(_currentPage),
                        buildPageIndicator: _buildPageIndicator,
                        pageController: _pageController,
                        changePage: changePage,
                        textStyle: textStyle,
                      )
                    : GetStartedOnboard(
                        //key: ValueKey(_currentPage),
                        )),
          ),
        ],
      ),
/*        bottomSheet: _currentPage == _numPages - 1
            ?             : const Text(''),*/
    );
  }
}
