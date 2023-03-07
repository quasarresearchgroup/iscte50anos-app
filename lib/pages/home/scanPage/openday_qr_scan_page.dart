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
import 'package:iscte_spots/services/auth/login_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/qr_scan_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';

class QRScanPageOpenDay extends StatefulWidget {
  QRScanPageOpenDay(
      {Key? key /*, required this.changeImage*/,
      required this.completedAllPuzzle})
      : super(key: key);
  //final void Function(Future<SpotRequest> request) changeImage;
  final void Function() completedAllPuzzle;
  @override
  State<StatefulWidget> createState() => QRScanPageOpenDayState();
}

class QRScanPageOpenDayState extends State<QRScanPageOpenDay> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController? qrController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  Decoration controlsDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8), color: Colors.white24);

  int _lastScan = 0;
  final int _scanCooldown = 4000;
  String? qrScanResult;
  bool _requesting = false;
  late Future<bool> cameraPermission;

  @override
  void initState() {
    super.initState();
    cameraPermission = Permission.camera.request().isGranted;
  }

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
    checkLaunchBarcode(context, newCode);
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQuerySize = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        myQRView(context),
        Positioned(
          bottom: mediaQuerySize.height * 0.6,
          child: (FutureBuilder<bool>(
              future: cameraPermission,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: controlsDecoration,
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline),
                        Text(
                          snapshot.error.toString(),
                          softWrap: true,
                          maxLines: 10,
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return !snapshot.data!
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: controlsDecoration,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                    "We need permission to access the camera to scan and detect qr codes."),
                                DynamicTextButton(
                                    child: const Text("Give Permission"),
                                    onPressed: () => openAppSettings())
                              ],
                            ),
                          ), //TODO
                        )
                      : const SizedBox.shrink();
                }
                return const SizedBox.shrink();
              })),
        ),
        Positioned(
          bottom: mediaQuerySize.height * 0.2,
          child: QRControlButtons(
              controlsDecoration: controlsDecoration,
              qrController: qrController),
        ),
        if (_requesting)
          SizedBox(
            width: mediaQuerySize.width,
            height: mediaQuerySize.height,
            //color: Theme.of(context).primaryColor.withOpacity(0.9),
            child: const LoadingWidget(
              strokeWidth: 10,
            ),
          ),
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
            LoggerService.instance.debug("scanned new code");

            SpotInfoRequest spotInfoRequest =
                await QRScanService.spotInfoRequest(
                    context: context, barcode: barcode);
            LoggerService.instance.debug(spotInfoRequest);
            if (mounted) {
              bool continueScan = await launchConfirmationDialog(
                  context, spotInfoRequest.title ?? "");

              if (continueScan && spotInfoRequest.id != null) {
                _lastScan = now;

                List<Spot> spots = (await DatabaseSpotTable.getAllWithIds(
                    [spotInfoRequest.id!]));
                if (spots.isNotEmpty) {
                  Spot spot = spots.first;
                  if (!spot.visited) {
                    spot.visited = true;
                    await DatabaseSpotTable.update(spot);
                  }
                }
                if (mounted) {
                  TopicRequest topicRequestCompleted =
                      await QRScanService.topicRequest(
                          context: context, topicID: spotInfoRequest.id!);

                  LoggerService.instance
                      .debug("spotInfoRequest: $topicRequestCompleted");
                  if (mounted) {
                    Navigator.of(context).pushNamed(
                      QRScanResults.pageRoute,
                      arguments: topicRequestCompleted.contentList,
                    );
                  }
                }
              }
            }
          }
        } on LoginException {
          LoggerService.instance.error("LoginException");
          LoginService.logOut(context);
        } on InvalidQRException {
          LoggerService.instance.error("InvalidQRException");
        } catch (e) {
          LoggerService.instance.error(e);
        }
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
                    LoggerService.instance.debug("Pressed \"CANCEL\"");
                    continueScan = false;
                    Navigator.pop(context);
                  },
                ),
                CupertinoButton(
                  child: Text(
                      AppLocalizations.of(context)!.qrScanConfirmationAccept),
                  onPressed: () {
                    LoggerService.instance.debug("Pressed \"ACCEPT\"");
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
                    LoggerService.instance.debug("Pressed \"CANCEL\"");
                    continueScan = false;
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                      AppLocalizations.of(context)!.qrScanConfirmationAccept),
                  onPressed: () {
                    LoggerService.instance.debug("Pressed \"ACCEPT\"");
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

  Widget myQRView(BuildContext context) => MobileScanner(
        key: qrKey,
        allowDuplicates: false,
        controller: qrController,
        onDetect: onQRViewCreated,
      );
}
