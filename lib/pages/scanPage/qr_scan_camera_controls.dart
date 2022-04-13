import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRControlButtons extends StatefulWidget {
  QRControlButtons(
      {Key? key, required this.controlsDecoration, this.controller})
      : super(key: key);
  Decoration controlsDecoration;
  QRViewController? controller;
  @override
  State<QRControlButtons> createState() => _QRControlButtonsState();
}

class _QRControlButtonsState extends State<QRControlButtons> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: widget.controlsDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
              onPressed: () async {
                await widget.controller?.toggleFlash();
                setState(() {});
              },
              icon: FutureBuilder<bool?>(
                future: widget.controller?.getFlashStatus(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Icon(
                        snapshot.data! ? Icons.flash_on : Icons.flash_on);
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            IconButton(
              onPressed: () async {
                await widget.controller?.flipCamera();
                setState(() {});
              },
              icon: FutureBuilder(
                future: widget.controller?.getCameraInfo(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return const Icon(Icons.switch_camera);
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ));
  }
}
