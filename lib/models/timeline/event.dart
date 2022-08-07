import 'package:flutter/material.dart';
import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_topic_table.dart';
import 'package:iscte_spots/models/database/tables/database_topic_table.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/rouded_timeline_icon.dart';
import 'package:logger/logger.dart';

enum EventScope {
  iscte,
  portugal,
  world,
}

EventScope? eventScopefromString(String? input) {
  try {
    return EventScope.values.firstWhere((element) => element.name == input);
  } on StateError {
    return null;
  }
}

class Event {
  Event({
    required this.id,
    this.title,
    this.date,
    this.scope,
  });
  final int id;
  final String? title;
  final int? date;
  final EventScope? scope;

  static Logger logger = Logger();

  @override
  String toString() {
    return 'Event{id: $id, title: $title, date: $date, scope: $scope}';
  }

  String getDateString() {
    int actualDate = date ?? 0;
    DateTime dateDateTime = DateTime.fromMillisecondsSinceEpoch(actualDate);
    return dateDateTime.year.toString() +
        "-" +
        dateDateTime.month.toString() +
        "-" +
        dateDateTime.day.toString();
  }

  factory Event.fromMap(Map<String, dynamic> json) => Event(
        id: json[DatabaseEventTable.columnId],
        title: json[DatabaseEventTable.columnTitle],
        date: json[DatabaseEventTable.columnDate],
        scope: eventScopefromString(json[DatabaseEventTable.columnScope]),
      );

  Map<String, dynamic> toMap() {
    return {
      DatabaseEventTable.columnId: id,
      DatabaseEventTable.columnTitle: title,
      DatabaseEventTable.columnDate: date,
      DatabaseEventTable.columnScope: scope != null ? scope!.name : null,
    };
  }

  Widget get scopeIcon {
    final Image worldMapImage =
        Image.asset('Resources/Img/TimelineIcons/world-map-819-595.jpg');
    final Image iscte50AnosImage =
        Image.asset('Resources/Img/TimelineIcons/logo_50_anos-819-585.jpg');
    final Image bandeiraPortugalImage =
        Image.asset('Resources/Img/TimelineIcons/pt-819-585.png');
    /*final Image bandeiraPortugalImage =
        Image.asset('icons/flags/png/pt.png', package: 'country_icons');*/

    switch (scope) {
      case EventScope.portugal:
        return RoundedTimelineIcon(child: bandeiraPortugalImage);
      case EventScope.world:
        return RoundedTimelineIcon(child: worldMapImage);
      case EventScope.iscte:
        return RoundedTimelineIcon(child: iscte50AnosImage);
      default:
        return RoundedTimelineIcon(child: worldMapImage);
    }
  }

  int get year {
    int actualDate = date ?? 0;
    DateTime dateDateTime = DateTime.fromMillisecondsSinceEpoch(actualDate);
    return dateDateTime.year;
  }

  Future<List<Topic>> get getTopicsList async {
    List<int> allIdsWithEventId =
        await DatabaseEventTopicTable.getAllIdsWithEventId(this.id);
    List<Topic> topicsList =
        await DatabaseTopicTable.getAllWithIds(allIdsWithEventId);
    return topicsList;
  }

  Future<List<Content>> get getContentList async {
    List<int> allIdsWithEventId =
        await DatabaseEventContentTable.getAllIdsWithEventId(this.id);
    List<Content> contentsList =
        await DatabaseContentTable.getAllWithIds(allIdsWithEventId);
    return contentsList;
  }
}
