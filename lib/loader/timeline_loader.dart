import 'package:flutter/services.dart';
import 'package:iscte_spots/models/content.dart';
import 'package:iscte_spots/models/database/tables/database_content_table.dart';
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
        int dateIntFromEpoch;
        try {
          dateIntFromEpoch = DateTime(int.parse(dateSplit[2]),
                  int.parse(dateSplit[1]), int.parse(dateSplit[0]))
              .millisecondsSinceEpoch;
        } on RangeError {
          dateIntFromEpoch = 0;
        }
        String title = lineSplit[1];
        ContentScope? scope = ContentScopefromString(lineSplit[2]);
        ContentType? contentType = ContentTypefromString(lineSplit[3]);
        Content content = Content(
            title: title,
            date: dateIntFromEpoch,
            scope: scope,
            type: contentType);
        //logger.d(content.toString());

        contentsList.add(content);
      });
      return contentsList;
    } catch (e) {
      logger.e(e);
      return contentsList;
    } finally {
      //logger.d(contentsList);
      logger.d("contentsList.length: " + contentsList.length.toString());
    }
  }

  static void insertContentEntriesFromCSV() async {
    final List<Content> contentsList = [];

    try {
      final String file = await rootBundle.loadString(timelineEntriesFile);

      logger.d(file.split("\n").length);
      file.split("\n").forEach((line) {
        List<String> lineSplit = line.split(";");

        List<String> dateSplit = lineSplit[0].split("-");
        int dateIntFromEpoch;
        try {
          dateIntFromEpoch = DateTime(int.parse(dateSplit[2]),
                  int.parse(dateSplit[1]), int.parse(dateSplit[0]))
              .millisecondsSinceEpoch;
        } on RangeError {
          dateIntFromEpoch = 0;
        }
        String title = lineSplit[1];
        ContentScope? scope = ContentScopefromString(lineSplit[2]);
        ContentType? contentType = ContentTypefromString(lineSplit[3]);
        Content content = Content(
            title: title,
            date: dateIntFromEpoch,
            scope: scope,
            type: contentType);
        //logger.d(content.toString());

        contentsList.add(content);
      });
      DatabaseContentsTable.addBatch(contentsList);
    } catch (e) {
      logger.e(e);
    } finally {
      //logger.d(contentsList);
      logger.d("contentsList.length: " + contentsList.length.toString());
    }
  }
}
