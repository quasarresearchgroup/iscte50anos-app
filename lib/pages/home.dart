import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/puzzle_piece.dart';
import 'package:iscte_spots/pages/puzzle_page.dart';
import 'package:iscte_spots/pages/scanPage/qr_scan_page.dart';
import 'package:iscte_spots/services/registration_service.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:iscte_spots/widgets/util/overlays.dart';
import 'package:logger/logger.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/flickr/flickr_iscte_photos.dart';

class Home extends StatefulWidget {
  Home({
    Key? key,
  }) : super(key: key);
  static const pageRoute = "/";
  final Logger _logger = Logger();
  final int shakerTimeThreshhold = 1000;
  final int shakerThreshhold = 5;
  @override
  _HomeState createState() => _HomeState();

  final Image originalImage =
      Image.asset('Resources/Img/Campus/campus-iscte-3.jpg');
  final FlickrIsctePhotoService flickrService = FlickrIsctePhotoService();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final Future<SharedPreferences> sharedPreferences =
      SharedPreferences.getInstance();
  List<Image> notViewedImages = [
    Image.asset('Resources/Img/Campus/campus-iscte-3.jpg'),
    Image.asset('Resources/Img/Campus/AulaISCTE_3.jpg'),
  ];
  List<String> fetchedImagesURL = [];
  List<Image> viewedImages = [];
  Image? currentPuzzleImage;
  late TabController tabController;

  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  int lastShake = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    initAsyncMethod();
  }

  void initAsyncMethod() async {
    await setupSharedPrefs();
    try {
      if (fetchedImagesURL.isEmpty) {
        fetchFromFlickr();
      }
    } catch (e) {
      widget._logger.d("Error on Fetch; Resetting image;");
    }
    currentPuzzleImage = notViewedImages.first;
    setupURLStream();
    setupMotionSensors();
  }

  Future<void> setupSharedPrefs() async {
    SharedPreferences prefs = await sharedPreferences;
    List<String> prefsFetchedImagesURL =
        prefs.getStringList('fetchedImagesURL') ?? [];
    for (String entry in prefsFetchedImagesURL) {
      if (!fetchedImagesURL.contains(entry)) {
        fetchedImagesURL.add(entry);
        notViewedImages.add(Image.network(entry));
      }
    }
    setState(() {});
  }

  void setupURLStream() {
    StreamSubscription<String> streamSubscription;
    streamSubscription =
        widget.flickrService.stream.listen((String event) async {
      if (!fetchedImagesURL.contains(event)) {
        setState(() {
          notViewedImages.add(Image.network(event));
        });
        fetchedImagesURL.add(event);
        SharedPreferences prefs = await sharedPreferences;
        prefs.setStringList('fetchedImagesURL', fetchedImagesURL);
      } else {
        widget._logger.d("duplicated photo entry: $event");
      }
    }, onError: (error) {
      widget._logger.d(error);
      showNetworkErrorOverlay(context, widget._logger);
    });
    _streamSubscriptions.add(streamSubscription);
  }

  void setupMotionSensors() {
    motionSensors.absoluteOrientationUpdateInterval =
        Duration.microsecondsPerSecond ~/ (0.25);
    _streamSubscriptions.add(
        motionSensors.userAccelerometer.listen((UserAccelerometerEvent event) {
      if ((event.x > widget.shakerThreshhold ||
          event.x < -widget.shakerThreshhold ||
          event.y > widget.shakerThreshhold ||
          event.y < -widget.shakerThreshhold ||
          event.z > widget.shakerThreshhold ||
          event.z < -widget.shakerThreshhold)) {
        randomizeChosenImage();
        widget._logger.d("Detected Shake");
      }
    }));
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
      widget._logger.d("canceled sensor subscription");
    }
  }

  void randomizeChosenImage() {
    int currTime = DateTime.now().millisecondsSinceEpoch;
    if ((currTime - lastShake) > widget.shakerTimeThreshhold) {
      lastShake = currTime;

      if (notViewedImages.length < 10) {
        fetchFromFlickr();
      }
      Image newImage;
      if (notViewedImages.isEmpty) {
        newImage = viewedImages[Random().nextInt(viewedImages.length)];
      } else {
        newImage = notViewedImages[Random().nextInt(notViewedImages.length)];
        notViewedImages.remove(newImage);
        viewedImages.add(newImage);
      }
      setState(() {
        currentPuzzleImage = newImage;
      });
      widget._logger.d("Randomized puzzle Image");
    } else {
      widget._logger.d("Woah slow down there");
    }
  }

  Future<void> fetchFromFlickr() async {
    try {
      widget.flickrService.fetch();
    } on SocketException catch (_) {
      showNetworkErrorOverlay(context, widget._logger);
    }
  }

  void fetchAndRandomize() async {
    try {
      setState(() {
        currentPuzzleImage = null;
      });
      fetchFromFlickr();
      randomizeChosenImage();
    } catch (e) {
      widget._logger.d("Error on Fetch; Resetting image;");
      setState(() {
        currentPuzzleImage = widget.originalImage;
      });
    }
  }

  void removePuzzlePieces(BuildContext context) {
    setState(() {
      DatabasePuzzlePieceTable.removeALL();
      widget._logger.d("Removed all Puzzle Pieces");
      Navigator.popAndPushNamed(context, PuzzlePage.pageRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: const NavigationDrawer(),
      appBar: AppBar(
        title: Title(
            color: Colors.black,
            child: Text(AppLocalizations.of(context)!.appName)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: IconButton(
                    icon: const FaIcon(FontAwesomeIcons.circleQuestion),
                    onPressed: () => showHelpOverlay(
                        context, currentPuzzleImage!, widget._logger))),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Text(
              (notViewedImages.length + 1).toString(),
              textScaleFactor: 1.5,
            )),
          )
        ],
      ),
      bottomNavigationBar: MyBottomBar(
        tabController: tabController,
        initialIndex: 0,
      ),
      floatingActionButton: HomeDial(
        removePuzzlePieces: removePuzzlePieces,
        randomizeChosenImage: randomizeChosenImage,
        fetchAndRandomize: fetchAndRandomize,
        notViewedImages: notViewedImages,
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
          QRScanPage()
        ],
      ),
    );
  }
}

class HomeDial extends StatelessWidget {
  HomeDial({
    Key? key,
    required this.removePuzzlePieces,
    required this.randomizeChosenImage,
    required this.fetchAndRandomize,
    required this.notViewedImages,
  }) : super(key: key);
  final Logger _logger = Logger();
  final Function removePuzzlePieces;
  final Function randomizeChosenImage;
  final Function fetchAndRandomize;
  final List<Image> notViewedImages;

  @override
  Widget build(BuildContext context) {
    var isDialOpen = ValueNotifier<bool>(false);

    return SpeedDial(
      backgroundColor: Theme.of(context).primaryColor,
      icon: Icons.add,
      iconTheme: IconThemeData(color: Theme.of(context).selectedRowColor),
      activeIcon: Icons.close,
      openCloseDial: isDialOpen,
      elevation: 8.0,
      children: [
        SpeedDialChild(
            child: const FaIcon(FontAwesomeIcons.helmetSafety),
            backgroundColor: Colors.deepPurpleAccent,
            label: 'getAll',
            onTap: () async {
              List<PuzzlePiece> all = await DatabasePuzzlePieceTable.getAll();
              String join = all
                  .map((PuzzlePiece e) =>
                      "[pos:${e.row},${e.column},top:${e.top},left:${e.left}]")
                  .toList()
                  .join("\n");
              _logger.d("Stored Puzzle Pieces:\n$join");
            }),
        SpeedDialChild(
            child: const FaIcon(FontAwesomeIcons.trash),
            backgroundColor: Colors.red,
            label: 'Delete',
            onTap: () {
              removePuzzlePieces(context);
            }),
        SpeedDialChild(
            child: const FaIcon(FontAwesomeIcons.trash),
            backgroundColor: Colors.blue,
            label: 'Delete api_key',
            onTap: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              String? apiKey;
              apiKey = await prefs.getString(
                  RegistrationService.backendApiKeySharedPrefsString);
              _logger.d("api_key before removal: $apiKey");
              await prefs
                  .remove(RegistrationService.backendApiKeySharedPrefsString);
              apiKey = await prefs.getString(
                  RegistrationService.backendApiKeySharedPrefsString);
              _logger.d("deleted api_key, current value: $apiKey");
            }),
        SpeedDialChild(
          child: const FaIcon(FontAwesomeIcons.rotateRight),
          backgroundColor: Colors.green,
          label: 'Refresh',
          onTap: () async {
            _logger.d("Pressed refresh");
            if (notViewedImages.isNotEmpty) {
              randomizeChosenImage();
            } else {
              fetchAndRandomize();
            }
          },
        ),
      ],
    );
  }
}
