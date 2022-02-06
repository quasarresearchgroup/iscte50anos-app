import 'dart:async';

import 'package:ISCTE_50_Anos/widgets/puzzle/puzzle_piece.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({Key? key}) : super(key: key);

  final int rows = 3;
  final int cols = 3;

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  late Image _image;
  late Future<List<Widget>> pieces;

  @override
  void initState() {
    super.initState();
    _image = const Image(
        //image: AssetImage('Resources/Img/Logo/logo_50_anos_main.jpg'));
        image: AssetImage('Resources/Img/campus-iscte-3.jpg'));

    pieces = splitImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
        future: pieces,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Stack(children: snapshot.data!);
          } else {
            return Center(child: Text(AppLocalizations.of(context)!.loading));
          }
        });
  }

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
  Future<List<Widget>> splitImage(Image image) async {
    Size imageSize = await getImageSize(image);
    List<Widget> split_pieces = [];
    for (int x = 0; x < widget.rows; x++) {
      for (int y = 0; y < widget.cols; y++) {
        setState(() {
          split_pieces.add(PuzzlePiece(
              key: GlobalKey(),
              image: image,
              imageSize: imageSize,
              row: x,
              col: y,
              maxRow: widget.rows,
              maxCol: widget.cols));
        });
      }
    }
    return split_pieces;
  }
}
