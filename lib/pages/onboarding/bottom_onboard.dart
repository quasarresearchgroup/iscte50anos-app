import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'getstarted_onboard_button.dart';
import 'next_onboard_button.dart';

class BottomSheetOnboard extends StatelessWidget {
  var bottomSheetHeight;
  var animDuration;
  var numPages;
  var pageController;
  var currentPage;
  var changePage;
  var textStyle;

  BottomSheetOnboard({
    Key? key,
    required this.bottomSheetHeight,
    required this.animDuration,
    required this.numPages,
    required this.pageController,
    required this.currentPage,
    required this.changePage,
    required this.textStyle,
  }) : super(key: key);

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < numPages; i++) {
      list.add(i == currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return Builder(
      builder: (BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        height: 8.0,
        width: isActive ? 24.0 : 16.0,
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).selectedRowColor
              : Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: bottomSheetHeight,
      child: AnimatedSwitcher(
          duration: animDuration,
          reverseDuration: animDuration,
          switchInCurve: Curves.easeInCubic,
          switchOutCurve: Curves.easeOutCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            Animation<Offset> finalAnimation;
            if (child is GetStartedOnboard) {
              finalAnimation =
                  Tween<Offset>(begin: const Offset(1, 0.0), end: Offset.zero)
                      .animate(animation);
            } else {
              finalAnimation =
                  Tween<Offset>(begin: const Offset(-1, 0.0), end: Offset.zero)
                      .animate(animation);
            }
            return SlideTransition(
              position: finalAnimation,
              child: child,
            );
          },
          child: currentPage != numPages - 1
              ? NextOnboardButton(
                  //key: ValueKey(_currentPage),
                  buildPageIndicator: _buildPageIndicator,
                  pageController: pageController,
                  changePage: changePage,
                  textStyle: textStyle,
                )
              : GetStartedOnboard(
                  //key: ValueKey(_currentPage),
                  )),
    );
  }
}
