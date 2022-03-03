import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:logger/logger.dart';

class PuzzlePage extends StatefulWidget {
  PuzzlePage({Key? key}) : super(key: key);
  final Logger logger = Logger();
  static const pageRoute = "/puzzle";

  final int rows = 3;
  final int cols = 3;

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  late Image _image;
  List<Widget> pieces = [];

  @override
  void initState() {
    super.initState();
    _image = const Image(image: AssetImage('Resources/Img/campus-iscte-3.jpg'));

    ImageManipulation.splitImagePuzzlePiece(
      image: _image,
      bringToTop: bringToTop,
      sendToBack: sendToBack,
      rows: widget.rows,
      cols: widget.cols,
    ).then((value) {
      setState(() {
        pieces = value;
      });
    });

    /*for (Widget element in tempPieces) {
      setState(() {
        pieces.add(element);
        widget.logger.d(pieces.length);
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: pieces);
  }

  void bringToTop(Widget widget) {
    setState(() {
      pieces.remove(widget);
      pieces.add(widget);
    });
  }

// when a piece reaches its final position, it will be sent to the back of the stack to not get in the way of other, still movable, pieces
  void sendToBack(Widget widget) {
    setState(() {
      pieces.remove(widget);
      pieces.insert(0, widget);
    });
  }
}
