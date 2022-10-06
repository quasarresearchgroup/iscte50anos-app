import 'package:flutter/services.dart';
import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_topic_table.dart';
import 'package:iscte_spots/models/database/tables/database_topic_table.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class TimelineCSVService {
  static const String EventsCsvFile =
      'Resources/CSVFiles/cronologia_cinquentenario_events.tsv';
  static const String ContentsCsvFile =
      'Resources/CSVFiles/cronologia_cinquentenario_contents.tsv';
  

  static Future<void> insertContentEntriesFromCSV() async {
    await _loadEventsCsv();
    await _loadContentsCsv();
    // static const String timelineEntriesFile = 'Resources/timeline.csv';
    /* try {
      final String file = await rootBundle.loadString(timelineEntriesFile);

      LoggerService.instance.debug(file.split("\n").length);
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
        //LoggerService.instance.debug(content.toString());
        eventsList.add(content);
      });
    } catch (e) {
      LoggerService.instance.error(e);
    } finally {
      LoggerService.instance.debug("eventsList.length: " + eventsList.length.toString());
      await DatabaseContentTable.addBatch(eventsList);
    }*/
  }

  static Future<void> _loadEventsCsv() async {
    final List<Event> eventsList = [];
    final List<EventTopicDBConnection> eventTopicDBConnectionList = [];
    try {
      final String file = await rootBundle.loadString(EventsCsvFile);
      List<String> splitLines = file.split("\n");
      LoggerService.instance.debug("Events CSV length: ${splitLines.length}");
      for (int eventId = 1; eventId < splitLines.length; eventId++) {
        String line = splitLines[eventId];
        List<String> lineSplit = line.split("\t");

        List<String> dateSplit = lineSplit[0].split("-");
        int dateIntFromEpoch;
        try {
          dateIntFromEpoch = DateTime(int.parse(dateSplit[0]),
                  int.parse(dateSplit[1]), int.parse(dateSplit[2]))
              .millisecondsSinceEpoch;
        } on RangeError {
          dateIntFromEpoch = 0;
        }
        String title = lineSplit[2];
        EventScope? eventScope = eventScopefromString(lineSplit[3]);
        var event = Event(
          id: eventId,
          date: dateIntFromEpoch,
          title: title,
          scope: eventScope,
        );
        eventsList.add(event);
        LoggerService.instance.debug(event.toMap());
        String topicName;
        for (int j = 4; j < lineSplit.length; j++) {
          topicName = lineSplit[j].replaceAll("\r", "");
          if (topicName.isNotEmpty) {
            int topicId = await DatabaseTopicTable.add(Topic(title: topicName));
            if (topicId == 0) {
              List<Topic> list = await DatabaseTopicTable.where(
                where: "${DatabaseTopicTable.columnTitle} = ?",
                whereArgs: [topicName],
                orderBy: DatabaseTopicTable.columnTitle,
              );
              if (list.first.id != null) {
                topicId = list.first.id!;
              } else {
                throw ("No Topic found with title: $topicName");
              }
            }
            eventTopicDBConnectionList.add(
                EventTopicDBConnection(topicId: topicId, eventId: eventId));
          }
        }
      }
    } catch (e) {
      LoggerService.instance.error(e);
    } finally {
      LoggerService.instance.debug("eventsList.length: ${eventsList.length}");
      await DatabaseEventTable.addBatch(eventsList);
      await DatabaseEventTopicTable.addBatch(eventTopicDBConnectionList);
    }
  }

  static Future<void> _loadContentsCsv() async {
    final List<Content> contents = [];
    final List<EventContentDBConnection> eventContentDBConnectionList = [];

    try {
      final String file = await rootBundle.loadString(ContentsCsvFile);
      List<String> splitLines = file.split("\n");
      LoggerService.instance.debug("Content CSV length: ${splitLines.length}");
      for (int contentId = 1; contentId < splitLines.length; contentId++) {
        String line = splitLines[contentId];
        List<String> lineSplit = line.split("\t");

        String description = lineSplit[3];
        String type = lineSplit[4];
        String link = lineSplit[5];

        if (type.isNotEmpty && link.isNotEmpty) {
          contents.add(
            Content(
              id: contentId,
              description: description,
              type: contentTypefromString(type),
              link: link,
            ),
          );
          String eventTitle = lineSplit[1];
          List<Event> list = await DatabaseEventTable.where(
            where: "${DatabaseEventTable.columnTitle} = ?",
            whereArgs: [eventTitle],
            orderBy: DatabaseEventTable.columnId,
          );
          if (list.isEmpty) {
            throw "No event found for Title: $eventTitle";
          } else {
            var eventId = list.first.id;
            eventContentDBConnectionList.add(EventContentDBConnection(
                contentId: contentId, eventId: eventId));
          }
        }
      }
    } catch (e) {
      LoggerService.instance.error(e);
    } finally {
      LoggerService.instance.debug("contents.length: ${contents.length}");
      await DatabaseContentTable.addBatch(contents);
      await DatabaseEventContentTable.addBatch(eventContentDBConnectionList);
    }
  }
}
