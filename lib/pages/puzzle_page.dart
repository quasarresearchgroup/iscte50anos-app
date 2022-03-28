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
  //make this a future so that previous operations get queued and complete only when this has values
  @override
  void initState() {
    super.initState();
    generatePieces(widget.image);
  }

  @override
  void didUpdateWidget(PuzzlePage oldWidget) {
    if (oldWidget.image != widget.image) {
      widget._logger.d("changing image");
      generatePieces(widget.image);
    }
    super.didUpdateWidget(oldWidget);
  }

  void generatePieces(Image img) async {
    setState(() {
      pieces = [];
    });
    Size imageSize = await ImageManipulation.getImageSize(img);
    final imageWidth = widget.constraints.maxWidth;
    final imageHeight =
        widget.constraints.maxWidth * imageSize.height / imageSize.width;

    pieces = await ImageManipulation.splitImagePuzzlePiece(
      image: img,
      bringToTop: bringToTop,
      sendToBack: sendToBack,
      rows: widget.rows,
      cols: widget.cols,
      constraints: widget.constraints,
    );
    pieces.insert(0, Expanded(child: Container()));
    pieces.insert(
        1,
        Container(
          decoration: BoxDecoration(
              color: Colors.brown,
              border: Border(
                bottom: BorderSide(
                    color: Theme.of(context).shadowColor.withAlpha(50)),
                top: BorderSide(
                    color: Theme.of(context).shadowColor.withAlpha(50)),
                right: BorderSide(
                    color: Theme.of(context).shadowColor.withAlpha(50)),
                left: BorderSide(
                    color: Theme.of(context).shadowColor.withAlpha(50)),
              )),
          child: SizedBox(
            width: imageWidth,
            height: imageHeight,
          ),
        ));
    setState(() {});
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
      pieces.insert(2, widget);
    });
  }
}
