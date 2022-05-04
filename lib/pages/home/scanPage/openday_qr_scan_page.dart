import 'package:flutter/material.dart';
import 'package:iscte_spots/models/spot_request.dart';
import 'package:iscte_spots/pages/home/scanPage/qr_scan_camera_controls.dart';
import 'package:iscte_spots/services/openday/openday_qr_scan_service.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:synchronized/synchronized.dart';

class QRScanPageOpenDay extends StatefulWidget {
  QRScanPageOpenDay(
      {Key? key, required this.changeImage, required this.completedAllPuzzle})
      : super(key: key);
  final Logger _logger = Logger();
  final void Function(Future<SpotRequest> request) changeImage;
  final void Function() completedAllPuzzle;
  @override
  State<StatefulWidget> createState() => QRScanPageOpenDayState();
}

class QRScanPageOpenDayState extends State<QRScanPageOpenDay> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Decoration controlsDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8), color: Colors.white24);

  int _lastScan = 0;
  final int _scanCooldown = 4000;
  String? qrScanResult;
  bool _requesting = false;

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
    Size mediaQuerySize = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        myQRView(context),
        Positioned(
          bottom: mediaQuerySize.height * 0.2,
          child: QRControlButtons(
              controlsDecoration: controlsDecoration, controller: controller),
        ),
        _requesting
            ? SizedBox(
                width: mediaQuerySize.width,
                height: mediaQuerySize.height,
                //color: Theme.of(context).primaryColor.withOpacity(0.9),
                child: const LoadingWidget(
                  strokeWidth: 10,
                ),
              )
            : Container(),
      ],
    );
  }

  void checkLaunchBarcode(BuildContext context, Barcode barcode) {
    var lock = Lock();

    lock.synchronized(
      () async {
        int now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastScan >= _scanCooldown && !_requesting) {
          setState(() => _requesting = true);
          await controller?.pauseCamera();
          widget._logger.d("scanned new code");
          _lastScan = now;
          String? newImageURL;
          Future<SpotRequest> spotRequest = OpenDayQRScanService.spotRequest(
              context: context, barcode: barcode);
          widget._logger.d("spotRequest: $spotRequest");
/*          newImageURL =
              await OpenDayQRScanService.requestRouter(context, spotRequest);
          if (newImageURL != null) {
            if (newImageURL == OpenDayQRScanService.allVisited) {
              widget.completedAllPuzzle();
            }
            widget.changeImage(spotRequest);
          }*/
          widget.changeImage(spotRequest);
          await spotRequest;
          await controller?.resumeCamera();
          setState(() => _requesting = false);
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
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      );
}
