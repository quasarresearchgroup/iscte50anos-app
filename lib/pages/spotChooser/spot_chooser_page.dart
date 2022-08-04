import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/pages/spotChooser/get_all_spots_service.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
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
  late Future<List<String>> future;
  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    future = SpotsRequestService.getAllSpots(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<String>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> slivers2 = [];
            if (PlatformService.instance.isIos) {
              slivers2.add(buildCupertinoSliverAppBar(context, snapshot));
              slivers2.add(buildCupertinoSliverRefreshControl(context));
            } else {
              slivers2.add(buildSliverAppBar(context, snapshot));
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

  CupertinoSliverRefreshControl buildCupertinoSliverRefreshControl(
      BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: () async {
        refreshCallback(context);
        showRefreshSnackBar(context);
      },
    );
  }

  SliverAppBar buildSliverAppBar(
      BuildContext context, AsyncSnapshot<List<String>> snapshot) {
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

  void refreshCallback(BuildContext context) {
    SchedulerBinding.instance?.addPostFrameCallback(
      (timeStamp) {
        widget._logger.d("fetching spots data");
        future = SpotsRequestService.getAllSpots(context: context);
        setState(() {});
      },
    );
  }

  void showRefreshSnackBar(BuildContext context) {
    SchedulerBinding.instance?.addPostFrameCallback(
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

  CupertinoSliverNavigationBar buildCupertinoSliverAppBar(
      BuildContext context, AsyncSnapshot<List<String>> snapshot) {
    return CupertinoSliverNavigationBar(
      largeTitle: Text(AppLocalizations.of(context)!.spotChooserScreen),
    );
  }

  Widget buildTopRow(List<String> list) {
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
                        },
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
                      overlayColor: MaterialStateColor.resolveWith(
                          (Set<MaterialState> states) {
                    return Colors.black;
                  })),
                  onPressed: () {
                    chooseSpot(list, Random().nextInt(list.length), context);
                  },
                  child: Text(AppLocalizations.of(context)!.random))
              : CupertinoButton(
                  child: Text(AppLocalizations.of(context)!.random),
                  onPressed: () {
                    chooseSpot(list, Random().nextInt(list.length), context);
                  },
                ),
        ],
      ),
    );
  }

  Widget buildSpotsGrid(List<String> list) {
    double spacing = 10;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return CachedNetworkImage(
            imageUrl: list[index],
            progressIndicatorBuilder: (BuildContext context, String string,
                DownloadProgress downloadProgress) {
              return const LoadingWidget();
            },
            imageBuilder: (BuildContext context, ImageProvider imageProvider) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: InkWell(
                    enableFeedback: true,
                    splashColor: Colors.black,
                    onTap: () {
                      chooseSpot(list, index, context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
/*
          return Image.network(
            list[index],
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object obje, StackTrace? err) {
              return Container(
                child: Text("Error"),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress != null) {
                return const LoadingWidget();
              } else {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: InkWell(
                      enableFeedback: true,
                      splashColor: Colors.black,
                      onTap: () {
                        chooseSpot(list, index, context);
                      },
                      child: child,
                    ),
                  ),
                );
              }
            },
          );
*/
        },
        childCount: list.length,
      ),
    );
  }

  void chooseSpot(List<String> list, int index, BuildContext context) {
    SharedPrefsService.storeCurrentPuzzleIMG(list[index]);
    DatabasePuzzlePieceTable.removeALL();
    Navigator.of(context).pop();
  }
}
