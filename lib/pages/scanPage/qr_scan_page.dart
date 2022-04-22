import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:iscte_spots/helper/helper_methods.dart';
import 'package:iscte_spots/models/visited_url.dart';
import 'package:iscte_spots/pages/scanPage/qr_scan_camera_controls.dart';
import 'package:iscte_spots/widgets/util/overlays.dart';
import 'package:logger/logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:synchronized/synchronized.dart';

import '../../models/database/tables/database_page_table.dart';

class QRScanPage extends StatefulWidget {
  QRScanPage({Key? key}) : super(key: key);
  final Logger logger = Logger();

  static const pageRoute = "/scan";
  static String titleHtmlTag = 'CGqCRe';

  @override
  State<StatefulWidget> createState() => QRScanPageState();
}

class QRScanPageState extends State<QRScanPage> {
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

  Future<void> extractData(final String url) async {
    _logger.d("url:$url");
    try {
      final response = await http.Client().get(Uri.parse(url));
      //Status Code 200 means response has been received successfully
      if (response.statusCode == 200) {
        var lock = Lock();
        int millisecondsSinceEpoch2 = DateTime.now().millisecondsSinceEpoch;
        var title = parser
            .parse(response.body)
            .getElementsByClassName(QRScanPage.titleHtmlTag);
        String name = title.map((e) => e.text).join("");

        await lock.synchronized(() async {
          DatabasePageTable.add(VisitedURL(
              content: name, dateTime: millisecondsSinceEpoch2, url: url));
          setState(() {
            qrScanResult = name;
          });
        });
        _logger.d("-----------------title-----------------------\n" +
            name +
            "\n" +
            millisecondsSinceEpoch2.toString());
      } else {
        setState(() {
          qrScanResult = 'ERROR: ${response.statusCode}.';
        });
        throw const SocketException('Error');
      }
    } on SocketException {
      rethrow;
    } catch (e) {
      _logger.e(e);
    }
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

      try {
        await extractData(barcode!.code!);
        await HelperMethods.launchURL(barcode!.code!);
      } on SocketException {
        showNetworkErrorOverlay(context, _logger);
      }
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
