import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/home/scanPage/qr_scan_camera_controls.dart';
import 'package:iscte_spots/services/openday/openday_qr_scan_service.dart';
import 'package:logger/logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:synchronized/synchronized.dart';

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
          bottom: MediaQuery.of(context).size.height * 0.2,
          child: QRControlButtons(
              controlsDecoration: controlsDecoration, controller: controller),
        ),
      ],
    );
  }

  void checkLaunchBarcode(BuildContext context, Barcode barcode) {
    var lock = Lock();

    lock.synchronized(
      () async {
        int now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastScan >= _scanCooldown) {
          widget._logger.d("scanned new code");
          _lastScan = now;
          String spotRequest =
              await OpenDayQRScanService.spotRequest(barcode: barcode);
          String? newImageURL =
              await OpenDayQRScanService.requestRouter(context, spotRequest);
          if (newImageURL != null) {
            widget.changeImage(newImageURL);
          }
        }
      },
    );
  }

  Widget myQRView(BuildContext context) => QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).primaryColor,
          borderWidth: 10,
          borderLength: 20,
          borderRadius: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8));
}
