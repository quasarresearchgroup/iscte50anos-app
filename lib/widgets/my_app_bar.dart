import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:logger/logger.dart';

class MyAppBar extends StatefulWidget with PreferredSizeWidget {
  MyAppBar({Key? key, this.trailing, this.middle, this.leading})
      : super(key: key);
  final Logger _logger = Logger();

  Widget? trailing;
  Widget? middle;
  Widget? leading;

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !PlatformService.instance.isIos
        ? AppBar(
            title: Text("Puzzle")
            /*FutureBuilder<SpotRequest>(
                future: currentPemit,
                builder: (BuildContext context,
                    AsyncSnapshot<SpotRequest> snapshot) {
                  if (snapshot.hasData) {
                    String spots;
                    SpotRequest spotRequest = snapshot.data as SpotRequest;
                    if (spotRequest.spotNumber != null) {
                      widget._logger.d(spotRequest);
                      currentPuzzleNumber = spotRequest.spotNumber;
                      spots = "nº " + currentPuzzleNumber!.toString();
                    } else {
                      spots = "";
                    }
                    return Text("Puzzle $spots");
                  } else {
                    return const LoadingWidget();
                  }
                })*/
            ,
            actions: widget.trailing != null ? [widget.trailing!] : null,
          )
        : CupertinoNavigationBar(
            middle: Text("Puzzle"),
            trailing: widget.trailing,
          );
  }
}
