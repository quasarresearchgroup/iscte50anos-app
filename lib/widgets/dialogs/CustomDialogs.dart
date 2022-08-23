
import 'package:flutter/material.dart';

showYesNoWarningDialog(String text, Function() yes, BuildContext context){
  showDialog(
    useRootNavigator: false,
    context: context,
    builder: (BuildContext
    context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              20),
        ),
        title: const Center(
            child: Text(
                "Aviso")),
        content: Text(text),
        actionsAlignment: MainAxisAlignment
            .center,
        actions: [
          TextButton(
            child: const Text(
                'Não'),
            onPressed: () {
              Navigator.of(
                  context)
                  .pop();
            },
          ),
          TextButton(
            child: const Text(
                'Sim'),
            onPressed: yes,
          ),
        ],
      );
    },
  );
}