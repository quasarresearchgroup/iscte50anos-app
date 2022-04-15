import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

class SkipButton extends StatelessWidget {
  const SkipButton({
    Key? key,
    required Logger logger,
    required PageController pageController,
    required int numPages,
    required this.animDuration,
    required this.textStyle,
  })  : _logger = logger,
        _pageController = pageController,
        _numPages = numPages,
        super(key: key);

  final Logger _logger;
  final PageController _pageController;
  final int _numPages;
  final Duration animDuration;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return TextButton(
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
    );
  }
}
