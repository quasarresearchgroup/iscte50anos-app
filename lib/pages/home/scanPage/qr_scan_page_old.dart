/*
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/helper/helper_methods.dart';
import 'package:iscte_spots/pages/home/scanPage/qr_scan_camera_controls.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/qr_scan_service.dart';
import 'package:iscte_spots/widgets/util/overlays.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanPage extends StatefulWidget {
  QRScanPage({Key? key}) : super(key: key);
  static String titleHtmlTag = 'CGqCRe';

  @override
  State<StatefulWidget> createState() => QRScanPageState();
}

class QRScanPageState extends State<QRScanPage> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController? qrController;
  Decoration controlsDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8), color: Colors.white24);
  Barcode? barcode;
  Barcode? barcodeold;
  String? qrScanResult;

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  Future<void> reassemble() async {
    super.reassemble();
  }

  void onQRViewCreated(Barcode newCode, MobileScannerArguments? args) {
    setState(() {
      barcode = newCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQuerySize = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          bottom: mediaQuerySize.height * 0.2,
          child: QRControlButtons(
              controlsDecoration: controlsDecoration,
              qrController: qrController),
        ),
        myQRView(context),
      ],
    );
  }

  Future<void> checkLaunchBarcode(BuildContext context) async {
    if (barcode != null && barcode != barcodeold) {
      //setState(() => barcodeold = barcode);
      barcodeold = barcode;

      try {
        LoggerService.instance.debug(barcode!.rawValue!);
        String scanResult = await QRScanService.extractData(barcode!.url!.url!);
        setState(() {
          qrScanResult = scanResult;
        });
        await HelperMethods.launchURL(barcode!.url!.url!);
      } on SocketException {
        showNetworkErrorOverlay(context);
      }
    }
  }

  Widget myQRView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    LoggerService.instance.debug("scanArea: $scanArea");
    //scanArea = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.8;
    return MobileScanner(
      key: qrKey,
      controller: qrController,
      onDetect: onQRViewCreated,
      // overlay: QrScannerOverlayShape(
      //   borderColor: Theme.of(context).colorScheme.primary,
      //   borderWidth: 10,
      //   borderLength: 20,
      //   borderRadius: 10,
      //   cutOutSize: scanArea,
      // ),
    );
  }
}
*/
