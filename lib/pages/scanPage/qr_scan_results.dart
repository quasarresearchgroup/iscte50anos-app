import 'package:flutter/widgets.dart';

class QRScanResults extends StatefulWidget {
  QRScanResults({Key? key, required this.controlsDecoration, this.qrScanResult})
      : super(key: key);
  Decoration controlsDecoration;
  var qrScanResult;
  @override
  State<QRScanResults> createState() => _QRScanResultsState();
}

class _QRScanResultsState extends State<QRScanResults> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: widget.controlsDecoration,
      child: Text(
        //'Result : ${barcode!.code}',
        'Result : ${widget.qrScanResult}',
        maxLines: 3,
      ),
    );
  }
}
