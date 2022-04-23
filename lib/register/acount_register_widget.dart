import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../widgets/util/iscte_theme.dart';

class AccountRegisterForm extends StatefulWidget {
  AccountRegisterForm({
    Key? key,
    required this.nameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
  }) : super(key: key);

  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  @override
  State<AccountRegisterForm> createState() => _AccountRegisterFormState();
}

class _AccountRegisterFormState extends State<AccountRegisterForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    List<TextFormField> formFields = generateFormFields();

    return Form(
      key: _formKey,
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
          controller: widget.emailController,
          decoration: buildInputDecoration(hint: "email"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
        TextFormField(
          controller: widget.passwordController,
          obscureText: true,
          decoration: buildInputDecoration(hint: "password"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            } else if (value.contains("@")) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ];
}
