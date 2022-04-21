import 'package:flutter/widgets.dart';

class QRScanResults extends StatelessWidget {
  const QRScanResults(
      {Key? key, required this.controlsDecoration, this.qrScanResult})
      : super(key: key);
  final Decoration controlsDecoration;
  final String? qrScanResult;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: controlsDecoration,
      child: Text(
        //'Result : ${barcode!.code}',
        'Result : $qrScanResult',
        maxLines: 3,
      ),
    );
  }
}
