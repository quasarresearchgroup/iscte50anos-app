import 'package:logger/logger.dart';

class TimeLineData {
  TimeLineData(this.data, String date) {
    if (date.isNotEmpty) {
      logger.d("date:" + date);
      List<String> dateSplit = date.split("-");
      if (dateSplit.isNotEmpty) {
        logger.d("dateSplit:" + dateSplit.toString());
        day = int.parse(dateSplit[0]);
        month = int.parse(dateSplit[1]);
        year = int.parse(dateSplit[2]);
      } else {
        year = 0;
        month = 0;
        day = 0;
      }
    } else {
      year = 0;
      month = 0;
      day = 0;
    }
  }

  late final int year;
  late final int month;
  late final int day;
  String? location;
  late final String data;
  static Logger logger = Logger();

  String getDateString() {
    return year.toString() + "-" + month.toString() + "-" + day.toString();
  }
}
