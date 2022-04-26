import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/auth/login_form_result.dart';
import 'package:iscte_spots/pages/home.dart';
import 'package:iscte_spots/services/auth/openday_login_service.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

class LoginOpendayPage extends StatefulWidget {
  LoginOpendayPage({Key? key, required this.changeToSignUp}) : super(key: key);

  @override
  State<LoginOpendayPage> createState() => _LoginOpendayState();
  void Function() changeToSignUp;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
}

class _LoginOpendayState extends State<LoginOpendayPage>
    with AutomaticKeepAliveClientMixin {
  final _loginFormkey = GlobalKey<FormState>();

  bool _loginError = false;
  bool _isLoading = false;

  String? loginValidator(String? value) {
    if (_loginError) {
      return "Invalid Credentials";
    } else if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  List<Widget> generateFormFields() {
    AutovalidateMode autovalidateMode = AutovalidateMode.always;
    return [
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.userNameController,
        decoration: IscteTheme.buildInputDecoration(hint: "Username"),
        textInputAction: TextInputAction.next,
        validator: (value) {
          return loginValidator(value);
        },
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.passwordController,
        decoration: IscteTheme.buildInputDecoration(hint: "Password"),
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
        child: const Text("Login"),
        onPressed: () async {
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
              PageRoutes.replacePushanimateToPage(context, page: Home());
            } else {
              setState(() {
                _loginError = true;
              });
            }
          }
          setState(() {
            _isLoading = false;
          });
        },
      ),
      Center(
        child: RichText(
            text: TextSpan(text: "Dont have an account? ", children: [
          TextSpan(
              text: "Sign up!",
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  widget.changeToSignUp();
                },
              style: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ))
        ])),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formFields = generateFormFields();
    List<Widget> formButtons = generateFormButtons();
    super.build(context);
    return _isLoading
        ? const LoadingWidget()
        : Form(
            key: _loginFormkey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [...formFields, ...formButtons]),
          );
  }

  @override
  bool get wantKeepAlive => true;
}