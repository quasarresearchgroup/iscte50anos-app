import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/pages/register/registration_error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

import '../../widgets/util/iscte_theme.dart';

class AccountRegisterForm extends StatefulWidget {
  const AccountRegisterForm({
    Key? key,
    required this.userNameController,
    required this.nameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmationController,
    required this.formKey,
    required this.errorCode,
  }) : super(key: key);

  final TextEditingController userNameController;
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;
  final GlobalKey<FormState> formKey;
  final RegistrationError errorCode;
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

  List<TextFormField> generateFormFields() {
    AutovalidateMode autovalidateMode = AutovalidateMode.always;
    return [
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.userNameController,
        decoration: IscteTheme.buildInputDecoration(hint: "userName"),
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (widget.errorCode == RegistrationError.existingUsername) {
            return 'Username already exists';
          } else if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.nameController,
        decoration: IscteTheme.buildInputDecoration(hint: "name"),
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.lastNameController,
        decoration: IscteTheme.buildInputDecoration(hint: "last name"),
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.emailController,
        decoration: IscteTheme.buildInputDecoration(hint: "email"),
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (widget.errorCode == RegistrationError.existingEmail) {
            return 'Email already exists';
          } else if (value == null || value.isEmpty) {
            return 'Please enter some text';
          } else if (!RegExp(r"\S+[@]\S+\.\S+").hasMatch(value) ||
              widget.errorCode == RegistrationError.invalidEmail) {
            //RegExp Explanation (checks for @ followed by any number of non whitespace character followed by a dot "." and then followed by any number of non whitespace characters)
            //https://regex101.com/r/TZDJmb/1
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.passwordController,
        obscureText: true,
        decoration: IscteTheme.buildInputDecoration(hint: "password"),
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (widget.errorCode == RegistrationError.passwordNotMatch) {
            return 'Passwords must match';
          } else if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.passwordConfirmationController,
        obscureText: true,
        decoration: IscteTheme.buildInputDecoration(hint: "confirm password"),
        textInputAction: TextInputAction.done,
        validator: (value) {
          if (widget.errorCode == RegistrationError.passwordNotMatch) {
            return 'Passwords must match';
          } else if (value == null || value.isEmpty) {
            return 'Please enter some text';
          } else if (value != widget.passwordController.text) {
            return 'Passwords must match';
          }
          return null;
        },
      ),
    ];
  }
}
