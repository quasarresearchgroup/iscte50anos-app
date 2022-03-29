import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/puzzle_page.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:iscte_spots/widgets/util/overlays.dart';
import 'package:logger/logger.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/flickr_iscte_photos.dart';

class Home extends StatefulWidget {
  Home({
    Key? key,
  }) : super(key: key);
  static const pageRoute = "/";
  final Logger _logger = Logger();
  final int shakerTimeThreshhold = 0;
  final int shakerThreshhold = 5;
  @override
  _HomeState createState() => _HomeState();
  final Image originalImage =
      Image.asset('Resources/Img/Campus/campus-iscte-3.jpg');
  final FlickrIsctePhotoService flickrService = FlickrIsctePhotoService();
}

class _HomeState extends State<Home> {
  final Future<SharedPreferences> sharedPreferences =
      SharedPreferences.getInstance();
  List<Image> notViewedImages = [
    Image.asset('Resources/Img/Campus/campus-iscte-3.jpg'),
    Image.asset('Resources/Img/Campus/AulaISCTE_3.jpg')
  ];
  List<String> fetchedImagesURL = [];
  List<Image> viewedImages = [];
  Image? currentPuzzleImage;

  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  int lastShake = 0;

  @override
  void initState() {
    super.initState();

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

      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Scaffold(
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
                        onPressed: () =>
                            showHelpOverlay(context, currentPuzzleImage!))),
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
          bottomNavigationBar: const MyBottomBar(selectedIndex: 0),
          floatingActionButton: FloatingActionButton(
            child: const FaIcon(FontAwesomeIcons.redoAlt),
            onPressed: () async {
              widget._logger.d("Pressed refresh");
              if (notViewedImages.isNotEmpty) {
                randomizeChosenImage();
              } else {
                fetchAndRandomize();
              }
            },
          ),
          body: Center(
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
        ));
  }

  Future<void> showHelpOverlay(BuildContext context, Widget image) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
            top: 100,
            right: 10,
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: image)));
      },
      maintainState: true,
      opaque: false,
    );
    overlayState?.insert(overlayEntry);
    widget._logger.d("Inserted Help overlay");
    await Future.delayed(const Duration(seconds: 2));
    overlayEntry.remove();
    widget._logger.d("Removed Help overlay");
  }
}
