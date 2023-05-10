import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
            hint: AppLocalizations.of(context)!.loginUsername,
            errorText: (widget.errorCode == RegistrationError.existingUsername)
                ? AppLocalizations.of(context)!
                    .registrationUsernameAlreadyExistsError
                : null),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.loginNoTextError;
          }
          return null;
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.nameController,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.next,
        decoration: IscteTheme.buildInputDecoration(
            hint: AppLocalizations.of(context)!.registrationName),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.loginNoTextError;
          }
          return null;
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.lastNameController,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.next,
        decoration: IscteTheme.buildInputDecoration(
            hint: AppLocalizations.of(context)!.registrationLastName),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.loginNoTextError;
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
            hint: AppLocalizations.of(context)!.registrationEmail,
            errorText: (widget.errorCode == RegistrationError.existingEmail)
                ? AppLocalizations.of(context)!
                    .registrationEmailAlreadyExistsError
                : null),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.loginNoTextError;
          } else if (!RegExp(r"\S+[@]\S+\.\S+").hasMatch(value) ||
              widget.errorCode == RegistrationError.invalidEmail) {
            //RegExp Explanation (checks for @ followed by any number of non whitespace character followed by a dot "." and then followed by any number of non whitespace characters)
            //https://regex101.com/r/TZDJmb/1
            return AppLocalizations.of(context)!.loginNoTextError;
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
            hint: AppLocalizations.of(context)!.registrationPassword,
            errorText: (widget.errorCode == RegistrationError.passwordNotMatch)
                ? AppLocalizations.of(context)!.registrationPasswordMustMatch
                : null,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _hidePassword = !_hidePassword;
                });
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  _hidePassword ? Icons.visibility : Icons.visibility_off,
                  key: UniqueKey(),
                ),
              ),
            )),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.loginNoTextError;
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
            hint: AppLocalizations.of(context)!.registrationConfirmPassword,
            errorText: (widget.errorCode == RegistrationError.passwordNotMatch)
                ? AppLocalizations.of(context)!.registrationPasswordMustMatch
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
                  duration: const Duration(milliseconds: 500),
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
            return AppLocalizations.of(context)!.loginNoTextError;
          } else if (value != widget.passwordController.text) {
            return AppLocalizations.of(context)!.registrationPasswordMustMatch;
          }
          return null;
        },
      ),
    ];
  }
}
