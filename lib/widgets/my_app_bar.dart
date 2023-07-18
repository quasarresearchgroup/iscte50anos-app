import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({
    Key? key,
    this.trailing,
    this.title,
    this.leading,
    this.middle,
    this.automaticallyImplyLeading = false,
  }) : super(key: key);

  final Widget? trailing;
  final String? title;
  final Widget? leading;
  final Widget? middle;
  final bool automaticallyImplyLeading;

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
    Widget? middle = widget.title != null
        ? Text(
            widget.title!,
            overflow: TextOverflow.fade,
            style: PlatformService.instance.isIos
                ? const TextStyle(color: IscteTheme.iscteColor)
                : Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: IscteTheme.iscteColor,
                    ),
          )
        : widget.middle;
    return !PlatformService.instance.isIos
        ? AppBar(
            leadingWidth: 100,
            titleSpacing: 0,
            automaticallyImplyLeading: widget.automaticallyImplyLeading,
            iconTheme: Theme.of(context)
                .iconTheme
                .copyWith(color: IscteTheme.iscteColor),
            actionsIconTheme: Theme.of(context)
                .iconTheme
                .copyWith(color: IscteTheme.iscteColor),
            leading: widget.leading ?? const DynamicBackIconButton(),
            title: middle,
            actions: widget.trailing != null ? [widget.trailing!] : null,
          )
        : CupertinoNavigationBar(
            //backgroundColor: IscteTheme.iscteColor,
            automaticallyImplyMiddle: widget.automaticallyImplyLeading,
            padding: EdgeInsetsDirectional.zero,
            automaticallyImplyLeading: false,
            leading: widget.leading ?? const DynamicBackIconButton(),
            middle: middle,
            trailing: widget.trailing,
          );
  }
}
