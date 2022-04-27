import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/auth/login_form_result.dart';
import 'package:iscte_spots/services/auth/openday_login_service.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class LoginOpendayPage extends StatefulWidget {
  final Logger _logger = Logger();

  LoginOpendayPage(
      {Key? key, required this.changeToSignUp, required this.loggingComplete})
      : super(key: key);

  @override
  State<LoginOpendayPage> createState() => _LoginOpendayState();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final void Function() loggingComplete;
  final void Function() changeToSignUp;
}

class _LoginOpendayState extends State<LoginOpendayPage>
    with AutomaticKeepAliveClientMixin {
  final _loginFormkey = GlobalKey<FormState>();

  bool _loginError = false;
  bool _isLoading = false;

  String? get _errorText => _loginError ? "Invalid Credentials" : null;

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
        decoration: IscteTheme.buildInputDecoration(
            hint: "Username", errorText: _errorText),
        textInputAction: TextInputAction.next,
        validator: (value) {
          return loginValidator(value);
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        obscureText: true,
        controller: widget.passwordController,
        decoration: IscteTheme.buildInputDecoration(
            hint: "Password", errorText: _errorText),
        textInputAction: TextInputAction.done,
        validator: (value) {
          return loginValidator(value);
        },
      ),
    ];
  }

  List<Widget> generateFormButtons() {
    return [
      ElevatedButton(
        style:
            ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
        child: const Text("Login"),
        onPressed: () async {
          await _loginAction();
        },
      ),
    ];
  }

  Future<void> _loginAction() async {
    setState(() {
      _loginError = false;
      _isLoading = true;
    });
    if (_loginFormkey.currentState!.validate()) {
      int statusCode = await OpenDayLoginService.login(
        LoginFormResult(
          username: widget.userNameController.text,
          password: widget.passwordController.text,
        ),
      );
      if (statusCode == 200) {
        widget.loggingComplete();
      } else {
        setState(() {
          _loginError = true;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formFields = generateFormFields();
    List<Widget> formButtons = generateFormButtons();
    super.build(context);
    return _isLoading
        ? const LoadingWidget()
        : Padding(
            padding: const EdgeInsets.only(bottom: 10),
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
                        children: [...formFields, ...formButtons]),
                  ),
                  Flexible(
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
                              widget._logger.d("change");
                              widget.changeToSignUp();
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  @override
  bool get wantKeepAlive => true;
}
