import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:logger/logger.dart';

class PuzzlePage extends StatefulWidget {
  PuzzlePage({Key? key, required this.image}) : super(key: key);
  final Logger _logger = Logger();
  static const pageRoute = "/puzzle";

  final int rows = 10;
  final int cols = 10;
  final Image image;

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  List<Widget> pieces = [];
  //make this a future so that previous operations get queued and complete only when this has values
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    generatePieces(widget.image);
  }

  void generatePieces(Image img) async {
    pieces = await ImageManipulation.splitImagePuzzlePiece(
      image: img,
      bringToTop: bringToTop,
      sendToBack: sendToBack,
      rows: widget.rows,
      cols: widget.cols,
    );
    setState(() {});
  }

  @override
  void didUpdateWidget(PuzzlePage oldWidget) {
    if (oldWidget.image != widget.image) {
      widget._logger.d("changing image");
      setState(() {
        generatePieces(widget.image);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  /*
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
*/

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
