import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
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
            TextButton(
              onPressed: () {
                _logger.i("pressed Skip");
                _pageController.animateToPage(
                  _numPages - 1,
                  duration: animDuration,
                  curve: Curves.easeIn,
                );
              },
              child: Text(
                'Skip',
                style: textStyle,
              ),
            )
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

  void changePage(int page) {
    setState(() {
      _lastPage = _currentPage;
      _currentPage = page;
    });
  }
}

class GetStartedOnboard extends StatelessWidget {
  GetStartedOnboard({
    Key? key,
  }) : super(key: key);

  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _logger.i('Get started');
        Navigator.pushReplacementNamed(context, PageRoutes.home);
      },
      child: SizedBox.expand(
        child: Container(
          color: Theme.of(context).selectedRowColor,
          child: const Center(
            child: Text(
              'Get started',
              style: TextStyle(
                color: Color(0xFF5B16D0),
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NextOnboardButton extends StatelessWidget {
  NextOnboardButton({
    Key? key,
    required PageController pageController,
    required Function() buildPageIndicator,
    required this.textStyle,
    required this.changePage,
  })  : _pageController = pageController,
        _buildPageIndicator = buildPageIndicator,
        super(key: key);

  void Function(int page) changePage;
  final _buildPageIndicator;
  final PageController _pageController;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColorDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
            Align(
              alignment: FractionalOffset.bottomRight,
              child: TextButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                  if (_pageController.page != null) {
                    changePage(_pageController.page!.toInt());
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Next',
                      style: textStyle,
                    ),
                    const SizedBox(width: 10.0),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 30.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
