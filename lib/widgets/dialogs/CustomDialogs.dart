import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';

void showYesNoWarningDialog({
  required BuildContext context,
  required String text,
  Function()? methodOnYes,
  Function()? methodOnNo,
}) {
  DynamicAlertDialog.showDynamicDialog(
    context: context,
    actions: [
      DynamicTextButton(
          onPressed: methodOnNo ?? Navigator.of(context).pop,
          child: Text(AppLocalizations.of(context)!.no)),
      DynamicTextButton(
          onPressed: methodOnYes,
          child: Text(AppLocalizations.of(context)!.yes))
    ],
    title: Text(
      AppLocalizations.of(context)!.warningTitle,
      style: Theme.of(context).textTheme.titleLarge,
    ),
    content: Text(
      text,
      style: Theme.of(context).textTheme.titleMedium,
    ),
  );
/*  showDialog(
    useRootNavigator: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Center(child: Text("Aviso")),
        content: Text(text),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            child: const Text('Não'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Sim'),
            onPressed: yes,
          ),
        ],
      );
    },
  );*/
}
