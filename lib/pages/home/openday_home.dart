import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_page.dart';
import 'package:iscte_spots/pages/home/scanPage/openday_qr_scan_page.dart';
import 'package:iscte_spots/pages/home/widgets/sucess_scan_widget.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/services/openday/openday_qr_scan_service.dart';
import 'package:iscte_spots/services/profile/profile_service.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/widgets/iscte_confetti_widget.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer_openday.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:iscte_spots/widgets/util/overlays.dart';
import 'package:logger/logger.dart';

import 'widgets/completed_challenge_widget.dart';

class HomeOpenDay extends StatefulWidget {
  static const pageRoute = "/homeOpenDay";

  HomeOpenDay({Key? key}) : super(key: key);
  final Logger _logger = Logger();

  final int scanSpotIndex = 1;
  final int puzzleIndex = 0;
  @override
  State<HomeOpenDay> createState() => _HomeOpenDayState();
}

class _HomeOpenDayState extends State<HomeOpenDay>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Image? currentPuzzleImage;
  bool _showSucessPage = false;
  late Future<Map> futureProfile;
  late Future<String> currentPemit;
  final ValueNotifier<bool> _completedAllPuzzlesBool =
      SharedPrefsService().allPuzzleCompleteState;
  late final ConfettiController _confettiController;
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(initialIndex: widget.puzzleIndex, length: 2, vsync: this);

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _lottieController.addStatusListener(
      (status) {
        widget._logger.d("listenning to sucess Puzzle animation $status");
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 500)).then((value) {
            setState(() {
              _lottieController.reset();
              _showSucessPage = false;
            });
          });
        }
      },
    );
    futureProfile = ProfileService().fetchProfile();
    currentPemit = OpenDayQRScanService.spotRequest();
//    initFunc();
  }

  @override
  void dispose() {
    super.dispose();
    _confettiController.dispose();
    _lottieController.dispose();
  }

  completePuzzleCallback() {
    widget._logger.d("Completed Puzzle!!");
    _confettiController.play();
    setState(() {});
    Future.delayed(Duration(seconds: 2))
        .then((value) => _tabController.animateTo(widget.scanSpotIndex));
  }

  rerfeshPermit() {
    Future<String> newPermit = OpenDayQRScanService.spotRequest();
    setState(() {
      currentPemit = newPermit;
    });
  }

  void _changeCurrentImage(String imageLink) async {
    widget._logger.d("changin imag: $imageLink");
    if (!OpenDayQRScanService.isError(imageLink)) {
      DatabasePuzzlePieceTable.removeALL();
      rerfeshPermit();
      setState(() {
        //currentPuzzleImage = Image.network(imageLink);
        _showSucessPage = true;
        futureProfile = ProfileService().fetchProfile();
      });
      _tabController.animateTo(widget.puzzleIndex);
    }
  }

  void _completedAllPuzzles() async {
    bool _completedAllPuzzleState =
        await SharedPrefsService.storeCompletedAllPuzzles();
    _tabController.animateTo(widget.puzzleIndex);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _completedAllPuzzlesBool,
      builder: (BuildContext context, bool challengeCompleteBool, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          drawer: NavigationDrawerOpenDay(),
          appBar: AppBar(
            title: FutureBuilder<Map>(
                future: futureProfile,
                builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
                  String spots;
                  if (snapshot.hasData) {
                    var profile = snapshot.data as Map;
                    spots = "nº " + profile["num_spots_read"].toString();
                  } else {
                    spots = "";
                  }
                  return Text("Puzzle $spots");
                }),
            actions: challengeCompleteBool
                ? null
                : [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.circleQuestion),
                          onPressed: () => showHelpOverlay(
                              context, currentPuzzleImage!, widget._logger),
                        ),
                      ),
                    ),
                  ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.score, size: 30),
              foregroundColor: Theme.of(context).unselectedWidgetColor,
              onPressed: () {
                Navigator.of(context).pushNamed(LeaderBoardPage.pageRoute);
              }),
          bottomNavigationBar: challengeCompleteBool
              ? Container()
              : MyBottomBar(
                  tabController: _tabController,
                  initialIndex: 0,
                ),
          body: buildHomeBody(challengeCompleteBool),
        );
      },
    );
  }

  AnimatedSwitcher buildHomeBody(bool challengeCompleteBool) {
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Stack(
                              children: [
                                FutureBuilder<String>(
                                    future: currentPemit,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (OpenDayQRScanService.isError(
                                            snapshot.data!)) {
                                          return buildErrorWidget();
                                        }
                                        currentPuzzleImage =
                                            Image.network(snapshot.data!);
                                        return PuzzlePage(
                                          image: Image.network(snapshot.data!),
                                          constraints: constraints,
                                          completeCallback:
                                              completePuzzleCallback,
                                        );
                                      } else if (snapshot.hasError) {
                                        return buildErrorWidget();
                                      } else {
                                        return LoadingWidget();
                                      }
                                    }),
                                IscteConfetti(
                                    confettiController: _confettiController)
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    QRScanPageOpenDay(
                      changeImage: _changeCurrentImage,
                      completedAllPuzzle: _completedAllPuzzles,
                    )
                  ],
                ),
    );
  }

  GestureDetector buildErrorWidget() {
    return GestureDetector(
      onTap: () {
        rerfeshPermit();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text('Ocorreu um erro a descarregar os dados'),
          ),
          const Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              'Tocar aqui para recarregar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
