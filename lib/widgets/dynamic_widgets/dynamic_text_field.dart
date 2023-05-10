import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';

class DynamicTextField extends StatelessWidget {
  TextStyle? style;
  Widget? prefix;
  Widget? suffix;
  String? placeholder;
  TextStyle? placeholderStyle;
  TextEditingController? controller;

  DynamicTextField({
    Key? key,
    this.prefix,
    this.suffix,
    this.placeholder,
    this.style,
    this.controller,
    this.placeholderStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (PlatformService.instance.isIos)
        ? CupertinoTextField(
            prefix: prefix,
            suffix: suffix,
            placeholder: placeholder,
            style: style,
            controller: controller,
            placeholderStyle: placeholderStyle,
            decoration: const BoxDecoration(color: Colors.transparent),
            textAlignVertical: TextAlignVertical.center,
          )
        : TextField(
            style: style,
            controller: controller,
            decoration: InputDecoration(
              prefix: prefix,
              suffix: suffix,
              hintText: placeholder,
              hintStyle: placeholderStyle,
            ),
          );
  }
}
