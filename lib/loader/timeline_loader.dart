import 'package:iscteSpots/models/timeline_item.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class TimelineLoader {
  static const String timelineEntriesFile = 'Resources/timeline.csv';
  static Logger logger = Logger();

  static Future<List<TimeLineData>> getTimeLineEntries() async {
    final List<TimeLineData> timeLineDataList = [];

    try {
      final String file = await rootBundle.loadString(timelineEntriesFile);

      logger.d(file.split("\n").length);
      file.split("\n").forEach((e) {
        List<String> eSplit = e.split(";");
        String date = eSplit[0];
        String data = eSplit[1];
        String? scope;
        String? contentType;
        try {
          scope = eSplit[2];
        } on RangeError {
          scope = null;
        }
        try {
          contentType = eSplit[3];
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
