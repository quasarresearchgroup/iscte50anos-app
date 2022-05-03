import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';

class OpenDayNotificationService {
  static final Logger _logger = Logger();

  static Future<void> showLoginErrorOverlay(BuildContext context) async {
    _openDayErrorSnackbar(context: context, data: "Authentication Error");
  }

  static void showConnectionErrorOverlay(BuildContext context) async {
    _openDayErrorSnackbar(
      context: context,
      data: "No Wifi",
      icon: Icon(Icons.wifi_off, color: Theme.of(context).selectedRowColor),
    );
  }

  static Future<void> showWrongSpotErrorOverlay(BuildContext context) async {
    _openDayErrorSnackbar(context: context, data: "Wrong Spot");
  }

  static Future<void> showErrorOverlay(BuildContext context) async {
    _openDayErrorSnackbar(context: context, data: "Error");
  }

  static Future<void> showAlreadeyVisitedOverlay(BuildContext context) async {
    _openDayErrorSnackbar(
        context: context, data: "You already visited that Spot");
  }

  static void showInvalidErrorOverlay(BuildContext context) {
    _openDayErrorSnackbar(
        context: context, data: "Are you sure that is a Spot at Iscte?");
  }

  static void showDisabledErrorOverlay(BuildContext context) {
    _openDayErrorSnackbar(context: context, data: "Spots are disabled now...");
  }

  static Future<void> showAllVisitedOverlay(BuildContext context) async {
    _openDaySucessSnackbar(context, "Wow you won!!");
  }

/*  static Future<void> showNewSpotFoundOverlay(BuildContext context) async {
    _openDaySucessSnackbar(context, "Wow you found it!!");
  }*/

  static void _openDayErrorSnackbar(
      {required BuildContext context, required String data, Widget? icon}) {
    _logger.i("Inserted overlay: $data");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        //duration: const Duration(seconds: 1),
        backgroundColor: Theme.of(context).errorColor,
        action: SnackBarAction(
            label: 'Dismiss',
            textColor: Theme.of(context).selectedRowColor,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),

        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(data,
                style: TextStyle(color: Theme.of(context).selectedRowColor)),
            icon ??
                FaIcon(FontAwesomeIcons.faceSadTear,
                    color: Theme.of(context).selectedRowColor),
          ],
        ),
      ),
    );
    _logger.i("Removed overlay: $data");
  }

  static void _openDaySucessSnackbar(BuildContext context, String data) {
    _logger.i("Inserted overlay: $data");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        //duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
        action: SnackBarAction(
            label: 'Dismiss',
            textColor: Theme.of(context).selectedRowColor,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              data,
              style: TextStyle(color: Theme.of(context).selectedRowColor),
            ),
            FaIcon(FontAwesomeIcons.faceSmile,
                color: Theme.of(context).selectedRowColor),
          ],
        ),
      ),
    );
    _logger.i("Removed overlay: $data");
  }
}
