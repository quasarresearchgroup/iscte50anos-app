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
  final int shakerTimeThreshhold = 1000;
  final int shakerThreshhold = 5;
  @override
  _HomeState createState() => _HomeState();
  final Image originalImage =
      Image.asset('Resources/Img/Campus/campus-iscte-3.jpg');
}

class _HomeState extends State<Home> {
  List<String> urls = [];
  Image? currentPuzzleImage;

  final FlickrIsctePhotoService flickrService = FlickrIsctePhotoService();

  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  int lastShake = 0;

  @override
  void initState() {
    super.initState();
    currentPuzzleImage = widget.originalImage;
    try {
      fetchFromFlickr();
    } catch (e) {
      widget._logger.d("Error on Fetch; Resetting image;");
      /*setState(() {
      currentPuzzleImage = widget.originalImage;

      });*/
    }
    setupMotionSensors();
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
        int currTime = DateTime.now().millisecondsSinceEpoch;
        if ((lastShake - currTime) > widget.shakerTimeThreshhold) {
          lastShake = currTime;
          randomizeImage(urls);
          widget._logger.d("Detected Shake");
        } else {
          widget._logger.d("Woah slow down there");
        }
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

  void randomizeImage(List<String> value2) {
    assert(value2.isNotEmpty);
    setState(() {
      currentPuzzleImage = null;
    });
    String randomurl =
        value2[Random().nextInt(value2.isEmpty ? 0 : value2.length)];
    setState(() {
      currentPuzzleImage = Image.network(randomurl);
    });

    widget._logger.d("Randomized puzzle Image");
  }

  Future<List<String>> fetchFromFlickr() async {
    List<String> imageURLS = await flickrService.fetch();
    urls = imageURLS;
    widget._logger.d("Fetched image URLS from flickr");
    return imageURLS;
  }

  void fetchAndRandomize() async {
    try {
      setState(() {
        currentPuzzleImage = null;
      });
      List<String> list = await fetchFromFlickr();
      randomizeImage(list);
    } catch (e) {
      widget._logger.d("Error on Fetch; Resetting image;");
      setState(() {
        currentPuzzleImage = widget.originalImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    widget._logger.d("rebuild Home");
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
          ),
          bottomNavigationBar: const MyBottomBar(selectedIndex: 0),
          floatingActionButton: FloatingActionButton(
            child: const FaIcon(FontAwesomeIcons.redoAlt),
            onPressed: () async {
              widget._logger.d("Pressed refresh");
              if (urls.isNotEmpty) {
                randomizeImage(urls);
              } else {
                fetchAndRandomize();
              }
            },
          ),
          body: (currentPuzzleImage != null)
              ? PuzzlePage(image: currentPuzzleImage!)
              : const LoadingWidget(),
        ));
  }
}
