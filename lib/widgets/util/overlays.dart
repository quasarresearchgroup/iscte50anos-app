import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

Future<void> showNetworkErrorOverlay(
    BuildContext context, Logger logger) async {
  logger.i("Inserted Network error overlay");
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).errorColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(AppLocalizations.of(context)!.networkError),
          const Icon(Icons.signal_wifi_connected_no_internet_4),
        ],
      ),
    ),
  );
  logger.i("Removed Network error overlay");
}

Future<void> showHelpOverlay(
    BuildContext context, Widget image, Orientation orientation) async {
  Logger _logger = Logger();

  OverlayState? overlayState = Overlay.of(context);
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) {
      var widgetWidth = min(MediaQuery.of(context).size.width * 0.2,
          MediaQuery.of(context).size.height * 0.2);
      return Positioned(
        top: orientation == Orientation.portrait ? 100 : 30,
        right: orientation == Orientation.portrait ? 10 : null,
        left: orientation == Orientation.portrait
            ? null
            : MediaQuery.of(context).size.width * 0.5 - (widgetWidth * 0.5),
        child: SizedBox(
          width: widgetWidth,
          child: Container(
              decoration: BoxDecoration(border: Border.all()), child: image),
        ),
      );
    },
    maintainState: true,
    opaque: false,
  );
  overlayState?.insert(overlayEntry);
  _logger.d("Inserted Help overlay");
  await Future.delayed(const Duration(seconds: 2));
  overlayEntry.remove();
  _logger.d("Removed Help overlay");
}
