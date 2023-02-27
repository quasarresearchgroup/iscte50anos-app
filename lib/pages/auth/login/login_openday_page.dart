import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/auth/login_form_result.dart';
import 'package:iscte_spots/services/auth/login_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

class LoginOpendayPage extends StatefulWidget {
  LoginOpendayPage({
    Key? key,
    required this.changeToSignUp,
    required this.loggingComplete,
    required this.animatedSwitcherDuration,
  }) : super(key: key);

  @override
  State<LoginOpendayPage> createState() => _LoginOpendayState();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final void Function() loggingComplete;
  final void Function() changeToSignUp;
  final Duration animatedSwitcherDuration;
}

class _LoginOpendayState extends State<LoginOpendayPage>
    with AutomaticKeepAliveClientMixin {
  final _loginFormkey = GlobalKey<FormState>();

  bool _hidePassword = true;
  bool _loginError = false;
  bool _generalError = false;
  bool _isLoading = false;

  bool _connectionError = false;

  String? get _errorText => _connectionError
      ? "Connection Error"
      : _generalError
          ? "Unknown Error"
          : _loginError
              ? "Invalid Credentials"
              : null;

  String? loginValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  List<Widget> generateFormFields() {
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction;
    return [
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.userNameController,
        textAlignVertical: TextAlignVertical.top,
        decoration: IscteTheme.buildInputDecoration(
            hint: "Username", errorText: _errorText),
        textInputAction: TextInputAction.next,
        validator: loginValidator,
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        obscureText: _hidePassword,
        controller: widget.passwordController,
        textAlignVertical: TextAlignVertical.center,
        decoration: IscteTheme.buildInputDecoration(
          hint: AppLocalizations.of(context)!.loginPassword,
          errorText: _errorText,
          suffixIcon: IconButton(
            onPressed: () => setState(() => _hidePassword = !_hidePassword),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Icon(
                _hidePassword ? Icons.visibility : Icons.visibility_off,
                key: UniqueKey(),
              ),
            ),
          ),
        ),
        textInputAction: TextInputAction.done,
        validator: loginValidator,
      ),
    ];
  }

  List<Widget> generateFormButtons() {
    return [
      DynamicTextButton(
        style: IscteTheme.iscteColor,
        child: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: _loginAction,
      ),
    ];
  }

  Future<void> _loginAction() async {
    setState(() {
      _loginError = false;
      _generalError = false;
      _isLoading = true;
    });
    try {
      if (_loginFormkey.currentState!.validate()) {
        LoginFormResult loginFormResult = LoginFormResult(
          username: widget.userNameController.text,
          password: widget.passwordController.text,
        );
        int statusCode = await LoginService.login(
          loginFormResult,
        );
        if (statusCode == 200) {
          widget.loggingComplete();
        } else {
          setState(() {
            _loginError = true;
          });
          LoggerService.instance.error(
              "Login error!: statusCode: $statusCode; loginForm: $loginFormResult;");
        }
      }
    } on SocketException {
      setState(() {
        _connectionError = true;
      });
      LoggerService.instance.error("SocketException on login!");
    } catch (e) {
      setState(() {
        _generalError = true;
      });
      LoggerService.instance.error(e);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedSwitcher(
      duration: widget.animatedSwitcherDuration,
      child: _isLoading
          ? const LoadingWidget()
          : Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
              child: Form(
                key: _loginFormkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 9,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ...generateFormFields(),
                            ...generateFormButtons()
                          ]),
                    ),
/*                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          Text("Dont have an account? "),
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).primaryColor),
                              label: Text("Sign up!"),
                              icon: Icon(Icons.adaptive.arrow_forward),
                              onPressed: () {
                                LoggerService.instance.debug("change");
                                widget.changeToSignUp();
                              }),
                        ],
                      ),
                    ),*/
                  ],
                ),
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
