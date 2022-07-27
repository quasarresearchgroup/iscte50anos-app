import 'package:flutter/services.dart';
import 'package:iscte_spots/models/content.dart';
import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:logger/logger.dart';

import '../models/event.dart';

class TimelineContentService {
  static const String timelineEntriesFile = 'Resources/timeline.csv';
  static final Logger _logger = Logger();

  static Future<List<Content>> getTimeLineEntries() async {
    final List<Content> contentsList = [];

    try {
      final String file = await rootBundle.loadString(timelineEntriesFile);

      _logger.d(file.split("\n").length);
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
        EventScope? scope = eventScopefromString(lineSplit[2]);
        ContentType? contentType = contentTypefromString(lineSplit[3]);
        Content content = Content(
            description: title,
            date: dateIntFromEpoch,
            scope: scope,
            type: contentType);
        //logger.d(content.toString());

        contentsList.add(content);
      });
      return contentsList;
    } catch (e) {
      _logger.e(e);
      return contentsList;
    } finally {
      //logger.d(contentsList);
      _logger.d("contentsList.length: " + contentsList.length.toString());
    }
  }

  static Future<void> insertContentEntriesFromCSV() async {
    final List<Content> contentsList = [];

    try {
      final String file = await rootBundle.loadString(timelineEntriesFile);

      _logger.d(file.split("\n").length);
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
        EventScope? scope = eventScopefromString(lineSplit[2]);
        ContentType? contentType = contentTypefromString(lineSplit[3]);
        Content content = Content(
            description: title,
            date: dateIntFromEpoch,
            scope: scope,
            type: contentType);
        //_logger.d(content.toString());
        contentsList.add(content);
      });
    } catch (e) {
      _logger.e(e);
    } finally {
      _logger.d("contentsList.length: " + contentsList.length.toString());
      await DatabaseContentTable.addBatch(contentsList);
    }
  }
}
