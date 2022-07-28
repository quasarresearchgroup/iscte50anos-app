import 'package:flutter/widgets.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_piece_clipper.dart';

class ClippedPieceWidget extends StatelessWidget {
  const ClippedPieceWidget({
    Key? key,
    required this.image,
    required this.row,
    required this.col,
    required this.maxRow,
    required this.maxCol,
    required this.width,
  }) : super(key: key);

  final double width;
  final Image image;
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ClipPath(
        child: image,
        clipper: PuzzlePieceClipper(row, col, maxRow, maxCol),
      ),
    );
  }
}
