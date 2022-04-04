import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

Future<void> showNetworkErrorOverlay(
    BuildContext context, Logger logger) async {
  OverlayState? overlayState = Overlay.of(context);
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: 100,
        right: 10,
        child: Material(
          elevation: 4.0,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).errorColor,
                border: Border.all(color: Colors.black)),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(AppLocalizations.of(context)!.networkError),
                    const Icon(Icons.signal_wifi_connected_no_internet_4),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    maintainState: true,
    opaque: false,
  );
  overlayState?.insert(overlayEntry);
  logger.i("Inserted Network error overlay");
  await Future.delayed(const Duration(seconds: 2));
  overlayEntry.remove();
  logger.i("Removed Network error overlay");
}

Future<void> showHelpOverlay(
    BuildContext context, Widget image, Logger logger) async {
  OverlayState? overlayState = Overlay.of(context);
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
          top: 100,
          right: 10,
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Container(
                  decoration: BoxDecoration(border: Border.all()),
                  child: image)));
    },
    maintainState: true,
    opaque: false,
  );
  overlayState?.insert(overlayEntry);
  logger.d("Inserted Help overlay");
  await Future.delayed(const Duration(seconds: 2));
  overlayEntry.remove();
  logger.d("Removed Help overlay");
}
