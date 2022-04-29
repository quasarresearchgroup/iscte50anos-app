import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/scanPage/qr_scan_camera_controls.dart';
import 'package:iscte_spots/services/openday/openday_notification_service.dart';
import 'package:logger/logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:synchronized/synchronized.dart';

import '../../services/openday/openday_qr_scan_service.dart';

class QRScanPageOpenDay extends StatefulWidget {
  QRScanPageOpenDay({Key? key, required this.changeImage}) : super(key: key);
  final Logger _logger = Logger();
  final void Function(String imageLink) changeImage;
  @override
  State<StatefulWidget> createState() => QRScanPageOpenDayState();
}

class QRScanPageOpenDayState extends State<QRScanPageOpenDay> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Decoration controlsDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8), color: Colors.white24);

  int _lastScan = 0;
  final int _scanCooldown = 1000;
  String? qrScanResult;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Future<void> reassemble() async {
    super.reassemble();
    /*
    if ( Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    */
    controller!.resumeCamera();
  }

  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    controller.scannedDataStream
        .listen((scanData) => checkLaunchBarcode(context, scanData));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        myQRView(context),
        Positioned(
          top: 10,
          child: QRControlButtons(
              controlsDecoration: controlsDecoration, controller: controller),
        ),
      ],
    );
  }

  void checkLaunchBarcode(BuildContext context, Barcode barcode) {
    var lock = Lock();

    lock.synchronized(() async {
      int now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastScan >= _scanCooldown) {
        widget._logger.d("scanned new code");
        _lastScan = now;
        String spotRequest =
            await OpenDayQRScanService.spotRequest(barcode: barcode);

        switch (spotRequest) {
          case OpenDayQRScanService.generalError:
            {
              OpenDayNotificationService.showErrorOverlay(context);
              widget._logger.d("generalError : $spotRequest");
            }
            break;
          case OpenDayQRScanService.connectionError:
            {
              OpenDayNotificationService.showConnectionErrorOverlay(context);
              widget._logger.d("connectionError : $spotRequest");
            }
            break;
          case OpenDayQRScanService.loginError:
            {
              OpenDayNotificationService.showLoginErrorOverlay(context);
              widget._logger.d("loginError : $spotRequest");
            }
            break;
          case OpenDayQRScanService.wrongSpotError:
            {
              OpenDayNotificationService.showWrongSpotErrorOverlay(context);
              widget._logger.d("wrongSpotError : $spotRequest");
            }
            break;
          case OpenDayQRScanService.alreadyVisitedError:
            {
              OpenDayNotificationService.showAlreadeyVisitedOverlay(context);
              widget._logger.d("alreadyVisitedError : $spotRequest");
            }
            break;
          case OpenDayQRScanService.allVisited:
            {
              OpenDayNotificationService.showAllVisitedOverlay(context);
              widget._logger.d("allVisited : $spotRequest");
            }
            break;
          case OpenDayQRScanService.invalidQRError:
            {
              OpenDayNotificationService.showInvalidErrorOverlay(context);
              widget._logger.d("invalidQRError : $spotRequest");
            }
            break;
          case OpenDayQRScanService.disabledQRError:
            {
              OpenDayNotificationService.showDisabledErrorOverlay(context);
              widget._logger.d("disabledQRError : $spotRequest");
            }
            break;
          default:
            {
              await OpenDayNotificationService.showNewSpotFoundOverlay(context);
              widget._logger.d("changed image: $spotRequest");
              widget.changeImage(spotRequest);
            }
        }
      }
    });
  }

  Widget myQRView(BuildContext context) => QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.secondary,
          borderWidth: 10,
          borderLength: 20,
          borderRadius: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8));
}
