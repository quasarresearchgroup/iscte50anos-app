import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/widgets/puzzle/puzzle_piece_widget.dart';

import '../widgets/puzzle/clipped_piece_widget.dart';
import '../widgets/splashScreen/moving_widget.dart';
import 'box_size.dart';

class ImageManipulation {
  static Future<Size> getImageSize(Image image) async {
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

  static Future<List<PuzzlePieceWidget>> splitImagePuzzlePiece({
    required Image image,
    required rows,
    required cols,
    required bringToTop,
    required sendToBack,
    required constraints,
  }) async {
    //logger.d('started split');
    List<PuzzlePieceWidget> outputList = [];
    Size imageSize = await getImageSize(image);
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < cols; y++) {
        var puzzlePiece = PuzzlePieceWidget(
          key: GlobalKey(),
          image: image,
          imageSize: imageSize,
          row: x,
          col: y,
          maxRow: rows,
          maxCol: cols,
          bringToTop: bringToTop,
          sendToBack: sendToBack,
          constraints: constraints,
        );
        outputList.add(puzzlePiece);
      }
    }
    //logger.d('finished split');
    return outputList;
  }

  static Future<List<MovingPiece>> splitImageMovableWidget({
    required Image image,
    required rows,
    required cols,
    required bringToTop,
    required sendToBack,
    required BoxConstraints constraints,
  }) async {
    //logger.d('started Image split');
    List<MovingPiece> outputList = [];
    Size imageSize = await getImageSize(image);

    final imageWidth = constraints.maxWidth;
    final imageHeight =
        constraints.maxHeight * constraints.maxWidth / imageSize.width;

    final pieceWidth = imageWidth / rows;
    final pieceHeight = imageHeight / cols;
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < cols; y++) {
        final BoxSize pieceConstraints = BoxSize(
            minWidth: -y * pieceWidth,
            minHeight: -x * pieceHeight,
            maxHeight: constraints.maxHeight - 2 * imageHeight,
            maxWidth: constraints.maxWidth - imageWidth);
        outputList.add(MovingPiece(
          weight: (Random().nextDouble() + 0.5) * 0.5,
          imageSize: imageSize,
          constraints: pieceConstraints,
          child: ClippedPieceWidget(
            image: image,
            row: x,
            col: y,
            maxRow: rows,
            maxCol: cols,
            width: imageWidth,
          ),
        ));
      }
    }
    //logger.d('finished Image split');
    return outputList;
  }
}
