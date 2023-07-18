import 'package:flutter/widgets.dart';

class OnboardTile extends StatefulWidget {
  OnboardTile({
    Key? key,
    required this.color,
    required this.bottomSheetHeight,
    required this.bottom,
    required this.center,
    required this.top,
  }) : super(key: key);

  Color color;
  double bottomSheetHeight;
  Widget bottom;
  Widget center;
  Widget top;

  @override
  State<OnboardTile> createState() => _OnboardTileState();
}

class _OnboardTileState extends State<OnboardTile> {
  List<double> textOpacity = [0.0, 0.0, 0.0];
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < textOpacity.length; i++) {
      Future.delayed(
        Duration(milliseconds: 500 * i),
        () => setState(() => textOpacity[i] = 1),
      ).onError((error, stackTrace) => null);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Duration opacityAnimationDuration = Duration(milliseconds: 500);
    return Container(
      color: widget.color,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: 20.0, right: 20.0, bottom: widget.bottomSheetHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedOpacity(
                duration: opacityAnimationDuration,
                opacity: textOpacity[0],
                child: widget.top,
              ),
              AnimatedOpacity(
                duration: opacityAnimationDuration,
                opacity: textOpacity[1],
                child: widget.center,
              ),
              AnimatedOpacity(
                duration: opacityAnimationDuration,
                opacity: textOpacity[2],
                child: widget.bottom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
