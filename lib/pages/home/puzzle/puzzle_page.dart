import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/puzzle_piece.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_piece_widget.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class PuzzlePage extends StatefulWidget {
  PuzzlePage({
    Key? key,
    required this.image,
    required this.constraints,
    required this.completeCallback,
  }) : super(key: key);
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 4));
  static const pageRoute = "/puzzle";

  final int rows = 5;
  final int cols = 5;
  final Image image;
  final BoxConstraints constraints;
  final Function completeCallback;

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage>
    with AutomaticKeepAliveClientMixin {
  final List<Widget> pieces = [];

  bool isTurned = false;
  //make this a future so that previous operations get queued and complete only when this has values
  @override
  void initState() {
    super.initState();
    generatePieces(widget.image);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(PuzzlePage oldWidget) {
    if (oldWidget.image != widget.image) {
      generatePieces(widget.image);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return pieces.isNotEmpty ? Stack(children: pieces) : const LoadingWidget();
  }

  void refreshPieces() {
    generatePieces(widget.image);
  }

  void rotatePuzzle() {
    isTurned = !isTurned;
    generatePieces(widget.image);
  }

  void generatePieces(Image img) async {
    Size originalSize = await ImageManipulation.getImageSize(img);
    double imageWidth;
    double imageHeight;
    imageWidth = !isTurned
        ? widget.constraints.maxWidth
        : widget.constraints.maxWidth * originalSize.aspectRatio;
    imageHeight = imageWidth / originalSize.aspectRatio;

    if (!isTurned) {
      if (imageWidth > widget.constraints.maxWidth) {
        imageWidth = widget.constraints.maxWidth;
        imageHeight = widget.constraints.maxWidth / originalSize.aspectRatio;
      } else if (imageHeight > widget.constraints.maxHeight) {
        imageHeight = widget.constraints.maxHeight;
        imageWidth = widget.constraints.maxHeight * originalSize.aspectRatio;
      }
    } else {
      if (imageWidth > widget.constraints.maxHeight) {
        imageWidth = widget.constraints.maxHeight;
        imageHeight = widget.constraints.maxHeight / originalSize.aspectRatio;
      } else if (imageHeight > widget.constraints.maxWidth) {
        imageHeight = widget.constraints.maxWidth;
        imageWidth = widget.constraints.maxWidth * originalSize.aspectRatio;
      }
    }

    /*imageHeight = min(
        imageWidth * originalSize.aspectRatio,
        quarterTurns.isEven
            ? widget.constraints.maxHeight
            : widget.constraints.maxWidth);
    if (imageHeight >= widget.constraints.maxHeight) {
      imageHeight = widget.constraints.maxHeight;
      imageWidth = imageHeight * originalSize.aspectRatio;
    } else if (imageWidth >= widget.constraints.maxWidth) {
      imageWidth = widget.constraints.maxWidth;
      imageHeight = imageWidth * originalSize.aspectRatio;
    }*/

    //imageHeight = min(widget.constraints.maxWidth * originalSize.aspectRatio, widget.constraints.maxHeight);

    //imageHeight = widget.constraints.maxHeight *
    //    widget.constraints.maxWidth /
    //    originalSize.width;

    final Size imageSize = Size(imageWidth, imageHeight);

    widget._logger.d(
        "quarterTurns: $isTurned ; imageSize.width: ${imageSize.width} ; imageSize.height: ${imageSize.height}");
    List<PuzzlePiece> storedPuzzlePieces =
        await DatabasePuzzlePieceTable.getAll();
    List<PuzzlePieceWidget> storedPuzzlePieceWidgets = [];
    List<Point> storedPositions = [];
    for (var element in storedPuzzlePieces) {
      storedPuzzlePieceWidgets.add(
        element.getWidget(
          image: img,
          imageSize: imageSize,
          bringToTop: bringToTop,
          sendToBack: sendToBack,
          constraints: widget.constraints,
          completeCallback: widget.completeCallback,
          isTurned: isTurned,
        ),
      );
      storedPositions.add(Point(element.row, element.column));
    }

    List<PuzzlePieceWidget> notStoredPieces =
        (await ImageManipulation.splitImagePuzzlePiece(
      image: img,
      bringToTop: bringToTop,
      sendToBack: sendToBack,
      rows: widget.rows,
      cols: widget.cols,
      imageSize: imageSize,
      constraints: widget.constraints,
      completeCallback: widget.completeCallback,
      isTurned: isTurned,
    ))
            .where((PuzzlePieceWidget element) {
      Point<int> point = Point(element.row, element.col);
      return !storedPositions.contains(point);
    }).toList();

    pieces.clear();
    pieces.add(SizedBox.expand(child: Container()));
    pieces.add(RotatedBox(
      quarterTurns: isTurned ? 1 : 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.brown,
          border: Border.all(
            color: Theme.of(context).shadowColor.withAlpha(100),
          ),
        ),
        child: SizedBox(
          width: imageSize.width,
          height: imageSize.height,
        ),
      ),
    ));
    //pieces.addAll(snappedPuzzlePieces);
    //pieces.addAll(movablePuzzlePieces);
    pieces.addAll(storedPuzzlePieceWidgets);
    pieces.addAll(notStoredPieces);
    pieces.add(Positioned(
      right: 0,
      bottom: 0,
      child: SpeedDial(
        child: const Icon(Icons.add),
        children: [
          SpeedDialChild(
              elevation: 0,
              child: const Icon(
                Icons.refresh,
              ),
              foregroundColor: Theme.of(context).unselectedWidgetColor,
              onTap: refreshPieces),
          SpeedDialChild(
              child: const Icon(
                Icons.rotate_right,
              ),
              foregroundColor: Theme.of(context).unselectedWidgetColor,
              onTap: rotatePuzzle),
        ],
      ),
    ));
    setState(() {});
  }

  void bringToTop(Widget targetWidget) {
    //widget._logger.d("Used bringToTop function on $targetWidget.");
    setState(() {
      pieces.remove(targetWidget);
      pieces.insert(pieces.length - 1, targetWidget);
    });
  }

// when a piece reaches its final position, it will be sent to the back of the stack to not get in the way of other, still movable, pieces
  void sendToBack(Widget targetWidget) {
    //widget._logger.d("Used sendToBack function on $targetWidget");
    setState(() {
      pieces.remove(targetWidget);
      pieces.insert(2, targetWidget);
    });
  }
}
