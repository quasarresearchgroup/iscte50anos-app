import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as imageLib;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({Key? key}) : super(key: key);
  static Logger logger = Logger();
  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  late Future<List<Image>> imageList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: imageList,
          builder: (BuildContext context, AsyncSnapshot<List<Image>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Text(AppLocalizations.of(context)!.loading),
              );
            } else {
              PuzzlePage.logger.i(snapshot.data);
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
          }),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.puzzleScreen),
      ),
    );
  }

  @override
  void initState() {
    Future<List<Image>> handlevalue() async {
      ByteData imageData =
          await rootBundle.load('Resources/Img/Logo/logo_50_anos_main.jpg');
      List<int> bytes = Uint8List.view(imageData.buffer);
      imageLib.Image? image = imageLib.decodeImage(bytes);
      return imageTest(
          inputImage: image!, verticalPieceCount: 3, horizontalPieceCount: 3);
    }

    imageList = handlevalue();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<List<Image>> imageTest(
      {required imageLib.Image inputImage,
      required int horizontalPieceCount,
      required int verticalPieceCount}) async {
    final int xLength = (inputImage.width / horizontalPieceCount).round();
    final int yLength = (inputImage.height / verticalPieceCount).round();
    List<imageLib.Image> pieceList = <imageLib.Image>[];

    for (int y = 0; y < verticalPieceCount; y++) {
      for (int x = 0; x < horizontalPieceCount; x++) {
        pieceList.add(imageLib.copyCrop(inputImage, x * xLength, y * yLength,
            (x + 1) * xLength, (y + 1) * yLength));
      }
    }
    //Convert image from image package to Image Widget to display
    List<Image> outputImageList = <Image>[];
    for (imageLib.Image img in pieceList) {
      outputImageList
          .add(Image.memory(Uint8List.fromList(imageLib.encodeJpg(img))));
    }

    return outputImageList;
    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
    //imageLib.Image thumbnail = imageLib.copyResize(image!, width: 120);

    //return Image.memory(Uint8List.fromList(imageLib.encodeJpg(image)));
    //return Image.memory(Uint8List.fromList(imageLib.encodeJpg(thumbnail)));
  }
}
