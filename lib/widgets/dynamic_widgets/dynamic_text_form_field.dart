import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';

class DynamicTextFormField extends StatelessWidget {
  AutovalidateMode autovalidateMode;
  bool obscureText;
  TextAlignVertical? textAlignVertical;
  TextAlign textAlign;
  TextEditingController? controller;
  String? Function(String?)? validator;
  TextInputAction? textInputAction;
  TextStyle? style;

  DynamicTextFormField({
    Key? key,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.obscureText = false,
    this.textAlignVertical,
    this.textAlign = TextAlign.start,
    this.controller,
    this.validator,
    this.textInputAction,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (PlatformService.instance.isIos)
        ? CupertinoTextFormFieldRow(
            autovalidateMode: autovalidateMode,
            textAlignVertical: textAlignVertical,
            textAlign: textAlign,
            obscureText: obscureText,
            controller: controller,
            decoration: const BoxDecoration(),
            validator: validator,
            textInputAction: textInputAction,
            style: style,
          )
        : TextFormField(
            style: style,
            autovalidateMode: autovalidateMode,
            obscureText: obscureText,
            controller: controller,
            textAlignVertical: textAlignVertical,
            textAlign: textAlign,
            decoration: const InputDecoration(),
            validator: validator,
            textInputAction: textInputAction,
          );
  }
}
