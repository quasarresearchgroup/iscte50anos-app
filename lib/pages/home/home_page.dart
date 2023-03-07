import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/pages/home/nav_drawer/drawer.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_page.dart';
import 'package:iscte_spots/pages/home/scanPage/openday_qr_scan_page.dart';
import 'package:iscte_spots/pages/home/widgets/sucess_scan_widget.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/pages/spotChooser/spot_chooser_page.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_icon_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/iscte_confetti_widget.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/overlays.dart';

import '../timeline/feedback_form.dart';
import 'widgets/completed_challenge_widget.dart';

class HomePage extends StatefulWidget {
  static const pageRoute = "/home";

  HomePage({Key? key}) : super(key: key);

  final int scanSpotIndex = 2;
  final int leaderBoardIndex = 1;
  final int puzzleIndex = 0;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  Image? currentPuzzleImage;
  int? currentPuzzleNumber;
  bool _showSucessPage = false;

  //late Future<Map> futureProfile;
  //late Future<SpotRequest> currentPemit;
  final ValueNotifier<bool> _completedAllPuzzlesBool =
      SharedPrefsService().allPuzzleCompleteNotifier;
  final ValueNotifier<Spot?> _currentSpotNotifier =
      SharedPrefsService().currentSpotNotifier;
  late final ConfettiController _confettiController;
  late final AnimationController _lottieController;

  // final GlobalKey<State<StatefulWidget>> _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(initialIndex: widget.puzzleIndex, length: 3, vsync: this);

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _lottieController.addStatusListener(
      (status) {
        LoggerService.instance
            .debug("listening to success Puzzle animation $status");
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 500)).then((value) {
            setState(() {
              _lottieController.reset();
              _showSucessPage = false;
            });
            _tabController.animateTo(widget.puzzleIndex);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _confettiController.dispose();
    _lottieController.dispose();
  }

  completePuzzleCallback() {
    LoggerService.instance.debug("Completed Puzzle!!");
    _confettiController.play();
    Spot? spot = _currentSpotNotifier.value;
    if (spot != null) {
      spot.visited = true;
      DatabaseSpotTable.update(spot);
    }
    setState(() {});
    Future.delayed(const Duration(seconds: 2))
        .then((value) => _tabController.animateTo(widget.scanSpotIndex));
  }

  void showSuccessPage() {
    setState(() {
      _showSucessPage = true;
    });
  }

  void _completedAllPuzzles() async {
    await SharedPrefsService.storeCompletedAllPuzzles();
    _tabController.animateTo(widget.puzzleIndex);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      return ValueListenableBuilder<bool>(
        valueListenable: _completedAllPuzzlesBool,
        builder: (BuildContext context, bool challengeCompleteBool, _) {
          return buildMaterialScaffold(challengeCompleteBool, orientation);
        },
      );
    });
  }

  Widget buildMaterialScaffold(
      bool challengeCompleteBool, Orientation orientation) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: const MyNavigationDrawer(),
      appBar: buildAppBar(orientation, challengeCompleteBool),
      bottomNavigationBar:
          (challengeCompleteBool || orientation == Orientation.landscape)
              ? null
              : MyBottomBar(
                  tabController: _tabController,
                  initialIndex: 0,
                ),
      body: Builder(builder: (context) {
        return orientation == Orientation.landscape
            ? Row(
                children: [
                  ValueListenableBuilder<Spot?>(
                      valueListenable: _currentSpotNotifier,
                      builder: (context, value, _) {
                        return NavigationRail(
                          onDestinationSelected: (index) {
                            if (index == 0) {
                              Scaffold.of(context).openDrawer();
                            } else {
                              if (value?.photoLink != null) {
                                String imgLink = value!.photoLink;
                                showHelpOverlay(
                                  context,
                                  Image.network(imgLink),
                                  orientation,
                                );
                              }
                            }
                          },
                          selectedIndex: 0,
                          destinations: const <NavigationRailDestination>[
                            NavigationRailDestination(
                              icon: Icon(Icons.menu),
                              selectedIcon: Icon(Icons.menu),
                              label: Text('Drawer'), //TODO
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.help),
                              label: Text('Help'), //TODO
                            ),
                          ],
                        );
                      }),
                  const VerticalDivider(),
                  Expanded(child: buildHomeBody(challengeCompleteBool)),
                  const VerticalDivider(),
                  MyBottomBar(
                    initialIndex: 0,
                    tabController: _tabController,
                    orientation: orientation,
                  ),
                ],
              )
            : buildHomeBody(challengeCompleteBool);
      }),
    );
  }

  MyAppBar? buildAppBar(Orientation orientation, bool challengeCompleteBool) {
    return orientation == Orientation.landscape
        ? null
        : MyAppBar(
            title: "Puzzle", //TODO
            leading: Row(
              children: [
                Builder(builder: (context) {
                  if (!PlatformService.instance.isIos) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  } else {
                    return CupertinoButton(
                      child: const Icon(
                        Icons.menu,
                        color: IscteTheme.iscteColor,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  }
                }),
                if (!PlatformService.instance.isWeb) const FeedbackFormButon(),
              ],
            ),
            trailing: challengeCompleteBool
                ? null
                : ValueListenableBuilder<Spot?>(
                    valueListenable: _currentSpotNotifier,
                    builder: (context, value, _) {
                      if (value?.photoLink != null) {
                        String imgLink = value!.photoLink;
                        return DynamicIconButton(
                          child: PlatformService.instance.isIos
                              ? const Icon(CupertinoIcons.question)
                              : const Icon(Icons.question_mark),
                          onPressed: () => showHelpOverlay(
                              context, Image.network(imgLink), orientation),
                        );
                        /*  if (!PlatformService.instance.isIos) {
                          return IconButton(
                            icon: const Icon(Icons.help),
                            onPressed: () => showHelpOverlay(
                                context, Image.network(imgLink), orientation),
                          );
                        } else {
                          return CupertinoButton(
                            onPressed: () => showHelpOverlay(
                                context, Image.network(imgLink), orientation),
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              CupertinoIcons.question_circle,
                              color: IscteTheme.iscteColor,
                            ),
                          );
                        }*/
                      } else {
                        return DynamicIconButton(
                            child: const Icon(
                              SpotChooserPage.icon,
                              color: IscteTheme.iscteColor,
                            ),
                            onPressed: () => Navigator.of(context)
                                .pushNamed(SpotChooserPage.pageRoute));
                      }
                    },
                  ),
          );
  }

  Widget buildHomeBody(bool challengeCompleteBool) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: challengeCompleteBool
          ? CompletedChallengeWidget()
          : _showSucessPage
              ? SucessScanWidget(
                  confettiController: _confettiController,
                  lottieController: _lottieController,
                )
              : TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    buildPuzzleBody(),
                    const LeaderBoardPage(),
                    QRScanPageOpenDay(
                      //changeImage: changeCurrentSpot,
                      completedAllPuzzle: _completedAllPuzzles,
                    ),
                  ],
                ),
    );
  }

  Widget buildPuzzleBody() {
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              ValueListenableBuilder<Spot?>(
                  valueListenable: _currentSpotNotifier,
                  builder: (context, value, _) {
                    if (value != null) {
                      return LayoutBuilder(builder: (context, constraints) {
                        return PuzzlePage(
                          spot: value,
                          completeCallback: completePuzzleCallback,
                          constraints: constraints,
                        );
                      });
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              SpotChooserPage.icon,
                              size: 100,
                            ),
                            DynamicTextButton(
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .spotChooserScreen,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: IscteTheme.iscteColor,
                                        )), //TODO
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(SpotChooserPage.pageRoute))
                          ],
                        ),
                      );
                    }
                  }),
              IscteConfetti(confettiController: _confettiController)
            ],
          )),
    );
  }

  GestureDetector buildErrorWidget() {
    return GestureDetector(
      onTap: () {
        //rerfeshPermit();
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('Ocorreu um erro a descarregar os dados'), //TODO
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'Tocar aqui para recarregar', //TODO
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
