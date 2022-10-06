import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class SkipButton extends StatelessWidget {
  const SkipButton({
    Key? key,
    required PageController pageController,
    required int numPages,
    required this.animDuration,
    required this.textStyle,
  })  :
        _pageController = pageController,
        _numPages = numPages,
        super(key: key);

  final PageController _pageController;
  final int _numPages;
  final Duration animDuration;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        LoggerService.instance.info("pressed Skip");
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
    );
  }
}
