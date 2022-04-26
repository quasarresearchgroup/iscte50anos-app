import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// -----------------------------------
///            Login Widget
/// -----------------------------------

class IscteLogin extends StatelessWidget {
  final loginAction;
  final String loginError;

  const IscteLogin(this.loginAction, this.loginError);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            loginAction();
          },
          child: const Text('Login using Iscte Login'),
        ),
        Text(loginError),
      ],
    );
  }
}
