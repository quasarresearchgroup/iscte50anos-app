import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRControlButtons extends StatelessWidget {
  const QRControlButtons(
      {Key? key, required this.controlsDecoration, this.qrController})
      : super(key: key);
  final Decoration controlsDecoration;
  final MobileScannerController? qrController;

  @override
  Widget build(BuildContext context) {
    return (qrController == null)
        ? Container()
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: controlsDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                    onPressed: () async {
                      await qrController!.toggleTorch();
                    },
                    icon: (qrController!.torchEnabled != null)
                        ? Icon(
                            qrController!.torchEnabled!
                                ? Icons.flash_off
                                : Icons.flash_on,
                          )
                        : Container()),
                IconButton(
                  onPressed: () async {
                    await qrController?.switchCamera();
                  },
                  icon: ValueListenableBuilder(
                    valueListenable: qrController!.cameraFacingState,
                    builder: (context, state, child) {
                      switch (state as CameraFacing) {
                        case CameraFacing.front:
                          return const Icon(Icons.camera_rear);
                        case CameraFacing.back:
                          return const Icon(Icons.camera_front);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
