import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';


class OpenDayNotificationService {
  

  static Future<void> showLoginErrorOverlay(BuildContext context) async {
    _openDayErrorSnackbar(
        context: context,
        data: AppLocalizations.of(context)!.qrScanNotificationLoginError);
  }

  static void showConnectionErrorOverlay(BuildContext context) async {
    _openDayErrorSnackbar(
      context: context,
      data: AppLocalizations.of(context)!.qrScanNotificationConnectionError,
      icon: Icon(Icons.wifi_off, color: Theme.of(context).selectedRowColor),
    );
  }

  static Future<void> showWrongSpotErrorOverlay(BuildContext context) async {
    _openDayErrorSnackbar(
        context: context,
        data: AppLocalizations.of(context)!.qrScanNotificationWrongSpot);
  }

  static Future<void> showErrorOverlay(BuildContext context) async {
    _openDayErrorSnackbar(
        context: context,
        data: AppLocalizations.of(context)!.qrScanNotificationError);
  }

  static Future<void> showAlreadeyVisitedOverlay(BuildContext context) async {
    _openDayErrorSnackbar(
        context: context,
        data: AppLocalizations.of(context)!.qrScanNotificationAlreadeyVisited);
  }

  static void showInvalidErrorOverlay(BuildContext context) {
    _openDayErrorSnackbar(
        context: context,
        data: AppLocalizations.of(context)!.qrScanNotificationInvalid);
  }

  static void showDisabledErrorOverlay(BuildContext context) {
    _openDayErrorSnackbar(
        context: context,
        data: AppLocalizations.of(context)!.qrScanNotificationDisabled);
  }

  static Future<void> showAllVisitedOverlay(BuildContext context) async {
    _openDaySucessSnackbar(
        context, AppLocalizations.of(context)!.qrScanNotificationAllVisited);
  }

/*  static Future<void> showNewSpotFoundOverlay(BuildContext context) async {
    _openDaySucessSnackbar(context, "Wow you found it!!");
  }*/

  static void _openDayErrorSnackbar(
      {required BuildContext context, required String data, Widget? icon}) {
    LoggerService.instance.error("Inserted overlay: $data");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: Theme.of(context).errorColor,
/*        action: SnackBarAction(
            label: 'Ok',
            textColor: Theme.of(context).selectedRowColor,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }),*/
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              data,
              style: TextStyle(color: Theme.of(context).selectedRowColor),
              overflow: TextOverflow.ellipsis,
            ),
            icon ??
                FaIcon(FontAwesomeIcons.faceSadTear,
                    color: Theme.of(context).selectedRowColor),
          ],
        ),
      ),
    );
    LoggerService.instance.error("Removed overlay: $data");
  }

  static void _openDaySucessSnackbar(BuildContext context, String data) {
    LoggerService.instance.error("Inserted overlay: $data");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        /*       action: SnackBarAction(
            label: 'Ok',
            textColor: Theme.of(context).selectedRowColor,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }),*/
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              data,
              style: TextStyle(color: Theme.of(context).selectedRowColor),
              overflow: TextOverflow.ellipsis,
            ),
            FaIcon(FontAwesomeIcons.faceSmile,
                color: Theme.of(context).selectedRowColor),
          ],
        ),
      ),
    );
    LoggerService.instance.error("Removed overlay: $data");
  }
}
