import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/puzzle_page.dart';
import 'package:iscte_spots/pages/scanPage/openday_qr_scan_page.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:iscte_spots/widgets/util/overlays.dart';
import 'package:logger/logger.dart';

class HomeOpenDay extends StatefulWidget {
  HomeOpenDay({Key? key}) : super(key: key);
  final Logger _logger = Logger();

  final Image originalImage =
      Image.asset('Resources/Img/Campus/campus-iscte-3.jpg');

  @override
  State<HomeOpenDay> createState() => _HomeOpenDayState();
}

class _HomeOpenDayState extends State<HomeOpenDay>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  Image? currentPuzzleImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    setState(() {
      currentPuzzleImage = widget.originalImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: const NavigationDrawer(),
      appBar: AppBar(
        title: Text("openDay Home"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: IconButton(
                    icon: const FaIcon(FontAwesomeIcons.circleQuestion),
                    onPressed: () => showHelpOverlay(
                        context, currentPuzzleImage!, widget._logger))),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomBar(
        tabController: tabController,
        initialIndex: 0,
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return (currentPuzzleImage != null)
                    ? PuzzlePage(
                        image: currentPuzzleImage!,
                        constraints: constraints,
                      )
                    : const LoadingWidget();
              }),
            ),
          ),
          QRScanPageOpenDay()
        ],
      ),
    );
  }
}
