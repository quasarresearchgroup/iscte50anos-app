import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/puzzle_page.dart';
import 'package:iscte_spots/pages/scanPage/openday_qr_scan_page.dart';
import 'package:iscte_spots/services/openday/openday_qr_scan_service.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer_openday.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:iscte_spots/widgets/util/overlays.dart';
import 'package:logger/logger.dart';

import '../../services/openday/openday_notification_service.dart';

class HomeOpenDay extends StatefulWidget {
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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Image? currentPuzzleImage;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(initialIndex: widget.puzzleIndex, length: 2, vsync: this);
    setState(() {
      currentPuzzleImage = widget.originalImage;
    });
    initFunc();
  }

  void initFunc() async {
    setState(() {
      _loading = true;
    });
    String currentPemit = await OpenDayQRScanService.spotRequest();
    _changeCurrentImage(currentPemit);
    setState(() {
      _loading = false;
    });
  }

  void _changeCurrentImage(String imageLink) {
    widget._logger.d("changin imag: $imageLink");
    if (imageLink == OpenDayQRScanService.generalError) {
      OpenDayNotificationService.showErrorOverlay(context);
      widget._logger.d("generalError : $imageLink");
    } else if (imageLink == OpenDayQRScanService.loginError) {
      OpenDayNotificationService.showLoginErrorOverlay(context);
      widget._logger.d("loginError : $imageLink");
    } else if (imageLink == OpenDayQRScanService.wrongSpotError) {
      OpenDayNotificationService.showWrongSpotErrorOverlay(context);
      widget._logger.d("wrongSpotError : $imageLink");
    } else if (imageLink == OpenDayQRScanService.alreadyVisitedError) {
      OpenDayNotificationService.showAlreadeyVisitedOverlay(context);
      widget._logger.d("wrongSpotError : $imageLink");
    } else if (imageLink == OpenDayQRScanService.allVisited) {
      OpenDayNotificationService.showAllVisitedOverlay(context);
      widget._logger.d("wrongSpotError : $imageLink");
    } else if (imageLink == OpenDayQRScanService.invalidQRError) {
      OpenDayNotificationService.showInvalidErrorOverlay(context);
      widget._logger.d("wrongSpotError : $imageLink");
    } else if (imageLink == OpenDayQRScanService.disabledQRError) {
      OpenDayNotificationService.showDisabledErrorOverlay(context);
      widget._logger.d("wrongSpotError : $imageLink");
    } else {
      setState(() {
        currentPuzzleImage = Image.network(imageLink);
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
      bottomNavigationBar: MyBottomBar(
        tabController: _tabController,
        initialIndex: 0,
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          _loading
              ? const LoadingWidget()
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
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
    );
  }
}