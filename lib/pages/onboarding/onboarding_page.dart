import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/onboarding/bottom_onboard.dart';
import 'package:iscte_spots/pages/onboarding/onboard_tile.dart';
import 'package:iscte_spots/pages/onboarding/skip_onboard_button.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatefulWidget {
  static const pageRoute = "/onboard";
  static const IconData icon = Icons.departure_board;

  OnboardingPage({Key? key, required this.onLaunch}) : super(key: key);

  bool onLaunch;
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final double bottomSheetHeight = 100.0;
  late final AnimationController _controller;
  late final Tween<Offset> _offsetTween;
  final Duration animDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
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
    List<Widget> children = getChildren(context);
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
                  pageController: _pageController,
                  numPages: children.length,
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
                children: children,
              ),
            ),
          ],
        ),
        bottomSheet: BottomSheetOnboard(
          onLaunch: widget.onLaunch,
          bottomSheetHeight: bottomSheetHeight,
          animDuration: animDuration,
          numPages: children.length,
          pageController: _pageController,
          currentPage: _currentPage,
          changePage: changePage,
          textStyle: textStyle,
        ),
      ),
    );
  }

  List<Widget> getChildren(BuildContext context) {
    return <Widget>[
      OnboardTile(
        top: Text(
          AppLocalizations.of(context)!.onboardingTitle1,
          textScaleFactor: 2,
        ),
        center: Lottie.network(
            //"https://assets8.lottiefiles.com/packages/lf20_97qzkt8d.json"),
            "https://assets1.lottiefiles.com/packages/lf20_z7bpt8g7.json"),
        bottom: Text(
          AppLocalizations.of(context)!.onboardingText1,
          textScaleFactor: 1.5,
        ),
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.cyan,
      ),
      OnboardTile(
        top: Text(
          AppLocalizations.of(context)!.onboardingTitle2,
          textScaleFactor: 2,
        ),
        center: Image.asset("Resources/Img/Campus/campus-iscte-3.jpg"),
        bottom: Text(
          AppLocalizations.of(context)!.onboardingText2,
          textScaleFactor: 1.5,
        ),
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.blue,
      ),
      OnboardTile(
        top: Text(
          AppLocalizations.of(context)!.onboardingTitle3,
          textScaleFactor: 2,
        ),
        center: Lottie.network(
            "https://assets7.lottiefiles.com/packages/lf20_ykxkplzg.json"),
        //"https://assets4.lottiefiles.com/packages/lf20_1LsvAZ.json"),
        bottom: Text(
          AppLocalizations.of(context)!.onboardingText3,
          textScaleFactor: 1.5,
        ),
        bottomSheetHeight: bottomSheetHeight,
        color: IscteTheme.iscteColor,
      ),
      OnboardTile(
        top: Text(
          AppLocalizations.of(context)!.onboardingTitle4,
          textScaleFactor: 2,
        ),
        center: Lottie.network(
            "https://assets9.lottiefiles.com/packages/lf20_smcd09k7.json"),
        bottom: Text(
          AppLocalizations.of(context)!.onboardingText4,
          textScaleFactor: 1.5,
        ),
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.deepOrange,
      ),
      OnboardTile(
        top: Text(
          AppLocalizations.of(context)!.onboardingTitle5,
          textScaleFactor: 2,
        ),
        center: Lottie.network(
            "https://assets7.lottiefiles.com/packages/lf20_bq55cmov.json"),
        bottom: Text(
          AppLocalizations.of(context)!.onboardingText5,
          textScaleFactor: 1.5,
        ),
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.purple,
      ),
      OnboardTile(
        top: Text(
          AppLocalizations.of(context)!.onboardingTitle6,
          textScaleFactor: 2,
        ),
        center: Lottie.network(
            "https://assets1.lottiefiles.com/packages/lf20_0YHgFn.json"),
        bottom: Text(
          AppLocalizations.of(context)!.onboardingText6,
          textScaleFactor: 1.5,
        ),
        bottomSheetHeight: bottomSheetHeight,
        color: Colors.green,
      ),
    ];
  }
}
