import 'package:confetti/confetti.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:lottie/lottie.dart';

class SucessScanWidget extends StatelessWidget {
  const SucessScanWidget(
      {Key? key,
      required this.lottieController,
      required this.confettiController})
      : super(key: key);

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
            shape: RoundedRectangleBorder(
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
                    children: const [
                      Text("Wow you found it!!"),
                      FaIcon(FontAwesomeIcons.faceSmile),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.1,
            colors: [
              IscteTheme.iscteColor,
              IscteTheme.iscteColor.withBlue(IscteTheme.iscteColor.blue + 50),
              IscteTheme.iscteColor.withBlue(IscteTheme.iscteColor.blue - 50),
              Colors.white,
            ],
          ),
        )
      ],
    );
  }
}
