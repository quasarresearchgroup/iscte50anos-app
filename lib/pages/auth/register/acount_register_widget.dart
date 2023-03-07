import 'package:flutter/material.dart';
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
  bool _hidePassword = true;
  bool _hidePasswordConfirm = true;

  @override
  Widget build(BuildContext context) {
    List<Widget> formFields = generateFormFields();
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...formFields,
        ],
      ),
    );
  }

  List<Widget> generateFormFields() {
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction;
    return [
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.userNameController,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.next,
        decoration: IscteTheme.buildInputDecoration(
            hint: "username", //TODO
            errorText: (widget.errorCode == RegistrationError.existingUsername)
                ? 'Username already exists' //TODO
                : null),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text'; //TODO
          }
          return null;
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.nameController,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.next,
        decoration: IscteTheme.buildInputDecoration(hint: "name"), //TODO
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text'; //TODO
          }
          return null;
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.lastNameController,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.next,
        decoration: IscteTheme.buildInputDecoration(hint: "last name"), //TODO
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text'; //TODO
          }
          return null;
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.emailController,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.next,
        decoration: IscteTheme.buildInputDecoration(
            hint: "email", //TODO
            errorText: (widget.errorCode == RegistrationError.existingEmail)
                ? 'Email already exists' //TODO
                : null),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text'; //TODO
          } else if (!RegExp(r"\S+[@]\S+\.\S+").hasMatch(value) ||
              widget.errorCode == RegistrationError.invalidEmail) {
            //RegExp Explanation (checks for @ followed by any number of non whitespace character followed by a dot "." and then followed by any number of non whitespace characters)
            //https://regex101.com/r/TZDJmb/1
            return 'Please enter a valid email'; //TODO
          }
          return null;
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.passwordController,
        obscureText: _hidePassword,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.next,
        decoration: IscteTheme.buildInputDecoration(
            hint: "password", //TODO
            errorText: (widget.errorCode == RegistrationError.passwordNotMatch)
                ? 'Passwords must match' //TODO
                : null,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _hidePassword = !_hidePassword;
                });
              },
              icon: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: Icon(
                  _hidePassword ? Icons.visibility : Icons.visibility_off,
                  key: UniqueKey(),
                ),
              ),
            )),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text'; //TODO
          }
          return null;
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.passwordConfirmationController,
        obscureText: _hidePasswordConfirm,
        textInputAction: TextInputAction.done,
        textAlignVertical: TextAlignVertical.center,
        decoration: IscteTheme.buildInputDecoration(
            hint: "confirm password", //TODO
            errorText: (widget.errorCode == RegistrationError.passwordNotMatch)
                ? 'Passwords must match' //TODO
                : null,
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  _hidePasswordConfirm = !_hidePasswordConfirm;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: Icon(
                    _hidePasswordConfirm
                        ? Icons.visibility
                        : Icons.visibility_off,
                    key: UniqueKey(),
                  ),
                ),
              ),
            )),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text'; //TODO
          } else if (value != widget.passwordController.text) {
            return 'Passwords must match'; //TODO
          }
          return null;
        },
      ),
    ];
  }
}
