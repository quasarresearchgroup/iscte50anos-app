import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/auth/auth_page.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/onboard_service.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class GetStartedOnboard extends StatelessWidget {
  const GetStartedOnboard({
    Key? key,
    required this.onLaunch,
  }) : super(key: key);

  final bool onLaunch;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        LoggerService.instance.info('Tapped on Get started');
        OnboadingService.storeOnboard();
        if (onLaunch) {
          Navigator.pushNamed(context, AuthPage.pageRoute);
        } else {
          Navigator.pop(context);
        }
      },
      child: SizedBox.expand(
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.getStarted,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: IscteTheme.iscteColor),
          ),
        ),
      ),
    );
  }
}
