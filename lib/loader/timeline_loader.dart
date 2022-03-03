import 'package:flutter/services.dart';
import 'package:iscte_spots/models/timeline_item.dart';
import 'package:logger/logger.dart';

class ContentLoader {
  static const String timelineEntriesFile = 'Resources/timeline.csv';
  static Logger logger = Logger();

  static Future<List<Content>> getTimeLineEntries() async {
    final List<Content> contentsList = [];

    try {
      final String file = await rootBundle.loadString(timelineEntriesFile);

      logger.d(file.split("\n").length);
      file.split("\n").forEach((line) {
        List<String> lineSplit = line.split(";");
        List<String> dateSplit = lineSplit[0].split("-");
        int dateIntFromEpoch = DateTime(int.parse(dateSplit[2]),
                int.parse(dateSplit[1]), int.parse(dateSplit[0]))
            .millisecondsSinceEpoch;
        String title = lineSplit[1];
        ContentScope? scope = ContentScopefromString(lineSplit[2]);
        ContentType? contentType = ContentTypefromString(lineSplit[3]);

        contentsList.add(Content(
            title: title,
            date: dateIntFromEpoch,
            scope: scope,
            type: contentType));
      });

      logger.d(contentsList);

      return contentsList;
    } catch (e) {
      // If encountering an error, return 0
      return contentsList;
    }
  }
}
