import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class HelperMethods {
  static launchURL(String url) async {
    Logger logger = Logger();

    //if (await   (url)) {
    logger.d("url: $url");
    await launchUrl(Uri.parse(url));
    //} else {
    //  throw 'Could not launch $url';
    //}
  }

  static Duration deltaTime(DateTime lastDeltaTime) {
    DateTime currTime = DateTime.now();
    Duration timeDif = currTime.difference(lastDeltaTime);
    return timeDif;
  }
}
