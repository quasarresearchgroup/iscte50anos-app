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
import 'package:iscte_spots/services/qr_scan_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScanPageOpenDay extends StatefulWidget {
  const QRScanPageOpenDay(
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
  MobileScannerController qrController = MobileScannerController(
    facing: CameraFacing.back,
    autoStart: true,
    detectionTimeoutMs: 4000,
    detectionSpeed: DetectionSpeed.normal,
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
    qrController.dispose();
    super.dispose();
  }

  @override
  Future<void> reassemble() async {
    super.reassemble();
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
                                Text(AppLocalizations.of(context)!
                                    .qrScanPermissionText),
                                DynamicTextButton(
                                    onPressed: openAppSettings,
                                    child: Text(AppLocalizations.of(context)!
                                        .qrScanPermissionButton))
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
            qrController: qrController,
          ),
        ),
        if (_requesting)
          const Center(
            child: DynamicLoadingWidget(
              strokeWidth: 10,
            ),
          ),
      ],
    );
  }

  Future<void> checkLaunchBarcode(
      BuildContext context, BarcodeCapture barcode) async {
    if (_requesting) {
      LoggerService.instance.debug("try scanning again later!");
      return;
    }

    try {
      setState(() {
        _requesting = true;
      });
      LoggerService.instance.debug("scanned new code");

      SpotInfoRequest spotInfoRequest = await QRScanService.spotInfoRequest(
        context: context,
        barcode: barcode.barcodes.first,
      );
      LoggerService.instance.debug(spotInfoRequest);
      bool continueScan = false;
      if (mounted) {
        continueScan = await launchConfirmationDialog(
          context,
          spotInfoRequest,
        );
      }
      LoggerService.instance.debug("continueScan: $continueScan");

      if (continueScan && spotInfoRequest.id != null) {
        List<Spot> spots =
            (await DatabaseSpotTable.getAllWithIds([spotInfoRequest.id!]));
        if (spots.isNotEmpty) {
          Spot spot = spots.first;
          if (!spot.visited) {
            spot.visited = true;
            await DatabaseSpotTable.update(spot);
          }
        }
        if (mounted) {
          TopicRequest topicRequestCompleted = await QRScanService.topicRequest(
              context: context, topicID: spotInfoRequest.id!);

          LoggerService.instance
              .debug("spotInfoRequest: $topicRequestCompleted");
        }

        if (mounted) {
          Navigator.of(context).pushNamed(
            QRScanResults.pageRoute,
            arguments: spotInfoRequest,
          );
          DynamicAlertDialog.showDynamicDialog(
            icon: Icon(Icons.timeline, size: DynamicAlertDialog.iconSize),
            context: context,
            title: Text(
              AppLocalizations.of(context)!.qrScanResultExplanationDialogTitle(
                  spotInfoRequest.title ?? ""),
            ),
            content: Text(
              AppLocalizations.of(context)!
                  .qrScanResultExplanationDialogContent(
                      spotInfoRequest.title ?? ""),
            ),
          );
        }
      }
    } on LoginException {
      LoggerService.instance.error("LoginException");
      if (mounted) {
        LoginService.logOut(context);
      }
    } on QuizLevelNotAchieved {
      LoggerService.instance.error("QuizLevelNotAchieved");
      if (mounted) {
        await launchQuizLevelNotAchievedErrorDialog(context);
      }
    } on InvalidQRException {
      LoggerService.instance.error("InvalidQRException");
      if (mounted) {
        await launchQRErrorDialog(context);
      }
    } catch (e) {
      LoggerService.instance.error(e);
      if (mounted) {
        await launchQRErrorDialog(context);
      }
    }

    setState(() {
      _requesting = false;
    });
  }

  Future<bool> launchConfirmationDialog(
      context, SpotInfoRequest spotInfo) async {
    bool continueScan = false;

    await DynamicAlertDialog.showDynamicDialog(
        context: context,
        title: Text(
          spotInfo.visited
              ? AppLocalizations.of(context)!
                  .qrScanConfirmationVisited(spotInfo.title ?? "")
              : AppLocalizations.of(context)!
                  .qrScanConfirmation(spotInfo.title ?? ""),
        ),
        actions: [
          DynamicTextButton(
            child: Text(
              AppLocalizations.of(context)!.qrScanConfirmationCancel,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: IscteTheme.iscteColor),
            ),
            onPressed: () {
              LoggerService.instance.debug("Pressed \"CANCEL\"");
              continueScan = false;
              Navigator.pop(context);
            },
          ),
          DynamicTextButton(
            child: Text(
              AppLocalizations.of(context)!.qrScanConfirmationAccept,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: IscteTheme.iscteColor),
            ),
            onPressed: () {
              LoggerService.instance.debug("Pressed \"ACCEPT\"");
              continueScan = true;
              Navigator.pop(context);
            },
          )
        ]);

    return continueScan;
  }

  Future<void> launchQRErrorDialog(context) async {
    await DynamicAlertDialog.showDynamicDialog(
      context: context,
      title: Text(AppLocalizations.of(context)!.qrScanErrorAlertDialogTitle),
      content:
          Text(AppLocalizations.of(context)!.qrScanErrorAlertDialogContent),
      actions: [
        DynamicTextButton(
          child: Text(
            AppLocalizations.of(context)!.confirm,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: IscteTheme.iscteColor,
                ),
          ),
          onPressed: () {
            LoggerService.instance.debug("Pressed \"OK\"");
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Future<void> launchQuizLevelNotAchievedErrorDialog(context) async {
    await DynamicAlertDialog.showDynamicDialog(
      context: context,
      title: Text(AppLocalizations.of(context)!
          .qrScanQuizLevelNotAchievedErrorAlertDialogTitle),
      content: Text(AppLocalizations.of(context)!
          .qrScanQuizLevelNotAchievedErrorAlertDialogContent),
      actions: [
        DynamicTextButton(
          child: Text(
            AppLocalizations.of(context)!.confirm,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: IscteTheme.iscteColor,
                ),
          ),
          onPressed: () {
            LoggerService.instance.debug("Pressed \"OK\"");
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget myQRView(BuildContext context) => MobileScanner(
        key: qrKey,
        controller: qrController,
        onDetect: (BarcodeCapture newCode) async {
          await checkLaunchBarcode(context, newCode);
        },
      );
}
