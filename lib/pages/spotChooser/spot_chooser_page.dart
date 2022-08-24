import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/services/spotChooser/fetch_all_spots_service.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

void main() async {
  runApp(MaterialApp(home: SpotChooserPage()));
}

class SpotChooserPage extends StatefulWidget {
  SpotChooserPage({Key? key}) : super(key: key);
  static const String pageRoute = "SpotChooser";
  final Logger _logger = Logger();

  @override
  State<SpotChooserPage> createState() => _SpotChooserPageState();
}

class _SpotChooserPageState extends State<SpotChooserPage> {
  double blur = 10;
  double spacing = 10;

  late Future<List<Spot>> future;

  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    future = DatabaseSpotTable.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          children: [
            SpeedDialChild(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.refresh),
              onTap: () {
                refreshCallback(context);
              },
            ),
            SpeedDialChild(
              backgroundColor: Theme.of(context).errorColor,
              child: const Icon(Icons.delete),
              onTap: () async {
                await DatabaseSpotTable.removeALL();
                setState(() {
                  future = DatabaseSpotTable.getAll();
                });
              },
            )
          ]),
      body: FutureBuilder<List<Spot>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> slivers2 = [];
            if (PlatformService.instance.isIos) {
              slivers2.add(buildCupertinoSliverAppBar(context));
              slivers2.add(buildCupertinoSliverRefreshControl(context));
            } else {
              slivers2.add(buildSliverAppBar(context));
            }

            slivers2.addAll([
              buildTopRow(snapshot.data!),
              buildSpotsGrid(snapshot.data!),
            ]);
            return CustomScrollView(
                physics: const BouncingScrollPhysics(), slivers: slivers2);
          } else {
            return Container(
              color: Colors.yellow,
            );
          }
        },
      ),
    );
  }

  CupertinoSliverRefreshControl buildCupertinoSliverRefreshControl( BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: () async {
        refreshCallback(context);
        showRefreshSnackBar(context);
      },
    );
  }

  CupertinoSliverNavigationBar buildCupertinoSliverAppBar(BuildContext context) {
    return CupertinoSliverNavigationBar(
      largeTitle: Text(AppLocalizations.of(context)!.spotChooserScreen),
    );
  }

  SliverAppBar buildSliverAppBar( BuildContext context) {
    return SliverAppBar(
      title: Text(AppLocalizations.of(context)!.spotChooserScreen),
      floating: true,
      snap: true,
      stretch: true,
      onStretchTrigger: () async {
        refreshCallback(context);
        showRefreshSnackBar(context);
      },
    );
  }


  Future<void> refreshCallback(BuildContext context) async {
    widget._logger.d("fetching data");
    await SpotsRequestService.fetchAllSpots(context: context);
    future = DatabaseSpotTable.getAll();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Refreshed"),
      duration: Duration(seconds: 2),
    ));
    setState(() {});
  }

  void showRefreshSnackBar(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(
          (timeStamp) {
        if (PlatformService.instance.isIos) {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) => const CupertinoPopupSurface(
              child: SizedBox(
                height: kToolbarHeight,
                child: Center(
                  child: Text("Refreshing"),
                ),
              ),
            ),
          );
        } else {
          //globalKey.currentState?.showBottomSheet(
          //(context) =>
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).backgroundColor,
              content: Text("Refreshing",
                  style: Theme.of(context).textTheme.bodyMedium),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
//    if (mounted) {
    // }
  }



  Widget buildTopRow(List<Spot> list) {
    double sliderMax = 20;
    double sliderMin = 0;
    return SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              Text("$blur"),
              Expanded(
                child: (!PlatformService.instance.isIos)
                    ? Slider(
                  max: sliderMax,
                  min: sliderMin,
                  divisions: sliderMax.toInt() - sliderMin.toInt(),
                  activeColor: CupertinoTheme.of(context).primaryColor,
                  label: "$blur",
                  value: blur,
                  onChanged: (newBlur) {
                    setState(() {
                      blur = newBlur;
                    });
                  }
                )
                    : CupertinoSlider(
                  max: sliderMax,
                  min: sliderMin,
                  divisions: sliderMax.toInt() - sliderMin.toInt(),
                  thumbColor: CupertinoTheme.of(context).primaryColor,
                  activeColor: CupertinoTheme.of(context).primaryColor,
                  value: blur,
                  onChanged: (newBlur) {
                    setState(() {
                      blur = newBlur;
                    });
                  },
                ),
              ),
            ],
          ),
          (!PlatformService.instance.isIos)
              ? TextButton(
              style: Theme.of(context).textButtonTheme.style?.copyWith(
                  overlayColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                return Colors.black;
              })),
              onPressed: () {
                if (list.isNotEmpty) {
                  chooseSpot(list[Random().nextInt(list.length)], context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Theme.of(context).errorColor,
                      content: const Text("No Spots stored!")));
                }
              },
              child: Text( AppLocalizations.of(context)!.random,)): CupertinoButton(
            child: Text(AppLocalizations.of(context)!.random),
            onPressed: () {
              if (list.isNotEmpty) {
                chooseSpot(list[Random().nextInt(list.length)], context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Theme.of(context).errorColor,
                    content: const Text("No Spots stored!")));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildSpotsGrid(List<Spot> list) {
/*    if (list.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          ListTile(
            title: Text("No spots in list!"),
          ),
          ListTile(
            title: Text("No spots in list!"),
          ),
        ]),
      );
    } else {*/
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return list.isEmpty
              ? const Center(child: Text("List is empty"))
              : CachedNetworkImage(
              imageUrl: list[index].photoLink,
              progressIndicatorBuilder: (BuildContext context, String string,
                  DownloadProgress downloadProgress) {
                return const LoadingWidget();
              },
              imageBuilder: (BuildContext context, ImageProvider imageProvider) {
                return ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child:  Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: list[index].visited ? 0 : blur,
                              sigmaY: list[index].visited ? 0 : blur,
                            ),
                            child: InkWell(
                              enableFeedback: true,
                              splashColor: Colors.black,
                              onTap: () {
                                chooseSpot(list[index], context);
                              },
                              child: Container(
                                decoration: BoxDecoration(image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                )),
                              ),
                            ),
                          ),
                          list[index].visited
                              ? Positioned(
                                  right: 10,
                                  top: 10,
                                  child: Card(
                                    color: Theme.of(context)
                                        .backgroundColor
                                        .withAlpha(200),
                                    child: Icon(
                                      Icons.check,
                                      size: 50,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
          );
                }
              );
        },
        childCount: list.isEmpty ? 1 : list.length,
      ),
    );
    //}
  }

  Future<void> chooseSpot(Spot spot, BuildContext context) async {
    SharedPrefsService.storeCurrentPuzzleIMG(spot.photoLink);
    spot.visited = true;
    await DatabaseSpotTable.update(spot);
    await DatabasePuzzlePieceTable.removeALL();
    Navigator.of(context).pop();
  }
}
