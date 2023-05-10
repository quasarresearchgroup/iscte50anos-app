import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/widgets/iscte_confetti_widget.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:lottie/lottie.dart';

class SucessScanWidget extends StatelessWidget {
  const SucessScanWidget({
    Key? key,
    required this.lottieController,
    required this.confettiController,
  }) : super(key: key);

  final AnimationController lottieController;
  final ConfettiController confettiController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Card(
            color: Colors.green.shade700,
            margin: const EdgeInsets.all(50.0),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(IscteTheme.appbarRadius)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.network(
                  "https://assets6.lottiefiles.com/packages/lf20_Vwcw5D.json",
                  //"https://assets4.lottiefiles.com/datafiles/hToYrgLpHl1u69x/data.json",
                  //width: MediaQuery.of(context).size.width * 0.5,
                  //height: MediaQuery.of(context).size.height * 0.5,
                  //fit: BoxFit.contain,
                  controller: lottieController,
                  onLoaded: (LottieComposition composition) {
                    lottieController.forward();
                    confettiController.play();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(AppLocalizations.of(context)!
                          .qrScanNotificationFoundSpot),
                      const FaIcon(FontAwesomeIcons.faceSmile),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        IscteConfetti(confettiController: confettiController),
      ],
    );
  }
}
