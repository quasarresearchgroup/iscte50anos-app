import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';

class OpenDayNotificationService {
  static final Logger _logger = Logger();
  static Future<void> showLoginErrorOverlay(BuildContext context) async {
    _openDayErrorSnackbar(context, "Authentication Error");
  }

  static Future<void> showWrongSpotErrorOverlay(BuildContext context) async {
    _openDayErrorSnackbar(context, "Wrong Spot");
  }

  static Future<void> showErrorOverlay(BuildContext context) async {
    _openDayErrorSnackbar(context, "Error");
  }

  static Future<void> showAlreadeyVisitedOverlay(BuildContext context) async {
    _openDayErrorSnackbar(context, "You already visited that Spot");
  }

  static void showInvalidErrorOverlay(BuildContext context) {
    _openDayErrorSnackbar(context, "Are you sure that is a Spot at Iscte?");
  }

  static void showDisabledErrorOverlay(BuildContext context) {
    _openDayErrorSnackbar(context, "Spots are disabled now...");
  }

  static Future<void> showAllVisitedOverlay(BuildContext context) async {
    _openDaySucessSnackbar(context, "Wow you won!!");
  }

  static void _openDayErrorSnackbar(BuildContext context, String data) {
    _logger.i("Inserted overlay: $data");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 500),
        backgroundColor: Theme.of(context).errorColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(data),
            const FaIcon(FontAwesomeIcons.faceSadTear),
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
        duration: const Duration(milliseconds: 500),
        backgroundColor: Colors.green,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(data),
            const FaIcon(FontAwesomeIcons.faceSmile),
          ],
        ),
      ),
    );
    _logger.i("Removed overlay: $data");
  }
}
