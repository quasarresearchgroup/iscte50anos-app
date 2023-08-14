import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:url_launcher/url_launcher.dart';

class HelperMethods {
  static launchURL(String url) async {
    LoggerService.instance.debug("url: $url");
    await launchUrl(Uri.parse(url));
  }

  static Duration deltaTime(DateTime lastDeltaTime) {
    DateTime currTime = DateTime.now();
    Duration timeDif = currTime.difference(lastDeltaTime);
    return timeDif;
  }
}
