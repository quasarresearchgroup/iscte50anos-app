import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

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
      color: Colors.transparent,
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
                  LoggerService.instance.info("Pressed next onboard button.");
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
                      AppLocalizations.of(context)!.next,
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
