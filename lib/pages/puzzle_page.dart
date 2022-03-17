import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:logger/logger.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../services/flickr.dart';

class PuzzlePage extends StatefulWidget {
  PuzzlePage({Key? key, required this.image}) : super(key: key);
  final Logger _logger = Logger();
  static const pageRoute = "/puzzle";

  final int rows = 10;
  final int cols = 10;
  Image image;

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
  fetchFromFlickr() => createState().fetchFromFlickr();
  randomizeImage() {
    _PuzzlePageState state = createState();
    state.urls?.then((value) {
      state.randomizeImage(value);
      state.generatePieces(image);
    });
  }

  fetchAndRandomizeImage() async {
    _PuzzlePageState state = createState();
    state.fetchFromFlickr();
    state.urls?.then((value) {
      state.randomizeImage(value);
      state.generatePieces(image);
    });
  }
}

class _PuzzlePageState extends State<PuzzlePage> {
  List<Widget> pieces = [];
  //make this a future so that previous operations get queued and complete only when this has values
  Future<List<String>>? urls;
  final shakerThreshhold = 8;
  final FlickrService flickrService = FlickrService();

  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  final Vector3 _userAaccelerometer = Vector3.zero();

  @override
  void initState() {
    super.initState();
    fetchFromFlickr();
    generatePieces(widget.image);
    motionSensors.absoluteOrientationUpdateInterval =
        Duration.microsecondsPerSecond ~/ (0.25);
    _streamSubscriptions.add(
        motionSensors.userAccelerometer.listen((UserAccelerometerEvent event) {
      _userAaccelerometer.setValues(event.x, event.y, event.z);
      if (event.x > shakerThreshhold ||
          event.x < -shakerThreshhold ||
          event.y > shakerThreshhold ||
          event.y < -shakerThreshhold ||
          event.z > shakerThreshhold ||
          event.z < -shakerThreshhold) {
        urls?.then((value) {
          randomizeImage(value);
          generatePieces(widget.image);
        });
      }
    }));
    //changeImage();
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
    String randomurl = value2[Random().nextInt(value2.length)];
    widget.image = (Image.network(randomurl));
  }

  void fetchFromFlickr() async {
    urls = flickrService.getImageURLS();
    return;
  }

  void generatePieces(Image img) async {
    pieces = await ImageManipulation.splitImagePuzzlePiece(
      image: img,
      bringToTop: bringToTop,
      sendToBack: sendToBack,
      rows: widget.rows,
      cols: widget.cols,
    );
    setState(() {});
  }

  @override
  void didUpdateWidget(PuzzlePage oldWidget) {
    if (oldWidget.image != widget.image) {
      widget._logger.d("changing image");
      generatePieces(widget.image);
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  /*
  void changeImage(
      {Image img = const Image(
          image: AssetImage('Resources/Img/Campus/campus-iscte-3.jpg'))}) {
    _image = img;
    ImageManipulation.splitImagePuzzlePiece(
      image: _image!,
      bringToTop: bringToTop,
      sendToBack: sendToBack,
      rows: widget.rows,
      cols: widget.cols,
    ).then((value) {
      setState(() {
        pieces = value;
      });
    });
  }
*/

  @override
  Widget build(BuildContext context) {
    return Stack(children: pieces);
  }

  void bringToTop(Widget widget) {
    setState(() {
      pieces.remove(widget);
      pieces.add(widget);
    });
  }

// when a piece reaches its final position, it will be sent to the back of the stack to not get in the way of other, still movable, pieces
  void sendToBack(Widget widget) {
    setState(() {
      pieces.remove(widget);
      pieces.insert(0, widget);
    });
  }
}
