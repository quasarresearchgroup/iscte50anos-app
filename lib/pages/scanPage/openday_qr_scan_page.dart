import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/scanPage/qr_scan_camera_controls.dart';
import 'package:iscte_spots/services/openday/openday_qr_scan_service.dart';
import 'package:logger/logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanPageOpenDay extends StatefulWidget {
  QRScanPageOpenDay({Key? key, required this.changeImage}) : super(key: key);
  final Logger logger = Logger();
  final void Function(String imageLink) changeImage;
  @override
  State<StatefulWidget> createState() => QRScanPageOpenDayState();
}

class QRScanPageOpenDayState extends State<QRScanPageOpenDay> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  final Logger _logger = Logger();
  QRViewController? controller;
  Decoration controlsDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8), color: Colors.white24);
  Barcode? barcode;
  Barcode? barcodeold;
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
        .listen((scanData) => setState(() => barcode = scanData));
  }

  @override
  Widget build(BuildContext context) {
    checkLaunchBarcode(context);

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

  Future<void> checkLaunchBarcode(BuildContext context) async {
    if (barcode != null && barcode != barcodeold) {
      //setState(() => barcodeold = barcode);
      barcodeold = barcode;
      String spotRequest =
          await OpenDayQRScanService.spotRequest(barcode: barcode!);
      widget.changeImage(spotRequest);
      widget.logger.d("OpenDay Scan");
    }
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
