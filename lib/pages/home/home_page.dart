import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/pages/home/nav_drawer/drawer.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_page.dart';
import 'package:iscte_spots/pages/home/scanPage/openday_qr_scan_page.dart';
import 'package:iscte_spots/pages/home/state/PuzzleState.dart';
import 'package:iscte_spots/pages/home/widgets/sucess_scan_widget.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/pages/spotChooser/spot_chooser_page.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
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

  completePuzzleCallback() async {
    LoggerService.instance.debug("Completed Puzzle!!");
    _confettiController.play();
    Spot? spot = _currentSpotNotifier.value;
    if (spot != null) {
      spot.visited = true;
      DatabaseSpotTable.update(spot);
    }
    await DynamicAlertDialog.showDynamicDialog(
        context: context,
        title: Text(AppLocalizations.of(context)!.help),
        content: Text(AppLocalizations.of(context)!.puzzleCompleteDialog),
        actions: [
          DynamicTextButton(
              child: Text(AppLocalizations.of(context)!.confirm),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ]);

    setState(() {});
    Future.delayed(const Duration(seconds: 1))
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
                          backgroundColor: Colors.white,
                          selectedIconTheme: Theme.of(context).iconTheme,
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
                          destinations: <NavigationRailDestination>[
                            NavigationRailDestination(
                              icon: const Icon(Icons.menu),
                              selectedIcon: const Icon(Icons.menu),
                              label: Text(AppLocalizations.of(context)!.menu),
                            ),
                            NavigationRailDestination(
                              icon: const Icon(Icons.question_mark),
                              label: Text(AppLocalizations.of(context)!.help),
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
            title: AppLocalizations.of(context)!.puzzleScreen,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                              ? const Icon(
                                  CupertinoIcons.question,
                                  color: IscteTheme.iscteColor,
                                )
                              : const Icon(Icons.question_mark),
                          onPressed: () => showHelpOverlay(
                              context, Image.network(imgLink), orientation),
                        );
                      } else {
                        return DynamicIconButton(
                          child: const Icon(
                            SpotChooserPage.icon,
                            color: IscteTheme.iscteColor,
                          ),
                          onPressed: () => Navigator.of(context)
                              .pushNamed(SpotChooserPage.pageRoute),
                        );
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
          child: ValueListenableBuilder<Spot?>(
              valueListenable: _currentSpotNotifier,
              builder: (context, currentSpot, _) {
                if (currentSpot != null) {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return PuzzlePage(
                                  spot: currentSpot,
                                  completeCallback: completePuzzleCallback,
                                  constraints: constraints,
                                );
                              },
                            ),
                            IscteConfetti(
                              confettiController: _confettiController,
                            )
                          ],
                        ),
                      ),
                      ValueListenableBuilder<double>(
                          valueListenable: PuzzleState.currentPuzzleProgress,
                          builder: (context, double progress, _) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: progress,
                                  ),
                                  builder: (context, value, _) =>
                                      LinearProgressIndicator(
                                    value: value,
                                    color: IscteTheme.iscteColor,
                                    backgroundColor: IscteTheme.greyColor,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!
                                      .puzzleProgress((progress * 100).round()),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: IscteTheme.iscteColor,
                                      ),
                                )
                              ],
                            );
                          }),
                    ],
                  );
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
                                AppLocalizations.of(context)!.spotChooserScreen,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: IscteTheme.iscteColor,
                                    )),
                            onPressed: () => Navigator.of(context)
                                .pushNamed(SpotChooserPage.pageRoute))
                      ],
                    ),
                  );
                }
              })),
    );
  }
}
