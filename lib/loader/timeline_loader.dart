import 'package:IscteSpots/models/timeline_item.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class TimelineLoader {
  static const String TIMELINEENTRIESFILE = 'Resources/timeline.csv';
  static Logger logger = Logger();

  static Future<List<TimeLineData>> getTimeLineEntries() async {
    final List<TimeLineData> timeLineDataList = [];

    try {
      final String file = await rootBundle.loadString(TIMELINEENTRIESFILE);

      logger.d(file.split("\n").length);
      file.split("\n").forEach((e) {
        List<String> e_split = e.split(";");
        String date = e_split[0];
        String data = e_split[1];
        String? scope;
        String? contentType;
        try {
          scope = e_split[2];
        } on RangeError {
          scope = null;
        }
        try {
          contentType = e_split[3];
        } on RangeError {
          contentType = null;
        }

        timeLineDataList.add(TimeLineData(
            data: data, date: date, scope: scope, contentType: contentType));
      });

      logger.d(timeLineDataList);

      return timeLineDataList;
    } catch (e) {
      // If encountering an error, return 0
      return timeLineDataList;
    }
  }
}
