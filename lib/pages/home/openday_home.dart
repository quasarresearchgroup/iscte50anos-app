import 'dart:io';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/requests/spot_request.dart';
import 'package:iscte_spots/pages/home/nav_drawer/navigation_drawer_openday.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_page.dart';
import 'package:iscte_spots/pages/home/scanPage/openday_qr_scan_page.dart';
import 'package:iscte_spots/pages/home/widgets/sucess_scan_widget.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/services/openday/openday_qr_scan_service.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/widgets/iscte_confetti_widget.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
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
  int? currentPuzzleNumber;
  bool _showSucessPage = false;
  //late Future<Map> futureProfile;
  late Future<SpotRequest> currentPemit;
  final ValueNotifier<bool> _completedAllPuzzlesBool =
      SharedPrefsService().allPuzzleCompleteNotifier;
  final ValueNotifier<String> _currentPuzzleImg =
      SharedPrefsService().currentPuzzleIMGNotifier;
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
        widget._logger.d("listening to success Puzzle animation $status");
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
    //futureProfile = ProfileService().fetchProfile();
    currentPemit = OpenDayQRScanService.spotRequest(context: context);
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
    Future.delayed(const Duration(seconds: 2))
        .then((value) => _tabController.animateTo(widget.scanSpotIndex));
  }

  void rerfeshPermit() {
    Future<SpotRequest> newPermit =
        OpenDayQRScanService.spotRequest(context: context);
    Future<String?> newImageURL = newPermit
        .then((value) => OpenDayQRScanService.requestRouter(context, value));
    //_refreshProfile();
    setState(() {
      currentPemit = newPermit;
    });
  }

/*
  void _refreshProfile() {
    futureProfile = ProfileService().fetchProfile();
  }*/
  void showSuccessPage() {
    setState(() {
      _showSucessPage = true;
    });
  }

  void changeCurrentImage(Future<SpotRequest> request) async {
    widget._logger.d("changing image: $request");
    SpotRequest requestResult = await request;
    var newImageURL =
        await OpenDayQRScanService.requestRouter(context, requestResult);
    if (newImageURL != null) {
      if (newImageURL == OpenDayQRScanService.allVisited) {
        _completedAllPuzzles();
      } else if (!OpenDayQRScanService.isError(newImageURL)) {
        DatabasePuzzlePieceTable.removeALL();
        currentPemit = request;
        setState(() {
          currentPemit;
        });
        showSuccessPage();
      }
    }
/*
    if (request.locationPhotoLink != null) {
      if (!OpenDayQRScanService.isError(request.locationPhotoLink!)) {
        DatabasePuzzlePieceTable.removeALL();
        //rerfeshPermit();
        setState(() {
          currentPuzzleImage = Image.network(request.locationPhotoLink!);
          currentPuzzleNumber = request.spotNumber;
          _showSucessPage = true;
          //_refreshProfile();
        });
        _tabController.animateTo(widget.puzzleIndex);
      } else if (OpenDayQRScanService.isCompleteAll(
          request.locationPhotoLink!)) {
        _completedAllPuzzles();
      }
    }
*/
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
        if (Platform.isIOS) {
          return buildCupertinoScaffold(challengeCompleteBool);
        } else {
          return buildMaterialScaffold(challengeCompleteBool);
        }
      },
    );
  }

  Widget buildCupertinoScaffold(bool challengeCompleteBool) {
    return CupertinoPageScaffold(
      child: Text("home"),
      navigationBar: CupertinoNavigationBar(
        middle: Text("Puzzle"),
        trailing: challengeCompleteBool
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: ValueListenableBuilder<String>(
                    valueListenable: _currentPuzzleImg,
                    builder: (context, value, _) {
                      return IconButton(
                        icon: const FaIcon(FontAwesomeIcons.circleQuestion),
                        onPressed: () => showHelpOverlay(
                            context, Image.network(value), widget._logger),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }

  Widget buildMaterialScaffold(bool challengeCompleteBool) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: NavigationDrawerOpenDay(),
      appBar: AppBar(
        title: Text("Puzzle")
        /*FutureBuilder<SpotRequest>(
                future: currentPemit,
                builder: (BuildContext context,
                    AsyncSnapshot<SpotRequest> snapshot) {
                  if (snapshot.hasData) {
                    String spots;
                    SpotRequest spotRequest = snapshot.data as SpotRequest;
                    if (spotRequest.spotNumber != null) {
                      widget._logger.d(spotRequest);
                      currentPuzzleNumber = spotRequest.spotNumber;
                      spots = "nº " + currentPuzzleNumber!.toString();
                    } else {
                      spots = "";
                    }
                    return Text("Puzzle $spots");
                  } else {
                    return const LoadingWidget();
                  }
                })*/
        ,
        actions: challengeCompleteBool
            ? [Container()]
            : [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ValueListenableBuilder<String>(
                      valueListenable: _currentPuzzleImg,
                      builder: (context, value, _) {
                        return IconButton(
                          icon: const FaIcon(FontAwesomeIcons.circleQuestion),
                          onPressed: () => showHelpOverlay(
                              context, Image.network(value), widget._logger),
                        );
                      },
                    ),
                  ),
                ),
              ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          child: const FaIcon(
            FontAwesomeIcons.rankingStar,
            color: Colors.grey,
            size: 30,
          ),
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
      body: buildMaterialHomeBody(challengeCompleteBool),
    );
  }

  AnimatedSwitcher buildMaterialHomeBody(bool challengeCompleteBool) {
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
                                ValueListenableBuilder<String>(
                                    valueListenable: _currentPuzzleImg,
                                    builder: (context, value, _) {
                                      if (value.isNotEmpty) {
                                        return PuzzlePage(
                                          image: Image.network(value),
                                          constraints: constraints,
                                          completeCallback:
                                              completePuzzleCallback,
                                        );
                                      } else {
                                        return LoadingWidget();
                                      }
                                    })
/*                                FutureBuilder<String>(
                                    future: currentPemit,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data != null &&
                                            OpenDayQRScanService.isCompleteAll(
                                                snapshot.data!
                                                    .locationPhotoLink!)) {
                                          _completedAllPuzzles();
                                        }
                                        if (OpenDayQRScanService.isError(
                                            snapshot
                                                .data!.locationPhotoLink!)) {
                                          return buildErrorWidget();
                                        }
                                        currentPuzzleImage = Image.network(
                                            snapshot.data!.locationPhotoLink!);

                                        return PuzzlePage(
                                          image: currentPuzzleImage!,
                                          constraints: constraints,
                                          completeCallback:
                                              completePuzzleCallback,
                                        );
                                      } else if (snapshot.hasError) {
                                        return buildErrorWidget();
                                      } else {
                                        return const LoadingWidget();
                                      }
                                    })*/
                                ,
                                IscteConfetti(
                                    confettiController: _confettiController)
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    QRScanPageOpenDay(
                      changeImage: changeCurrentImage,
                      completedAllPuzzle: _completedAllPuzzles,
                    ),
                  ],
                ),
    );
  }

  GestureDetector buildErrorWidget() {
    return GestureDetector(
      onTap: () {
        rerfeshPermit();
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
              child: Text('Ocorreu um erro a descarregar os dados'),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'Tocar aqui para recarregar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
