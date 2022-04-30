import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_page.dart';
import 'package:iscte_spots/pages/home/scanPage/openday_qr_scan_page.dart';
import 'package:iscte_spots/services/openday/openday_qr_scan_service.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer_openday.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:iscte_spots/widgets/util/overlays.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

class HomeOpenDay extends StatefulWidget {
  static const pageRoute = "/homeOpenDay";

  HomeOpenDay({Key? key}) : super(key: key);
  final Logger _logger = Logger();

  final Image originalImage =
      Image.asset('Resources/Img/Campus/campus-iscte-3.jpg');
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
  bool _showCompletePage = false;
  late final ConfettiController _confettiController;
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(initialIndex: widget.puzzleIndex, length: 2, vsync: this);
    setState(() {
      currentPuzzleImage = widget.originalImage;
    });
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
              _showCompletePage = false;
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
    setState(() {
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
        _showCompletePage = true;
      });
      _tabController.animateTo(widget.puzzleIndex);
    }
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
          _showCompletePage = true;
        });
      }),
      bottomNavigationBar: MyBottomBar(
        tabController: _tabController,
        initialIndex: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showCompletePage
            ? lottieCompleteLoginBuilder()
            : TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  _loading
                      ? const LoadingWidget()
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: LayoutBuilder(builder: (BuildContext context,
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
                  QRScanPageOpenDay(changeImage: _changeCurrentImage)
                ],
              ),
      ),
    );
  }

  Widget lottieCompleteLoginBuilder() => Stack(
        children: [
          Center(
            child: Card(
              color: Colors.green.shade700,
              margin: const EdgeInsets.all(50.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(IscteTheme.appbarRadius)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.network(
                    "https://assets6.lottiefiles.com/packages/lf20_Vwcw5D.json",
                    //"https://assets4.lottiefiles.com/datafiles/hToYrgLpHl1u69x/data.json",
                    //width: MediaQuery.of(context).size.width * 0.5,
                    //height: MediaQuery.of(context).size.height * 0.5,
                    //fit: BoxFit.contain,
                    controller: _lottieController,
                    onLoaded: (LottieComposition composition) {
                      _lottieController.forward();
                      _confettiController.play();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text("Wow you found it!!"),
                        FaIcon(FontAwesomeIcons.faceSmile),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.1,
              colors: [
                IscteTheme.iscteColor,
                IscteTheme.iscteColor.withBlue(IscteTheme.iscteColor.blue + 50),
                IscteTheme.iscteColor.withBlue(IscteTheme.iscteColor.blue - 50),
                Colors.white,
              ],
            ),
          )
        ],
      );
}
