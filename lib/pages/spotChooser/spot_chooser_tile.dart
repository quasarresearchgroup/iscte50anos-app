import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_page.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

class ChooseSpotTile extends StatefulWidget {
  const ChooseSpotTile({
    Key? key,
    required this.spot,
    required,
    required this.blur,
    required this.chooseSpotCallback,
  }) : super(key: key);
  final Spot spot;
  final double blur;
  final Future<void> Function(Spot spot, BuildContext context)
      chooseSpotCallback;

  @override
  State<ChooseSpotTile> createState() => _ChooseSpotTileState();
}

class _ChooseSpotTileState extends State<ChooseSpotTile> {
  late final Future<int> _completePercentageFuture;
  @override
  void initState() {
    super.initState();
    _completePercentageFuture = fetchCompletePercentage(widget.spot);
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        imageUrl: widget.spot.photoLink,
        progressIndicatorBuilder: (BuildContext context, String string,
            DownloadProgress downloadProgress) {
          return const LoadingWidget();
        },
        imageBuilder: (BuildContext context, ImageProvider imageProvider) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: widget.spot.visited ? 0 : widget.blur,
                    sigmaY: widget.spot.visited ? 0 : widget.blur,
                  ),
                  child: InkWell(
                    enableFeedback: true,
                    splashColor: Colors.black,
                    onTap: () {
                      widget.chooseSpotCallback(widget.spot, context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Card(
                    color: Theme.of(context).backgroundColor.withAlpha(100),
                    child: SizedBox.square(
                      dimension: 50,
                      child: Center(
                        child: widget.spot.visited
                            ? const Icon(
                                Icons.check,
                                size: 40,
                              )
                            : FutureBuilder<int>(
                                future: _completePercentageFuture,
                                builder: (BuildContext context,
                                    AsyncSnapshot<int> snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      "${snapshot.data!}%",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          overflow: TextOverflow.ellipsis),
                                    );
                                  } else {
                                    return const LoadingWidget();
                                  }
                                }),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  Future<int> fetchCompletePercentage(Spot spot) async {
    int nPlacedPieces =
        (await DatabasePuzzlePieceTable.getAllFromSpot(spot.id)).length;
    return (nPlacedPieces * 100 / (PuzzlePage.cols * PuzzlePage.rows)).round();
  }
}
