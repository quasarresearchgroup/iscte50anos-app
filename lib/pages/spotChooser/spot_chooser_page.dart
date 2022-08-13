import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
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
  late Future<List<Spot>> future;

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
            List<Spot> spotsList = snapshot.data!;
            return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    title:
                        Text(AppLocalizations.of(context)!.spotChooserScreen),
                    floating: true,
                    snap: true,
                    stretch: true,
                    onStretchTrigger: () {
                      return refreshCallback(context);
                    },
                    expandedHeight: 150,
                    flexibleSpace: FlexibleSpaceBar(
                      background: DecoratedBox(
                          position: DecorationPosition.foreground,
                          decoration: const BoxDecoration(),
                          child: buildTopRow(spotsList)),
                      collapseMode: CollapseMode.pin,
                    ),
                  ),
                  buildSpotsGrid(spotsList),
                ]);
          } else {
            return const LoadingWidget();
          }
        },
      ),
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

  Widget buildTopRow(List<Spot> list) {
    double sliderMax = 20;
    double sliderMin = 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            Text("$blur"),
            Expanded(
              child: Slider(
                  max: sliderMax,
                  min: sliderMin,
                  divisions: sliderMax.toInt() - sliderMin.toInt(),
                  label: "$blur",
                  value: blur,
                  onChanged: (newBlur) {
                    setState(() {
                      blur = newBlur;
                    });
                  }),
            ),
          ],
        ),
        TextButton(
            style: Theme.of(context).textButtonTheme.style?.copyWith(
                overlayColor:
                    MaterialStateColor.resolveWith((Set<MaterialState> states) {
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
            child: Text(
              AppLocalizations.of(context)!.random,
              style: TextStyle(color: Colors.white),
            )),
      ],
    );
  }

  Widget buildSpotsGrid(List<Spot> list) {
    double spacing = 10;

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
          return ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: list.isEmpty
                ? const Center(child: Text("List is empty"))
                : ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: InkWell(
                      enableFeedback: true,
                      splashColor: Colors.black,
                      onTap: () {
                        chooseSpot(list[index], context);
                      },
                      child: Container(
                        decoration: const BoxDecoration(),
                        child: Image.network(
                          list[index].photoLink,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
          );
        },
        childCount: list.isEmpty ? 1 : list.length,
      ),
    );
    //}
  }

  void chooseSpot(Spot spot, BuildContext context) {
    SharedPrefsService.storeCurrentPuzzleIMG(spot.photoLink);
    DatabasePuzzlePieceTable.removeALL();
    Navigator.of(context).pop();
  }
}
