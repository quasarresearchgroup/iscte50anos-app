import 'package:flutter/widgets.dart';

class OnboardTile extends StatefulWidget {
  Color color;
  double bottomSheetHeight;
  OnboardTile({Key? key, required this.color, required this.bottomSheetHeight})
      : super(key: key);

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
    const opacityAnimationDuration = const Duration(milliseconds: 500);
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
                child: const Text(
                  'Lorem Ipsum',
                  textScaleFactor: 2,
                ),
              ),
              AnimatedOpacity(
                duration: opacityAnimationDuration,
                opacity: textOpacity[1],
                child: Image.asset('Resources/Img/Campus/campus-iscte-3.jpg'),
              ),
              AnimatedOpacity(
                duration: opacityAnimationDuration,
                opacity: textOpacity[2],
                child: const Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam condimentum et nisi ac blandit. Suspendisse potenti. Phasellus nec semper orci. Proin porta est massa, vel convallis ex auctor at. Etiam rutrum, tortor vitae faucibus mollis, tellus arcu malesuada ligula, et vestibulum arcu odio vitae dolor. Praesent pellentesque mauris non augue egestas, sit amet maximus turpis molestie. Mauris et leo ex. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.",
                  textScaleFactor: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
