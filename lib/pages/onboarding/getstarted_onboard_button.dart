import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/auth/auth_page.dart';
import 'package:iscte_spots/services/onboard_service.dart';
import 'package:logger/logger.dart';

class GetStartedOnboard extends StatelessWidget {
  GetStartedOnboard({
    Key? key,
    required this.onLaunch,
  }) : super(key: key);

  bool onLaunch;
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _logger.i('Tapped on Get started');
        OnboadingService.storeOnboard();
        //PageRoutes.animateToPage(context, page: const AuthPage());
        if (onLaunch) {
          Navigator.popAndPushNamed(context, AuthPage.pageRoute);
        } else {
          Navigator.pushNamed(context, AuthPage.pageRoute);
        }
      },
      child: SizedBox.expand(
        child: Container(
          color: Theme.of(context).selectedRowColor,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.getStarted,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
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
