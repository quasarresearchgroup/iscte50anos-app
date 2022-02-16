import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class HelperMethods {
  static launchURL(String url) async {
    Logger logger = Logger();

    //if (await   (url)) {
    logger.d("-------------------url---------------------");
    logger.d(url);
    await launch(url);
    //} else {
    //  throw 'Could not launch $url';
    //}
  }

  static double deltaTime(int lastDeltaTime) {
    int currTime = DateTime.now().millisecondsSinceEpoch;
    double timeDif = (currTime - lastDeltaTime) / 10;
    lastDeltaTime = currTime;
    return timeDif;
  }
}
