import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/requests/spot_info_request.dart';
import 'package:iscte_spots/models/requests/topic_request.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/pages/home/scanPage/qr_scan_camera_controls.dart';
import 'package:iscte_spots/pages/home/scanPage/qr_scan_results.dart';
import 'package:iscte_spots/services/auth/exceptions.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/qr_scan_service.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:synchronized/synchronized.dart';

class QRScanPageOpenDay extends StatefulWidget {
  QRScanPageOpenDay(
      {Key? key /*, required this.changeImage*/,
      required this.completedAllPuzzle})
      : super(key: key);
  final Logger _logger = Logger();
  //final void Function(Future<SpotRequest> request) changeImage;
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
        try {
          if (now - _lastScan >= _scanCooldown && !_requesting) {
            setState(() => _requesting = true);
            await controller?.pauseCamera();
            widget._logger.d("scanned new code");

            SpotInfoRequest spotInfoRequest =
                await QRScanService.spotInfoRequest(
                    context: context, barcode: barcode);
            widget._logger.d(spotInfoRequest);
            bool continueScan = await launchConfirmationDialog(
                context, spotInfoRequest.title ?? "");

            if (continueScan && spotInfoRequest.id != null) {
              _lastScan = now;

              Spot spot =
                  (await DatabaseSpotTable.getAllWithIds([spotInfoRequest.id!]))
                      .first;
              if (!spot.visited) {
                spot.visited = true;
                await DatabaseSpotTable.update(spot);
              }
              Future<TopicRequest> topicRequest = QRScanService.topicRequest(
                  context: context, topicID: spotInfoRequest.id!);
              TopicRequest topicRequestCompleted = await topicRequest;
              widget._logger.d("spotInfoRequest: $topicRequestCompleted");

              Navigator.of(context).pushNamed(
                QRScanResults.pageRoute,
                arguments: topicRequestCompleted.contentList,
              );
            }
          }
        } on LoginException {
          widget._logger.e("LoginException");
        } on InvalidQRException {
          widget._logger.e("InvalidQRException");
        } catch (e) {
          widget._logger.e(e);
        }
        await controller?.resumeCamera();
        setState(() => _requesting = false);
      },
    );
  }

  Future<bool> launchConfirmationDialog(context, String topicTitle) async {
    bool continueScan = false;

    if (PlatformService.instance.isIos) {
      await showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(AppLocalizations.of(context)!.qrScanConfirmation),
              content: Text(topicTitle),
              actions: [
                CupertinoButton(
                  child: Text(
                      AppLocalizations.of(context)!.qrScanConfirmationCancel),
                  onPressed: () {
                    widget._logger.d("Pressed \"CANCEL\"");
                    continueScan = false;
                    Navigator.pop(context);
                  },
                ),
                CupertinoButton(
                  child: Text(
                      AppLocalizations.of(context)!.qrScanConfirmationAccept),
                  onPressed: () {
                    widget._logger.d("Pressed \"ACCEPT\"");
                    continueScan = true;
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    } else {
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: ((BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.qrScanConfirmation),
              content: Text(topicTitle),
              actions: [
                TextButton(
                  child: Text(
                      AppLocalizations.of(context)!.qrScanConfirmationCancel),
                  onPressed: () {
                    widget._logger.d("Pressed \"CANCEL\"");
                    continueScan = false;
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                      AppLocalizations.of(context)!.qrScanConfirmationAccept),
                  onPressed: () {
                    widget._logger.d("Pressed \"ACCEPT\"");
                    continueScan = true;
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }));
    }
    return continueScan;
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
