import 'package:flutter/widgets.dart';

class OnboardTile extends StatefulWidget {
  OnboardTile({
    Key? key,
    required this.color,
    required this.bottomSheetHeight,
    required this.child,
    required this.imageLink,
    required this.title,
  }) : super(key: key);

  Color color;
  double bottomSheetHeight;
  Widget child;
  String imageLink;
  String title;

  @override
  State<OnboardTile> createState() => _OnboardTileState();
}

class _OnboardTileState extends State<OnboardTile> {
  List<double> textOpacity = [0.0, 0.0, 0.0];
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < textOpacity.length; i++) {
      var future = Future.delayed(
        Duration(milliseconds: 500 * i),
        () {
          setState(() {
            textOpacity[i] = 1;
          });
        },
      ).onError((error, stackTrace) => null);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Duration opacityAnimationDuration = const Duration(milliseconds: 500);
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
                child: Text(
                  widget.title,
                  textScaleFactor: 2,
                ),
              ),
              AnimatedOpacity(
                duration: opacityAnimationDuration,
                opacity: textOpacity[1],
                child: Image.asset(widget.imageLink),
              ),
              AnimatedOpacity(
                duration: opacityAnimationDuration,
                opacity: textOpacity[2],
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
