import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:iscte_spots/widgets/splashScreen/moving_widget.dart';
import 'package:logger/logger.dart';

import '../my_bottom_bar.dart';
import '../util/loading.dart';

class Shaker extends StatelessWidget {
  const Shaker({Key? key}) : super(key: key);
  static const pageRoute = "/shake";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, PageRoutes.home);
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
          body: GravityPlane()),
    );
  }
}

class GravityPlane extends StatefulWidget {
  int rows = 7;
  int cols = 7;

  GravityPlane({Key? key}) : super(key: key);
  final Logger _logger = Logger();
  @override
  _GravityPlaneState createState() => _GravityPlaneState();
}

class _GravityPlaneState extends State<GravityPlane> {
  Future<List<MovingPiece>>? pieces;
  late int lastDeltaTime;
  late Image _image;

  Future<Size>? imageSize;

  @override
  void initState() {
    super.initState();

    _image = const Image(
        image: AssetImage('Resources/Img/Campus/campus-iscte-3.jpg'));
    imageSize = ImageManipulation.getImageSize(_image);
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
          image: _image,
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
