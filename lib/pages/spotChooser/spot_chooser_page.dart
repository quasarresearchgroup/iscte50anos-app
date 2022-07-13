import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/pages/spotChooser/get_all_spots_service.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

void main() async {
  runApp(MaterialApp(home: const SpotChooserPage()));
}

class SpotChooserPage extends StatefulWidget {
  const SpotChooserPage({Key? key}) : super(key: key);
  static const String pageRoute = "SpotChooser";

  @override
  State<SpotChooserPage> createState() => _SpotChooserPageState();
}

class _SpotChooserPageState extends State<SpotChooserPage> {
  double blur = 10;
  late Future<List<String>> future;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = SpotsRequestService.getAllSpots(context: context);
  }

  @override
  Widget build(BuildContext context) {
    double spacing = 10;
    double sliderMax = 20;
    double sliderMin = 0;
    return Scaffold(
      appBar: AppBar(title: Text("SpotChooser")),
      body: Column(
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
          Expanded(
            child: FutureBuilder<List<String>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: EdgeInsets.all(spacing),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: spacing,
                            crossAxisSpacing: spacing,
                            crossAxisCount: 2),
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: ImageFiltered(
                              imageFilter:
                                  ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                              child: InkWell(
                                enableFeedback: true,
                                splashColor: Colors.black,
                                onTap: () {
                                  SharedPrefsService.storeCurrentPuzzleIMG(
                                      snapshot.data![index]);
                                  DatabasePuzzlePieceTable.removeALL();
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Image.network(
                                    snapshot.data![index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const LoadingWidget();
                  }
                }),
          ),
        ],
      ),
    );
  }
}
