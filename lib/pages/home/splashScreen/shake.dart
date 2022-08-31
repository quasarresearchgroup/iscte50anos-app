import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:iscte_spots/pages/home/splashScreen/moving_widget.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

/*
class Shaker extends StatefulWidget {
  Shaker({Key? key}) : super(key: key);
  static const pageRoute = "/shake";

  @override
  State<Shaker> createState() => _ShakerState();

  final Logger _logger = Logger();
  final FlickrIsctePhotoService flickrService = FlickrIsctePhotoService();
}

class _ShakerState extends State<Shaker> {
  late StreamSubscription<String> _streamSubscription;
  List<Image> images = [Image.asset('Resources/Img/Campus/campus-iscte-3.jpg')];

  Image currentPuzzleImage =
      Image.asset('Resources/Img/Campus/campus-iscte-3.jpg');
  @override
  void initState() {
    super.initState();
    setupURLStream();
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  void setupURLStream() {
    _streamSubscription = widget.flickrService.stream.listen((String event) {
      final Image image = Image.network(event);
      if (!images.contains(image)) {
        setState(() {
          images.add(image);
        });
      } else {
        widget._logger.d("duplicated photo entry: $event");
      }
    }, onError: (error) {
      widget._logger.d(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Title(
              color: Colors.black,
              child: Text(AppLocalizations.of(context)!.shakerScreen)),
        ),
        floatingActionButton: FloatingActionButton(
          child: const FaIcon(FontAwesomeIcons.rotateRight),
          onPressed: () {
            if (images.isEmpty) {
              widget.flickrService.fetch();
            } else {
              setState(() {
                currentPuzzleImage = images[Random().nextInt(images.length)];
              });
            }
          },
        ),
        body: GravityPlane(
          image: currentPuzzleImage,
        ));
  }
}
*/
class GravityPlane extends StatefulWidget {
  GravityPlane({Key? key, required this.image}) : super(key: key);
  final Logger _logger = Logger();
  final Image image;
  final int rows = 7;
  final int cols = 7;

  @override
  _GravityPlaneState createState() => _GravityPlaneState();
}

class _GravityPlaneState extends State<GravityPlane> {
  Future<List<MovingPiece>>? pieces;
  late int lastDeltaTime;

  Future<Size>? imageSize;

  @override
  void initState() {
    super.initState();
    imageSize = ImageManipulation.getImageSize(widget.image);
  }

  @override
  void didUpdateWidget(GravityPlane oldWidget) {
    if (oldWidget.image != widget.image) {
      widget._logger.d("changing image");
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  void bringToTop(MovingPiece widget) {
    setState(() {
      pieces?.then((value) {
        value.remove(widget);
        value.add(widget);
      });
    });
  }

// when a piece reaches its final position, it will be sent to the back of the stack to not get in the way of other, still movable, pieces
  void sendToBack(MovingPiece widget) {
    setState(() {
      pieces?.then((value) {
        value.remove(widget);
        value.insert(0, widget);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        pieces = ImageManipulation.splitImageMovableWidget(
          image: widget.image,
          bringToTop: bringToTop,
          sendToBack: sendToBack,
          rows: widget.rows,
          cols: widget.cols,
          constraints: constraints,
        );

        return FutureBuilder(
            future: pieces,
            builder:
                (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
              if (snapshot.hasData) {
                //remove native splash screen is here to allow the GravityPlane to fully load behind the native splash screen
                FlutterNativeSplash.remove();
                return Stack(
                  children: snapshot.data!,
                );
              } else {
                return const Center(child: LoadingWidget());
              }
            });
      },
    );
  }
}
