import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

@Deprecated("new puzzle page is located in pages/puzzle_page")
class PuzzlePageOld extends StatefulWidget {
  const PuzzlePageOld({Key? key}) : super(key: key);
  static Logger logger = Logger();

  static const pageRoute = "/puzzle";

  @override
  _PuzzlePageOldState createState() => _PuzzlePageOldState();
}

@Deprecated("new puzzle page is located in pages/puzzle_page")
class _PuzzlePageOldState extends State<PuzzlePageOld> {
  late Future<List<Image>> imageList;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: imageList,
      builder: (BuildContext context, AsyncSnapshot<List<Image>> snapshot) {
        if (!snapshot.hasData) {
          return LoadingWidget();
        } else {
          PuzzlePageOld.logger.i(snapshot.data);
          return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return snapshot.data![index];
                //List.generate(9, (index) => snapshot.data![index],growable: false));
              });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future<List<Image>> handlevalue() async {
      ByteData imageData =
          await rootBundle.load('Resources/Img/Logo/logo_50_anos_main.jpg');
      List<int> bytes = Uint8List.view(imageData.buffer);
      image_lib.Image? image = image_lib.decodeImage(bytes);
      return imageTest(
          inputImage: image!, verticalPieceCount: 3, horizontalPieceCount: 3);
    }

    imageList = handlevalue();
  }

  Future<List<Image>> imageTest(
      {required image_lib.Image inputImage,
      required int horizontalPieceCount,
      required int verticalPieceCount}) async {
    final int xLength = (inputImage.width / horizontalPieceCount).round();
    final int yLength = (inputImage.height / verticalPieceCount).round();
    List<image_lib.Image> pieceList = <image_lib.Image>[];

    for (int y = 0; y < verticalPieceCount; y++) {
      for (int x = 0; x < horizontalPieceCount; x++) {
        pieceList.add(image_lib.copyCrop(inputImage, x * xLength, y * yLength,
            (x + 1) * xLength, (y + 1) * yLength));
      }
    }
    //Convert image from image package to Image Widget to display
    List<Image> outputImageList = <Image>[];
    for (image_lib.Image img in pieceList) {
      outputImageList
          .add(Image.memory(Uint8List.fromList(image_lib.encodeJpg(img))));
    }

    return outputImageList;
    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
    //imageLib.Image thumbnail = imageLib.copyResize(image!, width: 120);

    //return Image.memory(Uint8List.fromList(imageLib.encodeJpg(image)));
    //return Image.memory(Uint8List.fromList(imageLib.encodeJpg(thumbnail)));
  }
}
