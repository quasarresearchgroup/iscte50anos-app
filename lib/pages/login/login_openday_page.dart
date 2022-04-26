import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/auth/login_form_result.dart';
import 'package:iscte_spots/services/openday/openday_login_service.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';

import '../../widgets/util/iscte_theme.dart';
import '../home.dart';

class LoginOpendayPage extends StatefulWidget {
  LoginOpendayPage({Key? key}) : super(key: key);

  @override
  State<LoginOpendayPage> createState() => _LoginOpendayState();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
}

class _LoginOpendayState extends State<LoginOpendayPage> {
  final _loginFormkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    List<Widget> formFields = generateFormFields();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login OpenDay"),
      ),
      body: Form(
        key: _loginFormkey,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ...formFields,
        ]),
      ),
    );
  }

  List<Widget> generateFormFields() {
    AutovalidateMode autovalidateMode = AutovalidateMode.always;
    return [
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.userNameController,
        decoration: IscteTheme.buildInputDecoration(hint: "userName"),
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
        controller: widget.passwordController,
        decoration: IscteTheme.buildInputDecoration(hint: "password"),
        textInputAction: TextInputAction.done,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
      ElevatedButton(
          onPressed: () async {
            if (_loginFormkey.currentState!.validate()) {
              int statusCode = await OpenDayLogin.login(
                LoginFormResult(
                  username: widget.userNameController.text,
                  password: widget.passwordController.text,
                ),
              );
              if (statusCode == 200) {
                PageRoutes.replacePushanimateToPage(context, page: Home());
              }
            }
          },
          child: Text("Login")),
    ];
  }
}
