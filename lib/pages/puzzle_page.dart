import 'dart:async';

import 'package:iscteSpots/widgets/puzzle/puzzle_piece.dart';
import 'package:flutter/cupertino.dart';
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
    _image = const Image(
        //image: AssetImage('Resources/Img/Logo/logo_50_anos_main.jpg'));
        image: AssetImage('Resources/Img/campus-iscte-3.jpg'));

    splitImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: pieces);
  }

  //----------------------------------------------------------------------

  // we need to find out the image size, to be used in the PuzzlePiece widget
  Future<Size> getImageSize(Image image) async {
    final Completer<Size> completer = Completer<Size>();

    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;

    return imageSize;
  }

  // here we will split the image into small pieces using the rows and columns defined above; each piece will be added to a stack
  void splitImage(Image image) async {
    Size imageSize = await getImageSize(image);
    for (int x = 0; x < widget.rows; x++) {
      for (int y = 0; y < widget.cols; y++) {
        setState(() {
          var puzzlePiece = PuzzlePiece(
              key: GlobalKey(),
              image: image,
              imageSize: imageSize,
              row: x,
              col: y,
              maxRow: widget.rows,
              maxCol: widget.cols,
              bringToTop: bringToTop,
              sendToBack: sendToBack);
          widget.logger.i(puzzlePiece);
          pieces.add(puzzlePiece);
          widget.logger.i(pieces.length);
        });
      }
    }
  }

  // when the pan of a piece starts, we need to bring it to the front of the stack
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
