import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/pages/spotChooser/get_all_spots_service.dart';
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
            return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    title:
                        Text(AppLocalizations.of(context)!.spotChooserScreen),
                    floating: true,
                    snap: true,
                    stretch: true,
                    onStretchTrigger: () async {
                      widget._logger.d("fetching data");
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Refreshed"),
                        duration: Duration(seconds: 2),
                      ));
                      future =
                          SpotsRequestService.getAllSpots(context: context);
                      setState(() {});
                    },
                    expandedHeight: 150,
                    flexibleSpace: FlexibleSpaceBar(
                      background: DecoratedBox(
                          position: DecorationPosition.foreground,
                          decoration: const BoxDecoration(),
                          child: buildTopRow(snapshot.data!)),
                      collapseMode: CollapseMode.pin,
                    ),
                  ),
                  buildSpotsGrid(snapshot.data!),
                ]);
          } else {
            return const LoadingWidget();
          }
        },
      ),
    );
  }

  Widget buildTopRow(List<String> list) {
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
              chooseSpot(list, Random().nextInt(list.length), context);
            },
            child: Text(AppLocalizations.of(context)!.random)),
      ],
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
                  decoration: const BoxDecoration(),
                  child: Image.network(
                    list[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
        childCount: list.length,
      ),
    );
  }

  void chooseSpot(List<String> list, int index, BuildContext context) {
    SharedPrefsService.storeCurrentPuzzleIMG(list[index]);
    DatabasePuzzlePieceTable.removeALL();
    setState(() {});
    Navigator.of(context).pop();
  }
}
