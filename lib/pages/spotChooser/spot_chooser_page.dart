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
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_icon_button.dart';
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
  static const double BLUR = 10;
  static const double SPACING = 10;
  static const int CROSS_AXIS_COUNT = 2;

  late Future<List<Spot>> future;

  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    future = DatabaseSpotTable.getAll();
    // future.then((List<Spot> value) {
    //   if(value.isEmpty){
    //     SpotsRequestService.fetchAllSpots(context);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          // floatingActionButton: SpeedDial(
          //   children: [
          //     SpeedDialChild(
          //       backgroundColor: Theme.of(context).primaryColor,
          //       child: const Icon(Icons.refresh),
          //       onTap: () {
          //         refreshCallback(context);
          //       },
          //     ),
          //     SpeedDialChild(
          //       backgroundColor: Theme.of(context).colorScheme.error,
          //       child: const Icon(Icons.delete),
          //       onTap: () async {
          //         await DatabasePuzzlePieceTable.removeALL();
          //         await DatabaseSpotTable.removeALL();
          //         setState(() {
          //           future = DatabaseSpotTable.getAll();
          //         });
          //       },
          //     )
          //   ],
          //   child: const Icon(
          //     Icons.add,
          //     color: Colors.white,
          //   ),
          // ),
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
                slivers.addAll(buildSliverAppBar(context, list));
              }

              if (list.isNotEmpty) {
                slivers.add(_buildSpotsGrid(list, orientation));
              } else {
                slivers.addAll([
                  SliverPadding(
                    padding: const EdgeInsets.all(SPACING),
                    sliver: SliverFillRemaining(
                        child: buildDynamicRefreshButton(context, size: 50)),
                  ),
                ]);
              }
              return CustomScrollView(
                scrollDirection: orientation == Orientation.portrait
                    ? Axis.vertical
                    : Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: false,
                slivers: slivers,
              );
            },
          ),
        );
      },
    );
  }

  DynamicTextButton buildDynamicRefreshButton(BuildContext context,
      {double? size, bool displayText = true}) {
    return DynamicTextButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              PlatformService.instance.isIos
                  ? CupertinoIcons.refresh
                  : Icons.refresh,
              size: size,
            ),
            if (displayText)
              Text(
                AppLocalizations.of(context)!.refresh,
              ),
          ],
        ),
        onPressed: () => _refreshCallback(context));
  }

  List<Widget> buildSliverAppBar(BuildContext context, List<Spot> spotsList) {
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
          trailing: spotsList.isEmpty
              ? buildDynamicRefreshButton(context, displayText: false)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DynamicIconButton(
                        child: Icon(
                          PlatformService.instance.isIos
                              ? CupertinoIcons.shuffle
                              : Icons.shuffle,
                          color: IscteTheme.iscteColor,
                        ),
                        onPressed: () =>
                            _chooseRandomSpotCallback(spotsList, context)),
                    DynamicIconButton(
                        child: Icon(
                          PlatformService.instance.isIos
                              ? CupertinoIcons.question_circle
                              : Icons.question_mark_rounded,
                          color: IscteTheme.iscteColor,
                        ),
                        onPressed: () => _displayHelpDialog(context)),
                  ],
                ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: () async => await _refreshCallback(context),
        )
      ];
    } else {
      return [
        SliverAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: const DynamicBackIconButton(),
          /*title: Text(
            AppLocalizations.of(context)!.spotChooserScreen,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: IscteTheme.iscteColor,
                ),
          ),*/
          actions: [
            if (spotsList.isEmpty)
              buildDynamicRefreshButton(context, displayText: false),
            if (spotsList.isNotEmpty)
              DynamicIconButton(
                  child: Icon(
                    PlatformService.instance.isIos
                        ? CupertinoIcons.shuffle
                        : Icons.shuffle,
                    color: IscteTheme.iscteColor,
                  ),
                  onPressed: () =>
                      _chooseRandomSpotCallback(spotsList, context)),
            if (spotsList.isNotEmpty)
              DynamicIconButton(
                  child: Icon(
                    PlatformService.instance.isIos
                        ? CupertinoIcons.question_circle
                        : Icons.question_mark_rounded,
                    color: IscteTheme.iscteColor,
                  ),
                  onPressed: () => _displayHelpDialog(context)),
          ],
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
          snap: true,
          stretch: true,
          onStretchTrigger: () async => await _refreshCallback(context),
        ),
      ];
    }
  }

  void _displayHelpDialog(BuildContext context) {
    DynamicAlertDialog.showDynamicDialog(
      context: context,
      title: Text(AppLocalizations.of(context)!.help),
      content: Text(AppLocalizations.of(context)!.spotChooserHelpDialogContent),
    );
  }

  Future<void> _refreshCallback(BuildContext context) async {
    LoggerService.instance.debug("refreshing spot chooser page");
    await SpotsRequestService.fetchAllSpots(context);
    future = DatabaseSpotTable.getAll();
    if (mounted) {
      await DynamicSnackBar.showSnackBar(
          context,
          Text(AppLocalizations.of(context)!.refreshed),
          const Duration(seconds: 2)); //TODO
    }
    setState(() {});
  }

  Widget _buildSpotsGrid(List<Spot> spots, Orientation orientation) {
    return SliverPadding(
      padding: const EdgeInsets.all(SPACING),
      sliver: SliverGrid.count(
        crossAxisCount: CROSS_AXIS_COUNT,
        mainAxisSpacing: SPACING,
        crossAxisSpacing: SPACING,
        children: [
          ...(spots
              .map(
                (e) => ChooseSpotTile(
                  spot: e,
                  blur: BLUR,
                  chooseSpotCallback: _chooseSpotCallback,
                ),
              )
              .toList())
        ],
      ),
    );
  }

  void _chooseRandomSpotCallback(List<Spot> list, BuildContext context) {
    if (list.isNotEmpty) {
      DynamicAlertDialog.showDynamicDialog(
          context: context,
          title: Text(
            AppLocalizations.of(context)!.spotChooserRandomConfirmationTitle,
          ),
          content: Text(AppLocalizations.of(context)!
              .spotChooserRandomConfirmationContent),
          actions: [
            DynamicTextButton(
                child: Text(AppLocalizations.of(context)!
                    .spotChooserRandomConfirmationButton),
                onPressed: () {
                  _chooseSpotCallback(
                      list[Random().nextInt(list.length)], context);
                  Navigator.of(context).pop();
                })
          ]);
    } else {
      DynamicSnackBar.showSnackBar(
          context,
          Text(
            AppLocalizations.of(context)!.spotChooserNotSpotsStored,
          ),
          const Duration(seconds: 2)); //TODO
    }
  }

//TODO remove from ui page into own service
  Future<void> _chooseSpotCallback(Spot spot, BuildContext context) async {
    LoggerService.instance.debug("choosing new spot $spot");
    SharedPrefsService.storeCurrentSpot(spot);
    //await DatabasePuzzlePieceTable.removeALL();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
