import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
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
            style: const TextStyle(color: Colors.white),
          )
        : widget.middle;
    return !PlatformService.instance.isIos
        ? AppBar(
            leadingWidth: 100,
            automaticallyImplyLeading: widget.automaticallyImplyLeading,
            leading: widget.leading ?? const DynamicBackIconButton(),
            title: middle,
            actions: widget.trailing != null ? [widget.trailing!] : null,
          )
        : CupertinoNavigationBar(
            backgroundColor: IscteTheme.iscteColor,
            automaticallyImplyMiddle: widget.automaticallyImplyLeading,
            padding: EdgeInsetsDirectional.zero,
            automaticallyImplyLeading: false,
            leading: widget.leading ?? const DynamicBackIconButton(),
            middle: middle,
            trailing: widget.trailing,
          );
  }
}
