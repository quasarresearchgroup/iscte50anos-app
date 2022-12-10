import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/helper/helper_methods.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class QRScanResults extends StatelessWidget {
  static const String pageRoute = "QRScanResults";
  QRScanResults({
    Key? key,
    required this.data,
  }) : super(key: key);

  final List<Content> data;
  @override
  Widget build(BuildContext context) {
    LoggerService.instance.debug(data);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.qrScanResultScreen),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(data[index].title ?? ""),
              subtitle: Text(data[index].link),
              trailing: data[index].contentIcon,
              onTap: () {
                if (data[index].link.isNotEmpty) {
                  HelperMethods.launchURL(data[index].link);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
