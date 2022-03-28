import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/puzzle_page.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';
import 'package:motion_sensors/motion_sensors.dart';

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
  List<Image> images = [
    Image.asset('Resources/Img/Campus/campus-iscte-3.jpg'),
    Image.asset('Resources/Img/Campus/AulaISCTE_3.jpg')
  ];
  Image? currentPuzzleImage;

  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  int lastShake = 0;

  @override
  void initState() {
    super.initState();
    try {
      fetchFromFlickr();
    } catch (e) {
      widget._logger.d("Error on Fetch; Resetting image;");
    }
    currentPuzzleImage = images.first;
    setupURLStream();
    setupMotionSensors();
  }

  void setupURLStream() {
    StreamSubscription<String> streamSubscription;
    streamSubscription = widget.flickrService.stream.listen((String event) {
      if (!images.contains(event)) {
        setState(() {
          images.add(Image.network(event));
        });
      } else {
        widget._logger.d("duplicated photo entry: $event");
      }
    }, onError: (error) {
      widget._logger.d(error);
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

      assert(images.isNotEmpty);
      setState(() {
        currentPuzzleImage =
            images[Random().nextInt(images.isEmpty ? 0 : images.length)];
      });
      widget._logger.d("Randomized puzzle Image");
    } else {
      widget._logger.d("Woah slow down there");
    }
  }

  Future<void> fetchFromFlickr() async {
    widget.flickrService.fetch();
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
                    child: Text(
                  (images.length + 1).toString(),
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
              if (images.isNotEmpty) {
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
}
