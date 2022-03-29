import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

Future<void> showNetworkErrorOverlay(
    BuildContext context, Logger logger) async {
  OverlayState? overlayState = Overlay.of(context);
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) {
      double overlayWidth = 250;
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Material(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(100),
                child: SizedBox(
                  //width: 250,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent,
                        border: Border.all(color: Colors.black)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Text("Network Error"),
                            Icon(Icons.signal_wifi_connected_no_internet_4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
