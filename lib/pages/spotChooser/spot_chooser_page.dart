import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/services/spotChooser/fetch_all_spots_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_snackbar.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

import 'spot_chooser_tile.dart';

void main() async {
  runApp(MaterialApp(home: SpotChooserPage()));
}

class SpotChooserPage extends StatefulWidget {
  SpotChooserPage({Key? key}) : super(key: key);
  static const String pageRoute = "SpotChooser";
  static const IconData icon = Icons.directions_run;

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
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
/*          floatingActionButton: SpeedDial(
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
                  await DatabasePuzzlePieceTable.removeALL();
                  await DatabaseSpotTable.removeALL();
                  setState(() {
                    future = DatabaseSpotTable.getAll();
                  });
                },
              )
            ],
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),*/
          /*appBar: orientation == Orientation.portrait
              ? null
              : MyAppBar(
                  leading: const DynamicBackIconButton(),
                  title: AppLocalizations.of(context)!.spotChooserScreen),*/
          body: FutureBuilder<List<Spot>>(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LoadingWidget();
              }
              List<Spot> list = snapshot.data!;
              List<Widget> slivers = [];
              if (orientation == Orientation.portrait) {
                slivers.addAll(buildSliverAppBar(context));
              }

              int crossAxisCount =
                  2; //orientation == Orientation.portrait ? 2 : 4;
              if (list.isNotEmpty) {
                //slivers2.add(buildTopRow(list, crossAxisCount, orientation));
                slivers.add(buildSpotsGrid(list, crossAxisCount, orientation));
              } else {
                slivers.add(const SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    ListTile(
                      title: Center(child: Text("No spots in list!")), //TODO
                    ),
                  ]),
                ));
              }
              return CustomScrollView(
                scrollDirection: orientation == Orientation.portrait
                    ? Axis.vertical
                    : Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                slivers: slivers,
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> buildSliverAppBar(BuildContext context) {
    if (PlatformService.instance.isIos) {
      return [
        CupertinoSliverNavigationBar(
          padding: EdgeInsetsDirectional.zero,
          leading: const DynamicBackIconButton(),
          backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
          largeTitle: Text(
            AppLocalizations.of(context)!.spotChooserScreen,
            style: const TextStyle(color: IscteTheme.iscteColor),
          ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: () async => await refreshCallback(context),
        ),
      ];
    } else {
      return [
        SliverAppBar(
          expandedHeight: 100,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: const DynamicBackIconButton(),
          /*title: Text(
            AppLocalizations.of(context)!.spotChooserScreen,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: IscteTheme.iscteColor,
                ),
          ),*/
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              AppLocalizations.of(context)!.spotChooserScreen,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: IscteTheme.iscteColor,
                  ),
            ),
            stretchModes: const [StretchMode.fadeTitle],
          ),
          floating: true,
          stretch: true,
          stretchTriggerOffset: 50,
          onStretchTrigger: () async => await refreshCallback(context),
        )
      ];
    }
  }

  Future<void> refreshCallback(BuildContext context) async {
    LoggerService.instance.debug("fetching data");
    await SpotsRequestService.fetchAllSpots(context);
    future = DatabaseSpotTable.getAll();
    if (mounted) {
      await DynamicSnackBar.showSnackBar(
          context, const Text("Refreshed"), const Duration(seconds: 2)); //TODO
    }
    setState(() {});
  }

  Widget buildSpotsGrid(
      List<Spot> list, int crossAxisCount, Orientation orientation) {
    return SliverPadding(
      padding: EdgeInsets.all(spacing),
      sliver: SliverGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        children: [
          DynamicTextButton(
              style: IscteTheme.greyColor,
              child: Text(
                AppLocalizations.of(context)!.random,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: IscteTheme.iscteColor,
                    ),
              ),
              onPressed: () {
                if (list.isNotEmpty) {
                  chooseSpot(list[Random().nextInt(list.length)], context);
                } else {
                  DynamicSnackBar.showSnackBar(
                      context,
                      const Text("No Spots stored!"), //TODO
                      const Duration(seconds: 2)); //TODO
                }
              }),
          ...(list
              .map(
                (e) => ChooseSpotTile(
                  spot: e,
                  blur: blur,
                  chooseSpotCallback: chooseSpot,
                ),
              )
              .toList())
        ],
      ),
    );
  }

//TODO remove from ui page into own service
  Future<void> chooseSpot(Spot spot, BuildContext context) async {
    SharedPrefsService.storeCurrentSpot(spot);
    //await DatabasePuzzlePieceTable.removeALL();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
