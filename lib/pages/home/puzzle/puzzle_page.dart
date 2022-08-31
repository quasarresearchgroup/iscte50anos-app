import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/puzzle_piece.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_piece_widget.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class PuzzlePage extends StatefulWidget {
  PuzzlePage({
    Key? key,
    required this.spot,
    required this.constraints,
    required this.completeCallback,
  }) : super(key: key);
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 4));
  static const pageRoute = "/puzzle";

  static const int rows = 5;
  static const int cols = 5;
  final Spot spot;
  final BoxConstraints constraints;
  final Function completeCallback;

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage>
    with AutomaticKeepAliveClientMixin {
  final List<Widget> pieces = [];

  //make this a future so that previous operations get queued and complete only when this has values
  @override
  void initState() {
    super.initState();
    generatePieces(widget.spot);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(PuzzlePage oldWidget) {
    if (oldWidget.spot != widget.spot) {
      pieces.clear();
      generatePieces(widget.spot);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return pieces.isNotEmpty ? Stack(children: pieces) : const LoadingWidget();
  }

  void refreshPieces() {
    generatePieces(widget.spot);
  }
/*
  void rotatePuzzle() {
    isTurned = !isTurned;
    generatePieces(widget.image);
  }*/

  void generatePieces(Spot spot) async {
    Image img = Image.network(spot.photoLink);
    Size originalSize = await ImageManipulation.getImageSize(img);
    double imageWidth;
    double imageHeight;
    imageWidth = widget.constraints.maxWidth;
    imageHeight = imageWidth / originalSize.aspectRatio;

    if (imageWidth > widget.constraints.maxWidth) {
      imageWidth = widget.constraints.maxWidth;
      imageHeight = widget.constraints.maxWidth / originalSize.aspectRatio;
    } else if (imageHeight > widget.constraints.maxHeight) {
      imageHeight = widget.constraints.maxHeight;
      imageWidth = widget.constraints.maxHeight * originalSize.aspectRatio;
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

    //widget._logger.d("imageSize.width: ${imageSize.width} ; imageSize.height: ${imageSize.height}");
    List<PuzzlePiece> storedPuzzlePieces =
        await DatabasePuzzlePieceTable.getAllFromSpot(spot.id);
    List<PuzzlePieceWidget> storedPuzzlePieceWidgets = [];
    List<Point> storedPositions = [];
    for (var element in storedPuzzlePieces) {
      storedPuzzlePieceWidgets.add(
        await element.getWidget(
          imageSize: imageSize,
          bringToTop: bringToTop,
          sendToBack: sendToBack,
          constraints: widget.constraints,
          completeCallback: widget.completeCallback,
        ),
      );
      storedPositions.add(Point(element.row, element.column));
    }

    List<PuzzlePieceWidget> notStoredPieces =
        (await ImageManipulation.splitImagePuzzlePiece(
      spot: spot,
      bringToTop: bringToTop,
      sendToBack: sendToBack,
      rows: PuzzlePage.rows,
      cols: PuzzlePage.cols,
      imageSize: imageSize,
      constraints: widget.constraints,
      completeCallback: widget.completeCallback,
    ))
            .where((PuzzlePieceWidget element) {
      Point<int> point = Point(element.row, element.col);
      return !storedPositions.contains(point);
    }).toList();

    pieces.clear();
    pieces.add(SizedBox.expand(child: Container()));
    pieces.add(Container(
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
    ));
    //pieces.addAll(snappedPuzzlePieces);
    //pieces.addAll(movablePuzzlePieces);
    pieces.addAll(storedPuzzlePieceWidgets);
    pieces.addAll(notStoredPieces);
/*    pieces.add(Positioned(
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
          */ /*
          SpeedDialChild(
              child: const Icon(
                Icons.rotate_right,
              ),
              foregroundColor: Theme.of(context).unselectedWidgetColor,
              onTap: rotatePuzzle),*/ /*
        ],
      ),
    ));*/
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
