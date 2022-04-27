import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/pages/auth/register/registration_error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

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
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction;
    return [
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.userNameController,
        decoration: IscteTheme.buildInputDecoration(
            hint: "userName",
            errorText: (widget.errorCode == RegistrationError.existingUsername)
                ? 'Username already exists'
                : null),
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
        decoration: IscteTheme.buildInputDecoration(
            hint: "email",
            errorText: (widget.errorCode == RegistrationError.existingEmail)
                ? 'Email already exists'
                : null),
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) {
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
        decoration: IscteTheme.buildInputDecoration(
            hint: "password",
            errorText: (widget.errorCode == RegistrationError.passwordNotMatch)
                ? 'Passwords must match'
                : null),
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
        controller: widget.passwordConfirmationController,
        obscureText: true,
        decoration: IscteTheme.buildInputDecoration(
            hint: "confirm password",
            errorText: (widget.errorCode == RegistrationError.passwordNotMatch)
                ? 'Passwords must match'
                : null),
        textInputAction: TextInputAction.done,
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
}
