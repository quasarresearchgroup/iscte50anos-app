import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class IscteConfetti extends StatelessWidget {
  const IscteConfetti({
    Key? key,
    required ConfettiController confettiController,
  })  : _confettiController = confettiController,
        super(key: key);

  final ConfettiController _confettiController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        emissionFrequency: 0.1,
        colors: [
          IscteTheme.iscteColor,
          IscteTheme.iscteColor.withBlue(IscteTheme.iscteColor.blue + 50),
          IscteTheme.iscteColor.withBlue(IscteTheme.iscteColor.blue - 50),
          Colors.white,
        ],
      ),
    );
  }
}
