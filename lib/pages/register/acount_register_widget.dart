import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

import '../../widgets/util/iscte_theme.dart';

class AccountRegisterForm extends StatefulWidget {
  AccountRegisterForm({
    Key? key,
    required this.userNameController,
    required this.nameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmationController,
    required this.formKey,
  }) : super(key: key);

  final TextEditingController userNameController;
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;
  final GlobalKey<FormState> formKey;
  @override
  State<AccountRegisterForm> createState() => _AccountRegisterFormState();
}

class _AccountRegisterFormState extends State<AccountRegisterForm> {
  @override
  Widget build(BuildContext context) {
    List<TextFormField> formFields = generateFormFields();

    return Form(
      key: widget.formKey,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ...formFields,
      ]),
    );
  }

  InputDecoration buildInputDecoration({required String hint}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.only(left: 25, right: 25),
      border: UnderlineInputBorder(
          //border: OutlineInputBorder(
          borderRadius: BorderRadius.all(IscteTheme.appbarRadius)),
      hintText: hint,
    );
  }

  List<TextFormField> generateFormFields() => [
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.userNameController,
          decoration: buildInputDecoration(hint: "userName"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.nameController,
          decoration: buildInputDecoration(hint: "name"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.lastNameController,
          decoration: buildInputDecoration(hint: "last name"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.emailController,
          decoration: buildInputDecoration(hint: "email"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            } else if (!RegExp(r"\S+[@]\S+\.").hasMatch(value)) {
              //RegExp Explanation (checks for @ followed by any non whitespace character followed by a dot ".")
              //https://regex101.com/r/07m7Gw/1
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.passwordController,
          obscureText: true,
          decoration: buildInputDecoration(hint: "password"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.passwordConfirmationController,
          obscureText: true,
          decoration: buildInputDecoration(hint: "confirm password"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            } else if (value != widget.passwordController.text) {
              return 'Passwords must match';
            }
            return null;
          },
        ),
      ];
}
