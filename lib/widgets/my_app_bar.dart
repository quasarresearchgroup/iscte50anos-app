import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:logger/logger.dart';

class MyAppBar extends StatefulWidget with PreferredSizeWidget {
  MyAppBar({
    Key? key,
    this.trailing,
    this.title,
    this.leading,
    this.middle,
    this.automaticallyImplyLeading = false,
  }) : super(key: key);
  final Logger _logger = Logger();

  Widget? trailing;
  String? title;
  Widget? leading;
  Widget? middle;
  bool automaticallyImplyLeading;

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  void initState() {
    super.initState();
    assert(widget.middle == null && widget.title != null ||
        widget.middle != null && widget.title == null);
  }

  @override
  Widget build(BuildContext context) {
    var middle = widget.title != null
        ? Text(
            widget.title!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white),
          )
        : widget.middle;
    return !PlatformService.instance.isIos
        ? AppBar(
            automaticallyImplyLeading: widget.automaticallyImplyLeading,
            leading: widget.leading,
            title: middle
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
            backgroundColor: IscteTheme.iscteColor,
            automaticallyImplyMiddle: widget.automaticallyImplyLeading,
            padding: EdgeInsetsDirectional.zero,
            automaticallyImplyLeading: false,
            leading: widget.leading,
            middle: middle,
            trailing: widget.trailing,
          );
  }
}
