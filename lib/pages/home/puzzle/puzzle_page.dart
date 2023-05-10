import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/puzzle_piece.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_piece_widget.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({
    Key? key,
    required this.spot,
    required this.constraints,
    required this.completeCallback,
  }) : super(key: key);
  static const pageRoute = "/puzzle";

  static const int rows = 5;
  static const int cols = 5;
  final Spot spot;
  final BoxConstraints constraints;
  final Function completeCallback;

  @override
  PuzzlePageState createState() => PuzzlePageState();
}

class PuzzlePageState extends State<PuzzlePage>
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

    return pieces.isNotEmpty
        ? Stack(children: [
            SizedBox.expand(child: Container()),
            ...pieces,
            /*Positioned(
              right: 0,
              bottom: 0,
              child: FloatingActionButton(
                elevation: 0,
                onPressed: refreshPieces,
                child: const Icon(Icons.refresh),
              ),
            )*/
          ])
        : const DynamicLoadingWidget();
  }

  void refreshPieces() {
    generatePieces(widget.spot);
  }

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

    final Size imageSize = Size(imageWidth, imageHeight);

    //LoggerService.instance.debug("imageSize.width: ${imageSize.width} ; imageSize.height: ${imageSize.height}");
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

    if (!mounted) return;
    pieces.clear();
    pieces.add(
      Container(
        decoration: const BoxDecoration(color: IscteTheme.iscteColorSmooth),
        child: SizedBox(
          width: imageSize.width,
          height: imageSize.height,
        ),
      ),
    );
    pieces.addAll(storedPuzzlePieceWidgets);
    pieces.addAll(notStoredPieces);
    setState(() {});
  }

  void bringToTop(Widget targetWidget) {
    //LoggerService.instance.debug("Used bringToTop function on $targetWidget.");
    setState(() {
      pieces.remove(targetWidget);
      pieces.insert(pieces.length - 1, targetWidget);
    });
  }

// when a piece reaches its final position, it will be sent to the back of the stack to not get in the way of other, still movable, pieces
  void sendToBack(Widget targetWidget) {
    //LoggerService.instance.debug("Used sendToBack function on $targetWidget");
    setState(() {
      pieces.remove(targetWidget);
      pieces.insert(2, targetWidget);
    });
  }
}
