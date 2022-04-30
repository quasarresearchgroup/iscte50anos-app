import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_page.dart';
import 'package:iscte_spots/pages/home/scanPage/openday_qr_scan_page.dart';
import 'package:iscte_spots/pages/home/sucess_scan_widget.dart';
import 'package:iscte_spots/services/openday/openday_qr_scan_service.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer_openday.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:iscte_spots/widgets/util/overlays.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

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
  bool _loading = false;
  bool _showSucessPage = false;
  bool _completedAllPuzzlesBool = false;
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

    initFunc();
  }

  @override
  void dispose() {
    super.dispose();
    _confettiController.dispose();
    _lottieController.dispose();
  }

  void initFunc() async {
    setState(() {
      _loading = true;
    });
    await _setupInitialImage();
    bool completedAllPuzzlesState =
        await SharedPrefsService.getCompletedAllPuzzles();
    setState(() {
      _completedAllPuzzlesBool = completedAllPuzzlesState;
      _loading = false;
    });
  }

  Future<void> _setupInitialImage() async {
    String currentPemit = await OpenDayQRScanService.spotRequest();
    setState(() {
      currentPuzzleImage = Image.network(currentPemit);
    });
  }

  void _changeCurrentImage(String imageLink) async {
    widget._logger.d("changin imag: $imageLink");
    if (!OpenDayQRScanService.isError(imageLink)) {
      DatabasePuzzlePieceTable.removeALL();
      setState(() {
        currentPuzzleImage = Image.network(imageLink);
        _showSucessPage = true;
      });
      _tabController.animateTo(widget.puzzleIndex);
    }
  }

  void _completedAllPuzzles() async {
    bool _completedAllPuzzleState =
        await SharedPrefsService.storeCompletedAllPuzzles();
    setState(() {
      _completedAllPuzzlesBool = _completedAllPuzzleState;
    });
    _tabController.animateTo(widget.puzzleIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: const NavigationDrawerOpenDay(),
      appBar: AppBar(
        title: const Text("OpenDay Home"),
        actions: [
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
      floatingActionButton: FloatingActionButton(onPressed: () {
        widget._logger.i("playing confettis");
        setState(() {
          _showSucessPage = true;
        });
      }),
      bottomNavigationBar: !_completedAllPuzzlesBool
          ? MyBottomBar(
              tabController: _tabController,
              initialIndex: 0,
            )
          : Container(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _completedAllPuzzlesBool
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
                      _loading || currentPuzzleImage == null
                          ? const LoadingWidget()
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: LayoutBuilder(builder:
                                    (BuildContext context,
                                        BoxConstraints constraints) {
                                  return (currentPuzzleImage != null)
                                      ? PuzzlePage(
                                          image: currentPuzzleImage!,
                                          constraints: constraints,
                                        )
                                      : const LoadingWidget();
                                }),
                              ),
                            ),
                      QRScanPageOpenDay(
                        changeImage: _changeCurrentImage,
                        completedAllPuzzle: _completedAllPuzzles,
                      )
                    ],
                  ),
      ),
    );
  }
}

class CompletedChallengeWidget extends StatefulWidget {
  const CompletedChallengeWidget({Key? key}) : super(key: key);

  @override
  State<CompletedChallengeWidget> createState() =>
      _CompletedChallengeWidgetState();
}

class _CompletedChallengeWidgetState extends State<CompletedChallengeWidget> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _loading
          ? LoadingWidget()
          : Lottie.network(
              "https://assets9.lottiefiles.com/packages/lf20_tjbhujef.json",
              onLoaded: (LottieComposition composition) {
              setState(() {
                _loading = false;
              });
            }),
    );
  }
}
