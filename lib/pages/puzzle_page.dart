import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class PuzzlePage extends StatefulWidget {
  PuzzlePage({Key? key, required this.image, required this.constraints})
      : super(key: key);
  final Logger _logger = Logger();
  static const pageRoute = "/puzzle";

  final int rows = 5;
  final int cols = 5;
  final Image image;
  final BoxConstraints constraints;

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  List<Widget> pieces = [];
  Size? imageSize;
  //make this a future so that previous operations get queued and complete only when this has values
  @override
  void initState() {
    super.initState();
    generatePieces(widget.image);
  }

  void generatePieces(Image img) async {
    setState(() {
      pieces = [];
    });
    imageSize = await ImageManipulation.getImageSize(img);
    pieces = await ImageManipulation.splitImagePuzzlePiece(
      image: img,
      bringToTop: bringToTop,
      sendToBack: sendToBack,
      rows: widget.rows,
      cols: widget.cols,
      maxHeight: widget.constraints.maxHeight,
      maxWidth: widget.constraints.maxWidth,
    );
    pieces.insert(0, Expanded(child: Container()));
    pieces.insert(
        1,
        Container(
          decoration: BoxDecoration(
              border: Border(
            bottom:
                BorderSide(color: Theme.of(context).shadowColor.withAlpha(50)),
            top: BorderSide(color: Theme.of(context).shadowColor.withAlpha(50)),
            right:
                BorderSide(color: Theme.of(context).shadowColor.withAlpha(50)),
            left:
                BorderSide(color: Theme.of(context).shadowColor.withAlpha(50)),
          )),
          child: SizedBox(
            width: imageSize?.width,
            height: imageSize?.height,
          ),
        ));
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

  @override
  Widget build(BuildContext context) {
    return pieces.isNotEmpty ? Stack(children: pieces) : LoadingWidget();
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
      pieces.insert(1, widget);
    });
  }
}
