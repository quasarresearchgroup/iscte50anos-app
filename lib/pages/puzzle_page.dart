import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:logger/logger.dart';

class PuzzlePage extends StatefulWidget {
  PuzzlePage({Key? key}) : super(key: key);
  final Logger _logger = Logger();
  static const pageRoute = "/puzzle";

  final int rows = 10;
  final int cols = 10;

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
  changeImage(Image img) => createState().changeImage(img: img);
}

class _PuzzlePageState extends State<PuzzlePage> {
  List<Widget> pieces = [];
  Image? _image;

  @override
  void initState() {
    super.initState();
    changeImage();
  }

  void changeImage(
      {Image img = const Image(
          image: AssetImage('Resources/Img/Campus/campus-iscte-3.jpg'))}) {
    _image = img;
    ImageManipulation.splitImagePuzzlePiece(
      image: _image!,
      bringToTop: bringToTop,
      sendToBack: sendToBack,
      rows: widget.rows,
      cols: widget.cols,
    ).then((value) {
      setState(() {
        pieces = value;
      });
    });
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
