import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
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
      });
      await OpenDayNotificationService.showNewSpotFoundOverlay(context);
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
